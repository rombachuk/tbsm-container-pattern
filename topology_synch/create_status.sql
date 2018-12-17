
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
L1_BADS1 INTEGER, L1_BADS2 INTEGER, L1_BADS3 INTEGER, L1_BAD INTEGER, L1_DEGRS2 INTEGER, L1_DEGRS3 INTEGER, L1_DEGRS1 INTEGER, L1_DEGR INTEGER, 
L1_NUMS1 INTEGER, L2_NUMS1 INTEGER, L1_NUMS2 INTEGER, L2_NUMS2 INTEGER, L1_NUMS3 INTEGER, L3_NUMS3 INTEGER, 
S1STATUS INTEGER, S2STATUS INTEGER, S3STATUS INTEGER, S4STATUS INTEGER,
STATUSSTRING VARCHAR(512),STATUSTEXT VARCHAR(512),OVERALLSTATUS INTEGER, UPDATED_UNIX INTEGER , UPDATED_SQL TIMESTAMP , UPDATED_COUNT INTEGER DEFAULT 0,
UNIQUE (L3)
) @


CREATE OR REPLACE TRIGGER set_l3_status
  AFTER INSERT ON l3_status_staging
  REFERENCING NEW AS n OLD AS o
  FOR EACH ROW MODE DB2SQL
  BEGIN
    DELETE FROM l3_status WHERE l3 = n.l3;
    INSERT INTO l3_status 
     (L3, SITETYPE,
      L1_BADS1, L1_BADS2, L1_BADS3, L1_BADS1, L1_DEGRS1, L1_DEGRS2, L1_DEGRS3, L1_DEGRS1, 
      S1STATUS, S2STATUS, S3STATUS,S4STATUS,
      STATUSSTRING,STATUSTEXT,OVERALLSTATUS, UPDATED_UNIX, 
      UPDATED_SQL--, 
      --UPDATED_COUNT
      )
    VALUES (
      n.l3, split(1,'|',n.content), 
      INTEGER(split(2,'|',n.content)), INTEGER(split(3,'|',n.content)), INTEGER(split(4,'|',n.content)), INTEGER(split(5,'|',n.content)), INTEGER(split(6,'|',n.content)), INTEGER(split(7,'|',n.content)), INTEGER(split(8,'|',n.content)), INTEGER(split(9,'|',n.content)),
      INTEGER(split(10,'|',n.content)), INTEGER(split(11,'|',n.content)), INTEGER(split(12,'|',n.content)), INTEGER(split(13,'|',n.content)), INTEGER(split(14,'|',n.content)), INTEGER(split(15,'|',n.content)), INTEGER(split(16,'|',n.content)), INTEGER(split(17,'|',n.content)), 
      INTEGER(split(18,'|',n.content)), INTEGER(split(19,'|',n.content)), INTEGER(split(20,'|',n.content)), INTEGER(split(21,'|',n.content)), INTEGER(split(22,'|',n.content)), INTEGER(split(23,'|',n.content)), INTEGER(split(24,'|',n.content)), INTEGER(split(25,'|',n.content)), 
      INTEGER(split(26,'|',n.content)), INTEGER(split(27,'|',n.content)), INTEGER(split(28,'|',n.content)), INTEGER(split(29,'|',n.content)), INTEGER(split(30,'|',n.content)), INTEGER(split(31,'|',n.content)), 
      INTEGER(split(32,'|',n.content)), INTEGER(split(33,'|',n.content)), INTEGER(split(34,'|',n.content)), INTEGER(split(35,'|',n.content)), INTEGER(split(36,'|',n.content)), INTEGER(split(37,'|',n.content)), INTEGER(split(38,'|',n.content)), 
      split(39,'|',n.content),split(40,'|',n.content), INTEGER(split(41,'|',n.content)), INTEGER(split(42,'|',n.content)), 
      TIMESTAMP_FORMAT(split(43,'|',n.content),'YYYY-MM-DD HH24:MI:SS.FF')--, 
      --INTEGER(split(43,'|',n.content))
    );
  END @


commit work @

