CREATE PROCEDURE bad_cursor()
BEGIN
   DECLARE filem_id INT;
   DECLARE f CURSOR FOR SELECT film_id FROM sakila.film;
   OPEN f;
   FETCH f INTO film_id;  
   CLOSE f;
END
 
