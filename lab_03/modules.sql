-- 1. Скалярная функция
-- Вывести дату самого старшего генерального директора из ...
CREATE OR REPLACE FUNCTION public.max_date_gm(country VARCHAR(50))
RETURNS date AS '
	SELECT MAX(date_of_birth)
	FROM public.general_managers
	WHERE general_managers.citizenship = country;
' LANGUAGE SQL;

SELECT public.max_date_gm('Россия');


-- 2. Подставляемая табличная функция
-- Вывести названия и год создания брендов, генеральный директор которых из ...
CREATE OR REPLACE FUNCTION public.get_info_brand_by_country_gm(my_country VARCHAR(50))
RETURNS TABLE 
(
	name_company VARCHAR(100), 
	year_of_create INT
) 
AS '
	SELECT brands.name_company, brands.year_of_create
	FROM public.brands JOIN public.general_managers 
		ON brands.id_manager = general_managers.id 
	WHERE general_managers.citizenship = my_country
' LANGUAGE SQL;

SELECT * FROM public.get_info_brand_by_country_gm('Россия');


-- 3. Многооператорная табличная функция
-- Вывести название, страну и год создания компании из такой-то страны или такого-то года
CREATE OR REPLACE FUNCTION public.filter_country_or_year(my_country VARCHAR(40), my_year INT)
RETURNS TABLE 
(
	name_company VARCHAR(100), 
	country VARCHAR(40),
	year_of_create INT
)
AS ' 
begin
	RETURN QUERY
	SELECT brands.name_company, brands.country, brands.year_of_create
	FROM public.brands
	WHERE brands.country = my_country;
	
	RETURN QUERY
	SELECT brands.name_company, brands.country, brands.year_of_create
	FROM public.brands
	WHERE brands.year_of_create = my_year;
end;
' LANGUAGE plpgsql;

SELECT * FROM public.filter_country_or_year('Россия', 2000);


