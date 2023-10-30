-- #1
-- Aim: combine the first and last name
-- || <-- in SQLITE we use this symbol
SELECT 
  e.FirstName 
  ,e.LastName 
  ,e.FirstName || ' ' ||e.LastName AS FullName 
FROM 
  Employee e 
;
-- #2
-- Aim: flag if someone's name starts with the letter M
-- || <-- in SQLITE we use this symbol
WITH base AS (
  SELECT 
    e.FirstName 
    ,e.LastName 
    ,e.FirstName || ' ' ||e.LastName AS FullName 
  FROM 
    Employee e 
)
SELECT
  FullName
  ,CASE WHEN FullName LIKE 'm%' 
        THEN 1
        ELSE 0
        END                          AS flag
FROM 
  base
;

-- #3
-- Aim: 1. find the distinct list of countries we have billed and 2. present them in ascending order
-- Functions we wil use 
--   DISTINCT
--   ORDER BY
SELECT 
  DISTINCT BillingCountry 
FROM 
  Invoice i  
ORDER BY BillingCountry 
;

-- #4
-- Aim: Find the email domains
-- Functions we will use 
--    INSTR( string, substring )
--    SUBSTR( string, start, length )
SELECT 
  Email                                                     /* lets have a look at what the email values look like */
  ,INSTR(Email,'@')                    AS pos_in_string     /* find the position of @ in the string */
  ,SUBSTRING(Email,INSTR(Email,'@')+1) AS email_domain      /* for the email string, take all the chars after @ */
FROM 
  Employee  c 
;

-- #5
-- Aim: finding the length of phone employee phone numbers
-- Functions we will use 
--   LENGTH( string )
SELECT 
  Phone 
  ,LENGTH (Phone)
FROM 
  Employee e 
ORDER BY
  LENGTH (Phone) ASC
;

-- #6
-- Aim: standardise employee phone numbers so that they all start with +
-- Functions we will use 
--    CASE statements
--    SUBSTR( string, start, length )
SELECT 
  Phone 
  ,SUBSTRING(Phone,1,1) AS first_char
  ,CASE WHEN SUBSTRING(Phone,1,1) <> '+'  /* does not start with + */
          THEN '+'||Phone                 /* add + as a prefix */
        ELSE Phone                        /* otherwise use the value as is */
   end                  AS phone_std
  ,LENGTH(Phone)        AS str_len
FROM 
  Employee e 
;

-- #7
-- Aim: format playlist names
-- Functions we will use 
--   UPPER( string )
--   LOWER( string )
SELECT 
  Name 
  ,UPPER(Name) AS name_caps
  ,LOWER(Name) AS name_lower
FROM Playlist p 
;

-- #8
-- Aim: fixing spelling using the replace function
-- REPLACE( string, current value, new value )  
SELECT 
 DISTINCT city 
 ,Country                           
 ,REPLACE (City ,'Sidney','Sydney') AS city_name_fixed
FROM 
  Customer c 
ORDER BY 2
;
-- note: replace is case sensitive, if you want to change replace the value without worrying about case, you can use case statements
SELECT 
 DISTINCT city 
 ,Country    
 ,case when city like 's%ney' then 'Sydney'
  else City end 
FROM 
  Customer c 
ORDER BY 2
;

-- #9
-- AIM: 1. find many years since the last sale and 2, number of days since the last sale
-- JULIANDAY() function, which counts the number of DAYS since noon in Greenwich on November 24, 4714 B.C
-- DATETIME() functation, gets the database time... note that this is in UTC
SELECT 
  DATETIME()                                                  AS curr_date_time
  ,MAX(InvoiceDate)                                           AS max_date
  ,DATETIME() - MAX(InvoiceDate)                              AS year_diff
  ,JULIANDAY((DATETIME()) - MAX(JULIANDAY(InvoiceDate))       AS day_diff
  ,ROUND(JULIANDAY(DATETIME()) - max(JULIANDAY(InvoiceDate))) AS day_diff_rounded
FROM
  Invoice
;


-- something you might need to know for the future 
-- converting date formats
-- pgsql example: 
-- select to_char(to_date(admindate, 'MM-DD-YYYY'), 'YYYY-MM-DD')



-- EXTRA Hands On QS for later: 
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
