/*
Test Case: select & update 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/function/counter_function/select_update_incrdecr_03.ctl
Author: Ray
Function: INCR/DECR

Test Plan: 
Test MVCC SELECT/UPDATE scenarios if using click counter function (INCR/DECR) in select query, 
and the affected rows are overlapped,  

Test Scenario:
C1 select, C2 update, the affected rows are overlapped (based on where clause)
C1 uses INCR
C1 select doesn't affect C2 updates
C1,C2 update an unique index value
C1,C2 where clause is on each of multiple indexes respectively 
C1 commit, C2 commit
Metrics: data size = small, index = multiple indexes, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances will be updated(increment) by using INCR function 
   C2 instances will be updated after reevaluation 

NUM_CLIENTS = 3
C1: select incr from table t1;   
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
C1: CREATE INDEX idx_id on t1(id) with online parallel 2;
C1: CREATE INDEX idx_title on t1(title) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'book1',3),(2,'book2',5),(3,'book3',1),(4,'book4',0),(5,'book5',3),(6,'book6',2),(7,'book7',0);
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: SELECT title, INCR(id) FROM t1 WHERE id IN (5,7) AND title != 'book5'; 
MC: wait until C1 ready;
C2: UPDATE t1 SET id = 0 WHERE title IN ('book5','book7');
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 ready;
/* expect: C1 select - id = 7 is updated */
C1: SELECT * FROM t1 order by 1,2,3;
C1: commit;
/* expect: 2 rows (id=5,7)updated message should be generated once C2 ready, C2 select - id = 5,7 are updated based on C1 updated value*/
MC: wait until C1 ready;
C2: SELECT * FROM t1 order by 1,2,3;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 5,7 are updated */
C3: select * from t1 order by 1,2,3;
C3: commit;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
