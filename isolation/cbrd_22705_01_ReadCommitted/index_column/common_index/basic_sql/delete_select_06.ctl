/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/primary_key_column/basic_sql/delete_select_01.ctl
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
             but can see rows before the queries began.
C1 delete rows, C2 select rows, overlapped.
transactions are not blocked.

NUM_CLIENTS = 2
C1: DELETE FROM tb1 WHERE col ='spell';
C2: DELETE FROM tb1 WHERE id =6 or id =2;
C2: SELECT * FROM tb1 order by 1,2; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, col VARCHAR(10) );
C1: CREATE INDEX idx_id on tb1(col) with online parallel 2;
C1: CREATE INDEX idx_col on tb1(id) with online parallel 2;
C1: INSERT INTO tb1 VALUES(1,'do'),(2,'make'),(9,'spell'),(6,'have'),(5,'be');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE col ='spell';
MC: wait until C1 ready;

C2: DELETE FROM tb1 WHERE id =6 or id =2;
C2: SELECT * FROM tb1 WHERE id>0 ORDER BY id;
MC: wait until C2 ready;

C1: commit work;
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE id>0 ORDER BY id;
C2: commit work;
MC: wait until C2 ready;


C2: quit;
C1: quit;
