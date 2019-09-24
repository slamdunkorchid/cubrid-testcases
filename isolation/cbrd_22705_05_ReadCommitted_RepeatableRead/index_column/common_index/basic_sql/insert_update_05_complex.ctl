/*
Test Case: insert & update
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes. 
-    Update: X_LOCK acquired on current instance 
one user insert, another update the same row

NUM_CLIENTS = 2
C1: insert into t values(1,'abc');
C2: update t set id=2 where id=1; --expect 0 row affected
C3: update t set id=3 where id=2; --expect 0 row affected
C1: rollback
C2: commit
*/

MC: setup NUM_CLIENTS = 3;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10));
C1: create index idx on t(id) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(1,'abc');
MC: wait until C1 ready;

/* expect 0 row affected */
C2: update t set id=2 where id=1;
MC: wait until C2 ready;

C3: update t set id=3 where id=2;
MC: wait until C3 ready;

C1: rollback work;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
C3: commit;
MC: wait until C3 ready;

C2: select * from t order by 1;
C2: commit;

C1: quit;
C2: quit;
C3: quit;

