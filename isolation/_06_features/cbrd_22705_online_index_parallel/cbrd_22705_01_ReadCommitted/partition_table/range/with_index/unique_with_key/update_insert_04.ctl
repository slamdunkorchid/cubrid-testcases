/*
Test Case: insert & update
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes. 
-    Update: X_LOCK acquired on current instance 
one user update 1 to 11, then update 11 to 2, another insert 11

NUM_CLIENTS = 2
C1: update t set id=11 where id=1;
C1: update t set id=2 where id=11; --expected ok
C2: insert into t values(11,'abc'); --expected blocked
C1: commit;
C2: commit; -- expected ok, insert 1 row
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
C1: insert into t values(1,'abc');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: update t set id=11 where id=1;
C1: update t set id=12 where id=11;
MC: wait until C1 ready;
C2: insert into t values(11,'abc');
MC: wait until C2 blocked;

C1: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;

C2: select * from t order by 1,2;
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;

