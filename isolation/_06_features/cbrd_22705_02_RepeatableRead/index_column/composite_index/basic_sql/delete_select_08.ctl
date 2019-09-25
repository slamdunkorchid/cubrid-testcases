/*
Test Case: delete & select
Priority: 1
Reference case:
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,

NUM_CLIENTS = 2
C1: DELETE FROM tb1;
C2: DELETE FROM tb1;
C1: commit work;
C1: DELETE FROM tb1;
C2: select * from tb1 order by id; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;
C2: commit;
/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, city VARCHAR(10), hire_date DATE);
C1: INSERT INTO tb1 VALUES(1,'BJ','2003-2-1'),(2,'NY','2003-3-1'),(3,'BJ','2004-2-1'),(4,'WA','2003-2-1'),(5,'BJ','2004-2-1'),(6,'BJ','2003-5-1');
C1: CREATE INDEX idx_c_h ON tb1(city,hire_date) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE city='BJ' AND hire_date>'2004-1-1';
MC: wait until C1 ready;
C2: DELETE FROM tb1 WHERE hire_date='2003-2-1';
MC: wait until C2 ready;
C1: commit work;
C1: DELETE FROM tb1 WHERE hire_date='2003-5-1';
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE hire_date>'2003-1-1' AND city='BJ' ORDER BY id;
C2: commit work;
C2: SELECT * FROM tb1 ORDER BY id;
C2: commit;
C2: quit;
C1: quit;
