/*
Test Case: delete & insert
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
If a transaction updates its own inserted record. The record is only visible to its owner until it is committed,
therefore no other transaction can read/modify it
one user insert, another delete rows include the inserted row

NUM_CLIENTS = 2
prepare (3,7)
C2: begin
C1: insert (5) and commit;
C2: delete from t where id<=5; --ready, didn't delete 5
C2: select  -- can not see C1's commit  
C2: commit -- now can see C1's commit
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int primary key,col varchar(10));
C1: insert into t values(3,'abc');
C1: insert into t values(7,'abc');
C1: commit work;

MC: wait until C1 ready;

/* test case */
/* expect id value: 3,7 */
C2: select * from t order by 1;
MC: wait until C2 ready;
C1: insert into t values(5,'abc');
C1: commit;
MC: wait until C1 ready;
C2: delete from t where id<=5;
MC: wait until C2 ready;

/* expect id value: 7 */
C2: select * from t order by 1;
C2: commit;
/* expect id value: 5,7 */
C2: select * from t order by 1;
C2: commit;

C2: quit;
C1: quit;

