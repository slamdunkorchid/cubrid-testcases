/*
Test Case: select & update 
Priority: 1
Reference case:
Author: Mandy

Test Point:
Select:
Row: no row locks acquired
Table: IS_LOCK. 
C1 select, C2 update, the affected rows are overlapped.
C1 execute before C2, check C1 does not block C2

NUM_CLIENTS = 2 
C1: select on table t1  
C2: update on the whole table, blocked
C3: verify the final result
*/


MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t1;
C1: create table t1(id int, col varchar(10));
C1: insert into t1 values(1,'abc'),(2,'def'),(3,'abc'),(4,'def'),(5,'ijk');
C1: create index idx on t1(id) with online parallel 2;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: select * from t1 where id >1 order by 1,2;
MC: wait until C1 ready;
C2: update t1 set id=id+1;
MC: wait until C2 ready;
C1: commit;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;

C3: select * from t1 order by 1,2;
C3: commit;

C1: quit;
C2: quit;
