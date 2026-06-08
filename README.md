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

## Note

- Formati data supportati: `YYYYMMDD`, `YYYY-MM-DD`, `DD/MM/YYYY`, `19 gennaio 1976`, `10 febbraio del 46`.
- Input citta supporta anche la provincia in coda: `Napoli NA`, `Napoli, NA`, `Napoli (NA)`.
