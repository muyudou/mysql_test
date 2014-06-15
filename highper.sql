CREATE PROCEDURE bad_cursor()
BEGIN
   DECLARE filem_id INT;
   DECLARE f CURSOR FOR SELECT film_id FROM sakila.film;
   OPEN f;
   FETCH f INTO film_id;  
   CLOSE f;
END
 
SET @sql := 'SELECT actor_id, first_name, last_name FROM sakila.actor WHERE first_name=?';
PREPARE stmt_fecth_actor FROM @sql;
SET @actor_name := 'Penelope';
EXECUTE stmt_fetch_actor USING @actor_name;
DEALLOCATE PREPARE stmt_fetch_actor;

DROP PROCEDURE IF EXISTS optimize_tables;
DELIMITER //
CREATE PROCEDURE optimize_tables(db_name VARCHAR(64))
BEGIN
   DECLARE t VARCHAR(64);
   DECLARE done INT DEFAULT 0;
   DECLARE c CURSOR FOR
      SELECT table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = db_name AND TABLE_TYPE='BASE TABLE';
   DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done=1;
   OPEN c;
   tables_loop: LOOP
      fetch c INTO t;
      IF done THEN 
         LEAVE tables_loop;
      END IF;
      SET @stmt_test := CONCAT("OPTIMIZE TABLE ", db_name, '.', t);
      PREPARE stmt FROM @stmt_test;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
   END LOOP;
   close c;
END //
DELIMITER;

REPEAT
   FETCH c INTO t;
   IF NOT done THEN
      SET @stmt_text := CONCAT("OPTIMIZE TABLE ", db_name, '.', t);
      PREPARE stmt FROM @stmt_text;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
   END IF;
UNTIL done END REPEAT;

CREATE DATABASE d CHARSET latin1;
CREATE TABLE d.t(
   col1 CHAR(1),
   col2 CHAR(1) CHARSET utf8,
   col3 CHAR(1) COLLATE latin1_bin
)DEFAULT CHARSET=cp1251;
