/*
Test Case: related to CUBRIDSUS-13960 ( insert is blocked )  
Priority: 1
Reference case:
Author: Lily

Test Point:
C1: insert into foo values (1,1);
C2: insert into foo values (1,2); --blocked, Expected is that C2 succeed to insert.
*/

/* preparation */
MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level read committed;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level read committed;
C2: commit;

C1: drop table if exists foo; 
C1: create table foo (a int, b int);
C1: insert into foo values (1,0);
C1: create index idx1 on foo (a) with online parallel 2;
C1: commit;
MC: wait until C1 ready;

/* test case */
C1: insert into foo values (1,1);
MC: wait until C1 ready;
C2: insert into foo values (1,2);
MC: wait until C2 ready;
C2: select * from foo order by 1,2;
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;

C1: set transaction isolation level repeatable read;
C1: drop table if exists foo;
C1: create table foo (a int, b int);
C1: insert into foo values (1,0);
C1: create index idx1 on foo (a) with online parallel 2;
C1: commit;
MC: wait until C1 ready;

C2: set transaction isolation level repeatable read;
C2: commit;
MC: wait until C2 ready;

/* test case */
C1: insert into foo values (1,1);
MC: wait until C1 ready;
C2: insert into foo values (1,2);
MC: wait until C2 ready;
C2: select * from foo order by 1,2;
MC: wait until C2 ready;

C1: commit;
MC: wait until C1 ready;
C2: commit;
MC: wait until C2 ready;

C2: quit;
C1: quit;
