/*
Test Case: delete & select
Priority: 1
Reference case:
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
C1 select rows, C2 delete rows, overlapped.
transactions are not blocked.

NUM_CLIENTS = 2
C1: SELECT * FROM tb1 order by 1,2; --using index skip scan 
C2: DELETE FROM tb1; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, acol int, bcol int);
C1: INSERT INTO tb1 SELECT rownum%2,rownum%50,rownum%100 FROM db_class a,db_class b, db_class c, db_class d where rownum <= 500;
C1: CREATE INDEX idx_id ON tb1(id) with online parallel 3;
C1: CREATE INDEX idx_all ON tb1(acol,bcol) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: SELECT * FROM tb1 WHERE acol=10 and bcol>50;
MC: wait until C1 ready;
C2: DELETE FROM tb1 WHERE acol < 2 and bcol > 50;
C2: commit work;
MC: wait until C2 ready;
C1: SELECT * FROM tb1 WHERE acol=10 and bcol>50;
C1: SELECT * FROM tb1 WHERE acol<2 and bcol>50;
C1: commit work;
C1: SELECT COUNT(*) FROM tb1 ORDER BY id;
C1: commit work;

C2: quit;
C1: quit;
