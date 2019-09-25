/*
Test Case: select & select 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/function/counter_function/select_select_incrdecr_05.ctl
Author: Ray
Function: INCR/DECR

Test Plan: 
Test MVCC SELECT scenarios (locks - X_LOCK on instance ??) if using click counter function (INCR/DECR) in select queries 
but the affected rows are overlapped

Test Scenario:
C1 select, C2 select, the selected rows are overlapped (based on where clause)
C1 uses DECR and C2 uses INCR
C1 where clause is not on index (heap scan), C2 where clause is on index (index scan)
C1 commit, C2 commit
Metrics: data size = small, index = multiple indexes(PK + simple index), where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances will be updated(decrement), C2 instances will be updated(increment) based on the reevaluation.

NUM_CLIENTS = 3
C1: select from table t1;   
C2: select from table t1;  
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
C1: CREATE TABLE t1(id INT PRIMARY KEY, title VARCHAR(10), read_count INT);
C1: CREATE INDEX idx_title on t1(title) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'book1',3),(2,'book2',5),(3,'book3',1),(4,'book4',0),(5,'book5',3),(6,'book6',2),(7,'book7',0);
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: SELECT title, DECR(read_count) FROM t1 WHERE read_count IN (0,3,5) and read_count <= 0; 
MC: wait until C1 ready;
C2: SELECT title, INCR(read_count) FROM t1 WHERE title IN ('book3','book4') and (id BETWEEN 4 AND 6); 
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 ready;
/* expect: C1 select - id = 4 is updated */
C1: SELECT * FROM t1 order by 1,2,3;
C1: commit;
/* expect: C2 select - id = 4 is updated based on C1 updated value (reevaluation, read_count = 0) */
MC: wait until C1 ready;
C2: SELECT * FROM t1 order by 1,2,3;
C2: commit;
MC: wait until C2 ready;
/* expect: id = 1 is updated */
C3: select * from t1 order by 1,2,3;
C3: commit;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
