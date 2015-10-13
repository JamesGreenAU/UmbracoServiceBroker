
-- Content Queue Procs

--
-- dbo.UpdateRecommendationsFromSummary
--
CREATE PROC dbo.UpdateRecommendationsFromSummary
	@nodeType nvarchar (256),
	@summary nvarchar (512), 
	@nodeid int,
	@ConversationHandle uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION

BEGIN DIALOG CONVERSATION @ConversationHandle 
	FROM SERVICE [//Content/Blog/UpdateRecommendation]
	TO SERVICE '//Recommendation/Blog/Update'
	ON CONTRACT [//Content/Blog/UpdateRecommendationContract]
	WITH ENCRYPTION = OFF;

DECLARE @body XML;
SET @body = '<request>
				<nodeType>' + @nodeType + '</nodeType>
				<summary>' + @summary + '</summary>
				<nodeId>' + cast(@nodeid AS NVARCHAR(128)) + '</nodeId>
			 </request>';

SEND ON CONVERSATION @ConversationHandle
	MESSAGE TYPE [//Recommendations/UpdateBlogPostMessage]  (@body);

COMMIT TRANSACTION
GO

--
-- dbo.ReadFromContentQueue
--
CREATE PROC dbo.ReadFromContentQueue
	@message_type nvarchar(256) OUTPUT,
	@message_body xml OUTPUT,
	@conversation_handle uniqueidentifier OUTPUT,
	@conversation_group_id uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION;

WAITFOR (
	-- Column names documented here: https://msdn.microsoft.com/en-us/library/ms186963.aspx#Anchor_3
	RECEIVE top(1)
		@message_type = message_type_name, 
		@message_body = message_body,
		@conversation_handle = conversation_handle, 
		@conversation_group_id = conversation_group_id 
	FROM dbo.[ContentQueue]
), TIMEOUT 2000

COMMIT TRANSACTION;
GO

-- Member Queue Procs

--
-- dbo.SendMemberWelcomePack
--
CREATE PROC dbo.SendMemberWelcomePack
	@name nvarchar (128),
	@email nvarchar (128),
	@ConversationHandle uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION

BEGIN DIALOG CONVERSATION @ConversationHandle 
	FROM SERVICE [//Member/Email/WelcomePack]
	TO SERVICE '//Email/SendAgent'
	ON CONTRACT [//Member/Email/WelcomePackContract]
	WITH ENCRYPTION = OFF;

DECLARE @body XML;
SET @body = '<request>
				<name>' + @name + '</name>
				<email>' + @email + '</email>
			 </request>';

SEND ON CONVERSATION @ConversationHandle
	MESSAGE TYPE [//Member/Email/WelcomePackMessage]  (@body);

COMMIT TRANSACTION
GO

--
-- dbo.ReadFromMemberQueue
--
CREATE PROC dbo.ReadFromMemberQueue
	@message_type nvarchar(256) OUTPUT,
	@message_body xml OUTPUT,
	@conversation_handle uniqueidentifier OUTPUT,
	@conversation_group_id uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION;

WAITFOR (
	-- Column names documented here: https://msdn.microsoft.com/en-us/library/ms186963.aspx#Anchor_3
	RECEIVE top(1)
		@message_type = message_type_name, 
		@message_body = message_body,
		@conversation_handle = conversation_handle, 
		@conversation_group_id = conversation_group_id 
	FROM dbo.[MemberQueue]
), TIMEOUT 2000

COMMIT TRANSACTION;
GO

-- Media Queue Procs

--
-- dbo.RequestCdnResourceInvalidation
--
CREATE PROC dbo.RequestCdnResourceInvalidation
	@resource nvarchar (256),
	@ConversationHandle uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION

BEGIN DIALOG CONVERSATION @ConversationHandle 
	FROM SERVICE [//Media/Cdn/SetInvalidation]
	TO SERVICE '//Cdn/InvalidationAgent'
	ON CONTRACT [//Media/Cdn/SetInvalidationContract]
	WITH ENCRYPTION = OFF;

DECLARE @body XML;
SET @body = '<request>
				<resource>' + @resource + '</resource>
			 </request>';

SEND ON CONVERSATION @ConversationHandle
	MESSAGE TYPE [//Media/Cdn/SetInvalidationMessage] (@body);

COMMIT TRANSACTION
GO

--
-- dbo.RequestCdnPolicyOnResource
--
CREATE PROC dbo.RequestCdnPolicyOnResource
	@resource nvarchar (256),
	@ConversationHandle uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION

BEGIN DIALOG CONVERSATION @ConversationHandle 
	FROM SERVICE [//Media/Cdn/SetPolicy]
	TO SERVICE '//Cdn/PolicyAgent'
	ON CONTRACT [//Media/Cdn/SetPolicyContract]
	WITH ENCRYPTION = OFF;

DECLARE @body XML;
SET @body = '<request>
				<resource>' + @resource + '</resource>
			 </request>';

SEND ON CONVERSATION @ConversationHandle
	MESSAGE TYPE [//Media/Cdn/SetPolicyMessage]  (@body);

COMMIT TRANSACTION
GO

--
-- dbo.ReadFromMediaQueue
--
CREATE PROC dbo.ReadFromMediaQueue
	@message_type nvarchar(256) OUTPUT,
	@message_body xml OUTPUT,
	@conversation_handle uniqueidentifier OUTPUT,
	@conversation_group_id uniqueidentifier OUTPUT
AS
BEGIN TRANSACTION;

WAITFOR (
	-- Column names documented here: https://msdn.microsoft.com/en-us/library/ms186963.aspx#Anchor_3
	RECEIVE top(1)
		@message_type = message_type_name, 
		@message_body = message_body,
		@conversation_handle = conversation_handle, 
		@conversation_group_id = conversation_group_id 
	FROM dbo.[MediaQueue]
), TIMEOUT 2000

COMMIT TRANSACTION;
GO