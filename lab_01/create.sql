--CREATE DATABASE clothes;

-- Генеральные директора
DROP TABLE IF EXISTS public.general_managers;
CREATE TABLE public.general_managers (
    id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    surname VARCHAR(30) NOT NULL,
    name VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30) NOT NULL,
    citizenship VARCHAR(50) NOT NULL,
    date_of_birth date NOT null
);

--insert into public.general_managers (surname, name, patronymic, citizenship, date_of_birth) values ('aaa', 'bbb', 'ccc', 'dfadf', '1990-01-01');

-- Фирмы
DROP TABLE IF EXISTS public.brands;
CREATE TABLE public.brands (
    id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    name_company VARCHAR(100) NOT NULL,
    country VARCHAR(40) NOT NULL,
    year_of_create int NOT NULL,
    id_manager int NOT NULL REFERENCES public.general_managers (id)
);

-- ТЦ
DROP TABLE IF EXISTS public.sc;
CREATE TABLE public.sc (
    id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    number_of_floors int NOT NULL,
    number_of_shops int NOT NULL
);

-- Магазины
DROP TABLE IF EXISTS public.shops;
CREATE TABLE public.shops (
    id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    name VARCHAR(50) NOT NULL,
    specialization VARCHAR(20) NOT NULL,
    number_of_employees int NOT NULL,
    profit int NOT NULL,
    id_sc int NOT NULL REFERENCES public.sc (id)
);

-- Владельцы ТЦ
DROP TABLE IF EXISTS public.owners_sc;
CREATE TABLE public.owners_sc (
    id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    surname VARCHAR(30) NOT NULL,
    name VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30) NOT NULL,
    citizenship VARCHAR(50) NOT NULL,
    date_of_birth date NOT NULL,
    id_sc int NOT NULL REFERENCES public.sc (id)
);

-- Связи магазинов и фирм
DROP TABLE IF EXISTS public.links_brands_n_shops;
CREATE TABLE public.links_brands_n_shops (
    id_shop int NOT NULL REFERENCES public.shops (id),
    id_brand int NOT NULL REFERENCES public.brands (id)
);