/*
Test Case: delete & insert
Priority: 1
Reference case:
Author: Rong Xu

Test Point:
A target record may be already locked and modified (updated or deleted) by another transaction. In this case:
1. current transaction will wait for the first updating transaction to commit or rollback
one user insert and then delete in-place, another user insert the same row

NUM_CLIENTS = 2
C1: insert(1)
C2: insert(1) --blocked
C1: delete(1)
C1: commit
check C2 insert successfully
*/

MC: setup NUM_CLIENTS = 2;

C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;

C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;

/* preparation */
C1: drop table if exists t;
C1: create table t(id int primary key,col varchar(10)) partition by range(id)(partition p1 values less than (10),partition p2 values less than (100));
C1: commit work;
MC: wait until C1 ready;

/* test case */
C1: insert into t values(1,'abc');
MC: wait until C1 ready;

C2: insert into t values(1,'abc');
MC: wait until C2 blocked;
C1: delete from t where id=1;
C1: commit work;
MC: wait until C1 ready;

MC: wait until C2 ready;
C2: commit;
C2: select * from t order by 1;
C2: commit;
MC: wait until C2 ready;


C2: quit;
C1: quit;

