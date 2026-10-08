CREATE DATABASE IF NOT EXISTS dw
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
 
USE dw;
 
DROP TABLE IF EXISTS fact_economy;
DROP TABLE IF EXISTS fact_society;
DROP TABLE IF EXISTS fact_sector;
DROP TABLE IF EXISTS bridge_event;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_time;
DROP TABLE IF EXISTS dim_sector;
 
CREATE TABLE dim_country (
    country_key   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    iso3_code     CHAR(3)      NOT NULL,
    country_name  VARCHAR(20)  NOT NULL,
    country_group VARCHAR(30)  NOT NULL,
    CONSTRAINT primary_key_dim_country PRIMARY KEY (country_key),
    CONSTRAINT unique_dim_country_iso3 UNIQUE (iso3_code)
);
 
CREATE TABLE dim_time (
    time_key INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `year`   SMALLINT     NOT NULL,
    decade   SMALLINT     GENERATED ALWAYS AS (`year` - MOD(`year`, 10)) STORED NOT NULL,
    CONSTRAINT primary_key_dim_time PRIMARY KEY (time_key),
    CONSTRAINT unique_dim_time_year UNIQUE (`year`),
);
 
CREATE TABLE dim_sector (
    sector_key   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    sector_code  VARCHAR(10)  NOT NULL,
    sector_name  VARCHAR(30)  NOT NULL,
    broad_sector VARCHAR(20)  NOT NULL,
    is_additive  TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT primary_key_dim_sector PRIMARY KEY (sector_key),
    CONSTRAINT unique_dim_sector_code UNIQUE (sector_code),
    CONSTRAINT check_dim_sector_broad CHECK (broad_sector IN ('Primary', 'Secondary', 'Tertiary'))
);
 
CREATE TABLE fact_economy (
    country_key     INT UNSIGNED NOT NULL,
    time_key        INT UNSIGNED NOT NULL,
    gdp_per_capita  DOUBLE       NULL,
    gdp             DOUBLE       NULL,
    gdp_growth_pct  DOUBLE       NULL,
    exports_pct_gdp DOUBLE       NULL,
    imports_pct_gdp DOUBLE       NULL,
    CONSTRAINT primary_key_fact_economy PRIMARY KEY (country_key, time_key),
    CONSTRAINT foreign_key_fact_economy_country FOREIGN KEY (country_key) REFERENCES dim_country (country_key),
    CONSTRAINT foreign_key_fact_economy_time    FOREIGN KEY (time_key)    REFERENCES dim_time (time_key)
);
 
CREATE TABLE fact_society (
    country_key     INT UNSIGNED NOT NULL,
    time_key        INT UNSIGNED NOT NULL,
    population      DOUBLE       NULL,
    gni_per_capita  DOUBLE       NULL,
    life_expectancy DOUBLE       NULL,
    urban_pop_pct   DOUBLE       NULL,
    CONSTRAINT primary_key_fact_society PRIMARY KEY (country_key, time_key),
    CONSTRAINT foreign_key_fact_society_country FOREIGN KEY (country_key) REFERENCES dim_country (country_key),
    CONSTRAINT foreign_key_fact_society_time    FOREIGN KEY (time_key)    REFERENCES dim_time (time_key)
);
 
CREATE TABLE fact_sector (
    country_key         INT UNSIGNED NOT NULL,
    time_key            INT UNSIGNED NOT NULL,
    sector_key          INT UNSIGNED NOT NULL,
    value_added_pct_gdp DOUBLE       NULL,
    value_added_usd     DOUBLE       NULL,
    employment_pct      DOUBLE       NULL,
    CONSTRAINT primary_key_fact_sector PRIMARY KEY (country_key, time_key, sector_key),
    CONSTRAINT foreign_key_fact_sector_country FOREIGN KEY (country_key) REFERENCES dim_country (country_key),
    CONSTRAINT foreign_key_fact_sector_time    FOREIGN KEY (time_key)    REFERENCES dim_time (time_key),
    CONSTRAINT foreign_key_fact_sector_sector  FOREIGN KEY (sector_key)  REFERENCES dim_sector (sector_key)
);
 
CREATE TABLE bridge_event (
    event_key         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    country_key       INT UNSIGNED NOT NULL,
    time_key          INT UNSIGNED NOT NULL,
    event_description VARCHAR(150) NOT NULL,
    category          VARCHAR(30)  NOT NULL,
    economic_impact   VARCHAR(50)  NOT NULL,
    CONSTRAINT primary_key_bridge_event PRIMARY KEY (event_key),
    CONSTRAINT foreign_key_bridge_event_country FOREIGN KEY (country_key) REFERENCES dim_country (country_key),
    CONSTRAINT foreign_key_bridge_event_time    FOREIGN KEY (time_key)    REFERENCES dim_time (time_key)
);