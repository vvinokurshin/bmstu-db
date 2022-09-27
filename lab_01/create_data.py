from faker import Faker
from russian_names import RussianNames
import random as r
import datetime

fake = Faker(locale='ru_Ru')

def generate_managers():
    with open('data/managers.csv', 'w') as f:
        f.write('surname;name;patronymic;citizenship;date_of_birth\n')
        for _ in range(1, 1001):
            name, patronymic, surname = RussianNames().get_person().split()
            date_of_birth = fake.date_between_dates(datetime.date(1972, 1, 1), datetime.date(2000, 1, 1))
            citizenship = fake.country()
            f.write(f'{surname};{name};{patronymic};{citizenship};{date_of_birth}\n')

def generate_brands():
    with open('data/brands.csv', 'w') as f:
        f.write('name_company;country;date_of_create;id_manager\n')
        ids_managers = [i for i in range(1, 1001)]
        count = len(ids_managers)

        for _ in range(1, 1001):
            name_company = fake.company()
            country = fake.country()
            date_of_create = fake.date_between_dates(datetime.date(1900, 1, 1), datetime.date(2020, 1, 1)).year
            ind = r.randint(1, count) - 1
            id_manager = ids_managers[ind]
            ids_managers.pop(ind)
            count -= 1
            f.write(f'{name_company};{country};{date_of_create};{id_manager}\n')

def generate_shops():
    with open('data/shops.csv', 'w') as f:
        f.write('name;specialization;number_of_employees;profit;id_sc\n')
        specializations = ['Мужское белье', 'Женское белье', 'Детския одежда', 'Мужская одежда', 'Женская одежда',
                           'Спортивная одежда', 'Летняя одежда', 'Зимняя одежда', 'Демисезонная одежда']

        for _ in range(1, 1001):
            name = fake.word().title()
            specialization = specializations[r.randint(0, len(specializations)) - 1]
            number_of_employees = r.randint(100, 10000)
            profit = r.randint(1000, 10000000)
            id_sc = r.randint(1, 1000)
            f.write(f'{name};{specialization};{number_of_employees};{profit};{id_sc}\n')

def generate_sc():
    with open('data/sc.csv', 'w') as f:
        f.write('name;address;number_of_floors;number_of_shops\n')

        for _ in range(1, 1001):
            name = fake.word().title()
            address = fake.address().replace(',', '')
            number_of_floors = r.randint(1, 20)
            number_of_shops = number_of_floors * r.randint(10, 20)
            f.write(f'{name};{address};{number_of_floors};{number_of_shops}\n')

def generate_owners_sc():
    with open('data/owners_sc.csv', 'w') as f:
        f.write('surname;name;patronymic;citizenship;date_of_birth;id_sc\n')

        for _ in range(1, 1001):
            name, patronymic, surname = RussianNames().get_person().split()
            date_of_birth = fake.date_between_dates(datetime.date(1972, 1, 1), datetime.date(2000, 1, 1))
            id_sc = r.randint(1, 1000)
            citizenship = fake.country()
            f.write(f'{surname};{name};{patronymic};{citizenship};{date_of_birth};{id_sc}\n')

def generate_links_brands_n_shops():
    with open('data/links_brands_n_shops.csv', 'w') as f:
        f.write('id_shop;id_brand\n')

        for _ in range(1, 2001):
            id_shop = r.randint(1, 1000)
            id_brand = r.randint(1, 1000)
            f.write(f'{id_shop};{id_brand}\n')

if __name__ == "__main__":
    generate_managers()
    generate_brands()
    generate_shops()
    generate_links_brands_n_shops()
    generate_sc()
    generate_owners_sc()