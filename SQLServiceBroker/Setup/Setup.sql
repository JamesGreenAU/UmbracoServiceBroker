
SELECT name, is_broker_enabled FROM sys.databases;

ALTER DATABASE msdb SET ENABLE_BROKER;
GO

ALTER DATABASE CURRENT SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE;
GO


CREATE QUEUE [umbracocms]
GO

-- Umbracocms service
CREATE SERVICE [//UmbracoSB/umbraco_cms_service] 
AUTHORIZATION dbo 
ON QUEUE umbracocms	
GO

CREATE MESSAGE TYPE [//UmbracoSB/Blog/index_related_content] 
AUTHORIZATION dbo 
VALIDATION = NONE
GO

CREATE MESSAGE TYPE [//UmbracoSB/Index/Response]
AUTHORIZATION dbo 
VALIDATION = NONE
GO

CREATE CONTRACT [//UmbracoSB/Blog/blog_index_contract]
  ( [//UmbracoSB/Blog/index_related_content]  SENT BY ANY,
    [//UmbracoSB/Index/Response] SENT BY ANY)
GO

ALTER SERVICE [//UmbracoSB/umbraco_cms_service] 
 ( ADD CONTRACT [//UmbracoSB/Blog/blog_index_contract] )
GO

-- index service
--CREATE QUEUE [indexqueue]
--GO

CREATE SERVICE [//UmbracoSB/index_service]
AUTHORIZATION dbo
ON QUEUE umbracocms
GO

ALTER SERVICE [//UmbracoSB/index_service]
 ( ADD CONTRACT [//UmbracoSB/Blog/blog_index_contract] )
GO
