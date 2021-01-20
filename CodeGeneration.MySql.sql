CREATE DATABASE  IF NOT EXISTS `codegeneration` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `codegeneration`;
-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: localhost    Database: codegeneration
-- ------------------------------------------------------
-- Server version	8.0.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping events for database 'codegeneration'
--

--
-- Dumping routines for database 'codegeneration'
--
/*!50003 DROP PROCEDURE IF EXISTS `GeneratePhpDatabaseSchemaClass` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpDatabaseSchemaClass`(
    IN _table_schema VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variable before cursor 
	DECLARE tableCursorFinished INTEGER DEFAULT 0;
	DECLARE tableName varchar(100) DEFAULT "";

	-- declare cursor for table columns
	DEClARE tableCursor 
		CURSOR FOR 
			SELECT CONCAT(UCASE(LEFT(TABLE_NAME, 1)), LCASE(SUBSTRING(TABLE_NAME, 2))) AS TABLE_NAME FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = _table_schema;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET tableCursorFinished = 1;

	SET _text = CONCAT(_text, 
		"class ", CONCAT(UCASE(LEFT(_table_schema, 1)), LCASE(SUBSTRING(_table_schema, 2))), 'Schema extends CI_Model', '\n',
        '{','\n');

	-- run cursor
	OPEN tableCursor;
		tableLoop: LOOP
			FETCH tableCursor INTO tableName;
			IF tableCursorFinished = 1 THEN 
				LEAVE tableLoop;
			END IF;
			-- build table classes list
			SET _text = CONCAT(_text, '\t', "public string $", tableName, ' = \"', tableName, '\";\n');
		END LOOP tableLoop;
	CLOSE tableCursor;
	SET _text = CONCAT(_text, '}','\n');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GeneratePhpSchema` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpSchema`(
    IN _table_schema VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variable before cursor 
	DECLARE tableCursorFinished INTEGER DEFAULT 0;
	DECLARE tableName varchar(100) DEFAULT "";

	-- declare cursor for table columns
	DEClARE tableCursor 
		CURSOR FOR 
			SELECT TABLE_NAME FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = _table_schema;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET tableCursorFinished = 1;

	SET _text = CONCAT(_text, "<?php", '\n',
		"defined('BASEPATH') || exit('No direct script access allowed');", '\n',
		'\n');
    call codegeneration.GeneratePhpDatabaseSchemaClass(_table_schema, _text);
	-- run cursor
	OPEN tableCursor;
		tableLoop: LOOP
			FETCH tableCursor INTO tableName;
			IF tableCursorFinished = 1 THEN 
				LEAVE tableLoop;
			END IF;
			-- build table classes list
            call codegeneration.GeneratePhpTableSchema(tableName, _table_schema, _text);
		END LOOP tableLoop;
	CLOSE tableCursor;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GeneratePhpTableSchema` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GeneratePhpTableSchema`(
    IN _table_name VARCHAR(100),
    IN _table_schema VARCHAR(100),
	INOUT _text varchar(4000))
BEGIN
	-- declare variable before cursor 
	DECLARE columnCursorFinished INTEGER DEFAULT 0;
	DECLARE columnName varchar(100) DEFAULT "";

	-- declare cursor for table columns
	DEClARE columnCursor 
		CURSOR FOR 
			SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = _table_schema AND TABLE_NAME = _table_name;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET columnCursorFinished = 1;

	SET _text = CONCAT(_text, "class ", CONCAT(UCASE(LEFT(_table_name, 1)), LCASE(SUBSTRING(_table_name, 2))), 'Schema extends CI_Model\r\n{\r\n');
	-- run cursor
	OPEN columnCursor;
		columnLoop: LOOP
			FETCH columnCursor INTO columnName;
			IF columnCursorFinished = 1 THEN 
				LEAVE columnLoop;
			END IF;
			-- build table classes list
			SET _text = CONCAT(_text, "public string $", columnName, ' = \"', columnName, '\";\r\n');
		END LOOP columnLoop;
	CLOSE columnCursor;
	SET _text = CONCAT(_text, '}\r\n');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-01-20 21:18:51
