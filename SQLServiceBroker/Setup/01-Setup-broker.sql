
SELECT name, is_broker_enabled, service_broker_guid FROM sys.databases;

ALTER DATABASE msdb SET ENABLE_BROKER;
ALTER DATABASE CURRENT SET NEW_BROKER  WITH ROLLBACK IMMEDIATE; -- Use ENABLE_BROKER if restoring db
GO

-- Content Queue DDL

CREATE QUEUE [ContentQueue]
GO

CREATE XML SCHEMA COLLECTION UpdateBlogPostMessageSchema AS
N'<?xml version="1.0" encoding="UTF-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="request">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:string" name="nodeType"/>
        <xs:element type="xs:string" name="summary"/>
        <xs:element type="xs:int" name="nodeId"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';

CREATE MESSAGE TYPE [//Recommendations/UpdateBlogPostMessage]
	AUTHORIZATION dbo
	VALIDATION = VALID_XML WITH SCHEMA COLLECTION UpdateBlogPostMessageSchema;
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

CREATE XML SCHEMA COLLECTION WelcomePackMessageSchema AS
N'<?xml version="1.0" encoding="UTF-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="request">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:string" name="name"/>
        <xs:element type="xs:string" name="email"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';

CREATE MESSAGE TYPE [//Member/Email/WelcomePackMessage]
	AUTHORIZATION dbo
	VALIDATION = VALID_XML WITH SCHEMA COLLECTION WelcomePackMessageSchema;
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

--**
-- Media Queue DDL

CREATE QUEUE [MediaQueue];
GO

CREATE XML SCHEMA COLLECTION CdnMessageSchema AS
N'<?xml version="1.0" encoding="UTF-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="request">
    <xs:complexType>
      <xs:sequence>
        <xs:element type="xs:string" name="resource"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>';

-- CDN Invalidation
CREATE MESSAGE TYPE [//Media/Cdn/SetInvalidationMessage]
	AUTHORIZATION dbo
	VALIDATION = VALID_XML WITH SCHEMA COLLECTION CdnMessageSchema;
GO

CREATE CONTRACT [//Media/Cdn/SetInvalidationContract]
	( [//Media/Cdn/SetInvalidationMessage] SENT BY ANY )
GO

CREATE SERVICE [//Media/Cdn/SetInvalidation]
	AUTHORIZATION dbo
	ON QUEUE [MediaQueue]
		( [//Media/Cdn/SetInvalidationContract] );
GO

CREATE SERVICE [//Cdn/InvalidationAgent]
	AUTHORIZATION dbo
	ON QUEUE [MediaQueue]
		( [//Media/Cdn/SetInvalidationContract] );
GO

-- CDN Set Policy
CREATE MESSAGE TYPE [//Media/Cdn/SetPolicyMessage]
	AUTHORIZATION dbo
	VALIDATION = VALID_XML WITH SCHEMA COLLECTION CdnMessageSchema;
GO

CREATE CONTRACT [//Media/Cdn/SetPolicyContract]
	( [//Media/Cdn/SetPolicyMessage] SENT BY ANY )
GO

CREATE SERVICE [//Media/Cdn/SetPolicy]
	AUTHORIZATION dbo
	ON QUEUE [MediaQueue]
		( [//Media/Cdn/SetPolicyContract] );
GO

CREATE SERVICE [//Cdn/PolicyAgent]
	AUTHORIZATION dbo
	ON QUEUE [MediaQueue]
		( [//Media/Cdn/SetPolicyContract] );
GO