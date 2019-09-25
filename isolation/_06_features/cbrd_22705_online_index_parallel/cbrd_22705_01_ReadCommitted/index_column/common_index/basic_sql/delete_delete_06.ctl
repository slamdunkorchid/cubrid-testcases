/*
Test Case: delete & delete 
Priority: 1
Reference case:
Author: Ray

Test Plan: 
Test concurrent DELETE transactions in MVCC (with single index schema)

Test Scenario:
C1 delete, C2 delete, the affected rows are overlapped (based on where clause)
C1,C2 where clauses are on index (i.e. index scan)
C1 delete instances equal to C2 delete instances 
C1 commit, C2 commit
Metrics: data size = small, index = single index, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait C1 completed (Locking Test)
2) The instances of C1 will be deleted
   The instances of C2 won't be deleted (after reevaluation) (Visibility/Reevaluation Test)

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
C1: CREATE TABLE t1(id INT, col VARCHAR(10));
C1: CREATE INDEX idx_id on t1(id) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc'),(2,'def'),(3,'ghi'),(4,'jkl'),(5,'mno'),(6,'pqr');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id = 1 or id = 2;
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE id >= 1 and id <= 2;
/* expect: C2 needs to wait until C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 1,2 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 0 row deleted message should generated once C2 ready, C2 select - id = 1,2(C1) are deleted */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: the instances of id = 1,2 are deleted */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;
