/* задание 2*/
CREATE PROCEDURE [dbo].[sp_report_3]  
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
   
    SELECT 
        SUM(f.quantity) AS [Продажи, шт.],  
        SUM(f.sale_grs) AS [Продажи с НДС, руб.],
        /* новые столбцы: */
        /* средняя цена закупки - деление общей стоимости всех
        закупленных товаров (без НДС в нашем случае) на их общее количество */
        ROUND((SUM(f.cost_net) / SUM(f.quantity)), 2) AS 
                        [Средняя цена закупки без НДС, руб.],
        /* маржа - стоимость продажи минус себестоимость*/
        ROUND(SUM(f.sale_net - f.cost_net), 2) AS [Маржа без НДС, руб.],
        /* наценка = ((цена продажи - себестоимость) * 100% / себестоимость) */
        ROUND(((SUM(f.sale_net - f.cost_net) * 100 )/ SUM(f.cost_net)), 2) AS [Наценка без НДС, %]
    FROM [dbo].[fct_cheque] AS f  
    INNER JOIN [dbo].[dim_goods] AS g  
        ON g.good_id = f.good_id    
    WHERE f.date_id BETWEEN @date_from_int AND @date_to_int  
        AND g.group_name = @good_group_name
END