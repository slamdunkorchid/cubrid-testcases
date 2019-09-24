
MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;


/* preparation */
C1: drop table if exists t;
C1: create table t(id bigint primary key, a char(10), b varchar(10), c timestamp default current_timestamp, d datetime default current_datetime);
C1: insert into t(id,a,b) select rownum,rownum,rownum from db_root connect by level<=100;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: create unique index idx1 on t(a asc,b desc,c asc,d desc) with online parallel 2;
MC: wait until C1 ready;
C2: insert into t values (10,'a','b','2000-01-01 18:00:00','2000-01-01 18:00:00') on duplicate key update id=id+1000;
MC: wait until C2 blocked;
C1: commit;
C1: update statistics on t;
C1: show indexes from t;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;
C1: update statistics on t;
C1: show indexes from t;
C1: select * from t where id=10 or id=1010;
C1: commit work;

C2: quit;
C1: quit;

