/*
Test Case: delete & delete 
Priority: 1
Reference case:
Isolation Level: Repeatable Read
Author: Ray

Test Plan: 
Test concurrent DELETE transactions in MVCC (with single index schema)

Test Scenario:
C1 delete, C2 delete, the affected rows are not overlapped (based on where clause)
C1,C2 where clauses are on index, C1 all-type search, C2 range-type search (i.e. sequence scan)
C2 contains a read query before delete
C1 commit, C2 commit
Metrics: data size = small, index = single index, where clause = simple, schema = single table

Test Point:
1) C2 doesn't need to wait until C1 completed (Locking Test)
2) C1 and C2 can only see the its own deletion but not other transactions deletion 
3) All the data affected from C1 and C2 should be deleted (Visibility Test)

NUM_CLIENTS = 3
C1: delete from table t1;  
C2: delete from table t1;  
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
C1: INSERT INTO t1 VALUES(1,'abc');INSERT INTO t1 VALUES(2,'def');INSERT INTO t1 VALUES(3,'ghi');INSERT INTO t1 VALUES(4,'jkl');INSERT INTO t1 VALUES(5,'mno');INSERT INTO t1 VALUES(6,'pqr');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id IN (3,6);
MC: wait until C1 ready;
/* expect: C2 select - all the data are selected */
C2: SELECT * FROM t1 order by 1,2;
MC: wait until C2 ready;
C2: DELETE FROM t1 WHERE id BETWEEN 4 AND 5;
/* expect: C2 doesn't needs to wait once C1 completed */
MC: wait until C2 ready;

/* expect: C1 select - id = 3,6 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
MC: wait until C1 ready;

/* expect: 2 rows (id=4,5) deleted message, C2 select - id = 4,5 are deleted, but id = 3,6 are still existed */
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;

/* expect: the instances of id = 3-6 are deleted */
C3: select * from t1 order by 1,2;
C3: commit;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
