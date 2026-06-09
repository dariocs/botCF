
CREATE OR REPLACE FUNCTION DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale(
  cognome CHAR(30),
  nome CHAR(30),
  sesso CHAR(1),
  dataNascita DECIMAL(8,0),
  comuneNasc CHAR(4)
)
RETURNS CHAR(16)
RETURNS NULL ON NULL INPUT
DETERMINISTIC
NO SQL
LANGUAGE RPGLE
PARAMETER STYLE GENERAL
EXTERNAL NAME 'DCARNEVALE/CDFIS(CDFIS_CALCCODICEFISCALE)';

-- Examples of invocation once the function exists:
-- 1) Simple SELECT (returns 1 row):
-- SELECT DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale(
--   'CARNEVALE', 'DARIO', 'M', 19880115, 'H501'
-- ) AS CODICEFISCALE
-- FROM SYSIBM.SYSDUMMY1;

-- 2) VALUES form (handy in STRSQL):
-- VALUES( DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale('CARNEVALE','DARIO','M',19880115,'H501'))

-- 3) Use inside a query joining a table of people (example):
-- SELECT p.*, DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale(p.surname, p.givenname, p.gender, p.birthdate, p.placecode)
--   AS CODICEFISCALE
-- FROM MYLIB.PEOPLE p
-- WHERE p.id = 123;

-- Deployment note: place this SQL in a member of QSQLSRC (DCARNEVALE) and run
-- RUNSQLSTM or paste into Run SQL Scripts. Creating the SQL function requires
-- that the service program `CDFIS` (library DCARNEVALE) is available in the
-- library list or referenced explicitly as done in EXTERNAL NAME.
