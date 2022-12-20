import peewee
import psycopg2
import datetime

CONNECT_DATA = {
    'dbname': 'clothes',
    'user': 'postgres',
    'host': 'localhost',
    'password': 'postgres',
    'port': 5432
}

CONNECTION_STRING = ' '.join(
    [f"{key}='{value}'" for key, value in CONNECT_DATA.items()])

TASK_1 = "SELECT DISTINCT department \
          FROM employee WHERE department NOT IN \
            (SELECT DISTINCT department \
             FROM employee \
             WHERE date_part('year', age(birthdate)) < 25);"

TASK_2 = "WITH first AS \
              (SELECT DISTINCT ON (date_, time_in) employee_id, date_, min(time_) \
              OVER (PARTITION BY employee_id, date_) AS time_in FROM timetable WHERE type_ = 1) \
          SELECT employee.id, employee.fio, time_in \
          FROM first JOIN employee ON first.employee_id = employee.id \
          WHERE date_ = CURRENT_DATE \
          AND time_in = \
              (SELECT min(time_in) \
              FROM first \
              WHERE date_ = CURRENT_DATE);"

TASK_3 = "SELECT  id , fio, count(first.employee_id) \
          FROM \
          	  (SELECT DISTINCT ON (employee_id , date_, time_in) employee_id, date_, min(time_)  \
          	  OVER (PARTITION BY employee_id, date_) AS time_in \
          	  FROM timetable \
          	  WHERE type_ = 1) as first  \
          JOIN employee ON first.employee_id = employee.id \
          WHERE time_in > '09:00:00' \
          GROUP BY id, fio \
          HAVING count(first.employee_id) >= 5;"


def print_result_sql(result):
    for res in result:
        print(res)


def print_result_peewee(data):
    print(' | '.join(str(col) for col in data[0].keys()))

    for string in data:
        print(' | '.join(str(col) for col in string.values()))


class BaseModel(peewee.Model):
    class Meta:
        database = peewee.PostgresqlDatabase('clothes', user='postgres', password='postgres',
                                             host='localhost', port=5432)


class Employee(BaseModel):
    id = peewee.PrimaryKeyField(column_name='id')
    fio = peewee.CharField(column_name='fio')
    birthdate = peewee.DateField(column_name='birthdate')
    department = peewee.CharField(column_name='department')

    class Meta:
        table_name = 'employee'


class Timetable(BaseModel):
    employee_id = peewee.ForeignKeyField(
        Employee, backref="employee_id", on_delete="cascade")
    date_ = peewee.DateField(column_name='date_')
    weekday = peewee.CharField(column_name='weekday')
    time_ = peewee.TimeField(column_name='time_')
    type_ = peewee.IntegerField(column_name='type_')

    class Meta:
        table_name = 'timetable'


def task_1():
    mode = int(input(
        'Выберите тип обработки:\n1) На уровне БД\n2) На уровне приложения\nВаш выбор: '))

    if mode == 1:
        cursor.execute(TASK_1)
        print_result_sql(cursor.fetchall())
    elif mode == 2:
        query = Employee.select(Employee.department).distinct().where(
            Employee.department.not_in(Employee.select(Employee.department).where(
                datetime.datetime.now().year - peewee.fn.Date_part('year', Employee.birthdate) < 25).distinct()
            ))
        print_result_peewee(query.dicts().execute())
    else:
        print('Неизвестная команда')


def task_2():
    mode = int(input(
        'Выберите тип обработки:\n1) На уровне БД\n2) На уровне приложения\nВаш выбор: '))

    if mode == 1:
        cursor.execute(TASK_2)
        print_result_sql(cursor.fetchall())
    elif mode == 2:
        query = Employee.select(Employee.id, Employee.fio, peewee.SQL('time_in')).from_(Timetable.select(
            peewee.fn.Distinct(Timetable.employee_id, Timetable.date_), Timetable.employee_id, Timetable.date_, peewee.fn.min(Timetable.time_).over(
                partition_by=[Timetable.employee_id, Timetable.date_]).alias('time_in')).where(Timetable.type_ == 1)).join(
            Employee, on=(Employee.id == peewee.SQL('employee_id'))).where(peewee.SQL('date_') == datetime.date.today()).order_by(
            peewee.SQL('time_in')).limit(1)
        print_result_peewee(query.dicts().execute())
    else:
        print('Неизвестная команда')


def task_3():
    mode = int(input(
        'Выберите тип обработки:\n1) На уровне БД\n2) На уровне приложения\nВаш выбор: '))

    if mode == 1:
        cursor.execute(TASK_3)
        print_result_sql(cursor.fetchall())
    elif mode == 2:
        query = Employee.select(Employee.id, Employee.fio, peewee.fn.count(peewee.SQL('employee_id'))).from_(Timetable.select(peewee.fn.Distinct(Timetable.employee_id, Timetable.date_), Timetable.employee_id, Timetable.date_,            peewee.fn.min(Timetable.time_).over(partition_by=[
            Timetable.employee_id, Timetable.date_]).alias('time_in')).where(Timetable.type_ == 1)).join(Employee, on=(Employee.id == peewee.SQL('employee_id'))).where(peewee.SQL('time_in') > '09:00:00').group_by(Employee.id, Employee.fio).having(peewee.fn.count(peewee.SQL('employee_id')) >= 5)
        print_result_peewee(query.dicts().execute())
    else:
        print('Неизвестная команда')


def main_menu():
    print('\n       Меню      ')
    print('1) Все отделы, в которых нет сотрудников моложе 25 лет')
    print('2) Найти сотрудника, который пришел на работу раньше всех')
    print('3) Найти сотрудников, опоздавших не менее 5-ти раз')
    print('0) Выход')
    print('Ваш выбор: ', end='')


def main():
    choise = 1

    while choise:
        main_menu()
        choise = int(input())

        if choise == 1:
            task_1()
        elif choise == 2:
            task_2()
        elif choise == 3:
            task_3()
        elif not choise:
            print('Выход...')
        else:
            print('Неизвестная команда!')


if __name__ == '__main__':
    conn = psycopg2.connect(CONNECTION_STRING)
    cursor = conn.cursor()
    main()
