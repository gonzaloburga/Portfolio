-- Proyecto de Limpieza de Datos de Laptops
-- Autor: Gonzalo Burga
-- Descripción: Este proyecto tiene como objetivo limpiar y preparar los datos de laptops
-- para su posterior análisis. Los datos originales contienen varias inconsistencias y
-- valores faltantes que deben ser tratados. 
-- Fuente: https://www.kaggle.com/datasets/jenilhareshbhaighori/real-world-laptop-data-analysis?select=laptop_uncleaned.csv

-- Vista del Dataset
SELECT *
FROM amazon_laptops
LIMIT 50;

-- Creación de backup
SELECT * INTO backup FROM amazon_laptops;

-- Columnas y sus tipos de datos
SELECT
	column_name,
	data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'amazon_laptops';

-- Estandarización de columnas y tipos de datos
ALTER TABLE amazon_laptops
	RENAME COLUMN "Rating" TO rating;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Brand" TO brand;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Screen_Size" TO screen_size_inches;
ALTER TABLE amazon_laptops
	RENAME COLUMN "CPU_Model" TO cpu_model;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Ram" TO ram_gb;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Operating_System" TO operating_system;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Series" TO series;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Color" TO color;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Resolution" TO resolution;
ALTER TABLE amazon_laptops
	RENAME COLUMN "USB" TO usb;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Battery" TO battery;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Graphics" TO graphics;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Disk_Size" TO disk_size_gb;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Card_desc" TO card_desk;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Title" TO title;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Price" TO price;
ALTER TABLE amazon_laptops
	RENAME COLUMN "Weight" TO weight_pounds;

UPDATE amazon_laptops
SET price = NULL
WHERE price = 'nan';

UPDATE amazon_laptops
SET price = SUBSTRING(price, 2, LENGTH(price));

UPDATE amazon_laptops
SET price = REPLACE(price, ',', '');

UPDATE amazon_laptops
SET 
	screen_size = SPLIT_PART(screen_size, ' ', 1),
	ram = SPLIT_PART(ram, ' ', 1);

UPDATE amazon_laptops
SET 
	weight = SPLIT_PART(weight, ' ', 1),
	disk_size = SPLIT_PART(disk_size, ' ', 1);

UPDATE amazon_laptops
SET screen_size = NULL
WHERE screen_size = 'nan';

UPDATE amazon_laptops
SET ram = NULL
WHERE ram = 'nan';

UPDATE amazon_laptops
SET weight = NULL
WHERE weight = 'nan';

UPDATE amazon_laptops
SET disk_size = NULL
WHERE disk_size = 'nan';

ALTER TABLE amazon_laptops
ALTER COLUMN screen_size TYPE numeric
	USING screen_size::numeric,
ALTER COLUMN ram TYPE INT
	USING ram::int;

ALTER TABLE amazon_laptops
ALTER COLUMN weight TYPE numeric
	USING weight::numeric,
ALTER COLUMN disk_size TYPE numeric
	USING disk_size::numeric;

ALTER TABLE amazon_laptops
ALTER COLUMN price TYPE numeric
	USING price::numeric;

-- Eliminación de columnas innecesarias.
-- Se consideró las siguiente columnas innecesarias para un análisis.
ALTER TABLE amazon_laptops
	DROP COLUMN IF EXISTS color,
	DROP COLUMN IF EXISTS weight_pounds,
	DROP COLUMN IF EXISTS usb,
	DROP COLUMN IF EXISTS battery,
	DROP COLUMN IF EXISTS series,
	DROP COLUMN IF EXISTS operating_system,
	DROP COLUMN IF EXISTS resolution,
	DROP COLUMN IF EXISTS graphics,
	DROP COLUMN IF EXISTS card_desk;

-- Eliminación de filas innecesarias.
-- En el dataset hay algunas filas que no son laptops, después de analizar cuales son,
-- se proce a eilimarlas.
DELETE FROM amazon_laptops
WHERE
	NOT (		
		title NOT ILIKE '%Replacement%'
		AND title NOT ILIKE '%Sleeve%'
		AND title NOT ILIKE '%Extender%'
		AND title NOT ILIKE '%Case%'
		AND (
			title ILIKE '%Laptop%'
			OR title ILIKE '%Notebook%'
			OR title ILIKE '%Toughbook%'
			OR title ILIKE '%Chromebook%'
			OR title ILIKE '%MacBook%'
		)
	);

