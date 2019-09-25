/*
Test Case: insert & delete
Priority: 1
Reference case: 1
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
-    Delete: X_LOCK acquired on current instance
two unique index
C1 delete by id, then C2 insert a value conflict with col
rollback re-evaluate

NUM_CLIENTS = 2
prepare (4,abc)
C1: delete from t where id=4;
C2: insert into t values(5,'abc'); -- expected blocked 
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int ,col varchar(10) unique);
C1: create unique index idx on t(id) with online parallel 2;
C1: insert into t values(4,'abc');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: delete from t where id=4;
MC: wait until C1 ready;
C2: insert into t values(5,'abc');
MC: wait until C2 blocked;
C1: rollback;
MC: wait until C2 ready;
/* expected (4,abc) */
C2: select * from t order by 1;
C2: commit;          

/* expected (4,abc) */
C2: select * from t order by 1; 
C2: commit;

C1: quit;
C2: quit;

