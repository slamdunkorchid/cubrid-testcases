/*
Test Case: update & delete 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance) if the instances of the transactions are not overlapped (with multiple indexes)

Test Scenario:
C1 update, C2 delete, the affected rows are not overlapped
C1's updates do not affect the C2's deletes
C1 where clause is not on index (i.e. index scan), C2 where clause is on index (heap index)
C2 where clause uses multiple indexes
C1 commit, C2 commit
Metrics: data size = small, index = multiple indexes(2 Unique indexes), where clause = simple, schema = single table

Test Point:
1) C1 and C2 will not be waiting 
2) C1 instances will be updated, C2 instances should be deleted

NUM_CLIENTS = 3
C1: update table t1;  
C2: delete from table t1;  
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
C1: CREATE TABLE t1(id INT UNIQUE, col VARCHAR(10) UNIQUE, tag VARCHAR(2));
C1: CREATE UNIQUE INDEX idx_id on t1(id) with online parallel 2;
C1: CREATE UNIQUE INDEX idx_col on t1(col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'stu','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET tag = 'X' WHERE tag BETWEEN 'D' AND 'E';
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE id = 1 or col IN ('def','ghi');
/* expect: no transactions need to wait */
MC: wait until C2 ready;
/* expect: C1 select - id = 4,5 are updated */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;
/* expect: C2 select - id = 1,2,3 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 4,5 are updated & id = 1,2,3 are deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
