/*
Test Case: insert & update
Priority: 1
Reference case:
Author: Rong Xu
Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
-    Update: X_LOCK acquired on current instance
C1 insert
    C2 update one value, modify one satisfied condition to not satisfied
    C2 commit
C1 commit

NUM_CLIENTS = 2
prepare(7,a)(8,bc)
C1: insert into t values(8,'abc');
C2: update t set col='abc' where id>0;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10));
C1: create index idx on t(id,col) with online parallel 2;
C1: insert into t values(6,'a');
C1: insert into t values(7,'b');
C1: insert into t values(8,'c');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t select * from t where id>0 and sleep(1)=0;
MC: wait until C1 ready;
C2: update t set id=-1 where id=8;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;
C1: commit work;
MC: wait until C1 ready;

/* expected (6,a)(7,b)(-1,c)(6,a)(7,b)(8,c) */
C2: select * from t order by 1;
C2: commit;

C2: quit;
C1: quit;
