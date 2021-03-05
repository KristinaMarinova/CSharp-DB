UPDATE Payments
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments

UPDATE Payments
SET TaxAmount = AmountCharged * TaxRate

UPDATE Payments
SET PaymentTotal = AmountCharged + TaxAmount