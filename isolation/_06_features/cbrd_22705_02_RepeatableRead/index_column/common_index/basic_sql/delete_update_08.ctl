/*
Test Case: delete & update
Priority: 1
Reference case:
Isolation Level: Repeatable Read
Author: Ray

Test Plan: 
Test concurrent DELETE/UPDATE transactions in MVCC (with single index schema)

Test Scenario:
C1 delete, C2 update, the affected rows are overlapped (based on where clause)
C1 C2 where clauses are on index (i.e. index scan)
C1's deleting the instances equal to the C2's updating instances
C1 commit, C2 commit
Metrics: schema = single table, index = single index, data size = small, where clause = simple

Test Point:
1) C2 needs to wait until C1 completed (Locking Test)
2) C1 and C2 can only see the its own delete/update but not other transactions changes (Visibility Test) 
3) C1 instances should be deleted, C2 instances shouldn't be updated since the data is selected

NUM_CLIENTS = 3
C1: delete from table t1;
C2: update table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT, col VARCHAR(10));
C1: CREATE INDEX idx_id on t1(id) with online parallel 3;
C1: INSERT INTO t1 VALUES(1,'abc');INSERT INTO t1 VALUES(2,'def');INSERT INTO t1 VALUES(3,'ghi');INSERT INTO t1 VALUES(4,'jkl');INSERT INTO t1 VALUES(5,'mno');INSERT INTO t1 VALUES(1,'bcd');INSERT INTO t1 VALUES(6,'pqr');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id >= 4 AND id <= 5;
MC: wait until C1 ready;
C2: UPDATE t1 SET col = 'abcd' WHERE id IN (4,5);
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 4,5 are deleted */
C1: SELECT * FROM t1 ORDER BY 1,2;
C1: commit;
/* expect: 0 row updated message should generated once C2 ready, C2 select - no instance is updated, id = 4,5 are still existed and unchanged  */
MC: wait until C2 ready;
C2: SELECT * FROM t1 ORDER BY 1,2;
C2: commit;
/* expect: id = 4,5 are deleted */
C3: select * from t1 ORDER BY 1,2;
C3: commit;

C1: quit;
C2: quit;
C3: quit;