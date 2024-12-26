USE [Fusion_MSA]
GO

/****** Object:  Table [Dim].[BYOD_VC_Tst]    Script Date: 17-12-2024 19:20:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Dim].[Mod_VC_Tst](
	[VCNPL_ID] [int] IDENTITY(1,1) NOT NULL,
	[FcstAreaId] [int] NOT NULL,
	[FcstArea] [varchar](100) NOT NULL,
	[FieldSubRegionId] [int] NOT NULL,
	[FieldSubRegion] [varchar](100) NOT NULL,
	--[FieldSummarySegmentId] [int] NOT NULL,
	--[FieldSummarySegment] [varchar](100) NOT NULL
) ON [PRIMARY]
GO