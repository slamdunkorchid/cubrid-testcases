/*
Test Case: delete & delete 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/multi_index/basic_sql/delete_delete_01.ctl
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are not overlapped (with multiple indexes)

Test Scenario:
C1 delete, C2 delete, the affected rows are not overlapped
C1,C2 where clauses are on index (i.e. index scan)
C1 where clause uses multiple indexes, C2 where clause uses multiple indexes
C1 commit, C2 commit
Metrics: data size = small, index = multiple indexes(Unique + simple index), where clause = simple, DELETE state = single table deletion

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
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT, col VARCHAR(10) UNIQUE, tag VARCHAR(2));
C1: CREATE INDEX idx_id on t1(id) with online parallel 2;
C1: CREATE UNIQUE INDEX idx_col on t1(col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'stx','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id BETWEEN 2 AND 3 or col = 'mno' and col != 'def';
MC: sleep 1;
C2: DELETE FROM t1 WHERE id IN ('1','6') and col != 'pqr' or tag = 'B';
/* expect: no transactions need to wait */
MC: wait until C1 ready;
MC: wait until C2 blocked;
/* expect: C1 select - id = 3,5 are deleted */
C1: SELECT * FROM t1 order by 1,2,3;
MC: wait until C1 ready;
C1: COMMIT WORK;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: C2 select - id = 1,2 are deleted */
C2: SELECT * FROM t1 order by 1,2,3;
MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 1,2,3,5 are deleted */
C3: select * from t1 order by 1,2,3;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
