import psycopg2
import utils
from config import CONNECTION_STRING, PATH_TO_SCRIPTS

def query(cursor, filename):
    cursor.execute(open(PATH_TO_SCRIPTS + filename, "r").read())
    utils.print_result(cursor.fetchall())


def handler(cursor, mode):
    if 1 <= mode <= 9:
        query(cursor, f"{mode}.sql")
    elif mode == 10:
        filename = utils.generate_data()
        query(cursor, f"{mode}.sql")
        utils.remove_file(filename)
    else:
        print('Введите число от 1 до 10!')


def menu():
    print('\n\n                   Меню:                   ')
    print('1) Вывести среднюю выручку по всем магазинам')
    print('2) Вывести название магазина, его выручку и адрес')
    print('3) Вывести для каждого магазина его название, прибыль\n\
   и среднуюю прибыль по всему ТЦ, в котором он \n\
   находится (группировка по ТЦ)')
    print('4) Вывести колонки таблицы магазинов')
    print('5) Вывести дату самого старшего генерального директора из России')
    print('6) Вывести название, страну и год создания компании из России или 2000-го года')
    print('7) Изменить количество магазинов в ТЦ с id 2 на 100')
    print('8) Вывести название текущей БД')
    print('9) Создать таблицу, содержащую информацию о скидках в магазинах')
    print('10) Заполнить случайными данными созданную таблицу')
    print('0) Выход')


def main():
    conn = psycopg2.connect(CONNECTION_STRING)
    cursor = conn.cursor()
    mode = 1

    while mode:
        menu()

        try:
            mode = int(input('\nВведите пункт меню: '))
        except ValueError:
            print('Введите число!')

        handler(cursor, mode)


if __name__ == "__main__":
    main()

    
    
