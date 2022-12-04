CREATE TABLE table1 (
	id int,
	var1 TEXT,
	valid_from_dttm date,
	valid_to_dttm date
);

CREATE TABLE table2 (
	id int,
	var2 TEXT,
	valid_from_dttm date,
	valid_to_dttm date
);


INSERT INTO table1(id, var1, valid_from_dttm, valid_to_dttm) VALUES 
(1, 'A', '2018-09-01', '2018-09-15'),
(1, 'B', '2018-09-16', '5999-12-31');

INSERT INTO table2(id, var2, valid_from_dttm, valid_to_dttm) VALUES 
(1, 'A', '2018-09-01', '2018-09-18'),
(1, 'B', '2018-09-19', '5999-12-31');


-- в качестве первой даты выбираем большую, а в качестве второй - меньшую, так как
-- нам необходимо найти наимеший интервал
SELECT table1.id, table1.var1, table2.var2, 
		CASE 
			WHEN table2.valid_from_dttm > table1.valid_from_dttm THEN 
				table2.valid_from_dttm
			ELSE
				table1.valid_from_dttm
		END AS valid_from_dttm,
		CASE 
			WHEN table1.valid_to_dttm < table2.valid_to_dttm THEN 
				table1.valid_to_dttm
			ELSE
				table2.valid_to_dttm
		END AS valid_to_dttm
-- делаем такой джойн, так как нам нужны все пересекающиеся данные в таблицах 
-- также нам надо добавить еще два условия соденинения, так как начало должно быть меньше конца
FROM table1 FULL OUTER JOIN table2 ON table1.id = table2.id 
								   AND table2.valid_from_dttm < table1.valid_to_dttm
		     					   AND table1.valid_from_dttm < table2.valid_to_dttm
-- сортируем по айди и дате начала
ORDER BY id, valid_from_dttm;
