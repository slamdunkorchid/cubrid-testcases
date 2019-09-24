
MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;


/* preparation */
C1: drop table if exists t2;
C1: drop table if exists t1;
C1: create table t1(id int primary key, col1 varchar(30));
C1: insert into t1 values(1,'james'),(2,'mikey'),(3,'lucy');
C1: create table t2(id bigint primary key ,col1 varchar(10),col2 int, constraint foreign key(col2) references t1(id));
C1: insert into t2 select rownum,rownum,1 from db_root connect by level<=10;
C1: insert into t2 select rownum+20,rownum+20,2 from db_root connect by level<=10;
C1: insert into t2 select rownum+40,rownum+40,3 from db_root connect by level<=10;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: insert into t1 values(4,'bob');
C1: update t2 set col2=4 where id>40;
MC: wait until C1 ready;
C2: create index idx_t2_col1_col2 on t2(col1 asc,col2 desc) with online parallel 2;
MC: wait until C2 blocked;
C1: commit;
MC: wait until C1 ready;
MC: wait until C2 ready;
C2: show indexes from t2;
C2: commit;
MC: wait until C2 ready;
C1: set optimization level 513;
C1: select /*+ recompile */ * from t2 where col1>40 and col2 >3 order by 2 asc,3 desc;
C1: commit work;
MC: wait until C1 ready;
C2: commit;

C2: quit;
C1: quit;

