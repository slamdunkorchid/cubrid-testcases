/*
Test Case: insert & update
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/insert_update_01.ctl/insert_update_09.ctl
Author: Rong Xu

Test Point:
Reading queries can only have a look at data committed before the transaction began
The only visible uncommitted data are the effects of current transaction updates
C1:insert;C2:begin;C1:commit;C2:update C1 committed value

NUM_CLIENTS = 2
C1: insert(7);
C2: select * from t order by 1;
C1: insert(8);
C2: update t set id=9 where id=7;  -- ok
C2: update t set id=19 where id=8; -- nok, invisable
C1: rollback work;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10));
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(7,'abc');
C1: commit;
MC: wait until C1 ready;
C2: select * from t order by 1;
MC: wait until C2 ready;
C1: insert into t values(8,'abc');
MC: wait until C1 ready;
C2: update t set id=9 where id=7;
C2: update t set id=19 where id=8;
MC: sleep 5;
C2: select * from t order by 1;
MC: wait until C2 ready;
C1: rollback work;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
C2: select * from t order by 1;
MC: wait until C2 ready;

C2: commit;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: quit;
C1: quit;

