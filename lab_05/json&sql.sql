-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь JSON

COPY 
	(SELECT row_to_json(b) FROM public.brands b) 
to '/home/data/brands.json';

COPY 
	(SELECT row_to_json(gm) FROM public.general_managers gm) 
to '/home/data/general_managers.json';

COPY 
	(SELECT row_to_json(lbns) FROM public.links_brands_n_shops lbns) 
to '/home/data/links_brands_n_shops.json';

COPY 
	(SELECT row_to_json(os) FROM public.owners_sc os) 
to '/home/data/owners_sc.json';

COPY 
	(SELECT row_to_json(s) FROM public.sc s) 
to '/home/data/sc.json';

COPY 
	(SELECT row_to_json(s2) FROM public.shops s2) 
to '/home/data/shops.json';


-- 2. Выполнить загрузку и сохранение JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

DROP TABLE IF EXISTS gm_import;
CREATE TABLE IF NOT EXISTS gm_import(doc json);
COPY gm_import FROM '/home/data/general_managers.json';
SELECT * FROM gm_import;

INSERT INTO public.general_managers (id, surname, name, patronymic, citizenship, date_of_birth)
SELECT (doc->>'id')::int, doc->>'surname', doc->>'name', doc->>'patronymic',
	   doc->>'citizenship', (doc->>'date_of_birth')::date FROM gm_import;
	  
SELECT * FROM general_managers;


DROP TABLE IF EXISTS brands_import;
CREATE TABLE IF NOT EXISTS brands_import(doc json);
COPY brands_import FROM '/home/data/brands.json';
SELECT * FROM brands_import;

INSERT INTO public.brands (id, name_company, country, year_of_create, id_manager)
SELECT (doc->>'id')::int, doc->>'name_company', doc->>'country',
	   (doc->>'year_of_create')::int, (doc->>'id_manager')::int FROM brands_import;
	  
SELECT * FROM brands;


DROP TABLE IF EXISTS sc_import;
CREATE TABLE IF NOT EXISTS sc_import(doc json);
COPY sc_import FROM '/home/data/sc.json';
SELECT * FROM sc_import;

INSERT INTO public.sc (id, name, address, number_of_floors, number_of_shops)
SELECT (doc->>'id')::int, doc->>'name', doc->>'address',
	   (doc->>'number_of_floors')::int, (doc->>'number_of_shops')::int FROM sc_import;
	  
SELECT * FROM sc;


DROP TABLE IF EXISTS shops_import;
CREATE TABLE IF NOT EXISTS shops_import(doc json);
COPY shops_import FROM '/home/data/shops.json';
SELECT * FROM shops_import;

INSERT INTO public.shops (id, name, specialization, number_of_employees, profit, id_sc)
SELECT (doc->>'id')::int, doc->>'name', doc->>'specialization', (doc->>'number_of_employees')::int,
	   (doc->>'profit')::int, (doc->>'id_sc')::int FROM shops_import;

SELECT * FROM shops;


DROP TABLE IF EXISTS owners_sc_import;
CREATE TABLE IF NOT EXISTS owners_sc_import(doc json);
COPY owners_sc_import FROM '/home/data/owners_sc.json';
SELECT * FROM owners_sc_import;

INSERT INTO public.owners_sc (id, surname, name, patronymic, citizenship, date_of_birth, id_sc)
SELECT (doc->>'id')::int, doc->>'surname', doc->>'name', doc->>'patronymic',
	   doc->>'citizenship', (doc->>'date_of_birth')::date, (doc->>'id_sc')::int FROM owners_sc_import;
	  
SELECT * FROM owners_sc;


DROP TABLE IF EXISTS links_import;
CREATE TABLE IF NOT EXISTS links_import(doc json);
COPY links_import FROM '/home/data/links_brands_n_shops.json';
SELECT * FROM links_import;

