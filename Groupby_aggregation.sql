
--Average --
SELECT  AVG(UnitPrice)
FROM InvoiceLine il  ;

-- Minimum, Maximum, Sum --]
SELECT  MIN(Total), MAX(Total), SUM (total)
FROM Invoice i ;

-- Count and Count DIstinct --
SELECT  COUNT(CustomerID), COUNT(DISTINCT City) 
FROM Customer c  ;

-- Disticnt --
SELECT DISTINCT City
FROM Customer c  ;

-- Group By --
SELECT BillingCity, MAX(Total) 
FROM Invoice i 
GROUP BY BillingCity ;


-- Group By with Order By --
SELECT BillingCity, MAX(Total) 
FROM Invoice i 
GROUP BY BillingCity 
ORDER BY BillingCity ASC ;


-- Group by using multiple columns --
SELECT Name,Composer,MAX(UnitPrice) 
FROM Track t 
GROUP BY Name,Composer ;


-- Group By with Where --
SELECT InvoiceId, Quantity, UnitPrice
FROM InvoiceLine il 
WHERE UnitPrice > 0.99
GROUP BY InvoiceId;


-- Group By with Having --
SELECT CustomerId ,InvoiceDate , MAX(Total)
FROM Invoice i 
GROUP BY CustomerId ,InvoiceDate 
HAVING MAX(Total) > 20.00;


-- Mandatoory Aggregate along with Having clause --
SELECT CustomerId ,InvoiceDate , Total
FROM Invoice i 
GROUP BY CustomerId ,InvoiceDate 
HAVING Total>20.00;

