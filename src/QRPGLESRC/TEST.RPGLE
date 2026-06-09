**free
ctl-opt main(main) bnddir('UTY') actgrp(*new);

/Include QUTYSRC,CDFISH

Dcl-Proc main;
  Dcl-S codiceFiscale Char(16);
  Dcl-S valido Ind;
  dcl-S vis  Char(50) Inz('');

  // Calcola codice fiscale
  codiceFiscale = CDFIS_CalcCodiceFiscale('CARNEVALE':'DARIO':'M':19880115:'H501');

  If codiceFiscale <> *Blanks;
    // Valida il codice calcolato
    valido = CDFIS_ValidaCodiceFiscale(codiceFiscale);

    If valido;
      // Codice fiscale valido

      vis= 'Codice fiscale valido: ' + codiceFiscale;
    Else;
      // Codice fiscale non valido
      vis= 'Codice fiscale non valido: ' + codiceFiscale;

    EndIf;
    dsply vis;
  EndIf;
End-Proc;

