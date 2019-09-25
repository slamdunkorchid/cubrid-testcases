/*
Test Case: delete & insert
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes.
-    Delete: X_LOCK acquired on current instance
there is index on t1(id,col), delete and insert value has no overlap
unique index

NUM_CLIENTS = 3
C1: DELETE FROM t1 WHERE id = 5;
C2: insert into t1 values(6,'123'); -- expected ok, not to be deleted
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
C1: create unique index idx on t1(id,col) with online parallel 2;
C1: INSERT INTO t1 VALUES(1,'abc'),(2,'def'),(3,'ghi'),(4,'jkl'),(5,'mno'),(5,'pqr'),(7,'stu');
C1: COMMIT WORK;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM t1 WHERE id = 5;
MC: wait until C1 ready;

C2: insert into t1 values(6,'123');
/* expect: no transactions need to wait */
MC: wait until C2 ready;

/* expected delete 2 row */
C1: commit;
MC: wait until C1 ready;

/* expected insert 1 row */
C2: commit;
MC: wait until C2 ready;

C3: select * from t1 order by 1,2;
C3: commit;
MC: wait until C3 ready;

C1: quit;
C2: quit;
C3: quit;
