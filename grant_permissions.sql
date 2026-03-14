-- This script grants the required view server state permission to the READAMC user.
-- You must run this script in SQL Server Management Studio (SSMS) 
-- logged in as a system administrator (like 'sa' or a Windows Administrator).

USE master;
GO

GRANT VIEW SERVER STATE TO [READAMC];
GO
