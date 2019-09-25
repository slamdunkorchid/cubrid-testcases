/*
Test Case: insert & insert
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/insert_insert_03.ctl
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
No Lock for non unique index
insert a lot of the same value

NUM_CLIENTS = 4
C1: insert 1000 rows, values(1);
C2: insert 1000 rows, values(1);
C3: insert 1000 rows, values(2);
C4: insert 1000 rows, values(3);
*/

MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id bigint ,col varchar(10));
C1: create index idx on t(id) where id%2=0 with online parallel 2;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: set @newincr=0;
C1: insert into t select (@newincr:=@newincr+1),'abc' from db_class a,db_class b,db_class c,db_class d limit 1000;
MC: wait until C1 ready;

C2: set @newincr=0;
C2: insert into t select (@newincr:=@newincr+1),'abc' from db_class a,db_class b,db_class c,db_class d limit 1000;
MC: wait until C2 ready;

C3: set @newincr=0;
C3: insert into t select (@newincr:=@newincr+1),'abc' from db_class a,db_class b,db_class c,db_class d limit 1000;
MC: wait until C3 ready;

C4: set @newincr=0;
C4: insert into t select (@newincr:=@newincr+1),'abc' from db_class a,db_class b,db_class c,db_class d limit 1000;
MC: wait until C4 ready;

C1: commit;
MC: wait until C1 ready;

C2: commit;
MC: wait until C2 ready;

C3: commit;
MC: wait until C3 ready;

C4: commit;
MC: wait until C4 ready;

/* expected (1,2000)(2,1000)(3,1000) */
C2: select sum(id) from t where id%2=0 using index idx(+);
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;
C3: quit;
C4: quit;
