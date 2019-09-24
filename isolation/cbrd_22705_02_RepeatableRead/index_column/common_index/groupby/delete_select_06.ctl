/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/common_index/groupbydelete_select_01.ctl
Author: Lily

Test Point:
there are a simple GROUP BY and where keyword in select statement.

NUM_CLIENTS = 2
C2: SELECT * FROM tb1 where sleep(1,name)=1;
C1: DELETE FROM tb1 WHERE id =201;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1(id INT, name VARCHAR(20), mont INT, amount INT DEFAULT 100);
C1: INSERT INTO tb1 VALUES(201, 'George' , 1, 450); INSERT INTO tb1 VALUES(201, 'George' , 2, 250); INSERT INTO tb1 VALUES(201, 'Laura'  , 1, 100); INSERT INTO tb1 VALUES(201, 'Laura'  , 2, 500);INSERT INTO tb1 VALUES(301, 'Max'    , 1, 300);INSERT INTO tb1 VALUES (301, 'Max'    , 2, 300);
C1: INSERT INTO tb1 VALUES(501, 'Stephan', 1, 300); INSERT INTO tb1 VALUES(501, 'Stephan', 2, DEFAULT);INSERT INTO tb1 VALUES (501, 'Chang'  , 1, 150);INSERT INTO tb1 VALUES(501, 'Chang'  , 2, 150);INSERT INTO tb1 VALUES(501, 'Sue'    , 1, 150);INSERT INTO tb1 VALUES (501, 'Sue'    , 2, 200);
C1: CREATE INDEX idx_id on tb1(id) with online parallel 3;
C1: commit work;

/* test case */
C2: SELECT tb1.id, avg(tb1.amount) FROM (select sleep(1)) x, tb1 WHERE amount > 100 GROUP BY id; 
MC: wait until C2 ready;
C1: DELETE FROM tb1 WHERE id = 501; 
MC: wait until C1 ready; 
C1: commit work;
MC: wait until C1 ready; 
C2: SELECT id, avg(amount) FROM tb1 WHERE amount > 100 GROUP BY id;
C2: commit work;
C2: SELECT id, avg(amount) FROM tb1 WHERE amount > 100 GROUP BY id;
C2: commit;
C2: quit;
C1: quit;
