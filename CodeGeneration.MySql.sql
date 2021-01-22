-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema codegeneration
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `codegeneration` ;

-- -----------------------------------------------------
-- Schema codegeneration
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `codegeneration` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `codegeneration` ;
USE `codegeneration` ;

-- -----------------------------------------------------
-- procedure GeneratePhpSchema
-- -----------------------------------------------------

DELIMITER $$
USE `codegeneration`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpSchema`(
    IN _databaseSchema VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variables before cursor 
	DECLARE tableCursorFinished INTEGER DEFAULT 0;
	DECLARE tableName varchar(100) DEFAULT "";

	-- declare cursor for tables
	DEClARE tableCursor 
		CURSOR FOR 
			SELECT CONCAT(UCASE(LEFT(TABLE_NAME, 1)), LCASE(SUBSTRING(TABLE_NAME, 2))) AS TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = _databaseSchema ORDER BY TABLE_NAME;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET tableCursorFinished = 1;

	SET _text = CONCAT(_text, "<?php", '\n',
		"defined('BASEPATH') || exit('No direct script access allowed');", '\n',
		'\n');
    call GeneratePhpSchemaDatabaseClass(_databaseSchema, _text);
	-- run cursor
	OPEN tableCursor;
		tableLoop: LOOP
			FETCH tableCursor INTO tableName;
			IF tableCursorFinished = 1 THEN 
				LEAVE tableLoop;
			END IF;
            -- cursor work
            call GeneratePhpSchemaTableClass(_databaseSchema, tableName, _text);
		END LOOP tableLoop;
	CLOSE tableCursor;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GeneratePhpSchemaDatabaseClass
-- -----------------------------------------------------

DELIMITER $$
USE `codegeneration`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpSchemaDatabaseClass`(
    IN _databaseSchema VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variables before cursor 
	DECLARE tableCursorFinished INTEGER DEFAULT 0;
	DECLARE tableName varchar(100) DEFAULT "";

	-- declare cursor for table
	DEClARE tableCursor 
		CURSOR FOR 
			SELECT CONCAT(UCASE(LEFT(TABLE_NAME, 1)), LCASE(SUBSTRING(TABLE_NAME, 2))) AS TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = _databaseSchema ORDER BY TABLE_NAME;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET tableCursorFinished = 1;

	SET _text = CONCAT(_text, 
		"class ", CONCAT(UCASE(LEFT(_databaseSchema, 1)), LCASE(SUBSTRING(_databaseSchema, 2))), 'Schema extends CI_Model', '\n',
        '{','\n');

	-- run cursor
	OPEN tableCursor;
		tableLoop: LOOP
			FETCH tableCursor INTO tableName;
			IF tableCursorFinished = 1 THEN 
				LEAVE tableLoop;
			END IF;
			-- cursor work
			SET _text = CONCAT(_text, '\t', "public string $", tableName, ' = \"', tableName, '\";\n');
		END LOOP tableLoop;
	CLOSE tableCursor;
	SET _text = CONCAT(_text, '}','\n');
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GeneratePhpSchemaStoredProcedureClass
-- -----------------------------------------------------

DELIMITER $$
USE `codegeneration`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpSchemaStoredProcedureClass`(
	IN _databaseSchema VARCHAR(100)
)
BEGIN
((SELECT
	r.specific_name,
	CONCAT(r.specific_name,
		CASE COUNT('routine_name') WHEN 1 THEN "(?)"
		ELSE CONCAT("(?", REPLACE(SPACE(COUNT('routine_name')-1), " ", ", ?"), ")")
		END) AS `Name`
FROM information_schema.routines r
	LEFT JOIN information_schema.parameters p
		ON p.specific_schema = r.routine_schema
		AND p.specific_name = r.specific_name
WHERE r.routine_schema NOT IN ('sys', 'information_schema', 'mysql', 'performance_schema')
	AND r.routine_schema = _databaseSchema -- put your database name here
	AND p.parameter_name IS NOT NULL
GROUP BY r.specific_name
ORDER BY r.routine_schema,
         r.specific_name,
         p.ordinal_position)
UNION
(SELECT
	r.specific_name,
	CONCAT(r.specific_name, "()") AS `Name`
FROM information_schema.routines r
LEFT JOIN information_schema.parameters p
	ON p.specific_schema = r.routine_schema
    AND p.specific_name = r.specific_name
WHERE r.routine_schema not in ('sys', 'information_schema', 'mysql', 'performance_schema')
	AND r.routine_schema = _databaseSchema -- put your database name here
	and p.parameter_name is null
group by r.specific_name
order by r.routine_schema,
         r.specific_name,
         p.ordinal_position))

ORDER BY NAME;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GeneratePhpSchemaTableClass
-- -----------------------------------------------------

DELIMITER $$
USE `codegeneration`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpSchemaTableClass`(
    IN _databaseSchema VARCHAR(100),
    IN _table_name VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variables before cursor 
	DECLARE columnCursorFinished INTEGER DEFAULT 0;
	DECLARE columnName varchar(100) DEFAULT "";

	-- declare cursor for columns
	DEClARE columnCursor 
		CURSOR FOR 
			SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = _databaseSchema AND TABLE_NAME = _table_name ORDER BY COLUMN_NAME;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET columnCursorFinished = 1;

	SET _text = CONCAT(_text,
		"class ", _table_name, 'Schema extends CI_Model', '\n'
        '{', '\n');

	-- run cursor
	OPEN columnCursor;
		columnLoop: LOOP
			FETCH columnCursor INTO columnName;
			IF columnCursorFinished = 1 THEN 
				LEAVE columnLoop;
			END IF;
			-- cursor work
			SET _text = CONCAT(_text, 
				'\t', "public string $", columnName, ' = ', '\"', columnName, '\"', ';', '\n');
		END LOOP columnLoop;
	CLOSE columnCursor;
	SET _text = CONCAT(_text, '}\n');
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
