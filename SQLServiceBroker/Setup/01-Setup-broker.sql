
SELECT name, is_broker_enabled, service_broker_guid FROM sys.databases;

ALTER DATABASE msdb SET ENABLE_BROKER;
ALTER DATABASE CURRENT SET NEW_BROKER  WITH ROLLBACK IMMEDIATE; -- Use ENABLE_BROKER if restoring db
GO

-- Content Queue DDL

CREATE QUEUE [ContentQueue]
GO

CREATE MESSAGE TYPE [//Recommendations/UpdateBlogPostMessage]
	AUTHORIZATION dbo
	VALIDATION = NONE
GO

CREATE CONTRACT [//Content/Blog/UpdateRecommendationContract]
	( [//Recommendations/UpdateBlogPostMessage] SENT BY ANY )
GO

CREATE SERVICE [//Content/Blog/UpdateRecommendation]
	AUTHORIZATION dbo
	ON QUEUE [ContentQueue]
		(  [//Content/Blog/UpdateRecommendationContract] );
GO

CREATE SERVICE [//Recommendation/Blog/Update]
	AUTHORIZATION dbo
	ON QUEUE [ContentQueue]
		(  [//Content/Blog/UpdateRecommendationContract] );
GO

-- Member Queue DDL

CREATE QUEUE [MemberQueue];
GO

CREATE MESSAGE TYPE [//Member/Email/WelcomePackMessage]
	AUTHORIZATION dbo
	VALIDATION = NONE
GO

CREATE CONTRACT [//Member/Email/WelcomePackContract]
	( [//Member/Email/WelcomePackMessage] SENT BY ANY )
GO

CREATE SERVICE [//Member/Email/WelcomePack]
	AUTHORIZATION dbo
	ON QUEUE [ContentQueue]
		( [//Member/Email/WelcomePackContract] );
GO

CREATE SERVICE [//Email/SendAgent]
	AUTHORIZATION dbo
	ON QUEUE [ContentQueue]
		( [//Member/Email/WelcomePackContract] );
GO
