/*
Test Case: update & select 
Priority: 1
Reference case:
Author: Ray
Function: INCR/DECR

Test Plan: 
Test MVCC UPDATE/SELECT scenarios if using click counter function (INCR/DECR) in select query, 
and the affected rows are overlapped

Test Scenario:
C1 update, C2 select, the affected rows are overlapped (based on where clause)
C2 uses INCR
C2 select doesn't affect C1 update
C1 where clause is not on index (heap scan), C2 where clause is on index (index scan)
C1 commit, C2 commit
Metrics: data size = small, index = composite index, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait C1 completed
2) C1 instances will be updated 
   C1 instances will be updated after reevaluation

NUM_CLIENTS = 3
C1: select from table t1;   
C2: update table t1;  
C3: select on table t1; C3 is used to check the final results
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
C1: CREATE TABLE t1(id INT, title VARCHAR(10), read_count INT);
C1: CREATE INDEX idx_id_title on t1(id,title) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'book1',3),(2,'book2',5),(3,'book3',1),(4,'book4',0),(5,'book5',4),(6,'book6',2),(7,'book7',4);
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: UPDATE t1 SET read_count = 0 WHERE read_count >= 5;
MC: wait until C1 ready;
C2: SELECT INCR(read_count) FROM t1 WHERE title IN ('book2');
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 blocked;
/* expect: C1 select - id = 2 is updated */
C1: SELECT * FROM t1 order by 1,2;
C1: commit;
/* expect: 1 row(id = 2) updated once C2 ready, C2 select - id = 2 is updated based on C1 value*/
MC: wait until C2 ready;
C2: SELECT * FROM t1 order by 1,2;
C2: commit;
/* expect: the instances of id = 2 is updated */
C3: select * from t1 order by 1,2;

C1: quit;
C2: quit;
C3: quit;
