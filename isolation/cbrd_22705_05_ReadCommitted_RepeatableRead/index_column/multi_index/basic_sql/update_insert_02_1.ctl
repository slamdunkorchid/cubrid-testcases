/*
Test Case: update & insert
Priority: 1
Reference case: 
Author: Rong Xu

Test Point:
-    Insert: X_LOCK on first key OID for unique indexes. 
-    Update: X_LOCK acquired on current instance 
there are overlap between C1 and C2
two index, unique index and non unique index

NUM_CLIENTS = 2
C1: update t set id=id||'a' where id>0 and 0=(select sleep (1)) using index idx;
C2: insert into t select rownum,rownum ||'a' from t where id>0 where rownum <= 3; --expected blocked
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10) unique);
C1: create index idx on t(id) with online parallel 3;
C1: insert into t values(4,'a');
C1: insert into t values(5,'d');
C1: insert into t values(6,'3');
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: update t set col=col||'a' where id>0 and sleep(1)=0;
MC: sleep 1;
C2: insert into t select rownum,rownum ||'a' from t where id>0 and rownum <= 3;
MC: wait until C2 ready;
MC: wait until C1 blocked;
C2: rollback;
MC: wait until C1 ready;

/* expect (4,aa)(5,da)(6,3a) */
C1: select * from t order by 1,2;
C1: commit work;
MC: wait until C1 ready;

/* expect (4,a)(5,d)(6,3a) */
C2: select * from t order by 1,2;
C2: commit;
MC: wait until C2 ready;

C1: quit;
C2: quit;

