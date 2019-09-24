/*
Test Case: delete & select
Priority: 1
Reference case:
Author: Lily

Test Point:
C1 delete rows, C2 select rows, overlapped.
transactions are not blocked.

NUM_CLIENTS = 2
C1: DELETE FROM tb1; -- using index 1
C2: SELECT * FROM tb1 order by 1,2;  -- using index 2
C1: rollback;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, col int);
C1: INSERT INTO tb1 SELECT rownum,rownum%100 FROM db_class a,db_class b where rownum <= 500;
C1: CREATE INDEX idx_1 ON tb1(id) with online parallel 3;
C1: CREATE INDEX idx_2 ON tb1(col) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: DELETE FROM tb1 WHERE id < 5;
MC: wait until C1 ready;

C2: SELECT * FROM tb1 WHERE col <3 ORDER BY id;
MC: wait until C2 ready;

/* expected 496 records */
C1: SELECT COUNT(*) FROM tb1 ORDER BY id;
C1: rollback;
MC: wait until C1 ready;

/* expected 500 records */
C2: SELECT COUNT(*) FROM tb1 ORDER BY id;
C2: commit work;
MC: wait until C2 ready;

C2: quit;
C1: quit;
