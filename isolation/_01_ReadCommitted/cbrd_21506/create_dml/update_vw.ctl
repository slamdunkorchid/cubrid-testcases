MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS tbl1,tbl2;
C1: CREATE TABLE tbl1(a INT, b INT);
C1: CREATE TABLE tbl2(a INT, b INT);
C1: INSERT INTO tbl1 VALUES (5,5),(4,4),(3,3),(2,2),(1,1);
C1: INSERT INTO tbl2 VALUES (6,6),(4,4),(3,3),(2,2),(1,1);
C1: CREATE VIEW vw AS SELECT tbl2.* FROM tbl2 LEFT JOIN tbl1 ON tbl2.a=tbl1.a WHERE tbl2.a<=3;
C1: COMMIT;
MC: wait until C1 ready;

/* transaction mix */

/* This dummy "describe" is important to guarantee that online index build does not complete before other transaction starts and others have chances before index build completes */
C1: describe tbl2;
MC: wait until C1 ready;

C2: create index a on tbl2(a desc,b desc) with online;
MC: wait until C2 blocked;

C3: update vw set a=1000;
MC: wait until C3 blocked;

C4: delete  from tbl2 where a<2;
MC: wait until C4 blocked;

C1: commit;
MC: wait until C2 unblocked;

MC: wait until C4 ready;
C4: commit;
MC: wait until C4 ready;

MC: wait until C3 ready;
C3: commit;
MC: wait until C3 ready;

C2: commit;
MC: wait until C2 ready;


/* verification */
C1: select a from tbl2 ignore index (a) where a > 0 order by 1;
C1: select a from tbl2 force index (a) where a > 0 order by 1;
C1: show index from tbl2;
C1: select * from tbl1 order by 1,2;
MC: wait until C1 ready;

/* exit */
C1: DROP table tbl1;
C1: DROP table tbl2;
C1: commit;

C1: quit;
C2: quit;
C3: quit;
C4: quit;
