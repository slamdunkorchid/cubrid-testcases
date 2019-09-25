/*
Test Case: select & update 
Priority: 1
Reference case:
Author: Mandy

Test Point:
Select:
Row: no row locks acquired
Table: IS_LOCK. 
C1 select, C2 update, the affected rows are not overlapped.
C1 execute before C2

NUM_CLIENTS = 2 
C1: select on table t1  
C2: update on table t1  
*/


MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t1;
C1: create table t1(id int, col varchar(10));
C1: insert into t1 values(1,'abc'),(2,'def'),(3,'abc'),(4,'def'),(1,'lmn'),(1,'lmn');
C1: create index idx on t1(id,col) with online parallel 2;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: select * from t1 where id=1 and col='abc' order by 1,2;
MC: wait until C1 ready;
C2: update t1 set id=7 where id=1 and col='lmn';
MC: wait until C2 ready;
C1: commit;
C2: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;

C1: quit;
C2: quit;
