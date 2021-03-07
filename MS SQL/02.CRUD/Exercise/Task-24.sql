--24. Countries and Currency (Euro / Not Euro)

SELECT 
	CountryName, CountryCode, 
	IIF(Currencies.CurrencyCode = 'EUR', 'Euro', 'Not Euro') AS Currency
FROM Countries 
LEFT JOIN Currencies ON Currencies.CurrencyCode = Countries.CurrencyCode
ORDER BY CountryName