create schema tuanlab7;
use tuanlab7;

delimiter //

create procedure getAccountCustomer ()
begin
	select * from 
    account inner join depositor
		on account.account_number = depositor.account_number
	inner join customer
		on depositor.customer_name = customer.customer_name
	order by account.account_number asc;
end //

create procedure getTotalAsset()
begin
	select sum(asset) as totalAsset from branch;
end //

create procedure getAssetAvgBalance(
	in b_name varchar(20),
    out b_asset int,
    out avg_a_balance int
    )
begin
	select asset
    into b_asset
    from branch
    where branch.branch_name = b_name;
    
    select avg(balance)
    into avg_a_balance
    from account
    where account.branch_name = b_name;
end //

create procedure checkAccountStatus(
	in a_number int,
    out a_status varchar(10)
)
begin
	declare a_balance int default 0;
    declare l_amount int default 0;
    
    select balance
    into a_balance
    from account
    where account.account_number = a_number;
    
    select sum(amount)
    into l_amount
    from loan;
    
    if a_balance > l_amount then
		set a_status = 'OK';
	elseif a_balance = l_amount then
		set a_status = 'Warning';
	else
		set a_status = 'Critical';
	end if;
end //

create procedure InsertAccountCustomer(
	in a_num int,
    in a_name varchar(9),
    in a_balance float,
    in d_cust_name varchar(10),
    in c_street varchar(20),
    in c_city varchar(20)
)
begin
	declare exit handler for 1062
    begin
		select concat('Duplicate key (',a_num,')occurred') as message;
    end;
    
    insert into account 
    values (a_num,a_name,a_balance);
    
    insert into depositor
    values (d_cust_name, a_num);
    
    insert into customer
    values (d_custname, c_street, c_city);
end //

create function GenAccountNumber(
	a_number int
)returns int
	deterministic
begin
	declare a_num int;
    
    set a_num = a_number + 100;
    
    return (a_num);
end //

create function BranchNameToID(
	b_name varchar(20)
)returns varchar(4)
	deterministic
begin
	declare id varchar(4);
    
    if b_name = 'SUT' then
		set id = '0001';
	elseif b_name = 'Mall' then
		set id = '0002';
	else
		set id = '0000';
	end if;
    return(id);
end //

delimiter ;

#==========================================================================================================

#!
call getAccountCustomer();
#2
call getTotalAsset();
#3
call getAssetAvgBalance('Mall', @b_asset, @avg_a_balance);
select @b_asset, @avg_a_balance;
#4
set @a_number = 3;
call checkAccountStatus(@a_number, @a_status);
select @a_number, @a_status;
#5
call InsertAccountCustomer(3,'SUT',300,'Nun','University','Korat');
#6
insert into account values(GenAccountNumber(4), 'SUT', 3000);
select * from account;
#7
select
	BranchNameToID(branch_name),
    branch_name,
    branch_city,
    asset
from
	branch;