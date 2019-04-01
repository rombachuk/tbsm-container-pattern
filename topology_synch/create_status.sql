
CREATE OR REPLACE FUNCTION split(pos INT, delimeter CHAR, string VARCHAR(1024))
LANGUAGE SQL
RETURNS VARCHAR(1024)
DETERMINISTIC NO EXTERNAL ACTION
BEGIN ATOMIC
    DECLARE x INT;
    DECLARE s INT;
    DECLARE e INT;

    SET x = 0;
    SET s = 0;
    SET e = 0;

    WHILE (x < pos) DO
        SET s = locate(delimeter, string, s + 1);
        IF s = 0 THEN
            RETURN NULL;
        END IF;
        SET x = x + 1;
    END WHILE;

    SET e = locate(delimeter, string, s + 1);
    IF s >= e THEN
        SET e = LENGTH(string) + 1;
    END IF;
    RETURN SUBSTR(string, s + 1, e - s -1);
END@


drop table L3_STATUS_STAGING @

create TABLE L3_STATUS_STAGING (
L3 VARCHAR(64) NOT NULL,
CONTENT VARCHAR(1024) NOT NULL,
UNIQUE (L3)
) @

drop table L3_STATUS @

create TABLE L3_STATUS (
L3 VARCHAR(64) NOT NULL, SITETYPE VARCHAR(10),
D1L1_BADS1 INTEGER, D1L1_BADS2 INTEGER, D1L1_BAD INTEGER, D1L1_DEGRS1 INTEGER,  D1L1_DEGRS2 INTEGER, D1L1_DEGR INTEGER,  
D2L1_BADS1 INTEGER, D2L1_BADS2 INTEGER, D2L1_BAD INTEGER, D2L1_DEGRS1 INTEGER,  D2L1_DEGRS2 INTEGER, D2L1_DEGR INTEGER,  
D3L1_BADS1 INTEGER, D3L1_BADS2 INTEGER, D3L1_BAD INTEGER, D3L1_DEGRS1 INTEGER,  D3L1_DEGRS2 INTEGER, D3L1_DEGR INTEGER,  
D4L2_BADS2 INTEGER, D3L2_BADS3 INTEGER, D4L2_BAD INTEGER, D4L2_DEGRS2 INTEGER,  D4L2_DEGRS3 INTEGER, D3L2_DEGR INTEGER,  
D1L1_NUM INTEGER, D2L1_NUM INTEGER, D3L1_NUM INTEGER, D4L2_NUM INTEGER, 
D1STATUS INTEGER, D2STATUS INTEGER, D3STATUS INTEGER, D4STATUS INTEGER,
S1STATUS INTEGER, S2STATUS INTEGER, S3STATUS INTEGER, S4STATUS INTEGER,
STATUSSTRING VARCHAR(512),STATUSTEXT VARCHAR(512),OVERALLSTATUS INTEGER, UPDATED_UNIX INTEGER , UPDATED_SQL TIMESTAMP , UPDATED_COUNT INTEGER DEFAULT 0,
PRIMARY KEY (L3)
) @


CREATE OR REPLACE TRIGGER set_l3_status
  AFTER INSERT ON l3_status_staging
  REFERENCING NEW AS n OLD AS o
  FOR EACH ROW MODE DB2SQL
  BEGIN
    DELETE FROM l3_status WHERE l3 = n.l3;
    INSERT INTO l3_status 
     (L3, SITETYPE,
D1L1_BADS1 , D1L1_BADS2 , D1L1_BAD , D1L1_DEGRS1 ,  D1L1_DEGRS2 , D1L1_DEGR ,  
D2L1_BADS1 , D2L1_BADS2 , D2L1_BAD , D2L1_DEGRS1 ,  D2L1_DEGRS2 , D2L1_DEGR ,  
D3L1_BADS1 , D3L1_BADS2 , D3L1_BAD , D3L1_DEGRS1 ,  D3L1_DEGRS2 , D3L1_DEGR ,  
D4L2_BADS2 , D3L2_BADS3 , D4L2_BAD , D4L2_DEGRS2 ,  D4L2_DEGRS3 , D3L2_DEGR ,  
D1L1_NUM , D2L1_NUM , D3L1_NUM , D4L2_NUM , 
D1STATUS , D2STATUS , D3STATUS , D4STATUS ,
S1STATUS , S2STATUS , S3STATUS , S4STATUS ,
      STATUSSTRING,STATUSTEXT,OVERALLSTATUS, UPDATED_UNIX, 
      UPDATED_SQL 
      )
    VALUES (
      n.l3, split(1,'|',n.content), 
      INTEGER(split(2,'|',n.content)), INTEGER(split(3,'|',n.content)), INTEGER(split(4,'|',n.content)), INTEGER(split(5,'|',n.content)), INTEGER(split(6,'|',n.content)), INTEGER(split(7,'|',n.content)), 
      INTEGER(split(8,'|',n.content)), INTEGER(split(9,'|',n.content)), INTEGER(split(10,'|',n.content)), INTEGER(split(11,'|',n.content)), INTEGER(split(12,'|',n.content)), INTEGER(split(13,'|',n.content)), 
      INTEGER(split(14,'|',n.content)), INTEGER(split(15,'|',n.content)), INTEGER(split(16,'|',n.content)), INTEGER(split(17,'|',n.content)), INTEGER(split(18,'|',n.content)), INTEGER(split(19,'|',n.content)), 
      INTEGER(split(20,'|',n.content)), INTEGER(split(21,'|',n.content)), INTEGER(split(22,'|',n.content)), INTEGER(split(23,'|',n.content)), INTEGER(split(24,'|',n.content)), INTEGER(split(25,'|',n.content)), 
      INTEGER(split(26,'|',n.content)), INTEGER(split(27,'|',n.content)), INTEGER(split(28,'|',n.content)), INTEGER(split(29,'|',n.content)), 
      INTEGER(split(30,'|',n.content)), INTEGER(split(31,'|',n.content)), INTEGER(split(32,'|',n.content)), INTEGER(split(33,'|',n.content)), 
      INTEGER(split(34,'|',n.content)), INTEGER(split(35,'|',n.content)), INTEGER(split(36,'|',n.content)), INTEGER(split(37,'|',n.content)), 
      INTEGER(split(38,'|',n.content)), INTEGER(split(39,'|',n.content)), INTEGER(split(40,'|',n.content)), INTEGER(split(41,'|',n.content)), 
      split(42,'|',n.content),split(43,'|',n.content), INTEGER(split(44,'|',n.content)), INTEGER(split(45,'|',n.content)), 
      TIMESTAMP_FORMAT(split(46,'|',n.content),'YYYY-MM-DD HH24:MI:SS.FF') 
    );
  END @


commit work @