INSERT INTO public.links_brands_n_shops (id_shop, id_brand)
SELECT (doc->>'id_shop')::int, (doc->>'id_brand')::int FROM links_import;

SELECT * FROM links_brands_n_shops;


-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом JSON, или
-- добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE. 

-- Новая таблица с единственным полем json
DROP TABLE IF EXISTS shops_json;
CREATE TABLE IF NOT EXISTS shops_json(
	info json
);

INSERT INTO shops_json(info) VALUES
('{"id": 1, "name": "Пятерочка", "specialization": "Продукты", "number_of_employees": 50}'),
('{"id": 2, "name": "Магнит", "specialization": "Продукты", "number_of_employees": 100}'),
('{"id": 3, "name": "H&M", "specialization": "Одежда", "number_of_employees": 150}'),
('{"id": 4, "name": "Bershka", "specialization": "Одежда", "number_of_employees": 50}'),
('{"id": 5, "name": "CR", "specialization": "Одежда", "number_of_employees": 10}');

SELECT * FROM shops_json;

-- Вставка одного поля в уже сущетвующую таблицу
DROP TABLE IF EXISTS shops_json_1;
CREATE TABLE IF NOT EXISTS shops_json_1(
	id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
	address jsonb
);

INSERT INTO shops_json_1(id, name) VALUES
(1, 'Пятерочка'),
(2, 'Магнит'),
(3, 'H&M'),
(4, 'Bershka'),
(5, 'CR');

SELECT * FROM shops_json_1;

UPDATE shops_json_1
SET address = ('{"city": "Москва", "street": "Арбатская"}')
WHERE id = 1;

UPDATE shops_json_1
SET address = ('{"city": "Заволжье", "street": "Пушкина"}')
WHERE id = 2;

UPDATE shops_json_1
SET address = ('{"city": "Нижний Новгород", "street": "Рождественская"}')
WHERE id = 3;

UPDATE shops_json_1
SET address = ('{"city": "Москва", "street": "1-я парковая"}')
WHERE id = 4;

UPDATE shops_json_1
SET address = ('{"city": "Заволжье", "street": "Ленина"}')
WHERE id = 5;

SELECT * FROM shops_json_1;


-- 4. Выполнить следующие действия:
-- 4.1. Извлечь JSON фрагмент из JSON документа

SELECT info->'name', info->'number_of_employees'
FROM shops_json;

-- 4.2. Извлечь значения конкретных узлов или атрибутов JSON документа
SELECT id, address->'city'
FROM shops_json_1;

-- 4.3. Выполнить проверку существования узла или атрибута
CREATE OR REPLACE FUNCTION is_exist(info json, my_key text)
RETURNS bool AS 
$$
BEGIN 
	RETURN (info->my_key) IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

select is_exist(shops_json.info, 'id') FROM shops_json;
select is_exist(shops_json.info, 'surname') FROM shops_json;

-- 4.4. Изменить JSON документ
SELECT * FROM shops_json_1;

UPDATE shops_json_1
SET address = address || '{"street":"Дзержинского"}'::jsonb
WHERE id = 5;

SELECT * FROM shops_json_1;

-- 4.5. Разделить JSON документ на несколько строк по узлам

DROP TABLE IF EXISTS shops_json;
CREATE TABLE IF NOT EXISTS shops_json(
	info json
);

INSERT INTO shops_json(info) VALUES
('[{"id": 1, "name": "Пятерочка", "specialization": "Продукты", "number_of_employees": 50},
{"id": 2, "name": "Магнит", "specialization": "Продукты", "number_of_employees": 100},
{"id": 3, "name": "H&M", "specialization": "Одежда", "number_of_employees": 150},
{"id": 4, "name": "Bershka", "specialization": "Одежда", "number_of_employees": 50},
{"id": 5, "name": "CR", "specialization": "Одежда", "number_of_employees": 10}]');

SELECT * FROM shops_json;

select jsonb_array_elements(info::jsonb)
from shops_json;
