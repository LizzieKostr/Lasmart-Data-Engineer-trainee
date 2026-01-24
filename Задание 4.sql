/* задание 4 */
CREATE PROCEDURE [dbo].[sp_report_5]  
    @date_from date,  
    @date_to date,  
    @good_group_name nvarchar(MAX)  
AS  
BEGIN  

    DECLARE @date_from_int int = 
        YEAR(@date_from) * 10000 +
        MONTH(@date_from) * 100 +
        DAY(@date_from)

    DECLARE @date_to_int int = 
        YEAR(@date_to) * 10000 +
        MONTH(@date_to) * 100 +
        DAY(@date_to)

    DECLARE @Groups TABLE (
        group_name NVARCHAR(250) PRIMARY KEY
        )

    INSERT INTO @Groups (group_name) 
    SELECT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@good_group_name, ',')
   
   
 SELECT 
    d.d AS [Дата],  
    s.store_name AS [Аптека],  
    g.group_name AS [Группа товара] ,  
    g.good_name AS [Номенклатура],  
    /* доля продаж в % = (продажи этого товара * 100 / все продажи в этот день 
                                                       в этом магазине
                                                       в этой группе)  */
    ROUND(SUM(f.sale_grs) * 100 /
        SUM(SUM(f.sale_grs)) OVER (
            PARTITION BY d.d, s.store_id, g.group_name
                                   ), 2
          ) AS [Доля продаж в группе, %]
 
 FROM [dbo].[fct_cheque] AS f  
 INNER JOIN [dbo].[dim_goods] AS g  
    ON g.good_id = f.good_id  
 INNER JOIN [dbo].[dim_stores] AS s  
    ON s.store_id = f.store_id  
 INNER JOIN [dbo].[dim_date] AS d  
    ON d.did = f.date_id   
 INNER JOIN @Groups AS grp
    ON grp.group_name = g.group_name

 WHERE date_id BETWEEN @date_from_int AND @date_to_int   
 GROUP BY 
    d.d,  
    s.store_id,
    s.store_name,  
    g.group_name,  
    g.good_name  
 ORDER BY
  [Доля продаж в группе, %] DESC,
  d.d,
  s.store_name,
  g.group_name

END