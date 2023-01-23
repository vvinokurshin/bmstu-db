from faker import Faker
from russian_names import RussianNames
import datetime
import time
import json
import os

import schedule

TABLENAME = 'gm_lab8_insert'
CONTAINER_NAME = 'nifi_container_persistent'

fake = Faker(locale='ru_Ru')


def generate_managers():
    global cur_id
    data = []
    for _ in range(1, 11):
        name, patronymic, surname = RussianNames().get_person().split()
        date_of_birth = fake.date_between_dates(datetime.date(
            1972, 1, 1), datetime.date(2000, 1, 1)).strftime('%Y-%m-%d')
        citizenship = fake.country()
        data.append({
            'id': cur_id,
            'surname': surname,
            'name': name,
            'patronymic': patronymic,
            'citizenship': citizenship,
            'date_of_birth': date_of_birth,
        })
        cur_id += 1

    return data


def generate_json():
    global id
    id += 1

    data = generate_managers()
    filename = f"data/{id}_{TABLENAME}_{datetime.datetime.now().strftime('%Y-%m-%d_%H.%M.%S')}.json"

    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)

    os.system(
        f"docker cp {filename} {CONTAINER_NAME}:/opt/nifi/nifi-current/lab_08/data/")
    os.remove(filename)


def main():
    schedule.every().second.do(generate_json)

    while True:
        schedule.run_pending()
        time.sleep(1)


if __name__ == '__main__':
    cur_id = 1
    id = 0
    main()
