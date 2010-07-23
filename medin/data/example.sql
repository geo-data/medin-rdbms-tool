-- SQL to create the SQLite schema used in the 'example' provider
-- plugin. This is taken from the BODC schema.

BEGIN;

CREATE TABLE METADATA
(
  METADATAID     NUMBER(10) PRIMARY KEY,
  TITLE          VARCHAR2(500),
  ABSTRACT       VARCHAR2(4000),
  RESTYP_ID      NUMBER(10)                     NOT NULL,
  RESLOC         NUMBER(10),
  IDENTIFIER     VARCHAR2(255),
  CODESPACE      VARCHAR2(255)             DEFAULT 'http://www.bodc.ac.uk',
  SDSTYP_ID      NUMBER(10),
  WEST           NUMBER(7,4),
  EAST           NUMBER(7,4),
  NORTH          NUMBER(7,4),
  SOUTH          NUMBER(7,4),
  VERTEXTMIN     NUMBER(11),
  VERTEXTMAX     NUMBER(11),
  VERTEXTREF_ID  VARCHAR2(500),
  SRSYS_ID       VARCHAR2(500),
  TEMPEXBGN      VARCHAR2(20),
  REVDATE        DATE,
  CREATED        DATE,
  PUBDATE        DATE,
  TEMPEXEND      VARCHAR2(20),
  LINEAGE        VARCHAR2(4000),
  SPARES         VARCHAR2(20)              DEFAULT 'inapplicable',
  FREQMOD_ID     NUMBER(10),
  MODDATE        TIMESTAMP(6)                   DEFAULT SYSTIMESTAMP,
  MODBY          VARCHAR2(50),
  STD_ID         NUMBER(10),
  FOREIGN KEY (RESLOC) REFERENCES CITATION (CITATIONID)
);

CREATE TABLE CITATION
(
  CITATIONID    NUMBER(10),
  PUBYEAR       DATE,
  PUBTYP        VARCHAR2(30),
  PUBTITLE      VARCHAR2(1000),
  VOLUME        NUMBER(10),
  ISSUE         VARCHAR2(45),
  PAGES         VARCHAR2(10),
  AUTHORS       VARCHAR2(1000),
  EDITORS       VARCHAR2(255),
  PUBPLACE      VARCHAR2(200),
  ORGREP        VARCHAR2(255),
  ONLINERES     VARCHAR2(500),
  ONLINERESNAM  VARCHAR2(500),
  EDITION       VARCHAR2(25),
  EDITIONDATE   DATE,
  PUBLISHER     VARCHAR2(255),
  PUBSUBTYP     VARCHAR2(30),
  CONTRACTCODE  VARCHAR2(100),
  URL_ACCESSED  DATE
);

CREATE TABLE ALT_TITLE
(
  METADATAID  NUMBER(10),
  ALTTITLE    VARCHAR2(350)                NOT NULL,
  PRIMARY KEY (METADATAID, ALTTITLE),
  FOREIGN KEY (METADATAID) REFERENCES METADATA (METADATAID)
);

Insert into ALT_TITLE (METADATAID, ALTTITLE) VALUES (182, 'test title');
Insert into ALT_TITLE (METADATAID, ALTTITLE) VALUES (183, 'Alternative title (test)');
Insert into ALT_TITLE (METADATAID, ALTTITLE) VALUES (191, 'A different title');

