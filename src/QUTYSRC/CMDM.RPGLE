      *=====================================================================
      * Command Procedures
      *
      *=====================================================================
     H NoMain
     H bnddir('UTY')

      *---------------------------------------------------------------------
      * Global definitions
      *---------------------------------------------------------------------
      /Copy QUtySrc,CmdH
      /Copy QUtySrc,StdTypH
      * File Information Data Structure
     D PSDS           SDS                  qualified
     D  Msgid                 40     46
     D  MsgTxt                91    170

      *=====================================================================
      *-- Process command with QCMDEXE
     P CMD_ExecCmd     B                   Export
      *=====================================================================
     D                 Pi
     D  Cmd                                Like( CmdTyp )  Value

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   cmd                      32702a   const options(*varsize)
     D   len                         15p 5 const
     D   igc                          3a   const options(*nopass)

     D CmdLen          S                   Like(DecTyp) Inz(%Size(Cmd))

      /free

        qcmdexc ( Cmd : CmdLen );
      /End-free

     P                 E

      *=====================================================================
      *-- Process command with CPF
     P CMD_PrcCmd      B                   Export
      *=====================================================================
     D                 Pi                  like(MsgIdTyp)
     D  PxCmdStr                  32000a   Const  Varying
     D  PxMsgDta                  32767a   Varying Options( *NoPass )
     D  PxSndEscMsg                    n   Const Options( *NoPass )

     D QMHRCVPM        PR                  extpgm('QMHRCVPM')
     D   RcvVar                   32767A   options(*varsize)
     D   RcvVarLen                   10I 0 const
     D   Format                       8A   const
     D   StackEnt                    10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   Action                      10A   const
     D   ErrorCode                32767A   options(*varsize)

     D QMHRSNEM        PR                  ExtPgm('QMHRSNEM')
     D   MsgKey                       4A   const
     D   ErrorCode                 8000A   options(*varsize)

     D ErrorCode       ds                  qualified
     D    BytesProv                  10I 0 inz(0)
     D    BytesAvail                 10I 0 inz(0)

     D MsgInfo         ds                  qualified
     D   BytesRtn                    10i 0
     D   BytesAvail                  10i 0
     D   MsgSev                      10i 0
     D   MsgId                        7a
     D   MsgType                      2a
     D   MsgKey                       4a
     D   Msgf                        10a
     D   MsgfReqLib                  10a
     D   Msgflib                     10a
     D   SendJob                     26a
     D   SendPgm                     12a
     D   SendPgmInst                  4a
     D   DateSent                     7a
     D   TimeSent                     6a
     D   RcvPgm                      10a
     D   RcvPgmInst                   4a
     D   SendType                     1a
     D   RcvType                      1a
     D                                1a
     D   CcsidStsTxt                 10i 0
     D   CcsidStsDta                 10i 0
     D   Alert                        9a
     D   CCSIDmsg                    10i 0
     D   CCSIDdta                    10i 0
     D   MsgDtaLen                   10i 0
     D   MsgDtaAvail                 10i 0
     D   MsgLen                      10i 0
     D   MsgAvail                    10i 0
     D   MsgHlpLen                   10i 0
     D   MsgHlpAvail                 10i 0
     D   MsgDta                   32767a


      /Free
       monitor;
       clear  MsgInfo ;
       CMD_ExecCmd( PxCmdStr );
       on-error;

           QMHRCVPM( MsgInfo
                     : %size(MsgInfo)
                     : 'RCVM0200'
                     : '*'
                     : 0
                     : '*LAST'
                     : *blanks
                     : -1
                     : '*OLD'
                     : ErrorCode );

             // Now the MsgInfo structure is filled in
             // with loads of information about the
             // error...
         // Se chiedo anche la descrizione dell'errore
           If %Parms >=2;
             PxMsgDta= %Trim(MsgInfo.MsgDta );
           EndIf;
       Endmon;
         // Se chiedo di fare un escape msg
           If %Parms >=3 and MsgInfo.MsgId<>*blanks;
            If  PxSndEscMsg = *on ;
            monitor;
             QMHRSNEM( MsgInfo.MsgKey : ErrorCode );
            ON-ERROR;
            endmon;
            Endif;
           Endif;
       Return  MsgInfo.MsgId ;

      /End-Free
     P                 E

      *=====================================================================
      **-- Get inquiry message reply:
     P CMD_GetInqRpy   B                   Export
      *=====================================================================
     D                 Pi           128a   Varying
     D  PxMsgDta                    512a   Const  Varying
     **
     D MsgKey          s              4a
     **-- Message information structure:
     D RCVM0100        Ds                  Qualified
     D  BytPrv                       10i 0
     D  BytAvl                       10i 0
     D  MsgSev                       10i 0
     D  MsgId                         7a
     D  MsgTyp                        2a
     D  MsgKey                        4a
     D                                7a
     D  CcsIdCnvSts                  10i 0
     D  CcsIdDta                     10i 0
     D  MsgLenRtn                    10i 0
     D  MsgLenAvl                    10i 0
     D  MsgRpy                       32a

     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      256a

     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  SpMsgId                       7a   Const
     D  SpMsgFq                      20a   Const
     D  SpMsgDta                    512a   Const  Options( *VarSize )
     D  SpMsgDtaLen                  10i 0 Const
     D  SpMsgTyp                     10a   Const
     D  SpCalStkE                    10a   Const  Options( *VarSize )
     D  SpCalStkCtr                  10i 0 Const
     D  SpMsgKey                      4a
     D  SpError                     512a          Options( *VarSize )
     **
     D  SpCalStkElen                 10i 0 Const  Options( *NoPass )
     D  SpCalStkEq                   20a   Const  Options( *NoPass )
     D  SpDspWait                    10i 0 Const  Options( *NoPass )
     **
     D  SpCalStkEtyp                 20a   Const  Options( *NoPass )
     D  SpCcsId                      10i 0 Const  Options( *NoPass )

     **-- Receive program message:
     D RcvPgmMsg       Pr                  ExtPgm( 'QMHRCVPM' )
     D  RpRcvVar                  32767a          Options( *VarSize )
     D  RpRcvVarLen                  10i 0 Const
     D  RpFmtNam                     10a   Const
     D  RpCalStkE                   256a   Const  Options( *VarSize )
     D  RpCalStkCtr                  10i 0 Const
     D  RpMsgTyp                     10a   Const
     D  RpMsgKey                      4a   Const
     D  RpWait                       10i 0 Const
     D  RpMsgAct                     10a   Const
     D  RpError                   32767a          Options( *VarSize )
     **
     D  RpCalStkElen                 10i 0 Const  Options( *NoPass )            call stack counter
     D  RpCalStkEq                   20a   Const  Options( *NoPass )            call stack counter
     **
     D  RpCalStkEtyp                 20a   Const  Options( *NoPass )            call stack counter
     D  RpCcsId                      10i 0 Const  Options( *NoPass )            call stack counter


      /Free

        SndPgmMsg( *Blanks
                 : *Blanks
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*INQ'
                 : '*EXT'
                 : *Zero
                 : MsgKey
                 : ERRC0100
                 );

        RcvPgmMsg( RCVM0100
                 : %Size( RCVM0100 )
                 : 'RCVM0100'
                 : '*'
                 : *Zero
                 : '*RPY'
                 : MsgKey
                 : -1
                 : '*OLD'
                 : ERRC0100
                 );

        Return  %Subst( RCVM0100.MsgRpy: 1: RCVM0100.MsgLenRtn );

      /End-Free
     P                 E

      *=====================================================================
      **-- Send completion message:
     P CMD_SndCmpMsg   B                   Export
      *=====================================================================
     D                 Pi            10i 0
     D  PxMsgDta                    512a   Const  Varying
     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      256a

     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  SpMsgId                       7a   Const
     D  SpMsgFq                      20a   Const
     D  SpMsgDta                    512a   Const  Options( *VarSize )
     D  SpMsgDtaLen                  10i 0 Const
     D  SpMsgTyp                     10a   Const
     D  SpCalStkE                    10a   Const  Options( *VarSize )
     D  SpCalStkCtr                  10i 0 Const
     D  SpMsgKey                      4a
     D  SpError                     512a          Options( *VarSize )
     **
     D  SpCalStkElen                 10i 0 Const  Options( *NoPass )
     D  SpCalStkEq                   20a   Const  Options( *NoPass )
     D  SpDspWait                    10i 0 Const  Options( *NoPass )
     **
     D  SpCalStkEtyp                 20a   Const  Options( *NoPass )
     D  SpCcsId                      10i 0 Const  Options( *NoPass )

     D MsgKey          s              4a

      /Free
        SndPgmMsg( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*COMP'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return  0;

        EndIf;
      /End-Free
     P                 E

      *=====================================================================
      **-- Send escape message:
     P CMD_SndEscMsg   B                   Export
      *=====================================================================
     D                 Pi            10i 0
     D  PxMsgId                       7a   Const
     D  PxMsgF                       10a   Const
     D  PxMsgDta                    512a   Const  Varying
     **-- API error data structure:
     D ERRC0100        Ds                  Qualified
     D  BytPrv                       10i 0 Inz( %Size( ERRC0100 ))
     D  BytAvl                       10i 0
     D  MsgId                         7a
     D                                1a
     D  MsgDta                      256a

     **-- Send program message:
     D SndPgmMsg       Pr                  ExtPgm( 'QMHSNDPM' )
     D  SpMsgId                       7a   Const
     D  SpMsgFq                      20a   Const
     D  SpMsgDta                    512a   Const  Options( *VarSize )
     D  SpMsgDtaLen                  10i 0 Const
     D  SpMsgTyp                     10a   Const
     D  SpCalStkE                    10a   Const  Options( *VarSize )
     D  SpCalStkCtr                  10i 0 Const
     D  SpMsgKey                      4a
     D  SpError                     512a          Options( *VarSize )
     **
     D  SpCalStkElen                 10i 0 Const  Options( *NoPass )
     D  SpCalStkEq                   20a   Const  Options( *NoPass )
     D  SpDspWait                    10i 0 Const  Options( *NoPass )
     **
     D  SpCalStkEtyp                 20a   Const  Options( *NoPass )
     D  SpCcsId                      10i 0 Const  Options( *NoPass )

     D MsgKey          s              4a
      /Free
        SndPgmMsg( PxMsgId
                 : PxMsgF + '*LIBL'
                 : PxMsgDta
                 : %Len( PxMsgDta )
                 : '*ESCAPE'
                 : '*PGMBDY'
                 : 1
                 : MsgKey
                 : ERRC0100
                 );

        If  ERRC0100.BytAvl > *Zero;
          Return  -1;

        Else;
          Return   0;
        EndIf;

      /End-Free
     P                 E

