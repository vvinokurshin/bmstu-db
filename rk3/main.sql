DROP TABLE IF EXISTS timetable;
DROP TABLE IF EXISTS employee;


CREATE TABLE IF NOT EXISTS employee
(
    id INT PRIMARY KEY,
    fio VARCHAR,
    birthdate DATE,
    department VARCHAR
);

CREATE TABLE IF NOT EXISTS timetable
(
	employee_id INT NOT NULL REFERENCES employee(id),
    date_ DATE,
    weekday VARCHAR,
    time_ time,
    type_ INT
);

INSERT INTO employee VALUES 
    (1, 'Иванов Иван Иванович', '1990-09-25', 'ИТ'),
    (2, 'Петров Петр Петрович', '1987-11-12', 'Бухгалтерия'),
   	(3, 'Иванов Петр Петрович', '2001-11-12', 'ДВ');
    
INSERT INTO timetable VALUES
    (1, '2022-12-14', 'Saturday', '9:00', 1),
    (1, '2018-12-14', 'Saturday', '9:20', 2),
    (2, '2018-12-14', 'Saturday', '9:05', 1),
    (1, '2018-12-14', 'Saturday', '9:25', 1);
   
   
SELECT * FROM employee;
SELECT * FROM timetable;
    
 DROP FUNCTION statistics_late(date);
CREATE OR REPLACE FUNCTION statistics_late(today DATE)
RETURNS TABLE 
(
	time_late int, 
	num_employee int
) AS
$$
    SELECT late, count(*) AS num
   	FROM (SELECT employee_id, extract(epoch from (min(time_) - '09:00:00')) / 60 AS late
          FROM timetable t
          WHERE date_ = today AND type_ = 1
		  GROUP BY employee_id
          HAVING min(time_) > '09:00:00') AS tmp
    GROUP BY late;
$$
LANGUAGE SQL;

SELECT *
FROM statistics_late('2018-12-15');
