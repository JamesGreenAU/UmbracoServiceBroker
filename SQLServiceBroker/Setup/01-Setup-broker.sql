
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
	ON QUEUE [MemberQueue]
		( [//Member/Email/WelcomePackContract] );
GO

CREATE SERVICE [//Email/SendAgent]
	AUTHORIZATION dbo
	ON QUEUE [MemberQueue]
		( [//Member/Email/WelcomePackContract] );
GO


-- Media Queue DDL

CREATE QUEUE [MediaQueue];
GO

-- CDN Invalidation
CREATE MESSAGE TYPE [//Media/Cdn/SetInvalidationMessage]
	AUTHORIZATION dbo
	VALIDATION = NONE
GO

CREATE CONTRACT [//Media/Cdn/SetInvalidationContract]
	( [//Media/Cdn/SetInvalidationMessage] SENT BY ANY )
GO

CREATE SERVICE [//Media/Cdn/SetInvalidation]
	AUTHORIZATION dbo
	ON QUEUE [MemberQueue]
		( [//Media/Cdn/SetInvalidationContract] );
GO

CREATE SERVICE [//Cdn/InvalidationAgent]
	AUTHORIZATION dbo
	ON QUEUE [MemberQueue]
		( [//Media/Cdn/SetInvalidationContract] );
GO

-- CDN Set Policy
CREATE MESSAGE TYPE [//Media/Cdn/SetPolicyMessage]
	AUTHORIZATION dbo
	VALIDATION = NONE
GO

CREATE CONTRACT [//Media/Cdn/SetPolicyContract]
	( [//Media/Cdn/SetPolicyMessage] SENT BY ANY )
GO

CREATE SERVICE [//Media/Cdn/SetPolicy]
	AUTHORIZATION dbo
	ON QUEUE [MemberQueue]
		( [//Media/Cdn/SetPolicyContract] );
GO

CREATE SERVICE [//Cdn/PolicyAgent]
	AUTHORIZATION dbo
	ON QUEUE [MemberQueue]
		( [//Media/Cdn/SetPolicyContract] );
GO