-- create hash partition table on a date field with size 2 and query all partition about this table 

create table hash_test(id int,	
			   test_time time,
			   test_date date,
			   test_timestamp timestamp, primary key(id,test_date))
	PARTITION BY HASH(test_date)
        PARTITIONS 2;

select * from db_class where class_name like 'hash%';


drop table hash_test;
