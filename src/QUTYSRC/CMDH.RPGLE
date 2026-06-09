      /If Not Defined( CmdHCopied )
      /Define          CmdHCopied
      /Else
      /Eof
      /EndIf

      * §STR§
      * Service programm CBXCMD
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Service programm nella BNDDIR CBXUTY
      *
      * @description
      * Raccolta delle procedure di servizio dei programmi.
      *
      * §END§

      /If Not Defined( SqlRpgIle )
      /Copy QUtySrc,StdTypH
      /EndIf

      * §STR§
      * Procedura CMD_ExecCmd
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Procedura
      *
      * @category Utility
      *
      * @description
      * La procedura esegue un comando CL in un programma,
      * riceve come parametro il comando da eseguire e
      * se il comando non va a buon fine il lavoro va in MSGW.
      *
      * Esempio di utilizzo
      * CMD_ExecCmd( 'WRKACTJOB ' );
      *
      * @param
      * Comando                   32000a  Const  Varying
      *
      * §END§

     D CMD_ExecCmd     Pr
     D  Cmd                                Like( CmdTyp  )  Value

      * §STR§
      * Procedura CMD_PrcCmd
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Procedura
      *
      * @category Utility
      *
      * @description
      * La procedura esegue un comando CL in un programma ,
      * di default è monitorata e demanda la gestione dell'errore al chiamante;
      * può ricevere da 1 a 3 parametri e restituisce il cpf con l'eventuale errore ;
      *
      * Esempio di utilizzo
      * cpf = CMD_PrcCmd('WRKACTJOB');
      * if cpf <> *blanks;
      * .... gestisco l'errore
      * endif;
      * Esempio di utilizzo con parametri
      * cpf = CMD_PrcCmd('WRKACTJOB': messaggio : *off );
      * if cpf <> *blanks;
      *  dsply messaggio ;
      * endif;
      *
      * @param
      * Comando                   32000a  Const  Varying
      * Messaggio di risposta     32767a  Varying Options( *NoPass )
      * Escape Message(*on/*off)       n  Const Options( *NoPass )
      *
      * @return
      * restituisce il codice del cpf 7a oppure *blanks se il comando è completato correttamente
      *
      * §END§

     D CMD_PrcCmd      Pr                  like(MsgIdTyp)
     D  CmdStr                    32000a   Const  Varying
     D  MsgDta                    32767a   Varying Options( *NoPass )
     D  MovPgmMsgs                     n   Const Options( *NoPass )

      * §STR§
      * Procedura CMD_GetInqRpy
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Procedura del srvpgm CBXCMD nella BNDDIR CBXUTY
      *
      * @category Utility
      *
      * @description
      * La procedura emette un messaggio di errore e manda in MSGW
      * il lavoro , a seconda della risposta al messaggio demanda al programma cosa fare
      *
      * Esempio di utilizzo
      * MsgRpy = CMD_GetInqRpy( 'Rispondi S/N ' );
      *    If  %Xlate( 's':'S': MsgRpy ) = 'S';
      *    ... faccio qualcosa
      *    else;
      *    ... non faccio niente
      *    Endif;
      *
      * @param
      * Messaggio                   512a  Varying
      *
      * @return
      * restituisce la risposta data al messaggio 128a
      *
      * §END§

     D CMD_GetInqRpy   Pr           128a   Varying
     D  PxMsgDta                    512a   Const  Varying

      * §STR§
      * Procedura CMD_SndCmpMsg
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Procedura
      *
      * @category Utility
      *
      * @description
      * La procedura emette un messaggio informativo di tipo COMP
      *
      * Esempio di utilizzo
      * CMD_SndCmpMsg( 'Ciao hai spedito il messaggio!' )
      *
      * @param
      * Messaggio                   512a  Varying
      *
      * @return
      *  0 se manda il messaggio
      * -1 se non manda il messaggio
      * §END§

     D CMD_SndCmpMsg   Pr            10i 0
     D  PxMsgDta                    512a   Const  Varying

      * §STR§
      * Procedura CMD_SndEscMsg
      *
      * @author Dario Carnevale Schianca il 28/07/2011
      *
      * @type  Procedura
      *
      * @category Utility
      *
      * @description
      * La procedura emette un messaggio di uscita di tipo ESCAPE
      *
      * Esempio di utilizzo
      * CMD_SndEscMsg( 'CPF9898' : 'QCPFMSG' : 'Errore esco dalla procedura');
      *
      * @param
      * Cpf                           7a  Const
      * File_Messaggi                10a  Const
      * Messaggio                   512a  Const  Varying
      *
      * @return
      * 0 se manda il messaggio
      * -1 se non manda il messaggio
      * §END§

     D CMD_SndEscMsg   Pr            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying


