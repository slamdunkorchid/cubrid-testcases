-- create vclass for created class with three int data type auto_increment field,insert data to this class,select data from this class,insert data to this class by specify the auto_increment field,select data from this class,drop class 

create class xoo ( id int auto_increment ,
		   id2 int auto_increment,
		   id3 int auto_increment,
                   title varchar(100));

insert into xoo(title) values ('aaa');
insert into xoo(title) values ('bbb');
insert into xoo(title) values ('ccc');

select * from xoo order by 1;

insert into xoo(id, id2,id3, title) values (10,10,10,'qqq');
insert into xoo(id, id2,id3, title) values (11,11,11,'www');
insert into xoo(id, id2,id3, title) values (12,12,12,'eee');

select * from xoo order by 1;

insert into xoo(title) values ('ddd');

select * from xoo order by 1;
create vclass vxoo (
	id int, 
	id2 decimal(10,0),
	id3 numeric(10,0),
	title varchar(100)
) as select * from xoo;

select * from vxoo;

drop vclass vxoo;
drop class xoo;
