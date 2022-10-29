import datetime
import os
import random as r

def is_date(num):
    return isinstance(num, datetime.date)

def is_int(num):
    return num == int(num)

def to_num(num):       
    if is_date(num) or is_int(num):
        return f'{num} |  '
    else:
        return "{:.2f} |  ".format(num)


def print_result(result):
    print('\nРезультат:')

    for i in range(len(result)):
        print('\n|  ', end="")
        for j in range (len(result[0])):
            try:
                print(to_num(result[i][j]), end = "")
            except ValueError:
                print(result[i][j], " |  ", end = "") 

DISCOUNTS = [i for i in range(5, 100, 5)]

def generate_data():
    filename = 'discounts.csv'
    with open(filename, 'w') as f:
        f.write('id;amount;id_shop\n')

        for i in range(1, 11):
            f.write(f'{i};{DISCOUNTS[r.randint(0, len(DISCOUNTS) - 1)]};{r.randint(1, 1000)}\n')

    os.system(f"docker cp {filename} 672aeabea2a2:/home/data")

    return filename

def remove_file(filename):
    os.remove(filename)