drop table if exists tree;
CREATE TABLE tree(ID INT, MgrID INT, Name VARCHAR(32),sort int);

INSERT INTO tree VALUES (1,0,'Kim',1);
INSERT INTO tree VALUES (2,0,'Moy',1);
INSERT INTO tree VALUES (3,1,'Jonas',3);
INSERT INTO tree VALUES (4,1,'Smith',3);
INSERT INTO tree VALUES (5,2,'Verma',2);
INSERT INTO tree VALUES (6,2,'Foster',2);
INSERT INTO tree VALUES (7,6,'Brown',1);

--test: system error for below query:
select  json_objectagg(id,mgrid) from (select * from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id)x;

select id,mgrid from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;

--expected error
select  json_arrayagg(id,mgrid) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;

select  json_arrayagg(id) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;
select  json_arrayagg(mgrid) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;

INSERT INTO tree VALUES (NULL,NULL,'null', null);

--expected error
select  json_objectagg(id,mgrid) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;

select id,mgrid from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;
select  json_arrayagg(id) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;
select  json_arrayagg(mgrid) from tree connect by prior id=mgrid ORDER SIBLINGS BY sort,id;

drop table if exists tree;
