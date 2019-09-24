/*
Test Case: delete & delete 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are not overlapped (with multiple indexes)

Test Scenario:
C1 delete, C2 delete, the affected rows are not overlapped
C1 where clause is on index (i.e. index scan), C2 where clause is not on index (heap scan)
C1 where clause uses multiple indexes
C1 commit, C2 commit
Metrics: data size = small, index = multiple indexes(PK + simple index), where clause = simple, DELETE state = single table deletion

Test Point:
1) C1 and C2 will not be waiting 
2) All the data affected from C1 and C2 should be deleted

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_col on t1(col) with online parallel 3;
C1: INSERT INTO t1 VALUES(1,'abc','A');INSERT INTO t1 VALUES(2,'def','B');INSERT INTO t1 VALUES(3,'ghi','C');INSERT INTO t1 VALUES(4,'jkl','D');INSERT INTO t1 VALUES(5,'mno','E');INSERT INTO t1 VALUES(6,'pqr','F');INSERT INTO t1 VALUES(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id IN (2,3) or col = 'mno';
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE tag = 'F';
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 2,3,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;
/* expect: C2 select - id = 6 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
/* expect: C2 select - id = 2,3,5,6 are deleted */
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 2,3,5,6 are deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C3: commit;
C1: quit;
C2: quit;
C3: quit;
