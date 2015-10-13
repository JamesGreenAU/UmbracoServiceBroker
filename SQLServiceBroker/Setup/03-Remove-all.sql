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

-- Media Queue Procs

DROP PROC dbo.ReadFromMediaQueue
GO

DROP PROC dbo.RequestCdnResourceInvalidation
GO

DROP PROC dbo.RequestCdnPolicyOnResource
GO

-- Media Queue DDL

-- CDN Policy
DROP SERVICE [//Media/Cdn/SetPolicy]
GO

DROP SERVICE [//Cdn/PolicyAgent]
GO

DROP CONTRACT [//Media/Cdn/SetPolicyContract]
GO

DROP MESSAGE TYPE [//Media/Cdn/SetPolicyMessage]
GO

-- CDN Invalidation
DROP SERVICE [//Cdn/InvalidationAgent]
GO

DROP CONTRACT [//Media/Cdn/SetInvalidationContract]
GO

DROP SERVICE [//Media/Cdn/SetInvalidation]
GO

DROP MESSAGE TYPE [//Media/Cdn/SetInvalidationMessage]
GO

DROP QUEUE [MediaQueue];
GO
