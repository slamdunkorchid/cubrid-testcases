 create table t(a int ,b timestamp default current_timestamp on update current_timestamp);
 create table t2 like t;
 insert t(a) values(1),(2),(3),(4);
 insert t2(a) values(1),(2),(3),(4);
 select * from t;
 select * from t2;
 update t set a=a+1;
 select * from t;
 update t2 set a=1;
 select * from t2;


 drop if exists t,t2;
 create table t(a int primary key,b timestamp default current_timestamp on update current_timestamp);
 create table t2 like t;
 insert t(a) values(1),(2),(3),(4);
 insert t2(a) values(1),(2),(3),(4);
 select * from t;
 select * from t2;
 update t set a=a+1;
 select * from t;
 update t2 set a=1;
 select * from t2;

  drop if exists t,t2;
 create table t(a int unique,b timestamp default current_timestamp on update current_timestamp);
 create table t2 like t;
 insert t(a) values(1),(2),(3),(4);
 insert t2(a) values(1),(2),(3),(4);
 select * from t;
 select * from t2;
 update t set a=a+1;
 select * from t;
 update t2 set a=1;
 select * from t2;

 drop if exists t,t2;
 create table t(a int unique,b timestamp default cast('2018-7-25 13:25:00' as timestamp) on update current_timestamp);
 create table t2 like t;
 insert t(a) values(1),(2),(3),(4);
 insert t2(a) values(1),(2),(3),(4);
 select * from t;
 select * from t2;
 update t set a=a+1;
 select * from t;
 update t2 set a=1;
 select * from t2;
 
