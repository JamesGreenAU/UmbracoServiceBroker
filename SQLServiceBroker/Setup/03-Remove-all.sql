SELECT name, is_broker_enabled, service_broker_guid FROM sys.databases;

ALTER DATABASE msdb SET ENABLE_BROKER;
ALTER DATABASE CURRENT SET NEW_BROKER  WITH ROLLBACK IMMEDIATE; -- Use ENABLE_BROKER if restoring db
GO

-- Content Queue Procs
DROP PROC dbo.UpdateRecommendationsFromSummary;
GO

DROP PROC dbo.ReadFromContentQueue;
GO

-- Content Queue DDL
DROP SERVICE [//Content/Blog/UpdateRecommendation]
GO

DROP SERVICE [//Recommendation/Blog/Update]
GO

DROP CONTRACT [//Content/Blog/UpdateRecommendationContract]
GO

DROP MESSAGE TYPE [//Recommendations/UpdateBlogPostMessage]
GO

DROP QUEUE [ContentQueue]
GO

-- Member Queue Procs
DROP PROC dbo.SendMemberWelcomePack
GO

DROP PROC dbo.ReadFromMemberQueue
GO

-- Member Queue DDL
DROP SERVICE [//Member/Email/WelcomePack]
GO

DROP SERVICE [//Email/SendAgent]
GO

DROP CONTRACT [//Member/Email/WelcomePackContract]
GO

DROP MESSAGE TYPE [//Member/Email/WelcomePackMessage]
GO

DROP QUEUE [MemberQueue];
GO