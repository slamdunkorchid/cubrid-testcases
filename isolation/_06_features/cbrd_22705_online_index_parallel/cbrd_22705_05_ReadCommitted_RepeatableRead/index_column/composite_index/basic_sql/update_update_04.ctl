/*
Test Case: update & update
Priority: 1
Reference case:
Author: Mandy

Test Point:
When two transaction update the same record, the second updater can proceed only if the first transaction rollbacks. 
If the first transaction commits, the second transaction must be aborted.
In this case, where conditions are not overlapped. But the first update result will affect the the second update's where condition.

NUM_CLIENTS = 3
C1: update on table t1; commit
C2: update on table t1; not blocked
C3: select on table t1, and C3 is used to check the update result
*/


MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t1;
C1: create table t1(id int, col varchar(10));
C1: insert into t1 values(1,'abc');insert into t1 values(2,'def');insert into t1 values(3,'abc');insert into t1 values(4,'ijk');insert into t1 values(1,'gh');insert into t1 values(5,'abc');
C1: create index idx on t1(id, col) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: update t1 set id=3, col='abc' where id<3 and col='def';
C1: select * from t1 order by 1,2;
MC: wait until C1 ready;
/* C2 only update 1 row*/
C2: update t1 set col='bb' where id=3 and col='abc';
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
/* we can only see the update result of C2, can see C1' update result */
C2: select * from t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* we can only see C1' update result */
C3: select * from t1 order by 1,2;

C3: commit;
C1: quit;
C2: quit;
C3: quit;

