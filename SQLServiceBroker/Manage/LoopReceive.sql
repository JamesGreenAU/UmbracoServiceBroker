DECLARE @message_type AS sysname;
DECLARE @message_body AS NVARCHAR(max);
DECLARE @dialog AS uniqueidentifier;

WHILE (1 = 1)
BEGIN
	BEGIN TRANSACTION
	PRINT 'Alpha';

	WAITFOR (
		-- Column names documented here: https://msdn.microsoft.com/en-us/library/ms186963.aspx#Anchor_3
		RECEIVE top(1)
			@message_type = message_type_name, 
			@message_body = message_body,
			@dialog = conversation_handle
		FROM dbo.umbracocms
	), TIMEOUT 2000

	--IF (@@ROWCOUNT = 0)
	--BEGIN
	--	PRINT 'Outta here';
	--	ROLLBACK TRANSACTION;
	--	BREAK;
	--END
	PRINT 'Soooo ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

	IF (@message_type = '//UmbracoSB/Blog/index_related_content')
	BEGIN
		PRINT 'has /index_related_content';
		PRINT @message_body;
		
	END
	COMMIT TRANSACTION; --ROLLBACK TRANSACTION;
END
GO

