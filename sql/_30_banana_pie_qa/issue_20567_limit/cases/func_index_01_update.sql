drop table if exists t;
create table t(col1 int,col2 varchar(20),col3 date);
insert into t values(1,'book1','2007-12-24');
insert into t values(2,'book2','2008-12-24');
insert into t values(3,'book3','2009-12-24');
insert into t values(4,'book4','2010-12-24');
insert into t values(5,'book2','2008-12-24');
insert into t values(6,'book2','2011-12-24');
insert into t values(7,'book5','2008-12-24');
CREATE INDEX idx1 ON t(year(col3));
CREATE INDEX idx2 ON t(col2);
CREATE INDEX idx3 ON t(year(col3),col2);
SELECT /*+ recompile */* FROM t WHERE year(col3)=2008 and col2='book2' ;
update t set col2='updated' WHERE year(col3)=2008 and col2='book2' using index idx1(+) keylimit 0+0+0+0+0+0+0,1-1+1;
select * from t order by 1,2,3;

update t set col2='updated' WHERE year(col3)=2008 and col2='book2' using index idx2(+) keylimit 2-(2*1),1;
select * from t order by 1,2,3;
update t set col2='updated' WHERE year(col3)=2008 or col2='book2' using index idx2(+) keylimit 1*(2-2),3;
select * from t order by 1,2,3;
update t set col2='updated' WHERE year(col3)=2008 or col2='book2' using index idx1(+) keylimit 0,3;
prepare stmt from 'update t set col2=? WHERE year(col3)=2008 or col2=? using index idx2(+) keylimit ?*(?-?),?';
execute stmt using 'updated','book2', 1,2,2,3;
select * from t order by 1,2,3;
drop table if exists t;
