SELECT shops.name, profit, sc.address
FROM public.shops JOIN public.sc ON shops.id_sc = sc.id;