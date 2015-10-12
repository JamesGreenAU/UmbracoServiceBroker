

DROP SERVICE [//UmbracoSB/umbraco_cms_service]
GO

DROP SERVICE [//UmbracoSB/index_service]
GO 

DROP CONTRACT [//UmbracoSB/Blog/blog_index_contract]
GO

DROP MESSAGE TYPE  [//UmbracoSB/Blog/index_related_content] 
GO

DROP MESSAGE TYPE  [//UmbracoSB/Index/Response] 
GO

DROP QUEUE umbracocms
GO

--DROP QUEUE indexqueue
--GO