-- Schema and Data Migrations.

-- Schema migrations are about changing the structure of a database or schema.

-- Data migrations are about moving data around.

-- Strategy for Schema and Data Migrations.
-- 1. Add column loc.
-- 2. Deploy new version of the API that will write values to both lat/lng and loc.
-- 3. Copy lat/lng to loc.
-- 4. Update code to only write to loc column.
-- 5. Drop columns lat/lng.

