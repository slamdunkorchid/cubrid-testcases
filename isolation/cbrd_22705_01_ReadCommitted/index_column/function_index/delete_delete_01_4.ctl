/*
Test Case: delete & delete 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/function_index/delete_delete_01.ctl
Author: Ray

Test Plan: 
Test DELETE locks (X_LOCK on instance) if the delete instances of the transactions are not overlapped (with function index)

Test Scenario:
C1 delete, C2 delete, the affected rows are not overlapped (based on where clause)
C1 where clause uses function index (i.e. index scan), C2 where clause uses another function index (index scan)
C1 commit, C2 commit
Metrics: data size = small, index = multiple function index(ABS + LENGTH), where clause = simple, DELETE state = single table deletion

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
C1: CREATE TABLE t1(id INT, col VARCHAR(10), tag VARCHAR(2));
C1: INSERT INTO t1 VALUES(1,'a','A'),(-1,'bb','B'),(-2,'ccc','C'),(2,'dddd','D'),(3,'eeeee','E'),(-3,'ffff','F'),(-4,'gggggg','G');
C1: CREATE INDEX idx_id_abs on t1(ABS(id)) with online parallel 2;
C1: CREATE INDEX idx_col_length on t1(LENGTH(col)) with online parallel 2;
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE ABS(id) = 3;
MC: wait until C1 ready;

C2: DELETE FROM t1 WHERE LENGTH(col) >= 2 and LENGTH(col) <= 3;
/* expect: no transactions need to wait */
MC: wait until C2 ready;

/* expect: C1 select - id = 3,-3 are deleted */
C1: SELECT * FROM t1 order by 1,2;
MC: wait until C1 ready;

/* expect: C2 select - id = -1,-2 are deleted */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;

/* expect: C2 select - id = -1,-2,3,-3 are deleted */
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;

/* expect: the instances of id = -1,-2,3,-3 are deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
