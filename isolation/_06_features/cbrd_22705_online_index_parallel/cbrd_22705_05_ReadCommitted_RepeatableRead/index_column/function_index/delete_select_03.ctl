/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/function_index/delete_select_01.ctl 
Author: Lily

Test Point:
two index, unique index and UPPER function index on the same column

NUM_CLIENTS = 2  -- use same index
C1: delete from tb1 where UPPER(col)='lucy'; 
C2: select * from tb1 where UPPER(col) like 'l%'
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;
C2: commit;
/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, col VARCHAR(10));
C1: INSERT INTO tb1 VALUES(101,'Tom');INSERT INTO tb1 VALUES(102,'Mike');INSERT INTO tb1 VALUES(103,'Stephan');INSERT INTO tb1 VALUES(102,'Lucy');INSERT INTO tb1 VALUES(103,'Elena');INSERT INTO tb1 VALUES(103,'laura');INSERT INTO tb1 VALUES(104,'L');INSERT INTO tb1 VALUES(105,NULL);INSERT INTO tb1 VALUES(105,'Ben');
C1: CREATE UNIQUE INDEX idx_all ON tb1(col) with online parallel 2;
C1: CREATE INDEX idx_2 ON tb1(UPPER(col)) with online parallel 3;
C1: commit work;

/* test case */
C1: DELETE FROM tb1 WHERE UPPER(col)='LUCY';
C1: DELETE FROM tb1 WHERE UPPER(col)='L';
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE UPPER(col) LIKE 'L%';
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE UPPER(col) LIKE 'L%';
C2: commit work;
C2: SELECT * FROM tb1 WHERE UPPER(col) LIKE 'L%';
C2: commit;
C2: quit;
C1: quit;

