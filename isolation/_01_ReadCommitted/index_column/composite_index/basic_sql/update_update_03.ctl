/*
Test Case: update & update
Priority: 1
Reference case:
Author: Mandy

Test Point:
C1 update, C2 update, the affected rows are not overlapped.
In this case, the primary key is created on two columns

NUM_CLIENTS = 3
C1: update on table t1  
C2: update on table t1  
C3: select on table t1; C3 is used to check the update result
*/


MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t1;
C1: create table t1(id int, col varchar(10));
C1: insert into t1 values(1,'abc'),(2,'def'),(3,'gh'),(4,'abc'),(5,'abc');
C1: create index idx on t1(id, col);
C1: commit work;
MC: wait until C1 ready;

/* C1 update, C2 update*/
C1: update t1 set col='bb' where id>1 and col='abc';
C2: update t1 set col='aa' where id<3;
MC: wait until C1 ready;
MC: wait until C2 ready;
C1: select * from t1 order by 1,2;
MC: wait until C1 ready;
C2: select * from t1 order by 1,2;
MC: wait until C2 ready;
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: commit;
MC: wait until C1 ready;
C1: select * from t1 order by 1,2;
MC: wait until C1 ready;
C2: select * from t1 order by 1,2;
MC: wait until C2 ready;
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C2: commit;
MC: wait until C2 ready;
C1: select * from t1 order by 1,2;
MC: wait until C1 ready;
C2: select * from t1 order by 1,2;
MC: wait until C2 ready;
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;
