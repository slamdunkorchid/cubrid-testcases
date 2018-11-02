MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level read committed;

/* preparation */
C1: DROP TABLE IF EXISTS t1;
C1: create table t1 (a int default 0,b int default 10,c bigint default 20);
C1: insert into t1(c) values (1),(2),(3),(4),(5);
C1: COMMIT;
MC: wait until C1 ready;

/* transaction mix */

/* This dummy "describe" is important to guarantee that online index build does not complete before other transaction starts and others have chances before index build completes */
C1: describe t1;
MC: wait until C1 ready;

C2: create index i on t1(b,c) with online;
MC: wait until C2 blocked;

C3: insert into t1(b,c) values (-1,-1);
MC: wait until C3 blocked;

C4: update t1 set c = 6 where c = 5;
MC: wait until C4 blocked;

C1: commit;
MC: wait until C2 unblocked;

/* C2 starts scan and will demote to IX. C3 and C4 will resume */

MC: wait until C3 ready;
MC: wait until C4 ready;

/* C2 should be blocked to promote to SCH_M */
MC: wait until C2 blocked;

C3: commit;
MC: wait until C3 ready;

C4: commit;
MC: wait until C4 ready;

MC: wait until C2 ready;
C2: commit;

MC: wait until C2 ready;

/* verification */
C1: select sum(set{c}) into :s from t1 ignore index (i) where b > -999 order by 1;
C1: select sum(set{c}) into :i from t1 force index (i) where b > -999 order by 1;
C1: select if (:s = :i, 'OK', 'NOK');
C1: show index from t1;
MC: wait until C1 ready;

/* exit */
C1: DROP table t1;
C1: commit;

C1: quit;
C2: quit;
C3: quit;
C4: quit;
