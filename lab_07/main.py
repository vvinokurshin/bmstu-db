import psycopg2
import py_linq
from config import CONNECTION_STRING, PATH
import objs
import utils
import json
from models import Managers, Brands


def linq2obj_menu():
    print('\n Меню  LINQ to Object ')
    print('1) Вывести бренды с id < 10')
    print('2) Посчитать количество брендов из России')
    print('3) Вывести бренды, отсортированные по названию ')
    print('4) Вывести пары старана-количество брендов из нее')
    print('5) Вывести название бренда и фамилию ген. директора')
    print('0) В главное меню')
    print('Ваш выбор: ', end='')


def linq2obj():
    brands = py_linq.Enumerable(objs.create_brands())
    managers = py_linq.Enumerable(objs.create_managers())
    choise = 1

    while choise:
        linq2obj_menu()
        choise = int(input())

        if choise == 1:
            utils.print_table(brands.where(lambda x: x['id'] < 10))
        elif choise == 2:
            print(brands.count(lambda x: x['country'] == 'Россия'))
        elif choise == 3:
            utils.print_table(brands.order_by(lambda x: x['name_company']))
        elif choise == 4:
            utils.print_table(brands.group_by(key_names=['country'], key=lambda x: x['country']).select(
                lambda y: {'country': y.key.country, 'count': y.count()}))
        elif choise == 5:
            utils.print_table(brands.join(managers, lambda x: x['id_manager'], lambda y: y['id']).select(
                lambda x: {'name_company': x[0]['name_company'], 'surname_manager': x[1]['surname']}))
        elif not choise:
            print('Выхожу в главное меню...')
        else:
            print('Неизвестная команда!')


def linq2json_menu():
    print('\n Меню  LINQ to JSON ')
    print('1) Заполнить JSON документа из таблицы brands')
    print('2) Вывести содержимое JSON на экран')
    print('3) Поменять страну бренда с <id> на <country>')
    print('4) Добавить запись в JSON')
    print('0) В главное меню')
    print('Ваш выбор: ', end='')


def to_json(filename, cur):
    cur.execute(
        f"COPY (SELECT json_agg(b) FROM public.brands b) to '/home/data/{filename}';")
    utils.move_file_from_docker(filename)


def read_json(filename):
    with open(f'{PATH}{filename}', 'r') as f:
        return json.load(f)


def save_json(filename, data):
    with open(f'{PATH}{filename}', 'w') as f:
        json.dump(data, f)


def update_json(filename):
    data = read_json(filename)

    if id := utils.input_num('Введите id бренда: '):
        country = input('Введите страну: ')

        for elem in data:
            if elem['id'] == id:
                elem['country'] = country
                save_json(filename, data)
                print('Успешно!')
                return

        print('Такого id не нашлось :(')


def insert_to_json(filename):
    data = read_json(filename)

    if record := utils.input_record():
        data.append(record)
        save_json(filename, data)


def linq2json():
    filename = 'brands_arr.json'
    conn = psycopg2.connect(CONNECTION_STRING)
    cur = conn.cursor()
    choise = 1

    while choise:
        linq2json_menu()
        choise = int(input())

        if choise == 1:
            to_json(filename, cur)
        elif choise == 2:
            utils.print_table(read_json(filename))
        elif choise == 3:
            update_json(filename)
        elif choise == 4:
            insert_to_json(filename)
        elif not choise:
            print('Выхожу в главное меню...')
        else:
            print('Неизвестная команда!')


def linq2sql_menu():
    print('\n       Меню  LINQ to SQL        ')
    print('1) Вывести информацию о ген. директорах, которые родились позже 01.01.1990')
    print('2) Вывести название бренда и фамилию ген. директора')
    print('3) Поменять страну бренда с <id> на <country>')
    print('4) Добавить бренд')
    print('5) Удалить бренд')
    print('6) Вывести столбцы таблицы ген. директоров')
    print('0) В главное меню')
    print('Ваш выбор: ', end='')


def update_record():
    if id := utils.input_num('Введите id бренда: '):
        country = input('Введите страну: ')
        query = Brands.update(country=country).where(Brands.id == id)
        query.execute()
        print('Успешно!')


def insert_record():
    if record := utils.input_record():
        query = Brands.insert({
            Brands.id: record['id'],
            Brands.name_company: record['name_company'],
            Brands.country: record['country'],
            Brands.year_of_create: record['year_of_create'],
            Brands.id_manager: record['id_manager']
        })
        query.execute()
        print('Успешно!')


def delete_record():
    if id := utils.input_num('Введите id бренда: '):
        query = Brands.delete().where(Brands.id == id)
        query.execute()
        print('Успешно!')


def call_procedure():
    conn = psycopg2.connect(CONNECTION_STRING)
    cur = conn.cursor()
    cur.execute("CALL print_columns('general_managers')")

    for notice in conn.notices:
        print(notice)


def linq2sql():
    choise = 1

    while choise:
        linq2sql_menu()
        choise = int(input())

        if choise == 1:
            query = Managers.select().where(Managers.date_of_birth > '01.01.1990')
            utils.print_table(query.dicts().execute())
        elif choise == 2:
            query = Brands.select(Brands.name_company, Managers.surname).join(
                Managers, on=(Brands.id_manager == Managers.id))
            utils.print_table(query.dicts().execute())
        elif choise == 3:
            update_record()
        elif choise == 4:
            insert_record()
        elif choise == 5:
            delete_record()
        elif choise == 6:
            call_procedure()
        elif not choise:
            print('Выхожу в главное меню...')
        else:
            print('Неизвестная команда!')


def main_menu():
    print('\n       Меню      ')
    print('1) LINQ to Object')
    print('2) LINQ to JSON')
    print('3) LINQ to SQL')
    print('0) Выход')
    print('Ваш выбор: ', end='')


def main():
    choise = 1

    while choise:
        main_menu()
        choise = int(input())

        if choise == 1:
            linq2obj()
        elif choise == 2:
            linq2json()
        elif choise == 3:
            linq2sql()
        elif not choise:
            print('Выход...')
        else:
            print('Неизвестная команда!')


if __name__ == '__main__':
    main()