Insert into METADATA
   (METADATAID, TITLE, ABSTRACT, RESTYP_ID, RESLOC, 
    IDENTIFIER, CODESPACE, SDSTYP_ID, WEST, EAST, 
    NORTH, SOUTH, VERTEXTMIN, VERTEXTMAX, VERTEXTREF_ID, 
    SRSYS_ID, TEMPEXBGN, REVDATE, CREATED, PUBDATE, 
    TEMPEXEND, LINEAGE, SPARES, FREQMOD_ID, MODDATE, 
    MODBY, STD_ID)
 Values
   (182, 'NIO Neutrally Buoyant Float Data Reports (1955-1964, 1969)', 'The data set comprises a series of ten reports produced by the
National Institute of Oceanography (NIO) - now the IOS Deacon Laboratory - 
containing tables of data and diagrams of trajectories derived from neutrally
buoyant floats. The floats were numbered between 1-180 and 209-227 and were
deployed as shown in the table below:
  Ship                 Dates                          Area                 Float Nos.

                          Jun 1955,                   NE Atlantic                        1-5
                          October-November 1955
                          April-May 1956            Norwegian Sea                 6-10
                          August 1956               NE Atlantic                        11
                          March 1957                NW Atlantic                      12-20
                          July-August 1957        NW Pacific                       21-24
                          May-July 1958            NE Atlantic                        25-33
                          November 1958          NE Atlantic                       34-39
R.V. Aries          June-October 1959     deep water off Bermuda   40-53,55,58
R.V. Crawford    October 1959             deep water off Bermuda    54,56-57
R.V. Aries           June-December 1959  deep water off Bermuda  59-60,64-65,68, 
                                                                                                        69,71,73-74
R.V. Crawford    November 1959         deep water off Bermuda    61-63,66-67,70,72
R.V. Atlantis       December 1959         deep water off Bermuda    75-77
R.V. Aries           February-June 1960    deep water off Bermuda  78-98
R.V. Aries           June-August 1960      deep water off Bermuda   99-119 
RRS Discovery  July 1961                     Faroe-Shetland Channel  120-127
Erika Dan           1962                           Labrador Sea                   128-132
RRS Discovery  July-August 1963        Arabian Sea                     133-134,136-139
Ernest Holt         July 1963                    Faroe Bank Channel        135
RRS Discovery  March-April 1964         Indian Ocean                  140-160
RRS Discovery  April                             Indian Ocean                  161-180
                          June-August 1964
RRS Discovery  February-March 1969   NW Mediterranean        209-227', 5, 7, 
    'EDMED182', 'http://www.bodc.ac.uk/', NULL, -180, 180, 
    80, -80, NULL, NULL, NULL, 
    'urn:ogc:def:crs:EPSG:7030', '1955', '2010-01-11 13:14:19', '2010-01-27 15:21:28', '2010-06-17 09:37:33', 
    '1969', 'INSTRUMENT TYPES: current meters.', 'inapplicable', 47, '2010-06-17 09:37:33.000000', 
    'Hannah Freeman (BODC)', 1);
Insert into METADATA
   (METADATAID, TITLE, ABSTRACT, RESTYP_ID, RESLOC, 
    IDENTIFIER, CODESPACE, SDSTYP_ID, WEST, EAST, 
    NORTH, SOUTH, VERTEXTMIN, VERTEXTMAX, VERTEXTREF_ID, 
    SRSYS_ID, TEMPEXBGN, REVDATE, CREATED, PUBDATE, 
    TEMPEXEND, LINEAGE, SPARES, FREQMOD_ID, MODDATE, 
    MODBY, STD_ID)
 Values
   (183, 'IOSDL Compilation of Surface Currents of the equatorial Indian Ocean (1854-1974)', 'The surface currents of the Indian Ocean data set comprises data collected between 1854 and 1974, covering the area bounded by coasts of Africa and Asia, longitudes 50deg E (in the Gulf of Aden) and 100deg E and latitude 25deg S. The surface currents, measured from ship''s drift, have been compiled into 10-day periods and 1-degree latitude-longitude quadrangles.  For each 10-day period and 1-degree quadrangle, the vector mean of all of the observations from all years has been calculated. With this amount of subdivision, coverage is often sparse and sometimes non-existent.  Historical data on surface currents seem to have been relatively neglected, in comparison to winds and sea surface temperatures. This is not altogether surprising, in view of their notorious errors, both random and systematic. Despite these disadvantages they have been re-examined in the equatorial Indian Ocean by scientists at the Institute of Oceanographic Sciences Deacon Laboratory (IOSDL), where in several places surface currents are strong, and have a well marked annual or semi-annual cycle.  Prior to the compilation of this data set and atlas, the best existing compilation was contained in the Koninglijk Nederlands Meteorologische Institut Indische Ocean, Oceanografische en Meteorologische Oegevens (2nd Edition) published in 1952. Thirty years of data had accumulated since it was compiled, although the more recent data were less numerous than those in the 1920s and 1930s. This, combined with a spatial resolution (2x2 degrees) somewhat coarse in regions of strong currents and the series of monthly charts which were barely adequate for showing the development of features with a semi-annual period, led to the compilation of this data set. The source material for this atlas was obtained from the UK Meteorological Office archive of historical surface currents.', 5, NULL, 
    'EDMED183', 'http://www.bodc.ac.uk/', NULL, 50, 100, 
    10, -25, NULL, NULL, NULL, 
    'urn:ogc:def:crs:EPSG:7030', '1854', '2010-01-21 10:09:44', '2010-02-25 13:48:08', '2010-06-17 09:37:33', 
    '1974', 'unknown', 'inapplicable', 47, '2010-06-17 09:37:33.000000', 
    'Hannah Freeman (BODC)', 1);
