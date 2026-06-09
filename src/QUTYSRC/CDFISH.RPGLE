        /If Not Defined(SqlEnv)
        /Include QUtySrc,StdTypH
        /EndIf

       // Calcola il codice fiscale completo
       //§STR§ *************************************************************************
       //§STR§ Procedure . . . : CDFIS_CalcCodiceFiscale
       //§STR§ Date  . . . . . : 06/11/2025
       //§STR§ Type  . . . . . : Function
       //§STR§ Category  . . . : Fiscal Code Calculation
       //§STR§
       //§STR§ Description . . : Calculates complete Italian fiscal code
       //§STR§
       //§STR§ Parameters:
       //§STR§   cognome     : Surname (input, 30A)
       //§STR§   nome        : First name (input, 30A)
       //§STR§   sesso       : Gender M/F (input, 1A)
       //§STR§   dataNascita : Birth date YYYYMMDD (input, 8S 0)
       //§STR§   comuneNasc  : Birth municipality code (input, 4A)
       //§STR§
       //§STR§ Returns . . . . : Complete fiscal code (16A) or blanks if error
       //§STR§
       //§STR§ *************************************************************************
       //§END§
       Dcl-Pr CDFIS_CalcCodiceFiscale Char(16);
         cognome     Char(30) Const;
         nome        Char(30) Const;
         sesso       Char(1)  Const;
         dataNascita Packed(8:0) Const;
         comuneNasc  Char(4)  Const;
       End-Pr;

       // Calcola solo la parte anagrafica (primi 11 caratteri)
       //§STR§ *************************************************************************
       //§STR§ Procedure . . . : CDFIS_CalcParteAnagrafica
       //§STR§ Date  . . . . . : 06/11/2025
       //§STR§ Type  . . . . . : Function
       //§STR§ Category  . . . : Fiscal Code Calculation
       //§STR§
       //§STR§ Description . . : Calculates first 11 characters of fiscal code
       //§STR§                   (surname + name + birth date + gender)
       //§STR§
       //§STR§ Parameters:
       //§STR§   cognome     : Surname (input, 30A)
       //§STR§   nome        : First name (input, 30A)
       //§STR§   sesso       : Gender M/F (input, 1A)
       //§STR§   dataNascita : Birth date YYYYMMDD (input, 8S 0)
       //§STR§
       //§STR§ Returns . . . . : First 11 characters or blanks if error
       //§STR§
       //§STR§ *************************************************************************
       //§END§
       Dcl-Pr CDFIS_CalcParteAnagrafica Char(11);
         cognome     Char(30) Const;
         nome        Char(30) Const;
         sesso       Char(1)  Const;
         dataNascita Packed(8:0) Const;
       End-Pr;

       // Calcola il carattere di controllo
       //§STR§ *************************************************************************
       //§STR§ Procedure . . . : CDFIS_CalcCarattereControllo
       //§STR§ Date  . . . . . : 06/11/2025
       //§STR§ Type  . . . . . : Function
       //§STR§ Category  . . . : Fiscal Code Calculation
       //§STR§
       //§STR§ Description . . : Calculates check character for fiscal code
       //§STR§
       //§STR§ Parameters:
       //§STR§   primi15Char : First 15 characters of fiscal code (input, 15A)
       //§STR§
       //§STR§ Returns . . . . : Check character (1A) or blank if error
       //§STR§
       //§STR§ *************************************************************************
       //§END§
       Dcl-Pr CDFIS_CalcCarattereControllo Char(1);
         primi15Char Char(15) Const;
       End-Pr;

       // Valida un codice fiscale esistente
       //§STR§ *************************************************************************
       //§STR§ Procedure . . . : CDFIS_ValidaCodiceFiscale
       //§STR§ Date  . . . . . : 06/11/2025
       //§STR§ Type  . . . . . : Function
       //§STR§ Category  . . . : Fiscal Code Validation
       //§STR§
       //§STR§ Description . . : Validates Italian fiscal code format and check digit
       //§STR§
       //§STR§ Parameters:
       //§STR§   codiceFiscale : Fiscal code to validate (input, 16A)
       //§STR§
       //§STR§ Returns . . . . : *On if valid, *Off if invalid
       //§STR§
       //§STR§ *************************************************************************
       //§END§
       Dcl-Pr CDFIS_ValidaCodiceFiscale Ind;
         codiceFiscale Char(16) Const;
       End-Pr;




