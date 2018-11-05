--pass unmatched types or formats of values


create class coo(
        col1 char(20),
        col2 nchar(20),
        col3 nchar varying(20),
        col4 bit(8),
        col5 bit varying(8),
        col6 numeric,
        col7 integer,
        col8 smallint,
        col9 monetary,
        col10 float,
        col11 double,
        col12 date,
        col13 time,
        col14 timestamp,
        col15 set,
        col16 multiset,
        col17 sequence,
        col18 blob,
        col19 clob,
	col20 datetime,
	col21 bigint
);
create index aa on coo(col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col20,col21) with online;

insert into coo (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14,col15, col16, col17, col18, col19, col20, col21)
 values('aaa', n'aaa', n'aaa', b'0011', b'0011', 10, 11, 12, 13, 14, 15, '1/1/2008', '1:1:1 pm', '01/31/1994 8:15:00 pm', {10, 20}, {'abc','def'}, {50,60,70}, bit_to_blob(B'000010'), char_to_clob('character'), '2010-10-01 1:10:11', 20102020202);

insert into coo (col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14,col15, col16, col17, col18, col19, col20, col21)
 values('bbb', n'bbb', n'bbb', b'1011', b'1010', 20, 21, 22, 23, 24, 25, '5/7/2010', '8:40:22 pm', '05/20/1985 8:15:00 pm', {11, 22}, {'ghj','yut'}, {80,90,100}, bit_to_blob(B'11100010'), char_to_clob('string'), '2022-11-12 12:12:12', 234930303);

show columns in coo;

--error, unmatched type
select var_samp(col1) from coo order by 1;
--error, unmatched type
select var_samp(col2) from coo order by 1;
--error, unmatched type
select var_samp(col3) from coo order by 1;
--error, unmatched type
select var_samp(col4) from coo order by 1;
--error, unmatched type
select var_samp(col5) from coo order by 1;
--error, unmatched type
select var_samp(col6) from coo order by 1;
--0, integer
select var_samp(col7) from coo order by 1;
--0, smallint
select var_samp(col8) from coo order by 1;
--0, monetary
select var_samp(col9) from coo order by 1;
--0, float
select var_samp(col10) from coo order by 1;
--0, double
select var_samp(col11) from coo order by 1;
--error, unmatched type
select var_samp(col12) from coo order by 1;
--error, unmatched type
select var_samp(col13) from coo order by 1;
--error, unmatched type
select var_samp(col14) from coo order by 1;
--error, unmatched type
select var_samp(col15) from coo order by 1;
--error, unmatched type
select var_samp(col16) from coo order by 1;
--error, unmatched type
select var_samp(col17) from coo order by 1;
--error, unmatched type
select var_samp(col18) from coo order by 1;
--error, unmatched type
select var_samp(col19) from coo order by 1;
--error, unmatched type
select var_samp(col20) from coo order by 1;
--0, bigint
select var_samp(col21) from coo order by 1;


delete from coo;
drop table coo;


