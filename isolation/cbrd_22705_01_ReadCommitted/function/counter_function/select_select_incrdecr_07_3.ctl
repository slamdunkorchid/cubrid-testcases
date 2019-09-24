/*
Test Case: select & select 
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/function/counter_function/select_select_incrdecr_07.ctl
Author: Ray
Function: INCR/DECR

Test Plan: 
Test MVCC SELECT scenarios (locks - IX_LOCK) if using click counter function (INCR/DECR) in select queries, 
and the affected rows are not overlapped, C1, C2 uses incr/decr to update an unique index to an identical value  

Test Scenario:
C1 select, C2 select, the selected rows are not overlapped (based on where clause)
C1 uses INCR and C2 uses DECR
C2 uses incr/decr to update an unique index to an identical value
C1 where clause is not on filtered index (heap scan), C2 where clause is on filtered index (index scan - total)
C1 commit, C2 commit
Metrics: data size = small, index = single filtered index, where clause = simple, schema = single table

Test Point:
1) C2 needs to wait until C1 completed
2) C1 instances will be updated(increment) because of C1 rollback
   C2 instances won't be updated(decrement) since duplicate key constraint error 

NUM_CLIENTS = 3
C1: select incr from table t1;   
C2: select decr from table t1;  
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
C1: INSERT INTO t1 VALUES(1,'book1',3),(2,'book2',5),(3,'book3',1),(4,'book4',0),(5,'book5',3),(6,'book6',2),(8,'book8',3);
C1: CREATE INDEX idx_id on t1(id) WHERE id IN (5,8) with online parallel 2;
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: SELECT title, INCR(id) FROM t1 WHERE id = 6; 
MC: wait until C1 ready;
C2: SELECT title, DECR(id) FROM t1 WHERE id = 8 USING INDEX idx_id(+); 
/* expect: C2 needs to wait once C1 completed */
MC: wait until C2 ready;
/* expect: C1 select - id = 6 is updated */
C1: SELECT * FROM t1 order by 1,2,3;
C1: commit;
/* expect: a duplicate key constraint error should be generated once C2 ready, no instance is updated */
MC: wait until C1 ready;
C2: SELECT * FROM t1 order by 1,2,3;
C2: commit;
MC: wait until C2 ready;
/* expect: the instances of id = 6 is updated */
C3: select * from t1 order by 1,2,3;
C3: commit;
MC: wait until C3 ready; 

C1: quit;
C2: quit;
C3: quit;
