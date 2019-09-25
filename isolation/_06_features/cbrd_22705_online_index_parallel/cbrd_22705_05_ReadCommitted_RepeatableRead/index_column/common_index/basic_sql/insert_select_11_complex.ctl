/*
Test Case: insert & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/insert_select_13.ctl
Author: Rong Xu
Test Point:
insert into ... select ... from ...

NUM_CLIENTS = 2
C1: insert into t values(2,'abc');
C2: insert into t2 select * from t order by 1; -- 2 will not insert into t2
C1: commit;
C3: insert into t2 select * from t order by 1; -- 2 will insert into t2
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
C1: create index idx on t(id desc) with online parallel 3;
C1: insert into t values(1,'abc');
C1: insert into t values(3,'abc');
C1: insert into t values(7,'abc');
C1: drop table if exists t1;
C1: create table t1(id int,col varchar(10));
C1: create index idx2 on t1(id) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(2,'abc');
MC: wait until C1 ready;
C2: insert into t1 select * from t where id>0;
MC: wait until C2 ready;
C1: commit work;
MC: wait until C1 ready;
C3: insert into t1 select * from t where id>0;
MC: wait until C3 ready;
C3: select * from t where id<10 order by 1,2;
C3: commit;
MC: wait until C3 ready;
C2: commit;
C2: select * from t where id<10 order by 1,2;
C2: commit;

C1: quit;
C2: quit;
C3: quit;

