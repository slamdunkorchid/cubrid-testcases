/*
Test Case: insert & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/insert_select_10.ctl
Author: Rong Xu

Test Point:
Reading queries can only have a look at data committed before the queries began
The only visible uncommitted data are the effects of current transaction updates

NUM_CLIENTS = 2
C1:insert begin;C2 begin;C1 rollback;C2:select; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10));
C1: create index idx on t(LENGTH(col)) with online parallel 2;
C1: insert into t values(1,'abc');
C1: insert into t values(3,'abc');
C1: insert into t values(7,'abc');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(2,'abc');
MC: wait until C1 ready;

C2: insert into t values(4,'a4');
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;

/* can see (2,abc)*/
C2: select * from t where LENGTH(col)>1 order by 1;
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;

