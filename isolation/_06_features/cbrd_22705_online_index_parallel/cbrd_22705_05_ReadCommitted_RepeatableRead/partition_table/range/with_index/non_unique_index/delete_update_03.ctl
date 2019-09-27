/*
Test Case: delete & update
Priority: 1
Reference case:
Author: Rong Xu

Test Plan:
Test UPDATE/DELETE locks (X_LOCK on instance)

Test Point:
C1 delete 1, C2 update 1 to 11

NUM_CLIENTS = 2
C1: UPDATE t SET id=11 where id=1;
C2: DELETE FROM t WHERE id=1; --expected blocked
*/

MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level repeatable read;

C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level repeatable read;


/* preparation */
C1: DROP TABLE IF EXISTS t;
C1: create table t(id int,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: create index idx on t(id) with online parallel 3;
C1: INSERT INTO t VALUES(1,'abc');INSERT INTO t VALUES(12,'edf');
C1: COMMIT WORK;
MC: wait until C1 ready;

C1: describe t;
MC: wait until C1 ready;

C2: create index idx1 on t(id desc,col desc) with online parallel 2;
MC: wait until C2 blocked;

/* test case */
C3: select * from t order by 1;
MC: wait until C3 blocked;

C1: DELETE FROM t WHERE id=1;
MC: wait until C1 ready;

C4: UPDATE t SET id=1 where id=12;
MC: wait until C4 blocked;

C1: commit;
MC: wait until C1 ready;
MC: wait until C2 unblocked;


MC: wait until C3 ready;
MC: wait until C4 ready;

/* expect (1,'edf') */
C4: select * from t order by 1;
C4: commit;
MC: wait until C2 ready;

C3: commit;
MC: wait until C3 ready;

C2: show index from t;
C2: commit;

C1: quit;
C2: quit;
C3: quit;
C4: quit;
