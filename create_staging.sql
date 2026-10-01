CREATE DATABASE IF NOT EXISTS aid_staging
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE aid_staging;

DROP TABLE IF EXISTS stg_maddison;

CREATE TABLE stg_maddison (
    country_iso3    CHAR(3)      NOT NULL,
    country_name    VARCHAR(20)  NOT NULL,
    indicator_code  VARCHAR(10)  NOT NULL,
    indicator_name  VARCHAR(50)  NOT NULL,
    `year`          SMALLINT     NOT NULL,
    `value`         DOUBLE       NULL,
    CONSTRAINT pk_stg_maddison PRIMARY KEY (country_iso3, indicator_code, `year`),
    CONSTRAINT chk_stg_maddison_year CHECK (`year` BETWEEN 1900 AND 2100)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS stg_wdi;

CREATE TABLE stg_wdi (
    country_iso3    CHAR(3)      NOT NULL,
    country_name    VARCHAR(20)  NOT NULL,
    indicator_code  VARCHAR(20)  NOT NULL,
    indicator_name  VARCHAR(100) NOT NULL,
    `year`          SMALLINT     NOT NULL,
    `value`         DOUBLE       NULL,
    CONSTRAINT pk_stg_wdi PRIMARY KEY (country_iso3, indicator_code, `year`),
    CONSTRAINT chk_stg_wdi_year CHECK (`year` BETWEEN 1900 AND 2100)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS stg_events;

CREATE TABLE stg_events (
    event_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `year`          SMALLINT     NOT NULL,
    country_iso3    CHAR(3)      NOT NULL,
    country_name    VARCHAR(20)  NOT NULL,
    `event`         VARCHAR(150) NOT NULL,
    category        VARCHAR(30)  NOT NULL,
    economic_impact VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_stg_events PRIMARY KEY (event_id),
    CONSTRAINT chk_stg_events_year CHECK (`year` BETWEEN 1900 AND 2100),
    INDEX idx_stg_events_country_year (country_iso3, `year`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;