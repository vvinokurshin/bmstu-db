DROP TABLE IF EXISTS public.discount;
CREATE TABLE public.discount (
    id INT PRIMARY KEY,
    amount INT NOT NULL,
    id_shop int NOT NULL REFERENCES public.shops (id)
);

ALTER TABLE public.discount ADD CONSTRAINT check_discount_amount CHECK (amount > 0 and amount <= 100);

SELECT * FROM public.discount;