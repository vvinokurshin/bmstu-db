class Brand():
    def __init__(self, id, name_company, country, year_of_create, id_manager):
        self.id = id
        self.name_company = name_company
        self.country = country
        self.year_of_create = year_of_create
        self.id_manager = id_manager

    def get(self):
        return {'id': self.id, 'name_company': self.name_company, 'country': self.country,
                'year_of_create': self.year_of_create, 'id_manager': self.id_manager}


def create_brands():
    with open('data/brands.csv', 'r') as f:
        strings = f.readlines()

    brands = []
    id = 1

    for string in strings:
        elems = string.strip().split(';')
        brands.append(Brand(id, *(elems[:3]), int(elems[3])).get())
        id += 1

    return brands


class Manager():
    def __init__(self, id, surname, name, patronymic, citizenship, date_of_birth):
        self.id = id
        self.surname = surname
        self.name = name
        self.patronymic = patronymic
        self.citizenship = citizenship
        self.date_of_birth = date_of_birth

    def get(self):
        return {'id': self.id, 'surname': self.surname, 'name': self.name,
                'patronymic': self.patronymic, 'citizenship': self.citizenship,
                'date_of_birth': self.date_of_birth}


def create_managers():
    with open('data/managers.csv', 'r') as f:
        strings = f.readlines()

    managers = []
    id = 1

    for string in strings:
        elems = string.strip().split(';')
        managers.append(Manager(id, *elems).get())
        id += 1

    return managers
