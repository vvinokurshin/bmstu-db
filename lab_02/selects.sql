-- 1. Инструкция SELECT, использующая предикат сравнения. 
-- Вывести названия магазинов и ТЦ, у которых количество этажей больше 15 + сортировать по количеству этажей
SELECT shops.name AS shop, sc.name AS shopping_center FROM public.shops JOIN public.sc ON shops.id_sc = sc.id
WHERE sc.number_of_floors > 15 ORDER BY sc.number_of_floors;


-- 2. Инструкция SELECT, использующая предикат BETWEEN
-- Вывести названия тех фирм, зам. директора которых родились между 1995-01-01 и 2000-01-01
SELECT brands.name_company FROM public.brands JOIN public.general_managers ON brands.id_manager = general_managers.id 
WHERE general_managers.date_of_birth BETWEEN '1995-01-01' AND '2000-01-01';


-- 3. Инструкция SELECT, использующая предикат LIKE. 
-- Вывести названия и количество магазинов тех ТЦ, у которых в адресе есть "д. 5"
SELECT sc.name, sc.number_of_shops FROM public.sc
WHERE sc.address LIKE '%д. 5%';


-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом
-- Вывести имя и фамилию владельцев ТЦ, где ТЦ имеет больше 50 магазинов
SELECT owners_sc.name, owners_sc.surname FROM public.owners_sc 
WHERE owners_sc.id_sc IN (SELECT sc.id FROM public.sc 
						  WHERE sc.number_of_shops > 50);
						 
						 
-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом
-- Вывести имя и фамилию тех зам. директоров, день рождения которых есть среди всех дат рождения владельцев тц
SELECT general_managers.name, general_managers.surname FROM public.general_managers
WHERE EXISTS (SELECT * FROM public.owners_sc WHERE owners_sc.date_of_birth = general_managers.date_of_birth);


--  6. Инструкция SELECT, использующая предикат сравнения с квантором
-- Вывести имя и фамилию тех зам. директоров, день рождения которых больше всех дат рождения владельцев тц 
-- (то есть, те зам. директора, которые младше всех владельцев ТЦ)
SELECT general_managers.name, general_managers.surname FROM public.general_managers
WHERE general_managers.date_of_birth > ALL (SELECT owners_sc.date_of_birth FROM public.owners_sc);


-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
-- Вывести количество магазинов во всех ТЦ, количество этажей которых больше 15
SELECT SUM(sc.number_of_shops) AS count_shops FROM public.sc
WHERE sc.number_of_floors > 15;


-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов
-- Вывести название и среднюю выручку всех ТЦ (в каждом ТЦ может быть несколько или ни одного магазина)
SELECT sc.name, 
	(SELECT AVG(shops.profit) FROM public.shops 
	WHERE shops.id_sc = sc.id) AS avg_profit
FROM public.sc;


-- 9. Инструкция SELECT, использующая простое выражение CASE
-- Выводит имя и месяц рождения текстом
SELECT name,
	CASE 
		WHEN date_of_birth::text LIKE '%01%' THEN 'В январе'
		WHEN date_of_birth::text LIKE '%02%' THEN 'В феврале'
		WHEN date_of_birth::text LIKE '%01%' THEN 'В марте'
		ELSE 'После марта'
	END AS birth
FROM general_managers;


-- 10. Инструкция SELECT, использующая поисковое выражение CASE
-- Выводит название и тип ТЦ в зависимости от количества этажей
SELECT name,
	CASE 
		WHEN number_of_floors >= 10 THEN 'Многоэтажка'
		ELSE 'Малоэтажка'
	END AS floors
FROM sc;


-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
-- Вывести названия магазинов и ТЦ в новую таблицу
SELECT shops.name AS shop, sc.name AS shopping_center
   INTO shops_n_sc 
   FROM public.shops JOIN public.sc ON shops.id_sc = sc.id;
SELECT * FROM shops_n_sc;
DROP TABLE shops_n_sc;


-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
-- ТЦ с максимальной выручкой
SELECT t.name, SSQ AS price_all 
FROM public.sc AS t JOIN
	(
		SELECT t1.id, profit AS SSQ
		FROM public.shops AS t1
		GROUP BY t1.id 
	) AS od ON od.id = t.id ORDER BY price_all DESC LIMIT 1

	
--13 Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
-- Вывести названия ТЦ, у которых максимальная и минимальная выручка со всех магазинов
SELECT 'MAX' AS Cr, t.name
FROM public.sc AS t 
WHERE id =
	(
		SELECT t1.id_sc
		FROM public.shops AS t1
		GROUP BY id 
		HAVING profit = 
		(
			SELECT MAX(SQ)
			FROM 
			(
				SELECT SUM(profit) AS SQ
				FROM public.shops 
				GROUP BY id 			
			) AS od 
		)
	)
UNION 
SELECT 'MIN' AS Cr, t.name
FROM public.sc AS t 
WHERE id =
	(
		SELECT t1.id_sc
		FROM public.shops AS t1
		GROUP BY id 
		HAVING profit = 
		(
			SELECT MIN(SQ)
			FROM 
			(
				SELECT SUM(profit) AS SQ
				FROM public.shops 
				GROUP BY id 			
			) AS od 
		)
	);


