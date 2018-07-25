drop if exists u01;
create table u01
(id int primary key, 
col1 timestamp default CURRENT_TIMESTAMP unique, 
col2 timestamp default CURRENT_TIMESTAMP on update current_timestamp not null, 
col3 timestamp default CURRENT_TIMESTAMP on update current_timestamp, 
col4 timestamp default CURRENT_TIMESTAMP
);

insert into u01 values(1, timestamp'12/12/2000 12:12:12', '12/12/2000 12:12:12', '12/12/2000 12:12:12', '12/12/2000 12:12:12');
insert into u01 values(2, timestamp'11/11/2000 11:11:11', '11/11/2000 11:11:11', '11/11/2000 11:11:11', '11/11/2000 11:11:11');
insert into u01 values(3, timestamp'10/10/2000 10:10:10', '10/10/2000 10:10:10', '10/10/2000 10:10:10', '10/10/2000 10:10:10');
insert into u01 values(4, timestamp'09/09/2000 09:09:09', '09/09/2000 09:09:09', '09/09/2000 09:09:09', '09/09/2000 09:09:09');
insert into u01 values(5, timestamp'08/08/2000 08:08:08', '08/08/2000 08:08:08', '08/08/2000 08:08:08', '08/08/2000 08:08:08');

update u01 set col2=default;
select if ((SYSTIMESTAMP - col2) >=0 && (col2-timestamp'12/12/2000 12:12:12')>0, 'ok', 'nok') from u01;
select if ((SYSTIMESTAMP - col3) >=0 && (col3-timestamp'12/12/2000 12:12:12')>0, 'ok', 'nok') from u01;
set @a=(select col3 from u01 where id=1);
update u01 set col1=default where id=1;
select sleep(2);
select if ((SYSTIMESTAMP - col1) >0 && (col1-@a)>0, 'ok', 'nok') from u01 where id=1;
select if ((SYSTIMESTAMP - col2) >0 && (col2-@a)>0, 'ok', 'nok') from u01 where id=1;
select if ((SYSTIMESTAMP - col3) >0 && (col3-@a)>0, 'ok', 'nok') from u01 where id=1;
set @b=(select current_timestamp);
set @c=(select col3 from u01 where id=1);
update u01 set col2=default where id > 1 order by id desc;
select sleep(2);
select if ((SYSTIMESTAMP - col2) >0 && (col2-@b)>0, 'ok', 'nok') from u01 where id>1;
select if ((SYSTIMESTAMP - col3) >0 && (col3-@b)>0, 'ok', 'nok') from u01 where id>1;
select if ((@c - col2) =0 && (@c - col3) =0, 'ok', 'nok') from u01 where id=1;

drop table u01;
drop variable @a;
drop variable @b;
drop variable @c;



