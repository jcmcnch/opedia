USE [Opedia]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblApi_Keys](
	[ID] [int] PRIMARY KEY IDENTITY(1,1),
	[Api_Key] [char] (36) UNIQUE NOT NULL,
	[Description] [nvarchar](150),
	[User_ID] [int] NOT NULL,
	CONSTRAINT [FK_UserID] FOREIGN KEY (User_ID)
	REFERENCES [dbo].[tblUsers] (UserID)
) ON [PRIMARY]
GO

---------------------
-- Constraint
---------------------
USE Opedia
GO

ALTER TABLE [tblApi_keys]
ADD CONSTRAINT U_Api_Key UNIQUE (Api_Key)
		    
---------------------
-- Indices
---------------------
		    
USE [Opedia]
GO



CREATE NONCLUSTERED INDEX [IX_tblApi_Keys_UserID] ON [dbo].[tblApi_Keys]
(
	[User_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON [PRIMARY]
GO
		    
CREATE NONCLUSTERED INDEX [IX_tblApi_Keys_Key] ON [dbo].[tblApi_Keys]
(
	[Api_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
ON [PRIMARY]
GO
