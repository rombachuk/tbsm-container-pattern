
DROP TABLE rulemgr_rule @

CREATE TABLE rulemgr_rule (
   name   VARCHAR(20) NOT NULL,
   key1  VARCHAR(60) NOT NULL,
   key2  VARCHAR(60) NOT NULL,
   key3  VARCHAR(60) NOT NULL,
   id VARCHAR(5) NOT NULL,
   jsondoc   VARCHAR(4096) NOT NULL,
   PRIMARY KEY (name), UNIQUE(key1,key2,key3,id)
) @

