/*
Test Case: insert in trigger & insert
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/trigger/basic_sql/trigger_insert_01.ctl
Author: Lily

Test Point:
when trigger is called, insert statement is executed
there is primary key on table;

NUM_CLIENTS = 2
C1: insert into tt1 to fire a trigger to insert a row into hi; 
C2: insert into hi; 
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS tt1;
C1: DROP TABLE IF EXISTS hi;
C1: CREATE TABLE hi( id INT PRIMARY KEY, col VARCHAR(10));
C1: CREATE TABLE tt1( id INT, col VARCHAR(10));
C1: CREATE TRIGGER tt1_insert AFTER INSERT ON tt1 EXECUTE INSERT INTO hi(id,col) VALUES(obj.id, obj.col);
C1: commit work;

/* primary key conflict */
C1: INSERT INTO tt1 VALUES(1,'test'),(2,'call'),(3,'cool');
MC: wait until C1 ready;
C2: INSERT INTO hi VALUES(2,'test');
MC: wait until C2 blocked;
C1: commit;
MC: wait until C2 ready;
C2: SELECT * FROM hi order by id;
C2: commit;
C2: SELECT * FROM hi order by id;
MC: wait until C2 ready;
C1: SELECT * FROM hi order by id;
MC: wait until C1 ready;

/* primary key do not conflict */
C1: INSERT INTO tt1 VALUES(4,'flinch');
MC: wait until C1 ready;
C2: INSERT INTO hi VALUES(5,'OK');
C2: SELECT * FROM hi order by id;
MC: wait until C2 ready;
C1: commit;
MC: wait until C1 ready;
C2: SELECT * FROM hi order by id;
C2: commit work;
C2: SELECT * FROM hi order by id;
MC: wait until C2 ready;
C1: SELECT * FROM hi order by id;

C2: commit;
C1: commit;
C2: quit;
C1: quit;
