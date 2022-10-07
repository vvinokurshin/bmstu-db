select * from pg_language;
SELECT name, default_version, installed_version FROM pg_available_extensions;
create extension plpython3u;

-- Определяемую пользователем скалярную функцию CLR
-- Получить максимальное количество магазинов ТЦ, среди тех ТЦ, у которых количество этажей равно ..
CREATE OR REPLACE FUNCTION max_count_shops(in_count_floors int)
RETURNS int
AS $$
res = plpy.execute(f' \
    SELECT MAX(number_of_shops) \
    FROM sc  \
    WHERE number_of_floors = {in_count_floors};')
if res:
    return res[0]['max']
$$ LANGUAGE plpython3u;

SELECT * FROM max_count_shops(18);

-- Пользовательскую агрегатную функцию CLR
-- Для таблицы ген. директоров посчитать количество человек в каждой стране
CREATE OR REPLACE FUNCTION count_gm(country VARCHAR(50))
RETURNS INT
AS $$
cur_count = 0
res = plpy.execute(f" \
				select * \
				from public.general_managers;")
for item in res:
	if item["citizenship"] == country:
		cur_count += 1
return cur_count
$$ LANGUAGE plpython3u;

SELECT citizenship, count_gm(citizenship) 
FROM public.general_managers
GROUP BY citizenship;

-- Определяемая пользователем табличную функцию CLR
-- Вывести названия и специализацию магазинов, которые располагаются в ТЦ, количество этажей которых равно  ..
CREATE OR REPLACE FUNCTION filter_shops_by_floors_sc(count_floors INT)
RETURNS TABLE 
(
	name VARCHAR(50),
	specialization VARCHAR(20)
) AS $$
res = plpy.execute(f" \
				select shops.name, shops.specialization, sc.number_of_floors \
				from public.shops JOIN public.sc ON shops.id_sc = sc.id;")
res_table = []
if res:
	for item in res:
		if item['number_of_floors'] == count_floors:
			res_table.append(item)
return res_table
$$ LANGUAGE plpython3u;

SELECT * FROM filter_shops_by_floors_sc(18);


-- Хранимая процедура CLR
-- Изменить количество этажей в ТЦ с id ... на ...
CREATE OR REPLACE PROCEDURE public.change_num_floors(new_value int, certain_id int)
AS $$
	plan = plpy.prepare("UPDATE public.sc \
						 SET number_of_floors = $1 where id = $2", ["INT", "INT"])
	plpy.execute(plan, [new_value, certain_id])
$$ LANGUAGE plpython3u;

CALL public.change_num_floors(1, 1);
SELECT * FROM public.sc;


-- Триггер CLR
-- Если мы обновляем страну какого-то бренда - у всех брендов с этой страной значение также обновляется
CREATE OR REPLACE FUNCTION update_num_shops_trigger()
RETURNS TRIGGER 
AS $$
old_num = TD["old"]["number_of_shops"]
new_num = TD["new"]["number_of_shops"]
run = plpy.execute(f" \
update public.sc set number_of_shops = {new_num} \
where sc.number_of_shops = {old_num}")
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER update_num_shops
AFTER UPDATE ON public.sc 
FOR EACH ROW 
EXECUTE PROCEDURE update_num_shops_trigger();

UPDATE public.sc  
SET number_of_shops = 2
WHERE sc.id = 1;

SELECT * FROM public.sc;


-- Определяемый пользователем тип данных CLR
-- Получить по айди название и адрес магазина
CREATE TYPE info_shop as
(
	name VARCHAR(50),
	address VARCHAR(100)
);

CREATE OR REPLACE FUNCTION get_info_shop(in_id INT)
RETURNS info_shop 
AS $$
res = plpy.execute(f" \
					SELECT shops.name, sc.address \
					FROM public.shops JOIN public.sc \
						 			  ON shops.id_sc = sc.id \
					WHERE shops.id = {in_id};")
if res:
	return (res[0]['name'], res[0]['address'])
$$ LANGUAGE plpython3u;

SELECT * FROM get_info_shop(1);
