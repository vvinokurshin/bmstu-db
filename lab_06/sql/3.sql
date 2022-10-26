WITH tmp AS 
(
	SELECT id, name, profit, id_sc
	FROM public.shops
)

SELECT name, AVG(profit) OVER(PARTITION BY id_sc) AS avg_profit, id_sc FROM public.shops;