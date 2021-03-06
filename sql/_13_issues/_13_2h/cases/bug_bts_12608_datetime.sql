--test cases from qa

--test: datetime type column with function as default value
--1. NOW()
drop table if exists t1;
create table t1(
a int primary key,
b int,
c datetime default NOW()
);

merge into t1 A
using db_root B on (A.a=1)
WHEN MATCHED THEN UPDATE SET c=default
WHEN NOT MATCHED THEN INSERT (A.a, A.b) VALUES(1, 1);

select a, b from t1 order by 1; 

--2. CURRENT_DATETIME()
drop table if exists t1;
create table t1(
a int primary key,
b int,
c datetime default CURRENT_DATETIME()
);

merge into t1 A
using db_root B on (A.a=1)
WHEN MATCHED THEN UPDATE SET c=default
WHEN NOT MATCHED THEN INSERT (A.a, A.b) VALUES(1, 1);

select a, b from t1 order by 1; 

--3. CURRENT_DATETIME
drop table if exists t1;
create table t1(
a int primary key,
b int,
c datetime default CURRENT_DATETIME
);

merge into t1 A
using db_root B on (A.a=1)
WHEN MATCHED THEN UPDATE SET c=default
WHEN NOT MATCHED THEN INSERT (A.a, A.b) VALUES(1, 1);

select a, b from t1 order by 1; 

--4. SYS_DATETIME
drop table if exists t1;
create table t1(
a int primary key,
b int,
c datetime default SYS_DATETIME
);

merge into t1 A
using db_root B on (A.a=1)
WHEN MATCHED THEN UPDATE SET c=default
WHEN NOT MATCHED THEN INSERT (A.a, A.b) VALUES(1, 1);

select a, b from t1 order by 1; 

--5. SYSDATETIME
drop table if exists t1;
create table t1(
a int primary key,
b int,
c datetime default SYSDATETIME
);

merge into t1 A
using db_root B on (A.a=1)
WHEN MATCHED THEN UPDATE SET c=default
WHEN NOT MATCHED THEN INSERT (A.a, A.b) VALUES(1, 1);

select a, b from t1 order by 1; 

drop table t1;

