/*
Test Case: delete & update 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/composite_index/basic_sql/delete_update_07.ctl
Author: Ray

Test Plan: 
Test DELETE/UPDATE locks (X_LOCK on instance) if the instances of the transactions are not overlapped (with multiple indexes)

Test Scenario:
C1 delete, C2 update, the affected rows are not overlapped (based on where clause)
C2 try to update an unique index column to a duplicate key which is C1 try to deleting 
C1 where clause is on index column (index scan), C2 where clause is not on index (heap scan) 
C1 rollback, C2 commit
Metrics: data size = small, index = multiple indexes(2 Unique indexes), where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances won't be deleted since C1 rollback, C2 instances shouldn't be updated (since the duplicate key hasn't been deleted)

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
C1: CREATE TABLE t1(id INT UNIQUE, col VARCHAR(10) UNIQUE, tag VARCHAR(2));
C1: CREATE UNIQUE INDEX idx_id on t1(id) with online parallel 2;
C1: CREATE UNIQUE INDEX idx_col on t1(col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'stu','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id BETWEEN 4 AND 5 or col = 'def' ;
MC: wait until C1 ready;
C2: UPDATE t1 SET col = 'def' WHERE tag = 'A' ;
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 2,4,5 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: rollback;
/* expect: a constraint error message should generated once C2 ready, C2 select - no instance is updated */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: no instance is deleted & updated */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
