--SQL Advance Case Study
  /* select top 1 * from DIM_MANUFACTURER
   select top 1  * from DIM_CUSTOMER
   select top 1 * from DIM_DATE
   select top 1 * from DIM_LOCATION
   select top 1  * from DIM_MODEL
   select top 1  * from FACT_TRANSACTIONS*/
--Q1--BEGIN 

     select distinct l.state from DIM_LOCATION as l left join FACT_TRANSACTIONS as f on l.IDLocation=f.IDLocation inner join DIM_CUSTOMER as c on f.IDCustomer=c.IDCustomer
	 where year(f.date) between 2005 and year(getdate())


--Q1--END

--Q2--BEGIN
	

	select top 1 l.state as state_max_sale,sum(f.totalprice) as total_revenue from DIM_MODEL as mo inner join
	 DIM_MANUFACTURER as ma on mo.IDManufacturer=ma.IDManufacturer inner join FACT_TRANSACTIONS as f on f.IDModel=mo.IDModel inner join
	  DIM_LOCATION as l on l.IDLocation=f.IDLocation
	where ma.Manufacturer_Name='samsung' and country='us' group by l.State order by sum(f.totalprice) 


--Q2--END

--Q3--BEGIN      

	select mo.Model_Name,l.State,l.ZipCode,count(f.idcustomer) as No_Transactions  from FACT_TRANSACTIONS as f inner join
	 DIM_MODEL as mo on f.IDModel=mo.IDModel inner join  DIM_LOCATION as l on f.IDLocation=l.IDLocation group by mo.Model_Name ,l.State, l.ZipCode 


--Q3--END

--Q4--BEGIN
 select top 1 IDModel,Model_Name,Unit_price from DIM_MODEL order by Unit_price 


--Q4--END

--Q5--BEGIN

 select Manufacturer_Name,tbl.idmodel,avg(totalprice) as average_price  from (select f.IDModel,TotalPrice,Manufacturer_Name from FACT_TRANSACTIONS as f inner join DIM_MODEL as mo on f.IDModel=mo.IDModel inner join  DIM_MANUFACTURER as ma on mo.IDManufacturer=ma.IDManufacturer) as tbl 
 where Manufacturer_Name in (
 select top 5 Manufacturer_Name from FACT_TRANSACTIONS as f inner join DIM_MODEL as mo on f.IDModel=mo.IDModel inner join  DIM_MANUFACTURER as ma on mo.IDManufacturer=ma.IDManufacturer
 group by Manufacturer_Name order by sum(Quantity) desc) group by Manufacturer_Name,tbl.IDModel order by average_price desc

--Q5--END

--Q6--BEGIN

select c.IDCustomer,c.Customer_Name,avg(totalprice) as average_price  from FACT_TRANSACTIONS  as f 
inner join DIM_CUSTOMER  as c on  f.IDCustomer=c.IDCustomer  where year(f.date)='2009' group by c.IDCustomer,c.Customer_Name having avg(totalprice)> 500


--Q6--END
	
--Q7--BEGIN  
	
	with top_5 as (
	select 
	year(f.date) as year_date,
	IDModel,
	sum(quantity) as total_quantity ,
	rank() over( partition by year(f.date) order by sum(quantity) desc) as ranking
	from FACT_TRANSACTIONS as f
	where year(f.date) in ('2008','2009','2010')
	group by 
	year(f.date),idmodel

	)
	select 
	IDModel
	from top_5 where ranking in (1,2,3,4,5) 
	group by idmodel having count(*)=3

--Q7--END	
--Q8--BEGIN


with second_top
as
(
select ma.Manufacturer_Name,year(f.Date) as [year], sum(f.TotalPrice) as sale,
rank() over (partition by year(f.date) order by sum(f.TotalPrice) desc ) as ranking
from DIM_MANUFACTURER as ma 
inner join 
DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer 
inner join 
FACT_TRANSACTIONS  as f  on f.IDModel=mo.IDModel
where year(f.date) in ('2009','2010')
group by 
ma.Manufacturer_Name,year(f.Date)
)
select 
Manufacturer_Name,[year],sale,ranking
from second_top where ranking='2'

--Q8--END
--Q9--BEGIN



select ma.Manufacturer_Name
from DIM_MANUFACTURER as ma 
inner join 
DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer 
inner join 
FACT_TRANSACTIONS  as f  on f.IDModel=mo.IDModel
where year(f.date)='2010' group by ma.Manufacturer_Name
except
select ma.Manufacturer_Name
from DIM_MANUFACTURER as ma 
inner join 
DIM_MODEL as mo on ma.IDManufacturer=mo.IDManufacturer 
inner join 
FACT_TRANSACTIONS  as f  on f.IDModel=mo.IDModel
where year(f.date)='2009' group by  ma.Manufacturer_Name


--Q9--END

--Q10--BEGIN

select IDCustomer,year,average_qty,average_spend,
(average_spend-previous_year_avg)/previous_year_avg*100 as perentage_change
 from (	
select IDCustomer,avg(totalprice) as average_spend, avg(Quantity) as average_qty,year(date) as [year]
,lag(avg(totalprice)) over (partition by idcustomer order by year(date)) as previous_year_avg
 from FACT_TRANSACTIONS where IDCustomer in
(select tbl.IDCustomer from
(
select top 100 iDCustomer,sum(TotalPrice) as total_spend,sum(quantity) as total_qty from fact_transactions group by IDCustomer
order by total_spend desc) as tbl
)
group by IDCustomer,year(date)) as tbl2




--Q10--END
	