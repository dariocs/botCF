@echo off
setlocal

REM Vai alla cartella del progetto dove si trova questo .bat
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo [ERRORE] Node.js non trovato. Installa Node.js 18+ e riprova.
  pause
  exit /b 1
)

if not exist "node_modules" (
  echo Installazione dipendenze in corso...
  call npm install
  if errorlevel 1 (
    echo [ERRORE] npm install non riuscito.
    pause
    exit /b 1
  )
)

if "%REMOTE_MCP_URL%"=="" (
  echo.
  echo Variabile d'ambiente REMOTE_MCP_URL non impostata.
  set /p REMOTE_MCP_URL=Inserisci endpoint MCP ^(esempio: http://localhost:3010/mcp^): 
)

if "%REMOTE_MCP_URL%"=="" (
  echo [ERRORE] Endpoint MCP non fornito. Avvio annullato.
  pause
  exit /b 1
)

echo Avvio chatbot...
call npm start

if errorlevel 1 (
  echo.
  echo [ERRORE] Avvio non riuscito.
)

echo.
echo Premi un tasto per chiudere...
pause >nul
endlocal
