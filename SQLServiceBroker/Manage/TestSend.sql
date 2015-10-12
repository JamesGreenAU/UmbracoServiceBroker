BEGIN TRANSACTION; 

DECLARE @ConversationHandle uniqueidentifier;

BEGIN DIALOG CONVERSATION @ConversationHandle 
	FROM SERVICE [//UmbracoSB/umbraco_cms_service]
	TO SERVICE '//UmbracoSB/index_service'
	ON CONTRACT [//UmbracoSB/Blog/blog_index_contract];
	
DECLARE @message_body AS VARBINARY(max);
SET @message_body = CONVERT(varbinary(max), '{ "name": "Blog Post" }');

SEND ON CONVERSATION @ConversationHandle
	MESSAGE TYPE [//UmbracoSB/Blog/index_related_content]
	(@message_body);

SELECT @ConversationHandle;

END CONVERSATION @ConversationHandle

COMMIT TRANSACTION;
GO
