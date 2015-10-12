
SELECT name, is_broker_enabled, service_broker_guid FROM sys.databases;

ALTER DATABASE msdb SET ENABLE_BROKER;
ALTER DATABASE CURRENT SET NEW_BROKER  WITH ROLLBACK IMMEDIATE; -- Use ENABLE_BROKER if restoring db
GO

CREATE QUEUE [umbracocms]
GO

CREATE MESSAGE TYPE [//UmbracoSB/Blog/index_related_content_message] 
AUTHORIZATION dbo 
VALIDATION = NONE
GO

CREATE CONTRACT [//UmbracoSB/Blog/blog_index_contract]
  ( [//UmbracoSB/Blog/index_related_content_message] SENT BY ANY )
GO

CREATE SERVICE [//UmbracoSB/umbraco_cms_service] 
AUTHORIZATION dbo 
ON QUEUE umbracocms	
	([//UmbracoSB/Blog/blog_index_contract]);
GO

CREATE SERVICE [//UmbracoSB/index_service]
AUTHORIZATION dbo
ON QUEUE umbracocms
	( [//UmbracoSB/Blog/blog_index_contract] )
GO