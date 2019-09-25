/*
Test Case: delete & select
Priority: 1
Reference case:
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
             but can see rows before the queries began.
C1 select rows, C2 delete rows, overlapped.
select and delete use same index.
transactions are not blocked.

NUM_CLIENTS = 2
C1: select * from tb1 order by id;
C2: DELETE FROM tb1 WHERE id <= 3;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, col VARCHAR(10) );
C1: INSERT INTO tb1 SELECT rownum,mod(rownum,100) FROM db_class a,db_class b where rownum<=500;
C1: CREATE INDEX idx_id on tb1(col) with online parallel 3;
C1: CREATE INDEX idx_col on tb1(id) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: SELECT * FROM tb1 WHERE col='2' ORDER BY id;
C1: DELETE FROM tb1 WHERE col in ('31','33','39');
MC: wait until C1 ready;
C2: SELECT * FROM tb1 WHERE id> 200 and id <= 210;
C2: DELETE FROM tb1 WHERE id> 200 and id <= 230;
C2: commit work;
MC: wait until C2 ready;
C1: SELECT COUNT(*) FROM tb1;
C1: commit work;
C1: SELECT COUNT(*) FROM tb1;
MC: wait until C1 ready;
C2: SELECT COUNT(*) FROM tb1;
MC: wait until C2 ready;
C1: commit;
C2: commit;

C2: quit;
C1: quit;
