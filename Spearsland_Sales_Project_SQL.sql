-- creating a copy of raw data to work on --


drop table if exists retail_sales_staging; -- drop existing table if retail_sales_staging exist
create table retail_sales_staging
like retail_sales; -- create retail_sales worksheet table (copy column name only)

insert into retail_sales_staging
select *
from retail_sales; -- copy row values from layoffs table to layoffs_staging table

select *
from retail_sales_staging; -- check if data is updated 




-- Removing Duplicate Rows --


CREATE TABLE `retail_sales_staging2` (
  `Store ID` text,
  `Product ID` int DEFAULT NULL,
  `Date` text,
  `Units Sold` int DEFAULT NULL,
  `Sales Revenue (USD)` double DEFAULT NULL,
  `Discount Percentage` int DEFAULT NULL,
  `Marketing Spend (USD)` int DEFAULT NULL,
  `Store Location` text,
  `Product Category` text,
  `Day of the Week` text,
  `Holiday Effect` text,
  `row_num` int -- new column `row_num` added to retail_sales_staging2 table
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from retail_sales_staging2; -- checking if new_row column is added into retail_sales_staging2 table

insert into retail_sales_staging2 -- copy all data from layoffs_staging table to retail_sales_staging2 table
select *,
row_number () over( -- adding row_num data for retail_sales_staging2 table, if row_num > 1, it is duplicate data
partition by `Store ID`, `Product ID`, `Date`, `Units Sold`, `Sales Revenue (USD)`, `Discount Percentage`, `Marketing Spend (USD)`, `Store Location`, `Product Category`, `Day of the Week`, `Holiday Effect`) row_num
from retail_sales_staging;

select *
from retail_sales_staging2
where row_num > 1; -- return empty row, thus no duplicate found

delete
from retail_sales_staging2
where row_num > 1; -- deleting duplicate rows from the table (if exist)




-- Standardazing data --


select distinct `Product ID`
from retail_sales_staging2;

update retail_sales_staging2
set `Store ID` = trim(`Store ID`),
`Day of the Week` = trim(`Day of the Week`),
`Store Location` = trim(`Store Location`);

select `Date`, str_to_date(`Date`, '%Y,%m,%d')
from retail_sales_staging2; -- check if Date is ni date arrangement
-- Date is in date arrangement, thus no need to update the column

-- if Date is not in date arrangement, update using this code--
update retail_sales_staging2 
set `Date` = str_to_date(`Date`, '%Y,%m,%d');

alter table retail_sales_staging2
modify column `Date` date; -- set Date to date category




-- checking NULL value/Blank VALUES --


select t1.`Product ID`, t1.`Product Category`, t2.`Product Category`
from retail_sales_staging2 t1
join retail_sales_staging2 t2
	on t1.`Product ID` = t2.`Product ID`
where (t1.`Product Category` is NULL or  t1.`Product Category` = '')
and (t2.`Product Category` is NOT NULL and  t1.`Product Category` != ''); -- checking NULL/blank in industry column based on company
-- return 0 rows, thus no NULL values

-- if null value exist, use below code--
update retail_sales_staging2 t1
join retail_sales_staging2 t2
	on t1.`Product ID` = t2.`Product ID`
set t1.`Product Category` = t2.`Product Category`
where (t1.`Product Category` is NULL or  t1.`Product Category` = '')
and (t2.`Product Category` is NOT NULL and  t1.`Product Category` != '');





-- Removing unimportant data --


select *
from retail_sales_staging2
where (`Sales Revenue (USD)` is NULL or `Sales Revenue (USD)` = '')
and (`Discount Percentage` is NULL or `Discount Percentage` = '')
and (`Marketing Spend (USD)` is NULL or `Marketing Spend (USD)` = ''); -- checking null/blank data from Sales Revenue (USD) & Discount Percentage & Marketing Spend (USD)

delete
from retail_sales_staging2
where (`Sales Revenue (USD)` is NULL or `Sales Revenue (USD)` = '')
and (`Discount Percentage` is NULL or `Discount Percentage` = '')
and (`Marketing Spend (USD)` is NULL or `Marketing Spend (USD)` = ''); -- delete null/blank data from Sales Revenue (USD) & Discount Percentage & Marketing Spend (USD)

alter table retail_sales_staging2
drop column row_num; -- removing unimportant column

select *
from retail_sales_staging2;