Insert into METADATA
   (METADATAID, TITLE, ABSTRACT, RESTYP_ID, RESLOC, 
    IDENTIFIER, CODESPACE, SDSTYP_ID, WEST, EAST, 
    NORTH, SOUTH, VERTEXTMIN, VERTEXTMAX, VERTEXTREF_ID, 
    SRSYS_ID, TEMPEXBGN, REVDATE, CREATED, PUBDATE, 
    TEMPEXEND, LINEAGE, SPARES, FREQMOD_ID, MODDATE, 
    MODBY, STD_ID)
 Values
   (191, 'LORACOM Acoustic transmission data from the western Mediterranean 1994-1996', 'During both LORACOM experiments oceanographic measurements were made to define the mean state of the sound channel along the acoustic transmission path. For the 1996 experiment additional data on the day-to-day variability of the sound channel and internal waves was also gathered.  During the 1994 experiment shallow CTD and deep temp/depth casts were made at 2 stations.', 5, 6, 
    'EDMED191', 'http://www.bodc.ac.uk/', NULL, 7, 8, 
    44, 43, NULL, NULL, NULL, 
    'urn:ogc:def:crs:EPSG:7030', '1994', '2010-01-11 13:35:38', '2010-02-25 13:53:05', '2010-06-17 09:37:33', 
    '1996', 'INSTRUMENT TYPES: CTD profilers, bathythermographs, water temperature sensors, sea level recorders.', 'inapplicable', 47, '2010-06-17 09:37:33.000000', 
    'Hannah Freeman (BODC)', 1);


Insert into CITATION
   (CITATIONID, PUBYEAR, PUBTYP, PUBTITLE, VOLUME, 
    ISSUE, PAGES, AUTHORS, EDITORS, PUBPLACE, 
    ORGREP, ONLINERES, ONLINERESNAM, EDITION, EDITIONDATE, 
    PUBLISHER, PUBSUBTYP, CONTRACTCODE, URL_ACCESSED)
 Values
   (4, '1994-10-01 00:00:00', NULL, 'Users Guide to the BOFS North Atlantic Data Set.', NULL, 
    NULL, NULL, 'Lowry, R.K., Machin, P. and Cramer, R.N', NULL, NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL);
Insert into CITATION
   (CITATIONID, PUBYEAR, PUBTYP, PUBTITLE, VOLUME, 
    ISSUE, PAGES, AUTHORS, EDITORS, PUBPLACE, 
    ORGREP, ONLINERES, ONLINERESNAM, EDITION, EDITIONDATE, 
    PUBLISHER, PUBSUBTYP, CONTRACTCODE, URL_ACCESSED)
 Values
   (5, '1992-07-01 00:00:00', NULL, 'The BOFS 1990 Spring Bloom Experiment: temporal evolution and spatial variability of the hydrographic field.', NULL, 
    NULL, NULL, 'Savidge, G., Turner, D.R., Burkhill, P.H., Watson, A.J., Angel, M.V., Pingree, R.D., Leach, H and Richards, K.J.', 'Progress in Oceanography Vol. 29(3): 235-281.', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL);

INSERT INTO CITATION
       (CITATIONID, ONLINERES, ONLINERESNAM)
       Values(6, 'www.google.co.uk', 'test');

INSERT INTO CITATION
       (CITATIONID, ONLINERES, ONLINERESNAM)
       Values(7, 'www.geodata.soton.ac.uk', 'test2');
COMMIT;