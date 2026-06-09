**free
ctl-opt nomain bnddir('UTY');

 /include qutysrc,cdfish

 // §STR§
 // AUTHOR: GitHub Copilot
 // TYPE: Service Program Module
 // CATEGORY: Codice Fiscale
 // DESCRIPTION: Verifica il codice fiscale italiano per persona fisica.
 // §END§

// Tabelle per il calcolo del carattere di controllo
Dcl-C VOCALIG 'AEIOU';
Dcl-C CONSONANTIG 'BCDFGHJKLMNPQRSTVWXYZ';
Dcl-C MESI 'ABCDEHLMPRST';

// Tabelle per il carattere di controllo
Dcl-C CARATTERI_PARI '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Dcl-C CARATTERI_DISPARI '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Dcl-C CARATTERI_CONTROLLO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

//----------------------------------------------------------------------
// Calcola il codice fiscale completo
//----------------------------------------------------------------------
Dcl-Proc CDFIS_CalcCodiceFiscale Export;
  Dcl-Pi *N Char(16);
    cognome     Char(30) Const;
    nome        Char(30) Const;
    sesso       Char(1)  Const;
    dataNascita Packed(8:0) Const;
    comuneNasc  Char(4)  Const;
  End-Pi;

  Dcl-S parteAnagrafica Char(11);
  Dcl-S primi15Char Char(15);
  Dcl-S carattereControllo Char(1);

  Monitor;
    // Calcola primi 11 caratteri
    parteAnagrafica = CDFIS_CalcParteAnagrafica(cognome : nome : sesso : dataNascita);
    If parteAnagrafica = *Blanks;
      Return *Blanks;
    EndIf;

    // Aggiungi codice comune
    primi15Char = parteAnagrafica + %Trim(comuneNasc);

    // Calcola carattere di controllo
    carattereControllo = CDFIS_CalcCarattereControllo(primi15Char);
    If carattereControllo = *Blank;
      Return *Blanks;
    EndIf;

    Return primi15Char + carattereControllo;

  On-Error;
    Return *Blanks;
  EndMon;

End-Proc;

//----------------------------------------------------------------------
// Calcola la parte anagrafica (primi 11 caratteri)
//----------------------------------------------------------------------
Dcl-Proc CDFIS_CalcParteAnagrafica Export;
  Dcl-Pi *N Char(11);
    cognome     Char(30) Const;
    nome        Char(30) Const;
    sesso       Char(1)  Const;
    dataNascita Packed(8:0) Const;
  End-Pi;

  Dcl-S risultato Char(11);
  Dcl-S cognomeProcessato Char(3);
  Dcl-S nomeProcessato Char(3);
  Dcl-S annoNascita Char(2);
  Dcl-S meseNascita Char(1);
  Dcl-S giornoNascita Char(2);
  Dcl-S dataStr Char(8);
  Dcl-S anno Zoned(4);
  Dcl-S mese Zoned(2);
  Dcl-S giorno Zoned(2);

  Monitor;
    // Valida parametri
    If %Trim(cognome) = '' Or %Trim(nome) = '' Or
       (sesso <> 'M' And sesso <> 'F') Or dataNascita <= 0;
      Return *Blanks;
    EndIf;

    // Processa cognome
    cognomeProcessato = processaNome(%Trim(%Upper(cognome)));

    // Processa nome
    nomeProcessato = processaNome(%Trim(%Upper(nome)));

    // Processa data di nascita
    dataStr = %Char(dataNascita);
    anno = %Int(%Subst(dataStr:1:4));
    mese = %Int(%Subst(dataStr:5:2));
    giorno = %Int(%Subst(dataStr:7:2));

    // Valida data
    If anno < 1900 Or anno > 2099 Or mese < 1 Or mese > 12 Or
       giorno < 1 Or giorno > 31;
      Return *Blanks;
    EndIf;

    // Anno (ultime 2 cifre)
    annoNascita = %Subst(%Char(anno):3:2);

    // Mese (lettera)
    meseNascita = %Subst(MESI:mese:1);

    // Giorno + sesso
    If sesso = 'F';
      giorno += 40;
    EndIf;
    giornoNascita = %EditC(giorno:'X');

    risultato = cognomeProcessato + nomeProcessato + annoNascita +
                meseNascita + giornoNascita;

    Return risultato;

  On-Error;
    Return *Blanks;
  EndMon;

End-Proc;

//----------------------------------------------------------------------
// Calcola il carattere di controllo
//----------------------------------------------------------------------
Dcl-Proc CDFIS_CalcCarattereControllo Export;
  Dcl-Pi *N Char(1);
    primi15Char Char(15) Const;
  End-Pi;

  Dcl-S somma Int(10);
  Dcl-S i Int(10);
  Dcl-S carattere Char(1);
  Dcl-S posizione Int(10);
  Dcl-S valore Int(10);

  Monitor;
    somma = 0;

    For i = 1 To 15;
      carattere = %Subst(primi15Char:i:1);

      If %Rem(i:2) = 1; // Posizione dispari
        valore = getValoreDispari(carattere);
        If valore < 0;
          Return *Blank;
        EndIf;
        somma += valore;
      Else; // Posizione pari
        valore = getValorePari(carattere);
        If valore < 0;
          Return *Blank;
        EndIf;
        somma += valore;
      EndIf;
    EndFor;

    // Calcola resto e carattere di controllo
    posizione = %Rem(somma:26) + 1;
    Return %Subst(CARATTERI_CONTROLLO:posizione:1);

  On-Error;
    Return *Blank;
  EndMon;

