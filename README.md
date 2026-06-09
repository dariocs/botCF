# Chatbot Codice Fiscale via MCP

Chatbot CLI in Node.js che raccoglie i dati dall'utente e invoca il tool MCP `calc_codice_fiscale` del server `remote-mcp-server`.

## Requisiti

- Node.js 18+

Opzionale:

- `REMOTE_MCP_URL` per cambiare endpoint (default: `http://as400.it:3010/mcp`)

## Avvio

```powershell
cd c:\botCF
$env:REMOTE_MCP_URL="http://as400.it:3010/mcp" 
npm start
```

## Comportamento

Il chatbot:

1. Verifica che il tool `calc_codice_fiscale` sia disponibile via `tools/list`.
2. Chiede all'utente i dati necessari (solo se mancanti, uno per volta).
3. Accetta la data anche in formato naturale italiano (esempio: `18 gennaio 1996`, `10 febbraio del 46`).
4. Chiede la citta di nascita (esempio: Pavia, Milano) e recupera automaticamente il codice comune Belfiore.
5. Se la citta e ambigua, richiede anche la provincia (esempio: `Castro (LE)`).
6. Esegue `tools/call` verso MCP e stampa il risultato del codice fiscale.

## Sorgenti RPG

La logica di calcolo del codice fiscale è implementata in RPG su IBM i:

### File di origine (`src/QUTYSRC/`)

- **CDFISM.RPGLE** - Modulo RPG che contiene la subroutine `CDFIS_CalcCodiceFiscale` per il calcolo del codice fiscale partendo da cognome, nome, sesso, data di nascita e codice comune Belfiore
- **CDFISM.RPGLE** - Modulo RPG principale 
- **CMDH.RPGLE** - Modulo di comando (header)
- **CMDM.RPGLE** - Modulo di comando (main)
- **STDTYPH.RPGLE** - Definizioni di tipi di dato standard

### File di binding (`src/QUTYSRC/`)

- **CDFISB.BND** - Binding che collega i moduli CDFISH e CDFISM creando il service program `CDFIS`
- **CMDB.BND** - Binding per i moduli di comando

## SQL Function

Il file `src/create_cdfis_sql_function.sql` definisce la funzione SQL `DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale` che espone la logica RPG come funzione SQL su IBM i:

```sql
CDFIS_SQL_CalcCodiceFiscale(
  cognome CHAR(30),
  nome CHAR(30),
  sesso CHAR(1),
  dataNascita DECIMAL(8,0),      -- Formato: YYYYMMDD
  comuneNasc CHAR(4)              -- Codice Belfiore (es. H501 per Milano)
)
```

**Restituisce:** `CHAR(16)` - il codice fiscale calcolato

**Utilizzo:** Può essere usata direttamente in query SQL per calcolare il codice fiscale da tabelle di persone:

```sql
SELECT DCARNEVALE.CDFIS_SQL_CalcCodiceFiscale(
  'CARNEVALE', 'DARIO', 'M', 19880115, 'H501'
) AS CODICEFISCALE
FROM SYSIBM.SYSDUMMY1;
```

## Note

- Formati data supportati: `YYYYMMDD`, `YYYY-MM-DD`, `DD/MM/YYYY`, `19 gennaio 1976`, `10 febbraio del 46`.
- Input citta supporta anche la provincia in coda: `Napoli NA`, `Napoli, NA`, `Napoli (NA)`.
