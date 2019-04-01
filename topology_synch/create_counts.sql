
/*-----------------------------------------------
 * L3 Section 
 *
 */

drop table L3_COUNTS @

create TABLE L3_COUNTS (
L3 VARCHAR(64) NOT NULL, L3TYPE VARCHAR(10), COUNTL2 INTEGER, 
 COUNTD1L1 INTEGER,
 COUNTD2L1 INTEGER,
 COUNTD3L1 INTEGER,
 COUNTD4L2 INTEGER,
PRIMARY KEY (L3)
) @


create or replace procedure populate_l3_counts () 
LANGUAGE SQL
BEGIN
DECLARE v_L3 VARCHAR(255);
DECLARE v_L3TYPE VARCHAR(10);
DECLARE v_cntl2 INT DEFAULT 0;
DECLARE v_cntd1l1 INT DEFAULT 0;
DECLARE v_cntd2l1 INT DEFAULT 0;
DECLARE v_cntd3l1 INT DEFAULT 0;
DECLARE v_cntd4l2 INT DEFAULT 0;
DECLARE v_cntl1,v_commitcount,v_count,v_numl3 INT DEFAULT 0;


DECLARE c1 CURSOR WITH HOLD FOR 
  SELECT l3 from  
  (SELECT  l3 from  d2_l1 group by l3
   UNION SELECT  l3 from  d3_l1 group by l3
   UNION SELECT  l3 from  d1_l1 group by l3) ;


SELECT COUNT(*) INTO v_numl3 from 
  (SELECT l3 from  
  (SELECT  l3 from  d2_l1 group by l3
   UNION SELECT  l3 from  d3_l1 group by l3
   UNION SELECT  l3 from  d1_l1 group by l3)
   );
 
call DBMS_OUTPUT.PUT_LINE('Num l3 = ' || v_l3);
OPEN c1;
WHILE v_count < v_numl3
DO
 SET v_cntl2 = 0; 
 SET v_cntd1l1 = 0;
 SET v_cntd2l1 = 0;
 SET v_cntd3l1 = 0;
 FETCH c1 INTO v_L3;

 SELECT COUNT(*) INTO v_cntd1l1 FROM (select l1 from d1_l1 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cntd2l1 FROM (select l1 from d2_l1 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cntd3l1 FROM (select l1 from d3_l1 WHERE l3 = v_L3 group by l1); 
 SELECT COUNT(*) INTO v_cntd4l2 FROM (select l2 from d4_l2 WHERE l3 = v_L3 group by l2); 
 SELECT COUNT(*) INTO v_cntl1 from
  (SELECT l1 from  
  (SELECT  l1 from  d1_l1 where l3 = v_L3  group by l1
   UNION SELECT  l1 from  d2_l1 where l3 = v_L3  group by l1
   UNION SELECT  l1 from  d3_l1 where l3 = v_L3  group by l1) group by l1);
 SELECT COUNT(*) INTO v_cntl2 from
  (SELECT l2 from  
  (SELECT  l2 from  d1_l1 where l3 = v_L3  group by l2
   UNION SELECT  l2 from  d2_l1 where l3 = v_L3  group by l2
   UNION SELECT l2 from d4_l2 where l3 = v_L3 group by l2
   UNION SELECT  l2 from  d3_l1 where l3 = v_L3  group by l2) group by l2);

 

 IF ((v_cntd1l1 > 0) and (v_cntd2l1 > 0) and (v_cntd3l1 > 0)) THEN SET v_l3type = 'D1D2D3'; END IF;
 IF ((v_cntd1l1 > 0) and (v_cntd2l1 > 0) and (v_cntd3l1 = 0)) THEN SET v_l3type = 'D1D2'; END IF;
 IF ((v_cntd1l1 > 0) and (v_cntd2l1 = 0) and (v_cntd3l1 > 0)) THEN SET v_l3type = 'D1D3'; END IF;
 IF ((v_cntd1l1 = 0) and (v_cntd2l1 > 0) and (v_cntd3l1 > 0)) THEN SET v_l3type = 'D2D3'; END IF;
 IF ((v_cntd1l1 > 0) and (v_cntd2l1 = 0) and (v_cntd3l1 = 0)) THEN SET v_l3type = 'D1only'; END IF;
 IF ((v_cntd1l1 = 0) and (v_cntd2l1 > 0) and (v_cntd3l1 = 0)) THEN SET v_l3type = 'D2only'; END IF;
 IF ((v_cntd1l1 = 0) and (v_cntd2l1 = 0) and (v_cntd3l1 > 0)) THEN SET v_l3type = 'D3only'; END IF;

 delete from L3_COUNTS where   l3 = v_L3 ; /* Clear any existing rows */
 insert into L3_COUNTS  (L3,L3TYPE,COUNTL2,COUNTD1L1,COUNTD2L1,COUNTD3L1, COUNTD4L2)
 values (v_l3,v_l3type, v_cntl2, v_cntd1l1, v_cntd2l1, v_cntd3l1, v_cntd4l2);
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



