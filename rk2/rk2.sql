-- Вариант 1
-- 1 задание
CREATE DATABASE RK2;

-- отделы
CREATE TABLE department  (
    id INT PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    employee_id INT NOT NULL
);

-- сотрудники
CREATE TABLE employeers (
    id INT PRIMARY KEY,
    department_id INT NOT NULL REFERENCES department (id),
    post VARCHAR(30) NOT NULL,
    fio VARCHAR(50) NOT NULL,
    salary INT NOT NULL
);

-- медикаменты
CREATE TABLE medications (
    id INT PRIMARY KEY,
    name  VARCHAR(30) NOT NULL,
    manual VARCHAR(30) NOT NULL,
    cost INT NOT NULL
);

-- таблица-связь сотрудников и медикаментов
CREATE TABLE emp2med (
   employee_id INT NOT NULL REFERENCES employeers (id),
   medication_id INT NOT NULL REFERENCES medications (id)
)

-- вставляем данные
INSERT INTO department(id, name, phone, employee_id) VALUES
(1, 'name1', '+79200168231', 10),
(2, 'name2', '+82312312331', 9),
(3, 'name3', '+34314413423', 8),
(4, 'name4', '+3414143434', 7),
(5, 'name5', '+343434343', 6),
(6, 'name6', '+43434343443', 1),
(7, 'name7', '+43143423434', 2),
(8, 'name8', '+43434243', 3),
(9, 'name9', '+3413442343', 4),
(10, 'name10', '+2313321323', 5);

INSERT INTO employeers(id, department_id, post, fio, salary) VALUES
(1, 6, 'director', 'abc', 15000),
(2, 7, 'main person', 'vfg', 16000),
(3, 8, 'director', 'adf', 17000),
(4, 9, 'main person', 'res', 19000),
(5, 10, 'director', 'dfa', 12000),
(6, 5, 'main person', 'fde', 16000),
(7, 4, 'director', 'uyt', 13000),
(8, 3, 'director', 'oiu', 17000),
(9, 2, 'main person', 'wer', 12000),
(10, 1, 'director', 'wer', 16000),
(11, 2, 'simple', 'asd', 15000),
(12, 3, 'simple', 'qwe', 1000);

INSERT INTO medications(id, name, manual, cost) VALUES
(1, 'wow', 'manual1', 1200),
(2, 'hey', 'manual2', 1000),
(3, 'hi', 'manual3', 1130),
(4, 'hello', 'manual4', 1200),
(5, 'bye', 'manual5', 1200),
(6, 'goodbye', 'manual6', 1200),
(7, 'swim', 'manual7', 1200),
(8, 'run', 'manual8', 1500),
(9, 'sleep', 'manual9', 1300),
(10, 'help', 'manual10', 1100);


INSERT INTO emp2med(employee_id, medication_id) VALUES
(1, 5),
(1, 10),
(10, 1),
(12, 8),
(5, 7),
(6, 3),
(5, 3),
(7, 7),
(8, 6),
(9, 5);

-- добавляем FK
ALTER TABLE department
   ADD CONSTRAINT FRKEY_DEP FOREIGN KEY (employee_id) REFERENCES employeers(id);

-- 2 задание
-- 1. Инструкция SELECT, использующая простое выражение CASE
-- Выводит название и регион отдела исходя из его номера
SELECT name,
   CASE
      WHEN phone LIKE '+7%' THEN 'rus'
      WHEN phone LIKE '+34%' THEN 'spain'
      ELSE 'other'
   END AS region
FROM department;

-- 2. Инструкцию, использующую оконную функцию
-- Вывести для каждого сотрудник его фио, зарплату и среднуюю зарплату по всему отделу, в котором он находится (группировка по отделу)
SELECT fio, salary, AVG(salary) OVER(PARTITION BY department_id) AS avg_salary, department_id FROM employeers;

-- 3. Инструкцию SELECT, консолидирующую данные с помощью предложения GROUP BY и предложения HAVING
-- Вывести айди отдела и суммарную зарплату тех сотрудников из тех отделов, у которых максимальная максимальная з.п. равна сумме всех з.п в этом отделе
-- (смысла в запросе мало, но что придумал...)
SELECT department_id, SUM(salary) AS salary
FROM employeers
GROUP BY department_id
HAVING SUM(salary) = MAX(salary);

-- 3 задание
-- Создать хранимую процедуру с двумя входными параметрами - имя базы данных и имя таблицы, которая выводит сведения об индексах
-- указанной таблицы в указанной базе данных

-- Джоиним две таблицы, которые содержат информацию о индексах
-- И накладыаем условие, чтобы выодились информация только о нужной
-- (которая задана в параметрах) таблице.

-- В pg_index - часть инфы об индексах
-- В pg_class - остальная инфа
CREATE OR REPLACE PROCEDURE index_info
(
    db_name_in VARCHAR(32),
    table_name_in VARCHAR(32)
)
AS '
DECLARE
    elem RECORD;
BEGIN
    FOR elem in
        SELECT * FROM pg_index
        JOIN pg_class ON pg_index.indrelid = pg_class.oid
        WHERE relname = table_name_in
    LOOP
        RAISE NOTICE ''elem: %'', elem;
    END LOOP;
END;
' LANGUAGE plpgsql;

CALL index_info('rk-2', 'department');

-- проверка
select *
from pg_index;

SELECT *
FROM pg_index
JOIN pg_class ON pg_index.indrelid=pg_class.oid
WHERE relname='department';