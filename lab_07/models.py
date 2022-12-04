import peewee


class BaseModel(peewee.Model):
    class Meta:
        database = peewee.PostgresqlDatabase('clothes', user='postgres', password='postgres',
                                             host='localhost', port=5432)


class Managers(BaseModel):
    id = peewee.PrimaryKeyField(column_name='id')
    surname = peewee.CharField(column_name='surname')
    name = peewee.CharField(column_name='name')
    patronymic = peewee.CharField(column_name='patronymic')
    citizenship = peewee.CharField(column_name='citizenship')
    date_of_birth = peewee.DateField(column_name='date_of_birth')

    class Meta:
        table_name = 'general_managers'


class Brands(BaseModel):
    id = peewee.PrimaryKeyField(column_name='id')
    name_company = peewee.CharField(column_name='name_company')
    country = peewee.CharField(column_name='country')
    year_of_create = peewee.IntegerField(column_name='year_of_create')
    id_manager = peewee.ForeignKeyField(Managers, column_name='id_manager')

    class Meta:
        table_name = 'brands'
