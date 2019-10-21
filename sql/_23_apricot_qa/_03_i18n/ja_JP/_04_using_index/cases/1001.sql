--+ holdcas on;
set names utf8;
CREATE TABLE test_jp ( 
  id     int    NOT NULL, 
  name      VARCHAR(20) collate utf8_ja_exp);
  
insert into test_jp values (1,'ぁはァヰン');
insert into test_jp values (2,'ぁはァヰ■'); 
insert into test_jp values (3,'Qdぁ1');
insert into test_jp values (103,'Qdぁ1');
insert into test_jp values (203,'Qdぁ=');
insert into test_jp values (303,'Qdぁ=.Qddヰ亜愛Qン');
insert into test_jp values (403,'Qdぁ1 =師師ヰ亜亜Qン');
insert into test_jp values (4,'Qd発は');
insert into test_jp values (104,'=d発は');
insert into test_jp values (5,'Qddヰ亜愛Qン'); 
insert into test_jp values (105,'=卍卍ヰ亜亜Qン');
insert into test_jp values (205,'=ぁぁヰ亜亜Qン'); 
insert into test_jp values (6,'麼は樹■沢ン');
insert into test_jp values (106,'%麼は樹■沢ン'); 
insert into test_jp values (7,'麼は樹■沢ン');
insert into test_jp values (107,'_麼は樹■沢ン');
insert into test_jp values (8,'=d発は');
insert into test_jp values (9,'Qァ遠沢ン');
insert into test_jp values (109,'?Qァ遠沢ン');
insert into test_jp values (10,'Qdぁ實');
insert into test_jp values (110,'*Qdぁ實');
create index i_test_jp_name on test_jp (name);


select id,name from test_jp
where
   (name between 'Qdぁ=' and 'Qd発は')
   or (name between 'Qdぁ1' and 'Qd発は')
   or (name > 'Qd語' and name < 'Qd発は')
using index i_test_jp_name(+) order by 2,1;



drop test_jp;
set names iso88591;
commit;
--+ holdcas off;
