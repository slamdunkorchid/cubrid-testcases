/*
Test Case: insert & select
Priority: 2
Reference case: cc_basic/_01_ReadCommitted/index_column/common_index/basic_sql/insert_select_16.ctl
Author: Rong Xu

Test Point:
Reading queries can only have a look at data committed before the queries began
changes committed after the query started are never seen
combination
 a) some user committed before the query begin
 b) some begin before the select begin, but commit after the select begin
 c) some begin before the select begin, commit after the select end
 d) some begin after the select begin, commit before the select end
 e) some begin after the select begin, commit after the select end

NUM_CLIENTS = 6
prepare(1,3,7)
*/

MC: setup NUM_CLIENTS = 6;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

C3: set transaction lock timeout INFINITE;
C3: set transaction isolation level read committed;

C4: set transaction lock timeout INFINITE;
C4: set transaction isolation level read committed;

C5: set transaction lock timeout INFINITE;
C5: set transaction isolation level read committed;

C6: set transaction lock timeout INFINITE;
C6: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int,col varchar(10));
C1: create index idx on t(id,col) with online parallel 2;
C1: insert into t values(1,'aa');
C1: insert into t values(3,'bb');
C1: insert into t values(7,'aa');
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: insert into t select * from t;
MC: wait until C1 ready;
C5: insert into t select * from t where id>0;
MC: wait until C5 ready;
C1: commit;
MC: wait until C1 ready;
C2: insert into t values(8,'aa');
MC: wait until C2 ready;
C6: select * from t where id>0 and col='aa' order by id;
MC: wait until C6 ready;
C3: insert into t values(3,'aa');
MC: wait until C3 ready;
C2: commit;
MC: wait until C2 ready;
C3: commit;
MC: wait until C3 ready;
C4: insert into t select * from t where id>0;
MC: wait until C4 ready;
C6: commit;
MC: wait until C6 ready;
C4: commit;
MC: wait until C4 ready;
C5: commit;
MC: wait until C5 ready;

C1: select * from t order by 1,2;
C1: commit;

C6: quit;
C5: quit;
C4: quit;
C3: quit;
C2: quit;
C1: quit;

