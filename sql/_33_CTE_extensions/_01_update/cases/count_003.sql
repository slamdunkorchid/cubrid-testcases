drop table if exists A;
CREATE TABLE A(col_int int,pk int primary key,col_int_key int);
CREATE INDEX idx_a_col_int_key ON a (col_int_key) with online;
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,1,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,2,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,3,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(7,4,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,5,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,6,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,7,2);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,8,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,9,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,10,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,11,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(7,12,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,13,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,14,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,15,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,16,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,17,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,18,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,19,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,20,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,21,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,22,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,23,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(7,24,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,25,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,26,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,27,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(7,28,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,29,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,30,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,31,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,32,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,33,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,34,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,35,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,36,2);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,37,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,38,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,39,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,40,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,41,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,42,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,43,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,44,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,45,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,46,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,47,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,48,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,49,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,50,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,51,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,52,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,53,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,54,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,55,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,56,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,57,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,58,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,59,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,60,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,61,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,62,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,63,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,64,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,65,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,66,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,67,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,68,9);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,69,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,70,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,71,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,72,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,73,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,74,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,75,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,76,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,77,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,78,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,79,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,80,4);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,81,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,82,6);
INSERT INTO A(col_int,pk,col_int_key) VALUES(2,83,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,84,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(0,85,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,86,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,87,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,88,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,89,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(3,90,0);
INSERT INTO A(col_int,pk,col_int_key) VALUES(1,91,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(7,92,2);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,93,2);
INSERT INTO A(col_int,pk,col_int_key) VALUES(9,94,7);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,95,1);
INSERT INTO A(col_int,pk,col_int_key) VALUES(5,96,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,97,8);
INSERT INTO A(col_int,pk,col_int_key) VALUES(4,98,3);
INSERT INTO A(col_int,pk,col_int_key) VALUES(8,99,5);
INSERT INTO A(col_int,pk,col_int_key) VALUES(6,100,6);
drop table if exists b;
create table b(i int,j char(10));
insert into b values(1,1);
insert into b values(68,1),(3,1);
with cte1(cn) as
(
SELECT count(*) FROM A WHERE col_int_key != 3 AND pk BETWEEN 1 AND 1 + 3 AND 
col_int_key BETWEEN 1 AND 1 + 7 OR col_int_key BETWEEN 1 AND 1 + 7 AND col_int_key <> 3
) update b set i=(select cn from cte1);

SELECT count(*) FROM A WHERE col_int_key != 3 AND pk BETWEEN 1 AND 1 + 3 AND
col_int_key BETWEEN 1 AND 1 + 7 OR col_int_key BETWEEN 1 AND 1 + 7 AND col_int_key <> 3;
select * from b order by 1 limit 10;

drop view if exists v1;
create view v1 as select col_int from A;

with cte1(cn) as
(
SELECT count(*) FROM A WHERE col_int_key BETWEEN 1 AND 1 + 7 AND col_int_key <> 3
) update v1 set col_int=(select cn from cte1);
SELECT count(*) FROM A WHERE col_int_key BETWEEN 1 AND 1 + 7 AND col_int_key <> 3;

select * from v1 order by 1 limit 10;

insert into b values(3,1);
with cte1(cn) as
(
SELECT count(*) FROM A WHERE col_int_key != 3 AND pk BETWEEN 1 AND 1 + 3 AND col_int_key BETWEEN 1 AND 1 + 7
) update b inner join cte1 on i=cn set j=cn;

SELECT count(*) FROM A WHERE col_int_key != 3 AND pk BETWEEN 1 AND 1 + 3 AND col_int_key BETWEEN 1 AND 1 + 7;

select * from b order by 1;
drop table if exists A;
