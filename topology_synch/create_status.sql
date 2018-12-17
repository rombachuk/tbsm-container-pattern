
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
      L1_BADS1, L1_BADS2, L1_BADS3, L1_BAD, L1_DEGRS1, L1_DEGRS2, L1_DEGRS3, L1_DEGR, 
      S1STATUS, S2STATUS, S3STATUS,S4STATUS,
      STATUSSTRING,STATUSTEXT,OVERALLSTATUS, UPDATED_UNIX, 
      UPDATED_SQL--, 
      --UPDATED_COUNT
      )
    VALUES (
      n.l3, split(1,'|',n.content), 
      INTEGER(split(2,'|',n.content)), INTEGER(split(3,'|',n.content)), INTEGER(split(4,'|',n.content)), INTEGER(split(5,'|',n.content)), INTEGER(split(6,'|',n.content)), INTEGER(split(7,'|',n.content)), INTEGER(split(8,'|',n.content)), INTEGER(split(9,'|',n.content)),
      INTEGER(split(10,'|',n.content)), INTEGER(split(11,'|',n.content)), INTEGER(split(12,'|',n.content)), INTEGER(split(13,'|',n.content)), 
      split(14,'|',n.content),split(15,'|',n.content), INTEGER(split(16,'|',n.content)), INTEGER(split(17,'|',n.content)), 
      TIMESTAMP_FORMAT(split(18,'|',n.content),'YYYY-MM-DD HH24:MI:SS.FF')--, 
      --INTEGER(split(43,'|',n.content))
    );
  END @


commit work @

