CREATE TABLE source_words(
  word  VARCHAR(50)  NOT NULL,
  INDEX (word)
) ENGINE=MyISAM;
LOAD DATA LOCAL INFILE '~/mysql/words' INTO TABLE source_words(word);

CREATE TABLE million_words(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  word VARCHAR(50) NOT NULL,
  PRIMARY KEY(id),
  UNIQUE INDEX (word)
) ENGINE=InnoDB;

INSERT INTO million_words(word)
SELECT DISTINCT word FROM source_words;
INSERT INTO million_words(word)
SELECT DISTINCT REVERSE(word) FROM source_words
WHERE REVERSE(word) NOT IN (select word FROM source_words);

#动态sql
SELECT @cnt := COUNT(*) FROM million_words;
SELECT @diff := 1000000-@cnt;

SET @sql = CONCAT("INSERT INTO million_words(word) SELECT DISTINCT CONCAT(word, 'X1Y') FROM source_words LIMIT ", @diff);

CREATE TABLE artist (
  artist_id INT UNSIGNED NOT NULL,
  type ENUM('Band', 'Person', 'Unknown', 'Combination') NOT NULL,
  name VARCHAR(255) NOT NULL,
  gender ENUM('Male', 'Female') DEFAULT NULL,
  founded YEAR DEFAULT NULL,
  country_id SMALLINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (artist_id)
) ENGINE=InnoDB;

CREATE TABLE album (
  album_id INT UNSIGNED NOT NULL,
  artist_id INT UNSIGNED NOT NULL,
  album_type_id INT UNSIGNED NOT NULL,
  name VARCHAR(255) NOT NULL,
  first_released YEAR NOT NULL,
  country_id SMALLINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY(album_id)
) Engine=InnoDB;

#PREPARE语法，可以实现动态sql查询
PREPARE cmd FROM @sql;
EXECUTE cmd;
SELECT COUNT(*) FROM million_words;


CREATE TABLE colors (
  name VARCHAR(20) NOT NULL,
  items VARCHAR(255) NOT NULL
) ENGINE=MyISAM; 
INSERT INTO colors(name, items) VALUES
('RED', 'Apples, Sun, Blood,...'),
('ORANGE', 'Oranges, Sand,...'),
('YELLOW', '...'),
('GREEN', 'Kermit, Grass, Leaves, Plants, Emeralds, Frogs, Seaweed, Spinach, Money, Jade, Go Traffic Light'),
('BLUE','Sky, Water,Blueberies,Earth'),
('INDIGO', '...'),
('VIOLET', '...'),
('WHITE', '...' ),
('BLACK', 'Night, Coal, Blackboard, Licorice, Piano, Keys,...');
ALTER TABLE colors ADD index(name);

