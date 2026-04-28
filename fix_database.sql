-- Periodic Table Database — full schema + data fixes for typical freeCodeCamp starter.
-- Run ONCE against a fresh lesson DB: psql --username=freecodecamp --dbname=periodic_table -f fix_database.sql
-- If a step errors because you already applied part of it, skip that section or restore from Reset.

-- 1. Remove bogus element 1000 (when present)
DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;

-- 2. Rename columns on properties
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

-- 3. NOT NULL on temperatures (starter data usually has no NULLs here)
ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

-- 4. Constraints on elements
ALTER TABLE elements ADD CONSTRAINT elements_symbol_key UNIQUE (symbol);
ALTER TABLE elements ADD CONSTRAINT elements_name_key UNIQUE (name);
ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;

-- 5. Foreign key: properties -> elements
ALTER TABLE properties
  ADD CONSTRAINT properties_atomic_number_fkey
  FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number);

-- 6. Types table + migrate old text column "type"
CREATE TABLE types (
  type_id SERIAL PRIMARY KEY,
  type VARCHAR NOT NULL UNIQUE
);

INSERT INTO types (type)
SELECT DISTINCT type FROM properties ORDER BY type;

ALTER TABLE properties ADD COLUMN type_id INT;

UPDATE properties AS p
SET type_id = t.type_id
FROM types AS t
WHERE p.type = t.type;

ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;

ALTER TABLE properties
  ADD CONSTRAINT properties_type_id_fkey
  FOREIGN KEY (type_id) REFERENCES types (type_id);

ALTER TABLE properties DROP COLUMN type;

-- 7. Capitalize symbols (first letter upper, rest lower)
UPDATE elements SET symbol = INITCAP(symbol);

-- 8. Atomic masses per atomic_mass.txt (numeric; strip trailing zeros in display via ::text in script)
UPDATE properties SET atomic_mass = 1.008 WHERE atomic_number = 1;
UPDATE properties SET atomic_mass = 4.0026 WHERE atomic_number = 2;
UPDATE properties SET atomic_mass = 6.94 WHERE atomic_number = 3;
UPDATE properties SET atomic_mass = 9.0122 WHERE atomic_number = 4;
UPDATE properties SET atomic_mass = 10.81 WHERE atomic_number = 5;
UPDATE properties SET atomic_mass = 12.011 WHERE atomic_number = 6;
UPDATE properties SET atomic_mass = 14.007 WHERE atomic_number = 7;
UPDATE properties SET atomic_mass = 15.999 WHERE atomic_number = 8;

-- 9. Fluorine (9) — insert element + properties if missing
INSERT INTO elements (atomic_number, symbol, name)
SELECT 9, 'F', 'Fluorine'
WHERE NOT EXISTS (SELECT 1 FROM elements WHERE atomic_number = 9);

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
SELECT 9, 18.998::numeric, -220, -188.1, t.type_id
FROM types t
WHERE t.type = 'nonmetal'
  AND NOT EXISTS (SELECT 1 FROM properties WHERE atomic_number = 9);

UPDATE properties SET atomic_mass = 18.998 WHERE atomic_number = 9;

-- 10. Neon (10)
INSERT INTO elements (atomic_number, symbol, name)
SELECT 10, 'Ne', 'Neon'
WHERE NOT EXISTS (SELECT 1 FROM elements WHERE atomic_number = 10);

INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
SELECT 10, 20.18::numeric, -248.6, -246.1, t.type_id
FROM types t
WHERE t.type = 'nonmetal'
  AND NOT EXISTS (SELECT 1 FROM properties WHERE atomic_number = 10);

UPDATE properties SET atomic_mass = 20.18 WHERE atomic_number = 10;

-- 11. Plain numeric column (no fixed DECIMAL scale) so atomic_mass::text matches atomic_mass.txt
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE numeric USING atomic_mass::numeric;

UPDATE properties SET atomic_mass = 1.008   WHERE atomic_number = 1;
UPDATE properties SET atomic_mass = 4.0026 WHERE atomic_number = 2;
UPDATE properties SET atomic_mass = 6.94   WHERE atomic_number = 3;
UPDATE properties SET atomic_mass = 9.0122 WHERE atomic_number = 4;
UPDATE properties SET atomic_mass = 10.81 WHERE atomic_number = 5;
UPDATE properties SET atomic_mass = 12.011 WHERE atomic_number = 6;
UPDATE properties SET atomic_mass = 14.007 WHERE atomic_number = 7;
UPDATE properties SET atomic_mass = 15.999 WHERE atomic_number = 8;
UPDATE properties SET atomic_mass = 18.998 WHERE atomic_number = 9;
UPDATE properties SET atomic_mass = 20.18  WHERE atomic_number = 10;
