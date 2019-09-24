/*
Test Case: delete & update 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/multi_index/basic_sql/delete_update_06.ctl
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are overlapped (with multiple indexes)

Test Scenario:
C1 delete, C2 update, the affected rows are overlapped (based on where clause)
C1's deleting the instances contain the C2's updating instances
C1 where clause is on index (index scan), C2 where clause is not on index (heap scan)
C1 rollback, C2 commit
Metrics: data size = small, index = multiple indexes(PK + simple index), where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances won't be deleted since C1 rollback, but C2 instances will be updated
   (i.e. the version won't be deleted, C2's search condition is satisfied)

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
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE INDEX idx_col on t1(col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'stu','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id >= 3 and id <= 5;
MC: wait until C1 ready;
C2: UPDATE t1 SET col = 'jkl' WHERE tag IN ('C','E');
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 3,4,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: rollback;
MC: wait until C1 ready;
/* expect: 2 rows updated message should be generated once C2 ready, C2 select - id = 3,5 are updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: id = 3,5 are updated, no instance is deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;

