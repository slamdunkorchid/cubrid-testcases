/* 
Test Case: select & select
Priority: 1
Reference case:
Author: Mandy

Test Point:
C1, C2, C3 select on multi rows without onverlap. 

NUM_CLIENTS = 3
C1: select on table t1
C2: select on table t1
C3: select on table t1
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
C1: create table t1 (id int, age int, name varchar(10));
C1: insert into t1 values (1,5,'abc'), (2,3,'def'),(3,10,'gh'),(4,12,'ijk'),(5,15,'ab'),(6,7,'gg');
C1: create index idx1 on t1(id) with online parallel 2;
C1: create index idx2 on t1(age) with online parallel 2;
C1: create index idx3 on t1(name) with online parallel 2;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: select * from t1 where id<3 and age<10 and name='abc' order by 1,2,3;
MC: wait until C1 ready;
C2: select * from t1 where id<5 and age<10 and name='def'  order by 1,2,3;
MC: wait until C2 ready;
C3: select * from t1 where id<10 and age<16 and name like 'g%' order by 1,2,3;
MC: wait until C3 ready;
C1: commit;
C2: commit;
C3: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
