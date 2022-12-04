PATH = 'data/'
CONTAINER_ID = '672aeabea2a2'
CONNECT_DATA = {
    'dbname': 'clothes',
    'user': 'postgres',
    'host': 'localhost',
    'password': 'postgres',
    'port': 5432 
}
CONNECTION_STRING = ' '.join([f"{key}='{value}'" for key, value in CONNECT_DATA.items()])
