
CREATE TABLE [EXTRACT_MDATA].[UPLOAD_JOB_LINES_FOR_DISCOUNT]
( 
	[Change Type] [nvarchar](max)  NULL,
	[Year] [nvarchar](max)  NULL,
	[Week Number] [nvarchar](max)  NULL,
	[Group Code] [nvarchar](max)  NULL,
	[Start Date] [nvarchar](max)  NULL,
	[End Date] [nvarchar](max)  NULL,
	[Duration] [nvarchar](max)  NULL,
	[Item ID] [nvarchar](max)  NULL,
	[Item Type Code] [nvarchar](max)  NULL,
	[Buying period before] [nvarchar](max)  NULL,
	[Buying period after] [nvarchar](max)  NULL,
	[Deal Total] [nvarchar](max)  NULL,
	[Deal Breakdown 1] [nvarchar](max)  NULL,
	[Deal Type 1] [nvarchar](max)  NULL,
	[Deal Breakdown 2] [nvarchar](max)  NULL,
	[Deal Type 2] [nvarchar](max)  NULL,
	[Deal Breakdown 3] [nvarchar](max)  NULL,
	[Deal Type 3] [nvarchar](max)  NULL,
	[Deal Breakdown 4] [nvarchar](max)  NULL,
	[Deal Type 4] [nvarchar](max)  NULL,
	[Promotional Price 1] [nvarchar](max)  NULL,
	[Deal Type] [nvarchar](max)  NULL,
	[Promotion Type Code] [nvarchar](max)  NULL,
	[Media Placement Code] [nvarchar](max)  NULL,
	[Promotion Message] [nvarchar](max)  NULL,
	[Scan 1] [nvarchar](max)  NULL,
	[Scan Type 1] [nvarchar](max)  NULL,
	[Scan 2] [nvarchar](max)  NULL,
	[Scan Type 2] [nvarchar](max)  NULL,
	[Scan 3] [nvarchar](max)  NULL,
	[Scan Type 3] [nvarchar](max)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)