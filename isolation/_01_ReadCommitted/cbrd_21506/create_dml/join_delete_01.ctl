MC: setup NUM_CLIENTS = 4;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;


/* preparation */
C1: DROP TABLE IF EXISTS t1,t2;
C1: create table t1(i int primary key,j char(10),k int);
C1: create table t2(m int ,n int unique);
C1: insert into t1 select rownum,rownum,rownum from db_root connect by level<=10;
C1: insert into t2 values(10,1),(11,2),(12,3),(13,4);
C1: COMMIT;
MC: wait until C1 ready;

/* transaction mix */

/* This dummy "describe" is important to guarantee that online index build does not complete before other transaction starts and others have chances before index build completes */
C1: describe t1;
MC: wait until C1 ready;

C2: create index a on t1(k) with online;
MC: wait until C2 blocked;

C3: delete t1 from t1 inner join t2 on t1.k=t2.n;
MC: wait until C3 blocked;

C1: commit;
MC: wait until C2 unblocked;

MC: wait until C3 ready;
C3: commit;
MC: wait until C3 ready;

MC: wait until C2 ready;
C2: commit;
MC: wait until C2 ready;

/* verification */
C1: select sum({k}) into :s from t1 ignore index (a) where k > 0 order by 1;
C1: select sum({k}) into :i from t1 force index (a) where k > 0 order by 1;
C1: select if (:s = :i, 'OK', 'NOK');
C1: show index from t1;
MC: wait until C1 ready;

/* exit */
C1: DROP table t1;
C1: DROP table t2;
C1: commit;

C1: quit;
C2: quit;
C3: quit;
