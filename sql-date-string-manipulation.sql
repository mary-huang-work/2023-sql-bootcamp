--concatenate the first and last name
-- note: sqllite uses || between values you want to concatenate 
select 
  e.FirstName 
  ,e.LastName 
  ,e.FirstName || ' ' ||e.LastName as FullName 
from 
  Employee e 
;

-- distinct / order by
select 
   DISTINCT BillingCountry 
from 
  Invoice i  
order by BillingCountry 
;

-- finding the domain of an email using instr and substring
SELECT 
  Email 
  ,INSTR(Email,'@')                    as pos_in_string
  ,SUBSTRING(Email,INSTR(Email,'@')+1) as email_domain 
FROM 
  Employee  c 
;

-- finding the length of phone employee phone numbers
SELECT 
  Phone 
  ,LENGTH (Phone)
FROM 
  Employee e 
;

-- standardising phone numbers
SELECT 
  Phone 
  ,SUBSTRING(Phone,1,1) as first_char
  ,case when SUBSTRING(Phone,1,1) <> '+' then '+'||Phone 
        else Phone 
   end                  as phone_std
  ,LENGTH(Phone)        as str_len
FROM 
  Employee e 
;

-- formatting letter case
SELECT 
  Name 
  ,upper(Name) as name_caps
  ,lower(Name) as name_lower
FROM Playlist p 
;

-- fixing spelling using the replace function
SELECT 
 DISTINCT city 
 ,Country
 ,REPLACE (City ,'Sidney','Sydney') as city_name_fixed
FROM 
  Customer c 
order by 2

;

-- Flag which months sales were not made
-- step1. create a calendar
with cal as (
SELECT 
  distinct(strftime ('%Y-%m',InvoiceDate)) as year_month_pt
FROM 
  Invoice i
--WHERE InvoiceDate between '2007-01-01' and '2007-08-01'
) 
-- step2. Extract and format information
,invoice_mod as (
select 
  i.invoiceid
  ,il.InvoiceLineId
  ,il.Quantity
  ,i.CustomerId
  ,i.BillingCountry
  ,i.Total
  ,strftime ('%Y-%m',InvoiceDate) as year_month_pt
FROM 
  Invoice i
  inner join InvoiceLine il on il.InvoiceId == i.InvoiceId
where BillingCountry == 'USA'
)
--step3.combine the datasets to see which months made a sale
select cal.year_month_pt
  ,sum(invoice_mod.quantity)
  ,sum(invoice_mod.total)
  ,case when invoice_mod.total >0 then 'sale made this month'
        else 'no sale made' end as sale_flag
from cal
  left join invoice_mod 
         on cal.year_month_pt== invoice_mod.year_month_pt
group by cal.year_month_pt

-- how many years since the last sale?
-- JULIANDAY() function, which counts the number of days since noon in Greenwich on November 24, 4714 B.C
-- DATETIME() functation, gets the database time... note that this is in UTC
select 
  datetime() 
  ,max(InvoiceDate)
  ,julianday(datetime()) - max(julianday(InvoiceDate)) day_diff
  ,datetime() - max(InvoiceDate) year_diff
from 
  Invoice
