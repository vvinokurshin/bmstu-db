COPY public.discount(id, amount, id_shop)
FROM '/home/data/discounts.csv' 
DELIMITER ';' csv HEADER;

SELECT * FROM public.discount;