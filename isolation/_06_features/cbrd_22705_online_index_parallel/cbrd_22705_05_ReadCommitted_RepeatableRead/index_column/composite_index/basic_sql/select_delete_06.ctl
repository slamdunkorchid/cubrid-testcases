/*
Test Case: delete & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/composite_index/basic_sql/select_delete_02.ctl
Author: Lily

Test Point:
-    delete: X_LOCK acquired on current instance..
-    select: no row locks acquired but IS_LOCK for table,
C1 select rows, C2 delete rows, overlapped.
transactions are not blocked.

NUM_CLIENTS = 2
C1: select * from tb1 order by id;
C2: DELETE FROM tb1;
C2: rollback;
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;
C2: commit;
/* preparation */
C1: DROP TABLE IF EXISTS tb1;
C1: CREATE TABLE tb1( id INT, acol int, name int);
C1: INSERT INTO tb1 SELECT mod(rownum,10),mod(rownum,50),mod(rownum,100) FROM db_class a,db_class b where rownum<=500;
C1: CREATE INDEX idx_all ON tb1(id,acol,name) with online parallel 3;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: SELECT * FROM tb1 WHERE id <2 and acol <2 ORDER BY id;
MC: wait until C1 ready;
C2: DELETE FROM tb1 WHERE id =0 and acol < 2 and name > 49 ;
C2: SELECT * FROM tb1 WHERE acol < 2 and name > 49 ORDER BY id ;
C2: rollback;
MC: wait until C2 ready;
C1: commit work;
C1: SELECT COUNT(*) FROM tb1 ORDER BY id;
C1: commit;
C2: quit;
C1: quit;
