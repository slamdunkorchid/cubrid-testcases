/*
Test Case: insert & insert
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
insert many rows and rollback

NUM_CLIENTS = 2
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: drop table if exists t1;
C1: create table t(id int,col int) partition by range(id)(partition p1 values less than (10000),partition p2 values less than MAXVALUE);
C1: create index idx on t(id,col) with online parallel 3;
C1: create table t1(id int);
C1: insert into t1 values(1);insert into t1 values(2);insert into t1 values(3);insert into t1 values(4);insert into t1 values(5);insert into t1 values(6);insert into t1 values(7);insert into t1 values(8);insert into t1 values(9);insert into t1 values(10);
C1: commit work;
MC: wait until C1 ready;

/* test case */
C2: select * from t order by 1,2;
MC: wait until C2 ready;
C1: insert into t select rownum,rownum*2 from t1 a,t1 b,t1 c,t1 d,t1 e,t1 f where rownum<=10000;
C1: commit;
MC: wait until C1 ready;

/* expect 0 */
C2: select count(*) from t order by 1;
C2: insert into t select rownum,rownum*2-1 from t1 a,t1 b,t1 c,t1 d,t1 e,t1 f where rownum<=10000;
MC: wait until C2 ready;
/* expect 10000 */
C2: select count(*) from t order by 1;
C2: rollback;
MC: wait until C2 ready; 

/* expect 10000 */
C1: select count(*) from t order by 1;
C1: commit;
MC: wait until C1 ready;

C2: quit;
C1: quit;

