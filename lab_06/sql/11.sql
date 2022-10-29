SELECT gm.surname AS surname_gm, gm.name AS name_gm, ow.surname AS surname_owner, ow.name AS name_owner
FROM general_managers gm, owners_sc ow
WHERE gm.surname = ow.surname;