End-Proc;

//----------------------------------------------------------------------
// Restituisce il valore ufficiale per i caratteri in posizione pari
//----------------------------------------------------------------------
Dcl-Proc getValorePari;
  Dcl-Pi *N Int(10);
    carattere Char(1) Const;
  End-Pi;

  Select;
    When carattere >= '0' And carattere <= '9';
      Return %Int(carattere);
    When carattere >= 'A' And carattere <= 'Z';
      Return %Scan(carattere:CARATTERI_CONTROLLO) - 1;
    Other;
      Return -1;
  EndSl;

End-Proc;

//----------------------------------------------------------------------
// Restituisce il valore ufficiale per i caratteri in posizione dispari
//----------------------------------------------------------------------
Dcl-Proc getValoreDispari;
  Dcl-Pi *N Int(10);
    carattere Char(1) Const;
  End-Pi;

  Select;
    When carattere = '0' Or carattere = 'A';
      Return 1;
    When carattere = '1' Or carattere = 'B';
      Return 0;
    When carattere = '2' Or carattere = 'C';
      Return 5;
    When carattere = '3' Or carattere = 'D';
      Return 7;
    When carattere = '4' Or carattere = 'E';
      Return 9;
    When carattere = '5' Or carattere = 'F';
      Return 13;
    When carattere = '6' Or carattere = 'G';
      Return 15;
    When carattere = '7' Or carattere = 'H';
      Return 17;
    When carattere = '8' Or carattere = 'I';
      Return 19;
    When carattere = '9' Or carattere = 'J';
      Return 21;
    When carattere = 'K';
      Return 2;
    When carattere = 'L';
      Return 4;
    When carattere = 'M';
      Return 18;
    When carattere = 'N';
      Return 20;
    When carattere = 'O';
      Return 11;
    When carattere = 'P';
      Return 3;
    When carattere = 'Q';
      Return 6;
    When carattere = 'R';
      Return 8;
    When carattere = 'S';
      Return 12;
    When carattere = 'T';
      Return 14;
    When carattere = 'U';
      Return 16;
    When carattere = 'V';
      Return 10;
    When carattere = 'W';
      Return 22;
    When carattere = 'X';
      Return 25;
    When carattere = 'Y';
      Return 24;
    When carattere = 'Z';
      Return 23;
    Other;
      Return -1;
  EndSl;

End-Proc;

//----------------------------------------------------------------------
// Valida un codice fiscale
//----------------------------------------------------------------------
Dcl-Proc CDFIS_ValidaCodiceFiscale Export;
  Dcl-Pi *N Ind;
    codiceFiscale Char(16) Const;
  End-Pi;

  Dcl-S primi15 Char(15);
  Dcl-S carattereCalcolato Char(1);
  Dcl-S carattereFornito Char(1);

  Monitor;
    // Verifica lunghezza
    If %Len(%Trim(codiceFiscale)) <> 16;
      Return *Off;
    EndIf;

    primi15 = %Subst(codiceFiscale:1:15);
    carattereFornito = %Subst(codiceFiscale:16:1);

    carattereCalcolato = CDFIS_CalcCarattereControllo(primi15);

    Return (carattereCalcolato = carattereFornito);

  On-Error;
    Return *Off;
  EndMon;

End-Proc;

//----------------------------------------------------------------------
// Procedura interna per processare nomi/cognomi
//----------------------------------------------------------------------
Dcl-Proc processaNome;
  Dcl-Pi *N Char(3);
    nome Char(30) Const;
  End-Pi;

  Dcl-S risultato Char(3);
  Dcl-S consonanti Char(30);
  Dcl-S vocali Char(30);
  Dcl-S i Int(10);
  Dcl-S carattere Char(1);

  consonanti = '';
  vocali = '';

  // Estrai consonanti e vocali
  For i = 1 To %Len(%Trim(nome));
    carattere = %Subst(nome:i:1);
    If %Scan(carattere:VOCALIG) > 0;
      vocali = %trim(vocali) + carattere;
    ElseIf %Scan(carattere:CONSONANTIG) > 0;
      consonanti = %trim(consonanti) + carattere;
    EndIf;
  EndFor;

  // Applica regole per il codice fiscale
  If %Len(%Trim(consonanti)) >= 3;
    risultato = %Subst(consonanti:1:3);
  ElseIf %Len(%Trim(consonanti)) = 2;
    risultato = %trim(consonanti) + %Subst(vocali:1:1);
  ElseIf %Len(%Trim(consonanti)) = 1;
    risultato = %trim(consonanti) + %Subst(vocali:1:2);
  Else;
    risultato = %Subst(vocali:1:3);
  EndIf;

  // Riempi con X se necessario
  risultato = %Subst(risultato + 'XXX':1:3);

  Return risultato;

End-Proc;

