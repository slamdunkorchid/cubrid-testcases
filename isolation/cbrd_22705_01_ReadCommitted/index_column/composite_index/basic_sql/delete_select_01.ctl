/*
Test Case: delete & select
Priority: 1
Reference case:
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
             but can see rows before the queries began.
C1 delete rows, C2 select rows, overlapped.
transactions are not blocked.

NUM_CLIENTS = 2
C1: DELETE FROM tb1;
C2: SELECT * FROM tb1 order by 1,2; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, city VARCHAR(10), hire_date DATE);
C1: INSERT INTO tb1 VALUES(1,'BJ','2003-2-1'),(2,'NY','2003-3-1'),(3,'BJ','2004-2-1'),(4,'WA','2003-2-1'),(5,'BJ','2004-2-1');
C1: CREATE INDEX idx_c_h ON tb1(city,hire_date) with online parallel 2;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE hire_date>'2003-1-1';
MC: sleep 2;
C2: SELECT * FROM tb1 WHERE city='BJ' ORDER BY id;
MC: wait until C2 ready;
C1: commit work;
C2: SELECT * FROM tb1 ORDER BY id;
C2: commit work;

C2: quit;
C1: quit;