-- 4. Рекурсивная функция
DROP TABLE IF EXISTS public.department;
CREATE TABLE public.department (
	id_em int PRIMARY KEY GENERATED ALWAYS AS identity,
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

-- Выводит иерархию сотрудника по его айди
CREATE OR REPLACE FUNCTION public.branch_employee(in_id INT)
RETURNS TABLE
(
	id INT
)
AS '
	DECLARE
	    cur_manager_id INT;
	BEGIN
		SELECT manager_id INTO cur_manager_id
		FROM public.department 
		WHERE department.id_em = in_id;

		IF cur_manager_id IS NOT NULL 
		THEN
	    	RETURN QUERY
			SELECT d1.id_em
				FROM public.department d1
				WHERE d1.id_em = in_id
			UNION ALL
				SELECT *
				FROM public.branch_employee(cur_manager_id);
	    ELSE 
			RETURN QUERY
			SELECT in_id as id;
		END IF;
	END;
' LANGUAGE plpgsql;

SELECT d.name FROM public.branch_employee(7) AS b JOIN public.department AS d ON b.id = d.id_em;


-- 5. Хранимая процедуру без параметров или с параметрами
-- Изменить количество магазинов в ТЦ с id ... на ...
CREATE OR REPLACE PROCEDURE public.change_num_shops(new_value int, certain_id int)
AS '
BEGIN
	UPDATE public.sc 
    SET number_of_shops = new_value
    WHERE sc.id = certain_id;
END;
' LANGUAGE plpgsql;
   
CALL public.change_num_shops(342, 1);
SELECT * FROM public.sc;


-- 6. Рекурсивная процедура
DROP TABLE IF EXISTS public.department;
CREATE TABLE public.department (
	id_em int PRIMARY KEY GENERATED ALWAYS AS identity,
	name varchar(20) NOT NULL,
	manager_id int,
	checked bool
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

-- Обновить столбец checked у выбранного сотрудника на TRUE (а также, у всех его руководителей)
CREATE OR REPLACE PROCEDURE public.set_status(in_id INT)
AS '
	DECLARE
	    cur_manager_id INT;
	BEGIN
		SELECT manager_id INTO cur_manager_id
		FROM public.department 
		WHERE department.id_em = in_id;

		UPDATE public.department 
	    SET checked = TRUE
	    WHERE department.id_em = in_id;

		IF cur_manager_id IS NOT NULL 
		THEN
			CALL PUBLIC.set_status(cur_manager_id);
		END IF;
	END;
' LANGUAGE plpgsql; 

CALL public.set_status(7);
SELECT * FROM public.department;


-- 7. Хранимая процедура с курсором
-- Заменить название страны на другое
CREATE OR REPLACE PROCEDURE public.change_country_gm
(
	old_country VARCHAR(100),
	new_country VARCHAR(100)
)
AS '
DECLARE
	cur_id INT;
    myCursor CURSOR 
	FOR
      	SELECT general_managers.id FROM public.general_managers
		WHERE general_managers.citizenship = old_country;
BEGIN
    OPEN myCursor;
    LOOP
        FETCH myCursor
        INTO cur_id;
        EXIT WHEN NOT FOUND;
        UPDATE public.general_managers 
	    SET citizenship = new_country
	    WHERE general_managers.id = cur_id;
    END LOOP;
    CLOSE myCursor;
END;
'LANGUAGE  plpgsql;

CALL change_country_gm('Центральноафриканская Республика', 'ЦАР');
SELECT * FROM public.general_managers;


-- 8. Хранимая процедура доступа к метаданным
-- Вывести в консоль список колонок в таблице под названием ...
CREATE OR REPLACE PROCEDURE print_columns(
	name_ VARCHAR(100)
)
AS ' 
DECLARE
	el RECORD;
BEGIN
	FOR el IN
		SELECT column_name
		FROM information_schema.columns
        WHERE table_name = name_
	LOOP
		RAISE NOTICE ''el = %'', el;
	END LOOP;
END;
' LANGUAGE plpgsql;

CALL print_columns('general_managers');


-- 9. Триггер AFTER
-- Если мы обновляем страну какого-то бренда - у всех брендов с этой страной значение также обновляется
CREATE OR REPLACE FUNCTION update_country_trigger()
RETURNS TRIGGER 
AS '
BEGIN
	UPDATE public.brands
	SET country = new.country
	WHERE brands.country = old.country;
	
	RETURN new;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER update_country
AFTER UPDATE ON public.brands 
FOR EACH ROW 
EXECUTE PROCEDURE update_country_trigger();

UPDATE public.brands  
SET country = 'Страна'
WHERE brands.id = 2;

SELECT * FROM public.brands;


-- 10. Триггер INSTEAD OF
DROP TABLE IF EXISTS public.department;
CREATE TABLE public.department (
	id_em int PRIMARY KEY GENERATED ALWAYS AS identity,
	name varchar(20)
);
INSERT INTO public.department (name)
VALUES 
	('Валера'),
	('Дима'),
	('Андрей'),
	('Коля'),
	('Лена'),
	('Степан'),
	('Антон');
SELECT * FROM public.department;

-- Создаем копию, так как с таблицей почему-то не работает
DROP VIEW IF EXISTS public.department_buf;
CREATE VIEW department_buf AS 
	SELECT * FROM public.department;
SELECT * FROM department_buf;

-- Вместо того, чтобы удалять строку я заполню ее налом
CREATE OR REPLACE FUNCTION del_record_triger()
RETURNS TRIGGER 
AS ' 
BEGIN
    UPDATE public.department_buf
    SET name = NULL
    WHERE department_buf.id_em = old.id_em;
    RETURN new;
END;
' LANGUAGE plpgsql;

CREATE TRIGGER del_record
INSTEAD OF DELETE ON department_buf
	FOR EACH ROW 
	EXECUTE PROCEDURE del_record_triger();

DELETE FROM public.department_buf 
WHERE department_buf.id_em = 1;

SELECT * FROM department_buf;
DROP view department_buf;


-- Защита
-- ВЫвкести общиую прибыль конкретного ТЦ
CREATE OR REPLACE FUNCTION public.profit_sc(in_id_sc INT)
RETURNS INT AS '
	SELECT SUM(profit)
	FROM public.shops
	WHERE shops.id_sc = in_id_sc;
' LANGUAGE SQL;

SELECT public.profit_sc(2);
