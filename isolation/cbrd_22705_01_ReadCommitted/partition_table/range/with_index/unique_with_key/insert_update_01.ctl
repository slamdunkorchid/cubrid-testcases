/*
Test Case: insert & update
Priority: 1
Reference case:
Author: Rong Xu
Test Point:
-    Insert: X_LOCK on first key OID for unique indexes. 
-    Update: X_LOCK acquired on current instance 
one user insert to p1(11,'a'), another update value p1(1,'a') to p2(11,a)

NUM_CLIENTS = 2
C1: insert(11,a);
C2: update t set id=11 where id=1; --expected blocked
C1: commit
C2: commit
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: create unique index idx on t(id,col) with online parallel 2;
C1: insert into t values(1,'a');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(11,'a');
MC: wait until C1 ready;
C2: update t set id=11 where id=1;
MC: wait until C2 blocked;
C1: commit work;
C2: commit;
C2: select * from t order by 1;
C2: commit;

C2: quit;
C1: quit;

