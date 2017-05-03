drop if exists u,t;
CREATE TABLE t(i int PRIMARY KEY, j int, k int);
CREATE TABLE u(i int, j int, k int);
ALTER TABLE u ADD constraint fk_t_u_i FOREIGN KEY(i) REFERENCES t(i);
CREATE INDEX i_u_j ON u(j);
INSERT INTO t SELECT ROWNUM, ROWNUM, ROWNUM FROM db_root connect by level<=100;
INSERT INTO u SELECT 1+(ROWNUM % 100), ROWNUM, ROWNUM FROM db_root connect by level<=500;
update u, t set u.j=12340 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12341 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 0, 5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12342 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-2,5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12343 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-1,5*1;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12344 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-1,10/2;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12345 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12346 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 0, 5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12347 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-2,5;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12348 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-1,5*1;
select * from u where u.j > 10 limit 10;
update u, t set u.j=12349 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-1,10/2;
select * from u where u.j > 10 limit 10;
update u, t set u.j=123410 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT 2-1,10/2;
select * from u where j=12340;
select * from u where j=12341;
select * from u where j=12342;
select * from u where j=12343;
select * from u where j=12344;
select * from u where j=12345;
select * from u where j=12346;
select * from u where j=12347;
select * from u where j=12348;
select * from u where j=12349;
select * from u where j=123410;
prepare stmt from 'update u, t set u.j=2341 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT ?-?,?/?';
execute stmt using 2,1,10,2;
prepare stmt from 'update u, t set u.j=2342 WHERE u.i = t.i AND u.j > 10 using index i_u_j keyLIMIT ?-?,?*?';
execute stmt using 2,1,5,1;
deallocate prepare stmt;
select * from u where j=2341;
select * from u where j=2342;
drop if exists u,t;
