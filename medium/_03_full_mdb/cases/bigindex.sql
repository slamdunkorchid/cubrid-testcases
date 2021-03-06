autocommit off;
create table bbigg(a int, b varchar(40));
create table mmedd(a int, b varchar(40));
grant all on bbigg to public;
grant all on mmedd to public;
insert into bbigg values (0,'zero');
insert into bbigg values (1,'one');
insert into bbigg values (2,'two');
insert into bbigg values (3,'three');
insert into bbigg values (4,'four');
insert into bbigg values (5,'five');
insert into bbigg values (6,'six');
insert into bbigg values (7,'seven');
insert into bbigg values (8,'eight');
insert into bbigg values (9,'nine');
insert into bbigg select 10  +a, '1' +b from bbigg;
insert into bbigg select 20  +a, '2' +b from bbigg;
insert into bbigg select 40  +a, '4' +b from bbigg;
insert into bbigg select 100  +a, '8' +b from bbigg;
insert into bbigg select 200 +a, 'a' +b from bbigg;
insert into bbigg select 400 +a, 'b' +b from bbigg;
insert into bbigg select 1000 +a, 'c' +b from bbigg;
insert into mmedd select a, b from bbigg;
commit work;
insert into bbigg select 2000 +a, 'd' +b from bbigg;
insert into bbigg select 4000 +a, 'E' +b from bbigg;
insert into bbigg select 10000 +a, 'F' +b from bbigg;
insert into bbigg select 20000 +a, 'G' +b from bbigg;
insert into bbigg select 40000 +a, 'H' +b from bbigg;
commit work;
update statistics on bbigg;
update statistics on mmedd;
create table bbiggindex(a int, b char(40));
create table mmeddindex(a int, b char(40));
insert into bbiggindex select * from bbigg;
insert into mmeddindex select * from mmedd;
create index i_bbiggindex_a on bbiggindex(a);
create index i_bbiggindex_b on bbiggindex(b);
create index i_mmeddindex_a on mmeddindex(a);
create index i_mmeddindex_b on mmeddindex(b);
select count(*) from bbigg;
select count(*) from bbiggindex;
commit work;
--set optimization: level 257;
select * from bbigg where b = 'three';
select * from bbiggindex where b = 'three';
select * from bbigg where a = 3;
select * from bbiggindex where a = 3;
select * from mmedd where b = 'zero';
select * from mmeddindex where b = 'zero';
select * from mmedd where a = 0;
select * from mmeddindex where a = 0;
drop mmedd, bbigg , bbiggindex, mmeddindex;
commit work;
