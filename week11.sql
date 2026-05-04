create schema w11;
use w11;

CREATE TABLE members (
    id          INT(5)         NOT NULL,
    userid      varchar(50)    NOT NULL,
    password    varchar(50)    NOT NULL,
    name        varchar(100)   NULL,
    tel         varchar(20)    NULL,
    age         INT            NULL,
    activated   varchar(1)     NULL,
    salary      INT            NULL,
    promotion   varchar(1)     NULL,
    PRIMARY KEY(id)
);

CREATE TABLE membersArchives (
    id          INT(5)         NOT NULL,
    userid      varchar(50)    NOT NULL,
    password    varchar(50)    NOT NULL,
    name        varchar(100)   NULL,
    tel         varchar(20)    NULL,
    age         INT            NULL,
    activated   varchar(1)     NULL,
    salary      INT            NULL,
    promotion   varchar(1)     NULL,
    PRIMARY KEY(id)
);


insert into members values 
(1, 'Husky', '1234', 'Malee flower', '044-111222', 33, 'Y', 10000, NULL),
(2, 'Bean', 'zxcvb', 'Green bean', '044-222333', 12, 'N', 20000, NULL),
(3, 'Tana', '1234qaz', 'Tana Khon', '044-555888', 18, 'Y', 30000, NULL);

delimiter //

create trigger before_members_insert
	before insert
    on members for each row
begin
	if new.age > 17 then
		set new.activated = 'Y';
	else
		set new.activated = 'N';
	end if;
end //

create trigger before_members_update
	before update
    on members for each row
begin
	if new.salary > old.salary then
		set new.promotion = 'y';
	elseif new.salary < old.salary then
		set new.promotion = 'n';
	else
		set new.promotion = null;
	end if;
end //

create trigger before_members_delete
	before delete
    on members for each row
begin
	insert into membersArchives values
    (old.id,old.userid,old.password,old.name,old.tel,old.age,old.activated,old.salary,old.promotion);
end //

delimiter ;

##########################################################################################################

insert into members values
(4, 'std1', '0987', 'May May', '044-214445', 25, NULL, 10000, NULL),
(5, 'std2', '5555', 'Jan May', '044-334445', 10, NULL, 15000, NULL);

update members
set salary = 20000
where id = 1;

delete from members where id = 4;
