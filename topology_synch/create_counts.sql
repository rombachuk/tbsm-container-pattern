
/*-----------------------------------------------
 * L3 Section 
 *
 */

drop table L3_COUNTS @

create TABLE L3_COUNTS (
L3 VARCHAR(64) NOT NULL, L3TYPE VARCHAR(10), COUNTL2 INTEGER, 
 COUNTS1L1 INTEGER,
 COUNTS2L1 INTEGER,
 COUNTS3L1 INTEGER,
COUNTL1 INTEGER, ACTIVEEVENTSFLAG INTEGER DEFAULT 0,
PRIMARY KEY (L3)
) @


create or replace procedure populate_l3_counts () 
LANGUAGE SQL
BEGIN
DECLARE v_L3 VARCHAR(255);
DECLARE v_L3TYPE VARCHAR(10);
DECLARE v_ACTIVEFLAG INT DEFAULT 0;
DECLARE v_cntl2 INT DEFAULT 0;
DECLARE v_cnts1l1 INT DEFAULT 0;
DECLARE v_cnts2l1 INT DEFAULT 0;
DECLARE v_cnts3l1 INT DEFAULT 0;
DECLARE v_cntl1,v_commitcount,v_count,v_numl3 INT DEFAULT 0;


DECLARE c1 CURSOR WITH HOLD FOR 
  SELECT l3 from  
  (SELECT  l3 from  l1_s2 group by l3
   UNION SELECT  l3 from  l1_s3 group by l3
   UNION SELECT  l3 from  l1_s1 group by l3) ;


SELECT COUNT(*) INTO v_numl3 from 
  (SELECT l3 from  
  (SELECT  l3 from  l1_s2 group by l3
   UNION SELECT  l3 from  l1_s3 group by l3
   UNION SELECT  l3 from  l1_s1 group by l3)
   );
 
call DBMS_OUTPUT.PUT_LINE('Num l3 = ' || v_l3);
OPEN c1;
WHILE v_count < v_numl3
DO
 SET v_cntl2 = 0; 
 SET v_cnts1l1 = 0;
 SET v_cnts2l1 = 0;
 SET v_cnts3l1 = 0;
 SET v_ACTIVEFLAG = 0; 
 FETCH c1 INTO v_L3;

 SELECT COUNT(*) INTO v_cnts1l1 FROM (select l1 from l1_s1 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cnts2l1 FROM (select l1 from l1_s2 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cnts3l1 FROM (select l1 from l1_s3 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cntl1 from
  (SELECT l1 from  
  (SELECT  l1 from  l1_s1 where l3 = v_L3  group by l1
   UNION SELECT  l1 from  l1_s2 where l3 = v_L3  group by l1
   UNION SELECT  l1 from  l1_s3 where l3 = v_L3  group by l1) );

 
 SELECT coalesce(max(ACTIVEEVENTSFLAG),0) into v_ACTIVEFLAG from L3_COUNTS where  l3 = v_L3 ; /* Get current events flag */

 IF ((v_cnts1l1 > 0) and (v_cnts2l1 > 0) and (v_cnts3l1 > 0)) THEN SET v_l3type = 'S1S2S3'; END IF;
 IF ((v_cnts1l1 > 0) and (v_cnts2l1 > 0) and (v_cnts3l1 = 0)) THEN SET v_l3type = 'S1S2'; END IF;
 IF ((v_cnts1l1 > 0) and (v_cnts2l1 = 0) and (v_cnts3l1 > 0)) THEN SET v_l3type = 'S1S3'; END IF;
 IF ((v_cnts1l1 = 0) and (v_cnts2l1 > 0) and (v_cnts3l1 > 0)) THEN SET v_l3type = 'S2S3'; END IF;
 IF ((v_cnts1l1 > 0) and (v_cnts2l1 = 0) and (v_cnts3l1 = 0)) THEN SET v_l3type = 'S1only'; END IF;
 IF ((v_cnts1l1 = 0) and (v_cnts2l1 > 0) and (v_cnts3l1 = 0)) THEN SET v_l3type = 'S2only'; END IF;
 IF ((v_cnts1l1 = 0) and (v_cnts2l1 = 0) and (v_cnts3l1 > 0)) THEN SET v_l3type = 'S3only'; END IF;

 delete from L3_COUNTS where   l3 = v_L3 ; /* Clear any existing rows */
 insert into L3_COUNTS  (L3,L3TYPE,COUNTL2,COUNTS1L1,COUNTS2L1,COUNTS3L1, COUNTL1,ACTIVEEVENTSFLAG)
 values (v_l3,v_l3type, v_cntl2, v_cnts1l1, v_cnts2l1, v_cnts3l1, v_cntl1,v_ACTIVEFLAG);
 set v_count = v_count + 1;
 set v_commitcount = v_commitcount + 1;
 IF (v_commitcount = 100) THEN
 commit work;
 set v_commitcount = 0;
 END IF;
END WHILE;
CLOSE C1; 

 call DBMS_OUTPUT.PUT_LINE('Count = ' || v_count);
END @



