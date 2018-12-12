drop procedure rulemgr_deldb_rule_alltemplates @
create or replace procedure rulemgr_deldb_rule_alltemplates(  IN p_rulename VARCHAR(255))
LANGUAGE SQL
BEGIN

DECLARE text VARCHAR(1000);
DECLARE stmt STATEMENT;

 SET text = 'DELETE from ranrulemgr_rule where name = ''' || p_rulename || '''';
 PREPARE stmt FROM text;
 EXECUTE stmt ;

END @

drop procedure rulemgr_popdb_like @
create or replace procedure rulemgr_popdb_like( IN p_key1 VARCHAR(64), IN p_key2 VARCHAR(255), IN p_key3 VARCHAR(64), 
                      IN p_newid VARCHAR(20), IN p_newrule VARCHAR(64),  IN p_newclassifier VARCHAR(255), IN p_newimpact VARCHAR(20), 
                      IN p_likeid VARCHAR(20), IN p_likerule VARCHAR(64),IN p_likeclassifier VARCHAR(255), IN p_likeimpact VARCHAR(20))  
LANGUAGE SQL
BEGIN

DECLARE rtext VARCHAR(200);
DECLARE text VARCHAR(6000);
DECLARE v_rule VARCHAR(4096);
DECLARE stmt STATEMENT;


 SET text = 'INSERT INTO rulemgr_rule(name,key1,key2,key3,id,jsondoc)  SELECT '''||p_newrule||''' as name,'''||p_key1||''' as key1,'''||p_key2||''' as key2,'''||p_key3||''' as key3,'''||p_newid||''' as id,replace(replace(replace(replace(jsondoc,'''||p_likerule||''','''||p_newrule||'''),'''||p_likeclassifier||''','''||p_newclassifier||'''),''"'||p_likeimpact||'"'',''"'||p_newimpact||'"''),''"'||p_likeid||'"'',''"'||p_newid||'"'') as jsondoc from rulemgr_rule where name = '''||p_likerule||''''; 
 PREPARE stmt FROM text;
 EXECUTE stmt ;

END @

commit work @


