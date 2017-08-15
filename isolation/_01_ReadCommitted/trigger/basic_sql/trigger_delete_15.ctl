/*
Test Case: delete in trigger & insert
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/trigger/basic_sql/trigger_delete_01.ctl
Author: Lily

Test Point:
when trigger is called, delete statement is executed

NUM_CLIENTS = 2
C1: start transaction;
C2: update a row from hi;
C1: insert into tt1 to fire a trigger to delete different row from hi; --ready
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tt1;
C1: DROP TABLE IF EXISTS hi;
C1: CREATE TABLE hi( id INT PRIMARY KEY, col VARCHAR(10));
C1: INSERT INTO hi VALUES(1,'111'),(2,'22'),(3,'333');
C1: CREATE TABLE tt1( id INT, col VARCHAR(10));
C1: CREATE TRIGGER tt1_insert AFTER INSERT ON tt1 EXECUTE DELETE FROM hi WHERE id = obj.id;
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: UPDATE hi SET col=NULL WHERE id=3;
MC: sleep 1;
C2: UPDATE hi SET id = 10 WHERE id=1;
C1: INSERT INTO tt1 VALUES(2,'test');
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;

C1: SELECT * FROM hi ORDER BY id,col;
C1: commit;
MC: wait until C1 ready;

C2: SELECT * FROM hi ORDER BY id,col;
C2: SELECT * FROM tt1 ORDER BY id,col;

C2: quit;
C1: quit;
