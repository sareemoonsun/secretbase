create schema tuanlab8;
use tuanlab8;

create view loan_view as
select branch_name, sum(amount) from loan
where amount > 3000;

create view join_view as
select a.account_number, a.branch_name, a.balance, c.customer_name
from account as a
inner join depositor as d
on a.account_number = d.account_number
inner join customer as c
on d.customer_name = c.customer_name
where a.branch_name = 'SUT';

create view account_view as
select * from account
where balance < 200
with check option;

delimiter //

CREATE PROCEDURE `transfer_money`(
    IN amount_transfer FLOAT,
    IN from_acc_num INT,
    IN to_acc_num INT
)
BEGIN
    DECLARE errorStatus BOOLEAN DEFAULT FALSE;
	declare checkID int;

    START TRANSACTION;
        BEGIN
            DECLARE EXIT HANDLER FOR NOT FOUND SET errorStatus = TRUE;
            select account_number into checkID from account where account_number = from_acc_num;
            select account_number into checkID from account where account_number = to_acc_num;
            if from_acc_num = to_acc_num then
				set errorStatus = true;
			end if;
            
            update account
            set balance = balance - amount_transfer
            where account_number = from_acc_num;
            
            update account
            set balance = balance + amount_transfer
            where account_number = to_acc_num;
        END;

    IF errorStatus = TRUE THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END //

CREATE PROCEDURE `loan_money`(
    IN loan_number INT,
    IN b_name CHAR(9),
    IN amount FLOAT,
    IN customer_name CHAR(9),
    IN acc_number INT
)
BEGIN
    DECLARE errorStatus BOOLEAN DEFAULT FALSE;
    declare sb_name char(9);
    declare b_asset float;
    declare c_name char(9);
    declare c_num int;
    START TRANSACTION;
        BEGIN
            DECLARE EXIT HANDLER FOR NOT FOUND SET errorStatus = TRUE;
            #branch not found
            select branch_name into sb_name from branch as b where b.branch_name = b_name;
            select asset into b_asset from branch as b where b.branch_name = b_name; 
            #amount >= asset
            if amount > b_asset then
				set errorStatus = true;
			elseif amount < 0 then
				set errorStatus = true;
			end if;
            #cust_name and num not found
            select customer_name into c_name from depositor as d where d.customer_name = customer_name;
            select account_number into c_num from depositor as d where d.account_number = acc_number;
            IF errorStatus = FALSE THEN
				INSERT INTO loan (loan_number, branch_name, amount) 
				VALUES (loan_number, b_name, amount);
  
				INSERT INTO borrower (customer_name, loan_number) 
				VALUES (customer_name, loan_number);
			  
				UPDATE branch SET asset = asset - amount WHERE branch_name = b_name;

				UPDATE account SET balance = balance + amount WHERE account_number = acc_number;
			END IF;
        END;

    IF errorStatus = TRUE THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END//

delimiter ;

#============================================================================================================
#1
select * from loan_view;
#2
select * from join_view;
#3
select * from account_view;
INSERT INTO account_view VALUES(4, 'SUT', 500);
#4
call transfer_money(10,1,8);
#5
CALL loan_money(103,'SUT',20000,'Som',1);