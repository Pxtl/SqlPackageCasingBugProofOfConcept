
CREATE VIEW [dbo].[DateBugDemoView]
AS
SELECT FORMAT(CAST('2018-08-07 2:34:56' AS DATETIME), 'mm') AS MyMinute
	, FORMAT(CAST('2018-08-07 2:34:56' AS DATETIME), 'MM') AS MyMonth
	, FORMAT(CAST('2018-08-07 2:34:56' AS DATETIME), 'mm') AS MyDemoColumn

