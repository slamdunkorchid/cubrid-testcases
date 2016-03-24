/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/common_index/orderby_limit/delete_select_01.ctl 
Author: Lily

Test Point:
there are simple order by keyword and RDERBY_NUM() in select statement.

NUM_CLIENTS = 2
C1: DELETE FROM tb1 WHERE id =501;
C2: SELECT * FROM tb1 order by 1,2; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1(id INT, name VARCHAR(20), month1 INT, amount INT DEFAULT 100); 
C1: INSERT INTO tb1 VALUES(201, 'George' , 1, 450), (201, 'George' , 2, 250), (201, 'Laura'  , 1, 100), (201, 'Laura'  , 2, 500),(301, 'Max', 1, 300), (301, 'Max'    , 2, 300); 
C1: INSERT INTO tb1 VALUES(501, 'Stephan', 1, 300), (501, 'Stephan', 2, DEFAULT), (501, 'Chang'  , 1, 150),(501, 'Chang'  , 2, 150),(501, 'Sue', 1, 150), (501, 'Sue'    , 2, 200); 
C1: CREATE INDEX idx_id on tb1(id);
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE id =501;
MC: wait until C1 ready;

C2: SELECT id AS a1, avg(amount) AS a2 FROM tb1 GROUP BY a1 ORDER BY a2 DESC FOR ORDERBY_NUM() BETWEEN 1 AND 3;
MC: wait until C2 ready;
C1: commit work;
MC: wait until C1 ready;

C2: SELECT id AS a1, avg(amount) AS a2 FROM tb1 GROUP BY a1 ORDER BY a2 DESC FOR ORDERBY_NUM() BETWEEN 1 AND 3;
C2: commit work;
MC: wait until C2 ready;


C2: quit;
C1: quit;
