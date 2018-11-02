MC: setup NUM_CLIENTS = 3;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;


/* preparation */
C1: DROP TABLE IF EXISTS t;
C1: create table t(i int primary key,j char(10),k int);
C1: insert into t select rownum,rownum,rownum from db_root connect by level<=10;
C1: COMMIT;
MC: wait until C1 ready;

/* transaction mix */

/* This dummy "describe" is important to guarantee that online index build does not complete before other transaction starts and others have chances before index build completes */
C1: describe t;
MC: wait until C1 ready;

C2: create index a on t(k) with online;
MC: wait until C2 blocked;

C3: delete from t where k in (3,4,5,6);
MC: wait until C3 blocked;

C1: commit;
MC: wait until C2 unblocked;

/* C2 starts scan and will demote to IX. C3 and C4 will resume */

MC: wait until C3 ready;

/* C2 should be blocked to promote to SCH_M */
MC: wait until C2 blocked;

C3: commit;
MC: wait until C3 ready;


MC: wait until C2 ready;
C2: commit;

MC: wait until C2 ready;

/* verification */
C1: select sum(set{k}) into :s from t ignore index (a) where k > -999 order by 1;
C1: select sum(set{k}) into :i from t force index (a) where k > -999 order by 1;
C1: select if (:s = :i, 'OK', 'NOK');
MC: wait until C1 ready;

/* exit */
C1: DROP table t;
C1: commit;

C1: quit;
C2: quit;
C3: quit;
