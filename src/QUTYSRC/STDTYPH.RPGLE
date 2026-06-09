      /If Not Defined( StdTypHCopied )
      /Define          StdTypHCopied
      /Else
      /Eof
      /EndIf

      *=====================================================================
      * Standard Data Types Header:
      *   Standard data types for use in any program.
      *
      *=====================================================================
     D NulPtrTyp       S               *

     D ApiFmtTyp       S              8    Based( NulPtrTyp )
     D BigIntTyp       S             20i 0 Based( NulPtrTyp )
     D BinTyp          S              9B 0 Based( NulPtrTyp )
     D BlnTyp          S              1N   Based( NulPtrTyp )
     D BufTyp          S          32767    Based( NulPtrTyp )
     D CmdTyp          S          32000    Based( NulPtrTyp )
     D ChrTyp          S              1    Based( NulPtrTyp )
     D CndTokTyp       S             12    Based( NulPtrTyp )
     D DatTyp          S               D   Based( NulPtrTyp )
     D DecTyp          S             15P 5 Based( NulPtrTyp )
     D FltTyp          S              8F   Based( NulPtrTyp )
     D IdxTyp          S              5I 0 Based( NulPtrTyp )
     D IntTyp          S             10I 0 Based( NulPtrTyp )
     D LglTyp          S              1    Based( NulPtrTyp )
     D MsgIdTyp        S              7    Based( NulPtrTyp )
     D NamTyp          S             10    Based( NulPtrTyp )
     D PrcPtrTyp       S               *   Based( NulPtrTyp ) ProcPtr
     D PtrTyp          S               *   Based( NulPtrTyp )
     D QNamTyp         S             20    Based( NulPtrTyp )
     D qualFileType    DS                  Based( NulPtrTyp ) Qualified
     D  size                               Like ( SmlIntTyp )
     D  name                               Like ( NamTyp    )
     D  lib                                Like ( NamTyp    )
     D  type                               Like ( NamTyp    )
     D  member                             Like ( NamTyp    )
     D qualNameType    DS                  Based( NulPtrTyp ) Qualified
     D  name                               Like ( NamTyp    )
     D  lib                                Like ( NamTyp    )
     D qualObjectType  DS                  Based( NulPtrTyp ) Qualified
     D  name                               Like ( NamTyp    )
     D  lib                                Like ( NamTyp    )
     D  type                               Like ( NamTyp    )
     D SmlBinTyp       S              4B 0 Based( NulPtrTyp )
     D SmlFltTyp       S              4F   Based( NulPtrTyp )
     D SmlIntTyp       S              5I 0 Based( NulPtrTyp )
     D StrTyp          S            256    Based( NulPtrTyp )
     D TimTyp          S               T   Based( NulPtrTyp )
     D TokTyp          S             32    Based( NulPtrTyp )
     D TmsTyp          S               Z   Based( NulPtrTyp )
     D TxtTyp          S             50    Based( NulPtrTyp )
     D UnsIntTyp       S             10u 0 Based( NulPtrTyp )
     D UnsBigIntTyp    S             20u 0 Based( NulPtrTyp )
     D UnsSmlIntTyp    S              5u 0 Based( NulPtrTyp )
     D UnsTynIntTyp    S              3u 0 Based( NulPtrTyp )
     D varBufTyp       S          32767    Based( NulPtrTyp ) Varying
     D varChrTyp       S              1    Based( NulPtrTyp ) Varying
     D varCmdTyp       S           3000    Based( NulPtrTyp ) Varying
     D varNamTyp       S             10    Based( NulPtrTyp ) Varying
     D varStrTyp       S            256    Based( NulPtrTyp ) Varying
     D varTxtTyp       S             50    Based( NulPtrTyp ) Varying
     D varTokTyp       S             32    Based( NulPtrTyp ) Varying

     D maxDecTyp       S             31p 0 Based( NulPtrTyp )
     D maxNumTyp       S             31s 0 Based( NulPtrTyp )

