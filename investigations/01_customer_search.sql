/*
Searching orders by CustomerID.

Dataset size:

50,000 Customers
500,000 Orders
1,500,541 OrderItems
*/

/*

No index on CustomerID for the first SELECT statement. This resulted in 3449 logical reads, and SQL Server completing a clustered index scan on the Orders table.

The clustered index is ordered by OrderID, so SQL server has no efficient way to find the records in this instance.

*/

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT *
FROM Orders
WHERE CustomerID = 12345

SET STATISTICS IO OFF
SET STATISTICS TIME OFF

/*

NONCLUSTERED index added - this resulted in 33 logical reads. SQL Server completed an index seek on the IX_Orders_CustomerID index to find the matching CustomerID values, followed by a key lookup to retrieve the rest of the columns from the Orders table.

*/

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Orders(CustomerID)

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT *
FROM Orders
WHERE CustomerID = 12345

SET STATISTICS IO OFF
SET STATISTICS TIME OFF

/*

Covering index added - this resulted in 3 logical reads. SQL Server completed an index seek on the IX_Orders_CustomerID index to find the matching CustomerID values, and all the required columns were retrieved from the index itself, eliminating the need for a key lookup.

*/

DROP INDEX IX_Orders_CustomerID ON Orders
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Orders(CustomerID)
INCLUDE (
  OrderID,
  TotalAmount,
  OrderDate,
  Status
)

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT *
FROM Orders
WHERE CustomerID = 12345

SET STATISTICS IO OFF
SET STATISTICS TIME OFF