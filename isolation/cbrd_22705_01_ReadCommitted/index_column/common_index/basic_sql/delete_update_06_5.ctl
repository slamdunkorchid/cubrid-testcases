/*
Test Case: delete & update 
Priority: 1
Reference case: 
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are overlapped (with single index)

Test Scenario:
C1 delete, C2 update, the affected rows are overlapped (based on where clause)
C1's deleting the instances contain the C2's updating instances
C2 try to update an unique index column to a duplicate key which is C1 try to deleting 
C1,C2's where clauses are on index (index scan) 
C1 rollback, C2 commit
Metrics: data size = small, index = single index(Unique), where clause = no, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) All the C1 instances won't be deleted since C1 rollback, the C2 instance won't be updated (duplicate key is not deleted) 
   (i.e.the version will be updated, the C2 search condition is satisfied but with duplicate key error) 

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
C1: CREATE UNIQUE INDEX idx_id on t1(id) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id >= 4 and id <= 5;
MC: wait until C1 ready;
C2: UPDATE t1 SET id = 4, col = 'xyz' WHERE id = 5;
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 4,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: rollback;
/* expect: a constraint error message should generated once C2 ready, C2 select - no instance is updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: no instance is  deleted, no instance is updated */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;
