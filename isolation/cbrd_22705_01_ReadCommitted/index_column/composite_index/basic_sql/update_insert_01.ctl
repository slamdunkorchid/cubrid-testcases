/*
Test Case: update & insert
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
changes committed after the query started are never seen
  A begin update
                   B begin insert which satisfy A
                   B commit
  A update end
  A commit

NUM_CLIENTS = 2
prepare (5,6,7)
C2: update t set id=id+1,col='c' where id>0 and sleep(1)=0;
C1: insert into t values(1,'c');
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10) unique);
C1: create index idx on t(id,col) with online parallel 2;
C1: insert into t values(5,'a');
C1: insert into t values(6,'b');
C1: insert into t values(7,'c');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C2: update t set id=id+1,col='c' where id>0 and sleep(1)=0;
C1: insert into t values(1,'c');
MC: wait until C1 ready;
MC: wait until C2 ready;
C1: commit;          
MC: wait until C1 ready;
C2: commit;          
/* result should be (1,c)(6,ac)(7,bc)(8,cc) */
C2: select * from t order by 1,2; 
C2: commit;

C2: quit;
C1: quit;

