/*
Test Case: update & delete
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/multi_index/basic_sql/update_delete_08.ctl
Author: Ray

Test Plan: 
Test UPDATE/DELETE locks (X_LOCK on instance) if the instances of the transactions are overlapped initially (with multiple indexes),
but C1's updated results affect the C2's deleting instances

Test Scenario:
C1 update, C2 delete, the affected rows are overlapped initially (based on where clause) 
C1's updating the instances intersect with in the C2's deleting instances 
C1's updated results do affect a portion the C2's deleting instances
C1 where clause is not on index (heap scan), C2 where clause is on index (index scan)  
C1 commit, C2 commit
Metrics: schema = single table, index = multiple indexes(PK + Unique + Composite index), data size = small, where clause = simple

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances will be updated, C2 instances which still satisfy the search condition will be deleted but others will not 
   (i.e.the version will be updated, the search condition of C2 is partially satisfied)  

NUM_CLIENTS = 3
C1: update table t1;  
C2: delete from table t1;  
C3: select on table t1; C3 is used to check the updated result
*/

MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: CREATE TABLE t1(id INT PRIMARY KEY, col VARCHAR(10), tag VARCHAR(2), description VARCHAR(100));
C1: CREATE UNIQUE INDEX idx_col on t1(col);
C1: CREATE INDEX idx_id_tag on t1(id, tag) with online parallel 3;
C1: INSERT INTO t1 VALUES(1,'abc','A','hello');INSERT INTO t1 VALUES(2,'def','B','morning');INSERT INTO t1 VALUES(3,'ghi','C','good');INSERT INTO t1 VALUES(4,'jkl','D','test');INSERT INTO t1 VALUES(5,'mno','E',NULL);INSERT INTO t1 VALUES(6,'pqr','F',NULL);INSERT INTO t1 VALUES(7,'stu','G','');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET tag = 'A' WHERE description IS NULL or description LIKE '%morning%';
MC: wait until C1 ready;
C2: DELETE FROM t1 WHERE tag IN ('B','C');
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 2,5,6 are updated */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 1 rows (id = 3)deleted message should be generated once C2 ready, C2 select - id = 3 is deleted */
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
MC: wait until C2 ready;
/* expect: id = 2,5,6 are updated, id = 3 is deleted */
C3: select * from t1 order by 1,2;
MC: wait until C3 ready;

C3: commit;
C1: quit;
C2: quit;
C3: quit;
