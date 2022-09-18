-- Генеральные директора
COPY public.general_managers(surname,name,patronymic,citizenship,date_of_birth)
FROM '/home/data/managers.csv' 
DELIMITER ';' csv HEADER;

-- Фирмы
COPY public.brands(name_company,country,year_of_create,id_manager)
FROM '/home/data/brands.csv' 
DELIMITER ';' csv HEADER;

-- ТЦ
COPY public.sc(name,address,number_of_floors,number_of_shops)
FROM '/home/data/sc.csv' 
DELIMITER ';' csv HEADER;

-- Магазины
COPY public.shops(name,specialization,number_of_employees,profit,id_sc)
FROM '/home/data/shops.csv' 
DELIMITER ';' csv HEADER;

-- Владельцы ТЦ
COPY public.owners_sc(surname,name,patronymic,citizenship,date_of_birth,id_sc)
FROM '/home/data/owners_sc.csv' 
DELIMITER ';' csv HEADER;

-- Связи магазинов и фирм
COPY public.links_brands_n_shops(id_shop,id_brand)
FROM '/home/data/links_brands_n_shops.csv' 
DELIMITER ';' csv HEADER;