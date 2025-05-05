USE ROLE ACCOUNTADMIN;

-- Create a specic role to use for this QuiCkStart
-- This is needed in order to use Notbokks with container runtimes
CREATE ROLE SP_LLM_QS_ROLE;

-- Grant the role to the current user
SET THIS_USER = CURRENT_USER();
grant ROLE SP_LLM_QS_ROLE to USER IDENTIFIER($THIS_USER);

-- Create a datbase where we will store the data and the notebook
CREATE OR REPLACE DATABASE SP_LLM_QS;

-- Create a Warehouse to use for executing SQL
CREATE WAREHOUSE IF NOT EXISTS SP_LLM_QS_WH;

-- Grant ownership and all priviligies on the database and warehouse to the new role
GRANT OWNERSHIP ON DATABASE SP_LLM_QS TO ROLE SP_LLM_QS_ROLE;
GRANT ALL PRIVILEGES ON DATABASE SP_LLM_QS TO ROLE SP_LLM_QS_ROLE;
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE SP_LLM_QS TO ROLE SP_LLM_QS_ROLE;

GRANT OWNERSHIP ON WAREHOUSE SP_LLM_QS_WH TO ROLE SP_LLM_QS_ROLE;
GRANT ALL PRIVILEGES ON WAREHOUSE SP_LLM_QS_WH TO ROLE SP_LLM_QS_ROLE;

-- Use th role for the rest of this script
USE ROLE SP_LLM_QS_ROLE;
USE DATABASE SP_LLM_QS;
USE SCHEMA PUBLIC;


-- Create a file format to be used when loading the sample data
CREATE or REPLACE file format csvformat
	TYPE=CSV
    PARSE_HEADER = TRUE
    FIELD_DELIMITER='|'
    TRIM_SPACE=TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    REPLACE_INVALID_CHARACTERS=TRUE
    DATE_FORMAT=AUTO
    TIME_FORMAT=AUTO
    TIMESTAMP_FORMAT=AUTO;

-- Create a stage that reference a AWS s3 bucket that has the sample data file
CREATE or REPLACE stage sp_data_stage
  file_format = csvformat
  url = 's3://sfquickstarts/sfguide_s_and_p_market_intelligence_analyze_earnings_transcripts_in_cortex_ai/';

-- Verify that we can read the S3 bucket from snowflake
ls @sp_data_stage;

-- Create the table to load the data into
CREATE OR REPLACE TABLE SAMPLE_TRANSCRIPT ( 
    CALLDATE DATE , 
    ENTEREDDATE DATE , 
    FISCALYEARQUARTER VARCHAR , 
    CALENDARYEARQUARTER VARCHAR , 
    TRADINGITEMID NUMBER(38, 0) , 
    COMPANYID NUMBER(38, 0) , 
    COMPANYNAME VARCHAR , 
    HEADLINE VARCHAR , 
    TRANSCRIPTID NUMBER(38, 0) , 
    SPEAKERTYPENAME VARCHAR , 
    TRANSCRIPTPERSONNAME VARCHAR , 
    TRANSCRIPTPERSONID NUMBER(38, 0) , 
    PROID NUMBER(38, 1) , 
    TRANSCRIPTCOMPONENTTYPEID NUMBER(38, 0) , 
    TRANSCRIPTCOMPONENTTYPENAME VARCHAR , 
    TRANSCRIPTCOMPONENTID NUMBER(38, 0) , 
    COMPONENTORDER NUMBER(38, 0) , 
    SENTENCEORDER NUMBER(38, 0) , 
    COMPONENTTEXT VARCHAR , 
    PROCESSEDTEXT VARCHAR 
); 

-- Load the data
COPY INTO SAMPLE_TRANSCRIPT
  FROM @sp_data_stage
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Verify that we have data in our table
SELECT * FROM SAMPLE_TRANSCRIPT LIMIT 10;
