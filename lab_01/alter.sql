-- Генеральные директора
ALTER TABLE public.general_managers ADD CONSTRAINT check_id_manager CHECK (id > 0);
ALTER TABLE public.general_managers ADD CONSTRAINT check_date_manager CHECK (date_of_birth >= '1900-01-01' and date_of_birth <= '2001-01-01');

-- Фирмы
ALTER TABLE public.brands ADD CONSTRAINT check_id_brand CHECK (id > 0);
ALTER TABLE public.brands ADD CONSTRAINT check_date_brand CHECK (year_of_create >= 1900 and year_of_create <= 2020);

-- ТЦ
ALTER TABLE public.sc ADD CONSTRAINT check_id_sc CHECK (id > 0);
ALTER TABLE public.sc ADD CONSTRAINT check_floors_sc CHECK (number_of_floors > 0);
ALTER TABLE public.sc ADD CONSTRAINT check_shops_sc CHECK (number_of_shops > 0);

-- Магазины
ALTER TABLE public.shops ADD CONSTRAINT check_id_shops CHECK (id > 0);
ALTER TABLE public.shops ADD CONSTRAINT check_employees_shops CHECK (number_of_employees > 0);
ALTER TABLE public.shops ADD CONSTRAINT check_profit_shops CHECK (profit > 0);

-- Владельцы ТЦ
ALTER TABLE public.owners_sc ADD CONSTRAINT check_id_owner CHECK (id > 0);
ALTER TABLE public.owners_sc ADD CONSTRAINT check_date_owner CHECK (date_of_birth >= '1900-01-01' and date_of_birth <= '2001-01-01');
