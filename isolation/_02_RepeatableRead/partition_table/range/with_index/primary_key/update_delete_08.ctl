/*
Test Case: update & delete
Priority: 1
Reference case:
Author: Rong Xu

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance)

Test Point:
C1 update 1 to 11, C2 delete 1

NUM_CLIENTS = 2
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS t;
C1: create table t(id int primary key,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: INSERT INTO t VALUES(1,'abc'),(12,'abc');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C2: select * from t order by 1,2;
MC: wait until C2 ready;
C1: UPDATE t SET id=11 where id=1;
C1: commit;
MC: wait until C1 ready;

/* expect delete 0 row, there is error message */
C2: DELETE FROM t WHERE id=1;
/* expect (1,'abc'),(12,'abc') */
C2: select * from t order by 1,2;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;

/* expect (11,'abc'),(12,'abc') */
C1: SELECT * FROM t order by 1,2;
C1: commit;
MC: wait until C1 ready;

C1: quit;
C2: quit;
