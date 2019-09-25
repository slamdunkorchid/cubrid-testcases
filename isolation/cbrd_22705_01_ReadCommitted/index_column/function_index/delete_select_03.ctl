/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/function_index/delete_select_01.ctl 
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
C1 delete rows, C2 select rows, overlapped.
transactions are not blocked.
two index, unique index and UPPER function index on the same column

NUM_CLIENTS = 2  -- use same index
C1: delete from tb1 where UPPER(col)='lucy'; 
C2: select * from tb1 where UPPER(col) like 'l%'
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, col VARCHAR(10));
C1: INSERT INTO tb1 VALUES(101,'Tom'),(102,'Mike'),(103,'Stephan'),(102,'Lucy'),(103,'Elena'),(103,'laura'),(104,'L'),(105,NULL),(105,'Ben');
C1: CREATE UNIQUE INDEX idx_all ON tb1(col) with online parallel 2;
C1: CREATE INDEX idx_2 ON tb1(UPPER(col)) with online parallel 2;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE UPPER(col)='LUCY';
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE UPPER(col) LIKE 'L%';
MC: wait until C2 ready;
C1: commit;
C2: commit work;
MC: wait until C1 ready;
MC: wait until C2 ready;

C2: SELECT * FROM tb1 ORDER BY id,col;
C2: commit;

C2: quit;
C1: quit;

