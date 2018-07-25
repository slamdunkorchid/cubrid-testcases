drop if exists t1;
CREATE TABLE t1 ( 
ts TIMESTAMP DEFAULT '2018-7-25' ON UPDATE CURRENT_TIMESTAMP,
dt DATETIME DEFAULT '2018-7-25' ON UPDATE CURRENT_TIMESTAMP
);
desc t1;

drop if exists t1;
CREATE TABLE t1 (
  ts1 TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,     
  ts2 TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);
desc t1;


drop if exists t1;
CREATE TABLE t1 (
  dt1 DATETIME ON UPDATE CURRENT_TIMESTAMP,         
  dt2 DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP 
);
desc t1;

drop if exists t1;
CREATE TABLE t1 (
  dt1 DATETIME ON UPDATE CURRENT_TIMESTAMP,         
  dt2 DATETIME NOT NULL ON UPDATE systimestamp
);
desc t1;



drop if exists t1;
CREATE TABLE t1 (
a int default 0,
ts TIMESTAMP DEFAULT '2018-7-25' ON UPDATE CURRENT_TIMESTAMP,
dt DATETIME DEFAULT '2018-7-25' ON UPDATE sys_TIMESTAMP
);
desc t1;
insert into t1(ts,dt) values(default,default);
select * from t1;
update t1 set a=1;
select * from t1;

drop if exists t;
create table t(
username varchar(10) unique,
text varchar(100),
edit_time datetime on update current_datetime default current_datetime
)
desc t;


drop if exists t;
  create table t(
username varchar(10) unique,
text varchar(100),
edit_time timestamp on update current_datetime default current_timestamp
)



drop if exists t;
  create table t(
username varchar(10) unique,
text varchar(100),
edit_time timestamp on update current_timestamp default current_datetime
);
desc t;


drop if exists t;
  create table t(
username varchar(10) unique,
text varchar(100),
edit_time timestamp on update now() default current_datetime
);
desc t;
