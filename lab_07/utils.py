import os
from config import CONTAINER_ID, PATH


def print_table(data):
    print(' | '.join(str(col) for col in data[0].keys()))

    for string in data:
        print(' | '.join(str(col) for col in string.values()))

# def print_json(data):


def delete_newline(filename):
    with open(f'{PATH}{filename}', 'r') as f:
        line = f.readline().replace(' \\n', '')

    with open(f'{PATH}/{filename}', 'w') as f:
        f.write(line)


def move_file_from_docker(filename):
    os.system(f"docker cp {CONTAINER_ID}:/home/data/{filename} {PATH}")
    delete_newline(filename)


def input_num(title):
    try:
        id = int(input(title))
        return id
    except:
        print('Некорректный ввод!')


def input_record():
    if id := input_num('Введите id бренда: '):
        name_company = input('Введите название бренда: ')
        country = input('Введите страну: ')

        if year := input_num('Введите год создания: '):
            if id_manager := input_num('Введите id ген. директора: '):
                return {
                    'id': id,
                    'name_company': name_company,
                    'country': country,
                    'year_of_create': year,
                    'id_manager': id_manager
                }

    return None