-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 
-- Для каждого ТЦ получить его название, суммарную, среднюю и максимальную выручку
SELECT sc.name,
	   SUM(p.profit) AS sum_profit,
	   AVG(p.profit) AS avg_profit, 
	   MAX(p.profit) AS max_profit
FROM public.sc JOIN public.shops AS p ON p.id_sc = sc.id 
GROUP BY sc.name;


-- 15.Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING
-- Вывести название и суммарную прибыль тех тц, к у которых максимальная выручка равна сумме всей выручки
SELECT sc.name, SUM(p.profit) AS profit
FROM public.sc JOIN public.shops AS p ON p.id_sc = sc.id 
GROUP BY sc.name
HAVING SUM(p.profit) = MAX(p.profit);


-- 16.Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений. 
INSERT INTO public.brands (name_company, country, year_of_create, id_manager) VALUES ('Мозайка', 'Россия', 1990-01-02, 3);
SELECT * FROM public.brands;


-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса. 
INSERT INTO public.brands (name_company, country, year_of_create, id_manager) 
SELECT brands.name_company, brands.country, brands.year_of_create, brands.id_manager FROM public.brands 
WHERE brands.id_manager < 5;
SELECT * FROM public.brands;


-- 18. Простая инструкция UPDATE
UPDATE public.shops
SET name = 'Гуччи'
WHERE id = 35;
SELECT * FROM public.shops;


-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET
UPDATE public.shops
SET name = (SELECT sc.name
 	FROM public.sc
 	WHERE id = 35 )
WHERE id = 35;
SELECT * FROM public.shops;


-- 20. Простая инструкция DELETE
DELETE FROM public.brands
WHERE id = 1001;
SELECT * FROM public.brands;


-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE. 
DELETE FROM public.links_brands_n_shops 
WHERE links_brands_n_shops.id_brand IN 
	(SELECT id FROM public.brands  
	WHERE brands.name_company  = 'Квадра');
SELECT * FROM public.links_brands_n_shops;


--22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- Средняя выручка всех ТЦ
WITH tmp (SupplierNo, NumberOfShips) AS (
	SELECT sc.name, 
		(SELECT AVG(shops.profit) FROM public.shops 
		WHERE shops.id_sc = sc.id) AS avg_profit
	FROM public.sc
)
SELECT AVG(NumberOfShips) AS avg_value
FROM tmp; 


-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
DROP TABLE IF EXISTS public.department;
CREATE TABLE public.department (
	id int PRIMARY KEY GENERATED ALWAYS AS identity,
	name varchar(20) NOT NULL,
	manager_id int
);
INSERT INTO public.department (name, manager_id)
VALUES 
	('Валера', NULL),
	('Дима', 1),
	('Андрей', 1),
	('Коля', 2),
	('Лена', 2),
	('Степан', 3),
	('Антон', 4);
SELECT * FROM public.department;

WITH RECURSIVE res(id, name, manager_id, level_user)
   AS
   (    
        SELECT id, name, manager_id, 0 AS LevelUser 
        FROM public.department WHERE manager_id IS NULL
        UNION ALL
        SELECT t1.id, t1.name, t1.manager_id, t2.level_user + 1 
        FROM public.department t1 
        JOIN res AS t2 ON t1.manager_id = t2.id
   )
SELECT * FROM res ORDER BY level_user;


--24.  Оконные функции. Использование конструкций MIN/MAX/AVG OVER() 
-- Вывести для каждого магазина его название, прибыль и среднуюю прибыль по всему ТЦ, в котором он находится (группировка по ТЦ)
SELECT id, name, profit, AVG(profit) OVER(PARTITION BY id_sc) AS avg_profit, id_sc FROM public.shops;


--25. Оконные фнкции для устранения дублей
--Из той таблицы, которая была получена в предыдущем запросе нужно удилть дубликаты
WITH tmp_1 AS (
	WITH tmp AS (
		SELECT id_sc, AVG(profit) 
						 OVER(PARTITION BY id_sc) AS avg_profit 
		FROM public.shops)
	SELECT id_sc, avg_profit, ROW_NUMBER() 
								OVER(PARTITION BY id_sc, avg_profit) 
								AS rownum 
	FROM tmp)
SELECT id_sc, avg_profit FROM tmp_1 WHERE rownum = 1;
 

-- Защита
WITH tmp (name, number_of_employees, profit) AS (
SELECT shops.name, shops.number_of_employees, shops.profit 
FROM public.shops JOIN public.links_brands_n_shops ON shops.id = links_brands_n_shops.id_shop 
				  JOIN public.brands ON links_brands_n_shops.id_brand = brands.id
WHERE brands.country = 'Россия')
SELECT 'MIN number' AS type_req, name, number_of_employees, profit FROM tmp
ORDER BY number_of_employees LIMIT 1;

WITH tmp (name, number_of_employees, profit) AS (
SELECT shops.name, shops.number_of_employees, shops.profit 
FROM public.shops JOIN public.links_brands_n_shops ON shops.id = links_brands_n_shops.id_shop 
				  JOIN public.brands ON links_brands_n_shops.id_brand = brands.id
WHERE brands.country = 'Россия')
SELECT 'MAX profit' AS type_req, name, number_of_employees, profit FROM tmp
ORDER BY profit DESC LIMIT 1;
