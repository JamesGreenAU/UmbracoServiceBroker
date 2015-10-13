SELECT * from sys.service_message_types;
GO

SELECT * from sys.service_contracts;
GO

SELECT * FROM sys.services;
GO

SELECT * from sys.service_queues
WHERE is_ms_shipped = 0;
GO