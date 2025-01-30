-- This script creates the neccessary objects to run the Quickstart
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS SP_LLM_QS;

CREATE WAREHOUSE IF NOT EXISTS SP_LLM_QS_WH;

USE DATABASE SP_LLM_QS;

-- Create a network rule and a external access integration to allow to download NLTK additions
CREATE OR REPLACE NETWORK RULE githubusercontent_network_rule
 MODE = EGRESS
 TYPE = HOST_PORT
 VALUE_LIST = ('raw.githubusercontent.com');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION SP_LLM_QS_NLTK_INTEGRATION
  ALLOWED_NETWORK_RULES= (GITHUBUSERCONTENT_NETWORK_RULE)
  ENABLED = TRUE;