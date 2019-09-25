/*
Test Case: delete & update 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are overlapped (with composite index)

Test Scenario:
C1 delete, C2 update, the affected rows are overlapped (based on where clause)
C1's deleting the instances equal to the C2's updating instances
C1,C2's where clauses are on index (index scan)
C1 commit, C2 commit
Metrics: data size = small, index = composite index, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances will be deleted, but C2 instances won't be updated since the search condition is no more satisfied
   (i.e. the version will be deleted, C2's search condition is not satisfied anymore)

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
C1: CREATE TABLE t1(id INT, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_id_col on t1(id,col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id >= 3 and id <= 5 and col != 'jkl';
MC: wait until C1 ready;
C2: UPDATE t1 SET col = 'ghi' WHERE id = 3 or id = 5;
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 3,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 0 row updated message should be generated once C2 ready, C2 select - no instance is updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: id = 3,5 are deleted */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;