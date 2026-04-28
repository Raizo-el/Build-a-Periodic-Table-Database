-- Run once if elements 9 and 10 fail element.sh (missing rows after earlier INSERT errors).
-- psql --username=freecodecamp --dbname=periodic_table -f repair_fluorine_neon.sql

INSERT INTO elements (atomic_number, symbol, name)
SELECT 9, 'F', 'Fluorine'
WHERE NOT EXISTS (SELECT 1 FROM elements WHERE atomic_number = 9);

INSERT INTO elements (atomic_number, symbol, name)
SELECT 10, 'Ne', 'Neon'
WHERE NOT EXISTS (SELECT 1 FROM elements WHERE atomic_number = 10);

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
SELECT 9, 18.998::numeric, -220, -188.1, t.type_id
FROM types t
WHERE t.type = 'nonmetal'
  AND NOT EXISTS (SELECT 1 FROM properties WHERE atomic_number = 9);

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
SELECT 10, 20.18::numeric, -248.6, -246.1, t.type_id
FROM types t
WHERE t.type = 'nonmetal'
  AND NOT EXISTS (SELECT 1 FROM properties WHERE atomic_number = 10);

UPDATE properties SET atomic_mass = 18.998 WHERE atomic_number = 9;
UPDATE properties SET atomic_mass = 20.18 WHERE atomic_number = 10;
