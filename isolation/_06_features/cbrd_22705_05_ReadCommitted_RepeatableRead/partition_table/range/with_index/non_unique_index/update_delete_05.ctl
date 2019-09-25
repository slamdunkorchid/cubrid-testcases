/*
Test Case: update & delete
Priority: 1
Reference case:
Author: Rong Xu

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance) 

Test Point:
C1 update p1, C2 delete p2

NUM_CLIENTS = 2
C1: UPDATE t SET col = 'abcd' where id<10;
C2: DELETE FROM t where id>10; -- expected ready
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS t;
C1: create table t(id int,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: create index idx on t(id) with online parallel 3;
C1: INSERT INTO t VALUES(1,'abc');
C1: INSERT INTO t VALUES(20,'def');
C1: INSERT INTO t VALUES(3,'ghi');
C1: INSERT INTO t VALUES(40,'jkl');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C2: DELETE FROM t where id>10;
MC: wait until C2 ready;
C1: UPDATE t SET id=id+10 where id<10;
MC: wait until C1 ready;

/* expect (1,'abc'),(3,'ghi') */
C2: SELECT * FROM t order by 1,2;
C2: commit;
MC: wait until C2 ready;

/* expect (11,'abc'),(13,'ghi')(20,'def')(40,'jkl') */
C1: SELECT * FROM t order by 1,2;
C1: commit;
MC: wait until C1 ready;

/* expect (11,'abc'),(13,'ghi') */
C2: SELECT * FROM t order by 1,2;
C2: commit;
MC: wait until C2 ready;

C1: quit;
C2: quit;
