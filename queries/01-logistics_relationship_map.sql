
/****************************************************************************************
							Asian Imports Database Queries
	List of Foreign Keys, their parent tables, please view ERD for more clarity.
****************************************************************************************/
USE asian_imports;

SELECT
  TABLE_NAME           AS child_table,
  COLUMN_NAME          AS child_column,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME AS parent_table,
  REFERENCED_COLUMN_NAME AS parent_column
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
  TABLE_SCHEMA = 'asian_imports'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY child_table, parent_table, CONSTRAINT_NAME;
