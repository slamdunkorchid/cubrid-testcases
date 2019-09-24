/*
Test Case: delete & insert
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/delete_insert_16.ctl
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
-    Delete: X_LOCK acquired on current instance 
one user delete, another insert other rows

NUM_CLIENTS = 2
prepare (1,2,7)
C1: delete from t where id<=3;
C2: insert into t values(4,'abc');
check no block
C1: rollback 
check select result
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int ,col varchar(10));
C1: create index idx on t(id) with online parallel 3;
C1: insert into t values(1,'abc');
C1: insert into t values(2,'abc');
C1: insert into t values(7,'abc');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: delete from t where id<=3;
MC: wait until C1 ready;
C2: insert into t values(4,'abc');
MC: wait until C2 ready;
C1: rollback work;
MC: wait until C1 ready;
C2: commit;
C2: select * from t order by 1;
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;

