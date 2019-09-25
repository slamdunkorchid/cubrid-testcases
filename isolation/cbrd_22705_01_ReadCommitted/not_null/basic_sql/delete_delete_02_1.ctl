/*
Test Case: delete & delete
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/not_null/basic_sql/delete_delete_02.ctl
Author: Ray

Test Plan: 
Test concurrent DELETE transactions in MVCC (with NOT NULL constraint)

Test Scenario:
C1 delete, C2 delete, the affected rows are overlapped (based on where clause)
C1 delete instances intersect with C2 delete instances
C1 where clause is on NOT NULL column (i.e. index scan), C2 where clause is not on NOT NULL column (heap scan)
C1 commit, C2 commit
Metrics: index = single index(Unique), data size = small, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed (Locking Test)
2) C1 instances should be deleted
   C2 instances should be deleted after reevaluation (Visibility/Reevaluation Test)

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
C1: CREATE TABLE t1(id INT NOT NULL UNIQUE, col VARCHAR(10), tag VARCHAR(2));
C1: CREATE UNIQUE INDEX idx_id on t1(id) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc','A'),(2,'def','B'),(3,'ghi','C'),(4,'jkl','D'),(5,'mno','E'),(6,'pqr','F'),(7,'abc','G');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id > 5;
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE col IN ('def','abc');
/* expect: C2 needs to wait until C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 6,7 are deleted */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 2 rows deleted message, C2 select - id = 1,2(C2),6,7(C1) are deleted */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: id = 1,2,6,7 are deleted */
C3: SELECT * FROM t1 order by 1,2;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;

