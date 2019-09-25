/*
Test Case: delete & update 
Priority: 2
Reference case:
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are not overlapped (with filtered index)
C1 try to delete a unique index that C2 try to update to

Test Scenario:
C1 delete, C2 update, the affected rows are not overlapped (based on where clause)
C1 try to delete a unique index that C2 try to update to 
C1 where clause doesn't use filtered index (heap scan), C2 where clause uses filtered index (i.e. index scan - partially)
A portion of C2 instances are using index scan
C1 rollback, C2 commit
Metrics: data size = small, index = single filtered index, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances shouldn't be deleted since C1 rollback
   C2 instances shouldn't be updated since the duplicate key constraint error

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: update table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT UNIQUE, col VARCHAR(10), tag VARCHAR(2));
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: CREATE INDEX idx_col on t1(col) WHERE col = 'jkl' with online parallel 2;
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE col IN ('pqr','abc');
MC: wait until C1 ready;
C2: UPDATE t1 SET id = 1 WHERE col = 'jkl' USING INDEX idx_col;
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 1,6,7 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: rollback;
/* expect: a duplicate key constraint error message, C2 select - no instance is updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: no instance is deleted&updated */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;