-- Verificación de duplicados.
SELECT 
	title
FROM amazon_laptops
GROUP BY title
HAVING COUNT(*) > 1;

DELETE FROM amazon_laptops 
WHERE ctid IN ( 
	SELECT ctid 
	FROM ( 
		SELECT 
			ctid, 
			ROW_NUMBER() OVER (PARTITION BY title) AS duplicate 
		FROM amazon_laptops 
	) AS s 
	WHERE s.duplicate > 1 
);

-- Repoblación de datos.
-- Se extrajo la marca (brand) y modelo de cpu (cpu_model) del título (title)
-- con tal de modificar correctamente la respectiva columna.
SELECT DISTINCT brand FROM amazon_laptops

UPDATE amazon_laptops
SET brand = 
	CASE 
		WHEN title ILIKE '%hyundai%' THEN 'Hyundai'
		WHEN title ILIKE '%panasonic%' THEN 'Panasonic'
		WHEN title ILIKE '%hp%' OR title ILIKE '%h p%' THEN 'HP'
		WHEN title ILIKE '%acer%' THEN 'Acer'
		WHEN title ILIKE '%hp%' THEN 'HP'
		WHEN title ILIKE '%otvoc%' THEN 'OTVOC'
		WHEN title ILIKE '%alienware%' THEN 'Alienware'
		WHEN title ILIKE '%microsoft%' THEN 'Microsoft'
		WHEN title ILIKE '%broage%' THEN 'Broage'
		WHEN title ILIKE '%vgke%' THEN 'VGKE'
		WHEN title ILIKE '%ecohero%' THEN 'EcoHero'
		WHEN title ILIKE '%lanruo%' THEN 'Lanruo'
		WHEN title ILIKE '%msi%' THEN 'MSI'
		WHEN title ILIKE '%dere%' THEN 'Dere'
		WHEN title ILIKE '%jumper%' THEN 'Jumper'
		WHEN title ILIKE '%lincplus%' THEN 'LincPlus'
		WHEN title ILIKE '%wakst%' THEN 'WAKST'
		WHEN title ILIKE '%thomson%' THEN 'Thomson'
		WHEN title ILIKE '%fusion5%' THEN 'Fusion5'
		WHEN title ILIKE '%chuwi%' THEN 'CHUWI'
		WHEN title ILIKE '%lenovo%' THEN 'Lenovo'
		WHEN title ILIKE '%dell%' THEN 'Dell'
		WHEN title ILIKE '%gigabyte%' THEN 'Gigabyte'
		WHEN title ILIKE '%apple%' THEN 'Apple'
		WHEN title ILIKE '%bmax%' THEN 'BMAX'
		WHEN title ILIKE '%packard bell%' THEN 'Packard Bell'
		WHEN title ILIKE '%coolby%' THEN 'Coolby'
		WHEN title ILIKE '%bitecool%' THEN 'BiTECOOL'
		WHEN title ILIKE '%samsung%' THEN 'Samsung'
		WHEN title ILIKE '%asus%' THEN 'ASUS'
		WHEN title ILIKE '%galaxy%' THEN 'Samsung'
		WHEN title ILIKE '%razer%' THEN 'Razer'
		WHEN title ILIKE '%teclast%' THEN 'Teclast'
	ELSE 'Generic' END;

SELECT DISTINCT cpu_model from amazon_laptops

UPDATE amazon_laptops
SET cpu_model =
	CASE
		WHEN title NOT ILIKE '%beat%' AND title NOT ILIKE '%>%' THEN
		CASE
			WHEN title ~* '.*?(core ?i3|intel ?i3|gen ?i3|i3-?)' THEN 'Intel Core i3'
			WHEN title ~* '.*?(core ?i5|intel ?i5|gen ?i5|i5-?)' THEN 'Intel Core i5'
			WHEN title ~* '.*?(core ?i7|intel ?i7|gen ?i7|i7-?)' THEN 'Intel Core i7'
			WHEN title ~* '.*?(core ?i9|intel ?i9|gen ?i9|i9-?)' THEN 'Intel Core i9'
			WHEN title ~* '.*?(core ?m3|intel ?m3)' OR title ILIKE '%m3-%' THEN 'Intel Core M3'
			WHEN title ~* '.*?(core ?m5|intel ?m5)' OR title ILIKE '%m5-%' THEN 'Intel Core M5'
			WHEN title ILIKE '%xeon%' THEN 'Intel Xeon'
			WHEN title ILIKE '%atom%' THEN 'Intel Atom'
			WHEN title ILIKE '%apple%' AND title ILIKE '%m1%' THEN 'Apple M1'
			WHEN title ILIKE '%apple%' AND title ILIKE '%m2%' THEN 'Apple M2'
			WHEN title ~* 'ryzen\s*(3|r3)' THEN 'AMD Ryzen 3'
			WHEN title ~* 'ryzen\s*(5|r5)' THEN 'AMD Ryzen 5'
			WHEN title ~* 'ryzen\s*(7|r7)' THEN 'AMD Ryzen 7'
			WHEN title ~* 'ryzen\s*(9|r9)' THEN 'AMD Ryzen 9'
			WHEN title ILIKE '%athlon%' THEN 'AMD Athlon'
			WHEN title ~* '.*?(amd\s*a-|amd\s*a\d{1}).*?' THEN 'AMD A'
			WHEN title ILIKE '%celeron%' THEN 'Intel Celeron'
			WHEN title ILIKE '%pentium%' THEN 'Intel Pentium'
			WHEN title ILIKE '%mediatek%' THEN 'MediaTek'
		ELSE 'Other' END 
		WHEN title ILIKE '%beat%' OR title ILIKE '%>%' THEN
		CASE
			WHEN title ~* '.*?(core ?i3|intel ?i3|gen ?i3|i3-\d{4}).*?(?=[Bb]eat|>)' THEN 'Intel Core i3'
        	WHEN title ~* '.*?(core ?i5|intel ?i5|gen ?i5|i5-\d{4}).*?(?=[Bb]eat|>)' THEN 'Intel Core i5'
			WHEN title ~* '.*?(core ?i7|intel ?i7|gen ?i7|i7-\d{4}).*?(?=[Bb]eat|>)' THEN 'Intel Core i7'
			WHEN title ~* '.*?(core ?i9|intel ?i9|gen ?i9|i9-\d{4}).*?(?=[Bb]eat|>)' THEN 'Intel Core i9'
			WHEN title ~* '.*?celeron.*?(?=[Bb]eat|>)' THEN 'Intel Celeron'
			WHEN title ~* '.*?pentium.*?(?=[Bb]eat|>)' THEN 'Intel Pentium'
			WHEN title ~* '.*?ryzen\s*(3|r3).*?(?=[Bb]eat|>)' THEN 'AMD Ryzen 3'
			WHEN title ~* '.*?ryzen\s*(5|r5).*?(?=[Bb]eat|>)' THEN 'AMD Ryzen 5'
			WHEN title ~* '.*?ryzen\s*(7|r7).*?(?=[Bb]eat|>)' THEN 'AMD Ryzen 7'
			WHEN title ~* '.*?ryzen\s*(9|r9).*?(?=[Bb]eat|>)' THEN 'AMD Ryzen 9'
		ELSE 'Other' END
	ELSE 'Other' END;

-- Verificación de datos nulos.
-- Se consideró eliminar los valores nulos de price y rating ya que pueden ser
-- cruciales para el análisis y rellenarlos con el promedio o la moda podría
-- modificar la integridad del análisis. En cuanto al resto de columnas se usó
-- un valor por defecto.
SELECT
	SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS null_title,
	SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS null_brand,
	SUM(CASE WHEN screen_size_inches IS NULL THEN 1 ELSE 0 END) AS null_screen,
	SUM(CASE WHEN cpu_model IS NULL THEN 1 ELSE 0 END) AS null_cpu_m,
	SUM(CASE WHEN ram_gb IS NULL THEN 1 ELSE 0 END) AS null_ram,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN disk_size_gb IS NULL THEN 1 ELSE 0 END) AS null_disk_size,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price
FROM amazon_laptops;

DELETE FROM amazon_laptops 
WHERE price IS NULL;

DELETE FROM amazon_laptops
WHERE rating IS NULL;

UPDATE amazon_laptops
SET ram_gb = 8
WHERE ram_gb IS NULL;

UPDATE amazon_laptops
SET disk_size_gb = 256
WHERE disk_size_gb IS NULL;

UPDATE amazon_laptops
SET screen_size_inches = 15.6
WHERE screen_size_inches IS NULL;

-- Eliminación de backup
DROP TABLE backup;

-- Fin del proyecto.