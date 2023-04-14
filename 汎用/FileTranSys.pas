{

 ---------------------------------------------------------------
  X,Y,ZModem,MLINK汎用処理コンポーネント   Ver 1.04
                       By Yoshihiro Myokan.
 ---------------------------------------------------------------

  本コンポーネントは、ホストプログラム'KTBBS'のTransSys.Pasを、
  Delphi用に改造した形となっています。

>KT621ASR.LZH ホストプログラム KTBBS ソースファイル

 【ＨＡＬ】さん、Seishiさん、もろぼし☆らむ　さんありがとうございました。

※TransSys.PasのM-LINK, ZMODEM部分に関しては、RTBBS(Resource版 TURBO-BBS)
 / Comserveさんのかかれたソースがもととなっているそうです。

  汚いソースですがお許しください(^^;;;


}
unit FileTranSys;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Comm;

Type

    TFileTranStatus = Record
        StartTime      : Integer;
        FileSize       : Integer;
        TranSize       : Integer;
        ErrCount       : Integer;
        FileName       : String;
        SendFileName   : String;
        GetFileName  : String;
     end;

    TProtocol       = (
                     pr_XMODEM_SUM_128,
                     pr_XMODEM_CRC_128,
                     pr_XMODEM_CRC_1024,
                     pr_YMODEM,
                     pr_YMODEM_G,
                     pr_ZMODEM,
                     pr_MLINK
                     );
     headertype = array[0..4] of byte; { hdrtype & ZF3..ZF0 (ZP0..ZP3) }

     TTranMode  = (TM_NONE,TM_UPLOAD,TM_DOWNLOAD);

     XprotType        = (SUM_128,CRC_128,CRC_1024);
     crctype	      = (SUM,CRC16,CRC32);
     line		=string[80];
     filbuffer = array[0..127] of Byte;


  TFileTran = class(TObject)
 private



        RecvBuf        : array[0..350000] of char;
        Rp: integer;
        Wp: integer;

        GOption             : Boolean;
        Xprotocol           : XprotType;
        Ybatch              : Boolean;
        OnFileTranReceive    : TCommNotifyRxTxEvent;

        chksum		        :  byte;
        _crc16		        :  word;
        _crc32		        :  longint;
        lastsent		:  byte;
        crcmode	                :   crctype;
        cancelled               : boolean;

        filebuf_		: array[0..1025] of byte;
        RecCount	        : integer;
        f_                      : File of byte;
        g_option                : boolean;


     procedure Xdownload( var successful:boolean);
     procedure Ydownload( var successful:boolean);
     procedure Zdownload( var successful:boolean);
     procedure Mdownload( var successful:boolean);
     procedure Xupload( var successful:boolean);
     procedure Yupload( var successful:boolean);
     procedure Zupload( var successful:boolean);
     procedure Mupload( var successful:boolean);
     procedure clearline;
     function  alpha(filename:String): boolean;
     function  RecvChar: Char;
     procedure waiting(tcount: integer);
     procedure xmitchar(ch: char);
     procedure xmitblock(Const Buf; len:integer);
     function  receiveblock(var rpt; len:integer) : word;
     procedure stringout(s:String);
     procedure blockreadM(var filebrock; n:word);
     procedure blockreadM2(var filebrock; n:word);
     procedure seekM2(n:longint; var rslt : boolean);
     procedure flush;
     function inbyte: byte;
     function timedin: boolean;
     procedure calcCRC(data:byte);
     Procedure calcblkCRC(var dt; n:word);
     Procedure clearCRC;
     Procedure acknak(var inch: byte; time: integer);
     Procedure sendcalc(ch : byte);
     Function takeCRC:longint;
     Function matchCRC:longint;
     Function time1970(PT:TDateTime): string;	(*1970.1.1からの秒数(Octal)*)
     Function GMTtoPACKT(GMT:LongInt) :TDateTime;(*1970.1.1からの秒数からPackTime*)
     Function acknakout(ch : byte): boolean;
     Procedure Fill_EOF_Code(var pt; n:word);
     Function send1block(blkunit: integer; blocknum: SmallInt): SmallInt;
     Procedure clearbuff;
     Procedure setheader;
     Function recchar(var error: boolean): byte;
     Function recv1block(var blkunit: integer; var blocknum: smallint): integer;
     Procedure storebuff(var buffernum: byte; var paused, aborted: boolean);
     Function Ztimedin:boolean;
     Function Zfromunixdate(s:string):TDateTime;
     Procedure Zmakepackedheader(htype:byte;datas:longint;var hdr:headertype);
     Function ZcheckfileCRC(crcreq:longint):longint;
     Procedure Zcancel;
     Procedure Zsendhex(b:byte);
     Procedure Zsendhexheader(header:headertype);
     Function ZcatchZDL:word;	(*エラーのとき_ZR_ERRを返す by Seishi*)
     Function Zgethex(var err : boolean) : byte;
     Procedure Zgetbinheader(var header:headertype;var err:boolean);
     Function Zgetheader(var header:headertype; var num:longint; var err :boolean):byte;
     Function Zmakeunpackedheader(var hdr:headertype):longint;
     Procedure Zsendstring(p:string);
     Procedure Zsendbyte(b:byte);
     Procedure Zsendblkbyte(var b; cnt:word);		{ｲﾝﾌﾟﾘﾒﾝﾄ by Seishi		 }
     Procedure Zsendbinheader(header:headertype);
     Procedure Zgethexheader(var header:headertype;var err:boolean);
     procedure ClearStatus;

     Procedure Start;

     Procedure Write(Buf : Pchar;Size : Integer);

     Function InReady : Boolean;

  protected

  public

     Protocol      : TProtocol;
     Terminated    : ^boolean;
     Success       : Boolean;
     Status        : TFileTranStatus;
     TranMode      : TTranMode;
     FOwner        : TObject;

     Procedure  OnReceive(Data : PChar; Size: Integer);
     Function   DownLoad(FileName : string) : Boolean;
     Function   UpLoad  (FileName : string;SendFileName : String) : Boolean;
     constructor Create(AOwner :TObject);

     function  Get_File_Size:integer;


  end;


Const

  cancan : array[0..15] of char = (
               #$18,#$18,#$18,#$18,#$18,#$18,#$18,#$18,#$08,#$08,#$08,#$08,#$08,#$08,#$08,#$08
               );

   ProtocolStr : Array [TProtocol] of String =(
                   'XMODEM [SUM] 128byte',
                   'XMODEM [CRC] 128byte',
                   'XMODEM [CRC] 1024byte',
                   'YMODEM',
                   'YMODEM-G',
                   'ZMODEM',
                   'M-LINK');


implementation

Uses Mtbbs;

  const
       crcstr:array[crctype] of string[7]=('SUM','CRC16','CRC32');


       SOH		 = 1; (* 共通部 *)
       STX		 = 2;
       EOT		 = 4;
       ACK		 = 6;
       NAK		 = $15;
       CAN		 = $18;
       C			 = $43;
       G			 = $47;
       _PAD		 = 42; (* ZMODEM 定義 *)
       _DLE		 = 24;
       _DLEE		 = 88;
       _BIN		 = 65;
       _HEX		 = 66;
       _BIN32	 = 67;
       _RQINIT	 = 0;
       _RINIT	 = 1;
       _SINIT	 = 2;
       _ACK		 = 3;
       _FILE		 = 4;
       _SKIP		 = 5;
       _NAK		 = 6;
       _ABORT	         = 7;
       _FIN		 = 8;
       _RPOS		 = 9;
       _DATA		 = 10;
       _EOF		 = 11;
       _FERR		 = 12;
       _CRC		 = 13;
       _CHALLENGE = 14;
       _COMPL	 = 15;
       _CAN		 = 16;
       _FREECNT	 = 17;
       _COMMAND	 = 18;
       _STDERR	 = 19;
       _CRCE		 = 104;
       _CRCG		 = 105;
       _CRCQ		 = 106;
       _CRCW		 = 107;
       _RUB0		 = 108;
       _RUB1		 = 109;
       CANFDX	 = $01;
       CANOVIO	 = $02;
       CANBRK	 = $04;
       CANCRY	 = $08;
       CANLZW	 = $10;
       CANFC32	 = $20;
       _CBIN		 = 1; { Use of ZF1 }
       _CNL		 = 2;
       _CRESUM	 = 3;
       _MNEW		 = 1; { Use of ZF2 }
       _MCRC		 = 2;
       _MAPND	 = 3;
       _MCLOB	 = 4;
       _MSPARS	 = 5;
       _MDIFF	 = 6;
       _MPROT	 = 7;
       _TLZW		 = 1; { Use of ZF3 , but not implemented. (compressions) }
       _TCRYPT	 = 2;
       _TRLE		 = 3;
       _CACK1	 = 1; { Use of ZF4 , but don't know how to use it. }
       _ZR_ERR	 = $FFFF;	{ receive error }
       INI		 = $4D; (* M-LINK 定義 *)
       ABT		 = $41;
       ETR		 = $45;
       EXT		 = $1B;
       MED		 = $0D;
       ACNT		 = 10;

       crc16table  : array[0..255] of word = (
	$0000,$1021,$2042,$3063,$4084,$50a5,$60c6,$70e7,
	$8108,$9129,$a14a,$b16b,$c18c,$d1ad,$e1ce,$f1ef,
	$1231,$0210,$3273,$2252,$52b5,$4294,$72f7,$62d6,
	$9339,$8318,$b37b,$a35a,$d3bd,$c39c,$f3ff,$e3de,
	$2462,$3443,$0420,$1401,$64e6,$74c7,$44a4,$5485,
	$a56a,$b54b,$8528,$9509,$e5ee,$f5cf,$c5ac,$d58d,
	$3653,$2672,$1611,$0630,$76d7,$66f6,$5695,$46b4,
	$b75b,$a77a,$9719,$8738,$f7df,$e7fe,$d79d,$c7bc,
	$48c4,$58e5,$6886,$78a7,$0840,$1861,$2802,$3823,
	$c9cc,$d9ed,$e98e,$f9af,$8948,$9969,$a90a,$b92b,
	$5af5,$4ad4,$7ab7,$6a96,$1a71,$0a50,$3a33,$2a12,
	$dbfd,$cbdc,$fbbf,$eb9e,$9b79,$8b58,$bb3b,$ab1a,
	$6ca6,$7c87,$4ce4,$5cc5,$2c22,$3c03,$0c60,$1c41,
	$edae,$fd8f,$cdec,$ddcd,$ad2a,$bd0b,$8d68,$9d49,
	$7e97,$6eb6,$5ed5,$4ef4,$3e13,$2e32,$1e51,$0e70,
	$ff9f,$efbe,$dfdd,$cffc,$bf1b,$af3a,$9f59,$8f78,
	$9188,$81a9,$b1ca,$a1eb,$d10c,$c12d,$f14e,$e16f,
	$1080,$00a1,$30c2,$20e3,$5004,$4025,$7046,$6067,
	$83b9,$9398,$a3fb,$b3da,$c33d,$d31c,$e37f,$f35e,
	$02b1,$1290,$22f3,$32d2,$4235,$5214,$6277,$7256,
	$b5ea,$a5cb,$95a8,$8589,$f56e,$e54f,$d52c,$c50d,
	$34e2,$24c3,$14a0,$0481,$7466,$6447,$5424,$4405,
	$a7db,$b7fa,$8799,$97b8,$e75f,$f77e,$c71d,$d73c,
	$26d3,$36f2,$0691,$16b0,$6657,$7676,$4615,$5634,
	$d94c,$c96d,$f90e,$e92f,$99c8,$89e9,$b98a,$a9ab,
	$5844,$4865,$7806,$6827,$18c0,$08e1,$3882,$28a3,
	$cb7d,$db5c,$eb3f,$fb1e,$8bf9,$9bd8,$abbb,$bb9a,
	$4a75,$5a54,$6a37,$7a16,$0af1,$1ad0,$2ab3,$3a92,
	$fd2e,$ed0f,$dd6c,$cd4d,$bdaa,$ad8b,$9de8,$8dc9,
	$7c26,$6c07,$5c64,$4c45,$3ca2,$2c83,$1ce0,$0cc1,
	$ef1f,$ff3e,$cf5d,$df7c,$af9b,$bfba,$8fd9,$9ff8,
	$6e17,$7e36,$4e55,$5e74,$2e93,$3eb2,$0ed1,$1ef0);
        crc32table : array[0..255] of longint=(
	$00000000,$77073096,$ee0e612c,$990951ba,$076dc419,$706af48f,$e963a535,
	$9e6495a3,$0edb8832,$79dcb8a4,$e0d5e91e,$97d2d988,$09b64c2b,$7eb17cbd,
	$e7b82d07,$90bf1d91,$1db71064,$6ab020f2,$f3b97148,$84be41de,$1adad47d,
	$6ddde4eb,$f4d4b551,$83d385c7,$136c9856,$646ba8c0,$fd62f97a,$8a65c9ec,
	$14015c4f,$63066cd9,$fa0f3d63,$8d080df5,$3b6e20c8,$4c69105e,$d56041e4,
	$a2677172,$3c03e4d1,$4b04d447,$d20d85fd,$a50ab56b,$35b5a8fa,$42b2986c,
	$dbbbc9d6,$acbcf940,$32d86ce3,$45df5c75,$dcd60dcf,$abd13d59,$26d930ac,
	$51de003a,$c8d75180,$bfd06116,$21b4f4b5,$56b3c423,$cfba9599,$b8bda50f,
	$2802b89e,$5f058808,$c60cd9b2,$b10be924,$2f6f7c87,$58684c11,$c1611dab,
	$b6662d3d,$76dc4190,$01db7106,$98d220bc,$efd5102a,$71b18589,$06b6b51f,
	$9fbfe4a5,$e8b8d433,$7807c9a2,$0f00f934,$9609a88e,$e10e9818,$7f6a0dbb,
	$086d3d2d,$91646c97,$e6635c01,$6b6b51f4,$1c6c6162,$856530d8,$f262004e,
	$6c0695ed,$1b01a57b,$8208f4c1,$f50fc457,$65b0d9c6,$12b7e950,$8bbeb8ea,
	$fcb9887c,$62dd1ddf,$15da2d49,$8cd37cf3,$fbd44c65,$4db26158,$3ab551ce,
	$a3bc0074,$d4bb30e2,$4adfa541,$3dd895d7,$a4d1c46d,$d3d6f4fb,$4369e96a,
	$346ed9fc,$ad678846,$da60b8d0,$44042d73,$33031de5,$aa0a4c5f,$dd0d7cc9,
	$5005713c,$270241aa,$be0b1010,$c90c2086,$5768b525,$206f85b3,$b966d409,
	$ce61e49f,$5edef90e,$29d9c998,$b0d09822,$c7d7a8b4,$59b33d17,$2eb40d81,
	$b7bd5c3b,$c0ba6cad,$edb88320,$9abfb3b6,$03b6e20c,$74b1d29a,$ead54739,
	$9dd277af,$04db2615,$73dc1683,$e3630b12,$94643b84,$0d6d6a3e,$7a6a5aa8,
	$e40ecf0b,$9309ff9d,$0a00ae27,$7d079eb1,$f00f9344,$8708a3d2,$1e01f268,
	$6906c2fe,$f762575d,$806567cb,$196c3671,$6e6b06e7,$fed41b76,$89d32be0,
	$10da7a5a,$67dd4acc,$f9b9df6f,$8ebeeff9,$17b7be43,$60b08ed5,$d6d6a3e8,
	$a1d1937e,$38d8c2c4,$4fdff252,$d1bb67f1,$a6bc5767,$3fb506dd,$48b2364b,
	$d80d2bda,$af0a1b4c,$36034af6,$41047a60,$df60efc3,$a867df55,$316e8eef,
	$4669be79,$cb61b38c,$bc66831a,$256fd2a0,$5268e236,$cc0c7795,$bb0b4703,
	$220216b9,$5505262f,$c5ba3bbe,$b2bd0b28,$2bb45a92,$5cb36a04,$c2d7ffa7,
	$b5d0cf31,$2cd99e8b,$5bdeae1d,$9b64c2b0,$ec63f226,$756aa39c,$026d930a,
	$9c0906a9,$eb0e363f,$72076785,$05005713,$95bf4a82,$e2b87a14,$7bb12bae,
	$0cb61b38,$92d28e9b,$e5d5be0d,$7cdcefb7,$0bdbdf21,$86d3d2d4,$f1d4e242,
	$68ddb3f8,$1fda836e,$81be16cd,$f6b9265b,$6fb077e1,$18b74777,$88085ae6,
	$ff0f6a70,$66063bca,$11010b5c,$8f659eff,$f862ae69,$616bffd3,$166ccf45,
	$a00ae278,$d70dd2ee,$4e048354,$3903b3c2,$a7672661,$d06016f7,$4969474d,
	$3e6e77db,$aed16a4a,$d9d65adc,$40df0b66,$37d83bf0,$a9bcae53,$debb9ec5,
	$47b2cf7f,$30b5ffe9,$bdbdf21c,$cabac28a,$53b39330,$24b4a3a6,$bad03605,
	$cdd70693,$54de5729,$23d967bf,$b3667a2e,$c4614ab8,$5d681b02,$2a6f2b94,
	$b40bbe37,$c30c8ea1,$5a05df1b,$2d02ef8d);




Procedure TFileTran.Write(Buf : PChar;Size : Integer);
Begin

   TMtbbs(FOwner).Write(Buf,Size);

End;


Function TFileTran.DownLoad(FileName : String):Boolean;
Begin

  If TranMode<>TM_None then
   Begin
       Result := False;
       Exit;
   end;

  TranMode:=Tm_DownLoad;

  Status.FileName     := FileName;
  Status.FileSize     := 9999999;
  Status.SendFileName := '';

  ClearStatus;

  Start;

  Result := Success;

End;

Function TFileTran.InReady : Boolean;
Begin

  Result := Rp<>Wp;

End;


Function TFileTran.UpLoad(FileName,SendFileName : String):Boolean;
Begin


  If  TranMode<>TM_None then
   Begin
       Result := False;
       exit;
   end;

    Success := False;

    If SendFileName='' then Status.SendFileName:=ExtractFileName(FileName)
                     else Status.SendFileName:=SendFileName;

    Status.FileName := FileName;
    Status.FileSize := Get_File_Size;

    If Status.FileSize=0 then
     Begin
         Result := False;
         exit;
     end;

    TranMode := Tm_UpLoad;
    ClearStatus;

    Start;

    Result := Success;



End;

procedure TFileTran.ClearStatus;
Begin

    Status.StartTime   := GetTickCount;
    Status.TranSize    := 0;
    Status.ErrCount    := 0;
    Status.GetFileName :=  '';

End;


Procedure TFileTran.Start;
Begin


    Rp := Wp;
    Success          := True;
    TMtbbs(FOwner).Receive := onReceive;

    Try
            GOption     := False;
      Case protocol of
        pr_XMODEM_SUM_128      : Xprotocol                :=SUM_128;
        pr_XMODEM_CRC_128      : Xprotocol                :=CRC_128;
        pr_XMODEM_CRC_1024     : Xprotocol                :=CRC_1024;
        pr_YMODEM              :           Begin
            GOption     := False;
            Ybatch      := False;       End;
        pr_YMODEM_G            :           Begin
            GOption     := True;
            Ybatch      := False;       End;
      End;

      Case TranMode of
       TM_DownLoad   :
         Case Protocol of
           pr_XMODEM_SUM_128,pr_XMODEM_CRC_128,pr_XMODEM_CRC_1024
                :      XUPLOAD(Success);
           pr_YMODEM,pr_YMODEM_G//,YMODEM_BAT,YMODEM_G_BAT
                :      YUPLOAD(Success);
           pr_ZMODEM
                :      ZUPLOAD(Success);
           pr_MLINK
                :      MUPLOAD(Success);
         End;
       TM_UpLoad :
         Case Protocol of
           pr_XMODEM_SUM_128,pr_XMODEM_CRC_128,pr_XMODEM_CRC_1024
                :      XDOWNLOAD(Success);
           pr_YMODEM,pr_YMODEM_G//,YMODEM_BAT,YMODEM_G_BAT
                :      YDOWNLOAD(Success);
           pr_ZMODEM
                :      ZDOWNLOAD(Success);
           pr_MLINK
                :      MDOWNLOAD(Success);
        End;
     End; // of tranmode
    Except
      Success := False;
    End;

      TranMode := Tm_None;
   TMtbbs(FOwner).Receive := TMtbbs(FOwner).TextReceive;


End;

constructor TFileTran.Create(AOwner :TObject);
Begin

    FOwner := AOwner;

    wp:=0;
    rp:=0;
    TranMode := Tm_None;
    Protocol := pr_ZModem;
    chksum := 0;


End;


Procedure TFileTran.onReceive(Data : Pchar; Size: Integer);
Var
 i : Integer;
 dummy : string;
begin

       For i:=0 to Size-1 do
        begin
         RecvBuf[wp] := Data[i];
         Wp := (wp+1) mod High(RecvBuf);
        End;


end;

Procedure TFileTran.xmitblock(Const Buf; len:integer);
(*シリアル出力ポートがレディならblockを出力する（ローカルモードなら出力しない）
  Terminated なら何もせずに戻る *)
  begin

	if (Not Terminated^) and (Len>0) then begin
                Write(@Buf,len);
	end;

  end;





  procedure TFileTran.calcCRC(data:byte);
	begin
	  case crcmode of
		sum  : chksum := Integer(chksum + data) mod 256;
		crc16:
		  _crc16:=crc16table[Hi(_crc16)xor data]xor(_crc16 shl 8);
		crc32:
		  _crc32:=crc32table[byte(_crc32) xor data] xor
										   ((_crc32 shr 8) and $00ffffff)
								{ crc32: Gary S. Brown. 氏の著作権がある }
	  end;
	end;

  Procedure TFileTran.calcblkCRC(var dt; n:word);
	type b = array [1..1024] of byte;
	var  i : word;
	begin
	  case crcmode of
		sum  :
		  for i:=1 to n do
                        chksum := Integer(chksum + b(dt)[i]) mod 256;
		crc16:
		  for i:=1 to n do
			_crc16 := Integer(crc16table[Integer(Hi(_crc16) xor b(dt)[i])] xor (Integer(_crc16 shl 8)));
		crc32:
		  for i:=1 to n do
			_crc32 := crc32table[byte(_crc32) xor b(dt)[i]] xor
										   ((_crc32 shr 8) and $00ffffff)
	  end;
	end;


  Function TFileTran.takeCRC:longint;
	begin
	  case crcmode of
		crc16:takeCRC:=_crc16;
		crc32:takeCRC:=_crc32;
	  end;
	end;


  Function TFileTran.matchCRC:longint;
	begin
	  case crcmode of
		crc16:matchCRC:=$0000;
		crc32:matchCRC:=$DEBB20E3;
	  end;
	end;


  Procedure TFileTran.clearCRC;
	begin
	  case crcmode of
		sum  :chksum:=0;
		crc16:_crc16:=0;
		crc32:_crc32:=$FFFFFFFF;
	  end;
	end;


Function TFileTran.time1970(PT:TDateTime): string;	(*1970.1.1からの秒数(Octal)*)
  var wk : TDateTime;						(*簡略版 by Seishi*)
	  st : string;
  begin

        //Wk:=PT- StrToDateTime('1970/01/01 00:00:00');
        Wk:=PT- EncodeDate(1970,01,01);
        st:=IntToStr(trunc(Wk) * 86400);
	st := '0'+st;
	time1970 := st;
  end;


Function TFileTran.GMTtoPACKT(GMT:LongInt) :TDateTime;(*1970.1.1からの秒数からPackTime*)
  var wk  : longint;					   (*簡略版 by Seishi*)
	  tmp : integer;
	  DT  : double;
  begin
	inc(GMT,(60*60*9));			{GMT->JST補正(9h)}
        Dt:=(StrToFloat( IntToStr(GMT)  ) / 86400);
        GMTtoPACKT := TDateTime(DT);

  end;


Function TFileTran.alpha(filename:String): boolean;
  var strpos: integer;
	  dots:		byte;
  begin
	dots := 0;
	alpha := true;
	if length(filename) > 0 then
	  for strpos := 1 to length(filename) do begin
		if filename[strpos] = '.' then inc(dots);
		if not (filename[strpos] in [chr($23)..chr($29),'.', '-', '_', '@', '0'..'9', 'A'..'Z'])
		  then alpha := false;
	  end;
	if dots > 1 then alpha := false;
  end;




Function TFileTran.inbyte: byte;
  var temp: char;
  begin

	  while (not inready) and (Not Terminated^) do
             Sleep(50);//Application.ProcessMessages;
	  temp := recvchar;
          Result := ord(temp);
  end;


Function TFileTran.timedin: boolean;
  (* １秒以内に受信データがあれば真を返す。used in X/Y/ZMODEM *)
  var
	begcnt	: integer;
  begin
	begcnt:=GetTickCount;
	while (Not Terminated^) and (not inready) and (GetTickCount-begcnt<1000)  do
            Sleep(20);
	Result := inready;
  end;


Procedure TFileTran.acknak(var inch: byte; time: integer);
(*time秒だけ以下のコードを待つ。タイムアウト or 回線切れなら０を返す。
　　ACK, NAK, CAN, C, G
*)
  var loop, loopend, i: integer;
  begin
	loopend := time*100;
	loop := 0;
	inch := 0;
	repeat
          Sleep(100); //  waiting(100);	  {wait 0.1sec}
	  if inready then inch := inbyte;
	  inc(loop);
	until (inch in [ACK, NAK, CAN, C, G, INI, ABT, ETR, EXT, MED]) or (loop >= loopend) or Terminated^;
  end;


Function TFileTran.acknakout(ch : byte): boolean;
  var  times, loops: integer;
  begin
	times := 0;
	repeat
//          writeln(comtest.D_F,inttostr(times)+chr(ch)+inttostr(Integer(inready)));
	  loops := 0;
	  xmitchar(chr(ch));
	  while (loops < 10) and (not timedin) and (Not Terminated^) do
           Begin
             inc(loops);
             Sleep(20);
           End;
	  inc(times);
	until inready or (times > 9) or Terminated^;
	acknakout := inready and (Not (Terminated^));
  end;

{ ------------------- }


Procedure TFileTran.Fill_EOF_Code(var pt; n:word);
  type byt = array[0..1023] of byte;
  begin
    if n<1024 then FillChar(byt(pt)[n], 1024-n, chr($1A));
  end;


Procedure TFileTran.sendcalc(ch : byte);
  begin
	xmitchar(chr(ch));
	calcCRC(ch);
  end;


Function TFileTran.send1block(blkunit: integer; blocknum: SmallInt): SmallInt;
(*１ブロック(=blkunit)送り、リザルトコードを確認、NAKなら再送する。
　0:ACK  9:CAN or １０回リトライしてもダメ or 回線切れ
*)
  var
	tries		: integer;
	wk			: integer;
	inch, loop	: byte;
  begin
	{while ProtocolStop do TransferNext;}
	tries := 0;
	repeat
	  inc(tries);
	  if blkunit = 1 then xmitchar(chr(SOH))
					 else xmitchar(chr(STX));
	  xmitchar(chr(lo(blocknum)));
	  xmitchar(chr($FF-lo(blocknum)));
	  clearCRC;
	  for wk := 0 to (blkunit-1) do begin
		xmitblock(filebuf_[wk shl 7],128);
		calcblkCRC(filebuf_[wk shl 7],128);
	  end;
	  if crcmode=CRC16 then begin
		xmitchar(chr(hi(_crc16))); xmitchar(chr(lo(_crc16)));
	  end
	  else xmitchar(chr(chksum));
	  if g_option then //Application.ProcessMessages
                      Else acknak(inch, 10);
	  if inready then inch := inbyte
	  else				   inch := ACK;
	  if tries = 5 then crcmode := CRC16;
	until (inch = ACK) or (inch = CAN) or (tries = 10) or Terminated^;
	if inch = ACK then send1block := 0
	else			   send1block := 9;
	//_^.CnStat := zfile;
  end;

Procedure TFileTran.Xdownload( var successful:boolean);
  var
	  inch, loop	: byte;
	  blocknum		: integer;
	  temp			: line;
	  rslt			: integer;
	  prtcl			: integer;
	  done			: boolean;
	  tries			: integer;
	  blkunit		: integer;
  	  results		: boolean;
  	  success		: boolean;
  begin

        g_option := GOption;

	case Xprotocol of
	  SUM_128  : begin crcmode := SUM;	blkunit := 1; end;
	  CRC_128  : begin crcmode := CRC16;	blkunit := 1; end;
	  CRC_1024 : begin crcmode := CRC16;	blkunit := 8; end;
	  else       begin successful := false; Exit;       ; end;
	end;
	successful := true;

	  if FileExists(Status.filename) then begin

          	assignFile(f_,Status.filename);
                reset(F_);
		done	 := false;
		rslt	 := 0;
		blocknum := 0;
		crcmode  := SUM;
		acknak(inch, 60);
		if inch = 0 then inch := CAN;
		if inch = C then crcmode := CRC16;

		repeat
		  if rslt = 0 then begin
			if eof(f_) then done := true
			else begin
			  blockreadm(filebuf_[0], blkunit);
                          Status.TranSize:=Status.TranSize+blkunit*128;
			  if eof(f_) and (RecCount = 0) then done := true
			  else begin
                           	inc(blocknum);
				Fill_EOF_Code(filebuf_[0],RecCount);
			  end;
			end;
		  end;
		  if (inch <> CAN) and (Not Terminated^) and not(done) then begin
			rslt := send1block(blkunit, blocknum);
		  end;
		  if done then rslt := 1;
		until (inch = CAN) or (rslt <> 0) or Terminated^ ;
		successful := (rslt = 1);
		tries := 0;
		if successful and (Not Terminated^) then repeat
		  xmitchar(chr(EOT));
		  acknak(inch, 60);
		  inc(tries);
		until (inch=ACK) or (tries > 10) or Terminated^;
		if (Not Terminated^) and (inch <> CAN) and not successful then
		   xmitblock(cancan, sizeof(cancan));
		closefile(f_);
	  end
	  else begin
		successful := false;
	  end;
 end;


Procedure TFileTran.clearbuff;
  begin
    FillChar(filebuf_[0], 128, chr(0));
  end;


Procedure TFileTran.setheader;
  var tmp    : line;
  begin
    clearbuff;
    str(Get_File_Size, tmp);
    tmp := Status.SendFileName+#0+tmp+' '+time1970(FileDateToDateTime(FileAge(Status.FileName)));
    tmp := AnsiLowerCase(tmp);        {小文字化(MS漢字はｽﾙｰ)}
    Move(tmp[1], filebuf_[0], length(tmp));
  end;

Procedure TFileTran.Ydownload(var successful:boolean);
  var
	  inch, loop	: byte;
	  blocknum		: integer;
	  temp			: line;
	  rslt			: integer;
	  prtcl			: integer;
	  wk			: integer;
	  done			: boolean;
	  tries			: integer;
	  g_work		: boolean;
	  blkunit		: integer;
	  ch			: char;
	  results		: boolean;
  	  success		: boolean;
  begin
    successful := true;
	crcmode  := CRC16;

        G_option:=Goption;

        blkunit := 8;

	  if FileExists(Status.FileName) then
           begin
          	  assignFile(F_,Status.FileName);
                  reset(F_);

		done	 := false;
		rslt	 := 0;
		blocknum := 0;
		acknak(inch, 60);
		if inch = 0 then inch := CAN;
		if	  inch = G then g_option := true
		else if inch = C then g_option := false
		else rslt := 9;
		repeat
		  if rslt = 0 then begin
			if blocknum = 0 then begin
			  setheader;
			end
			else if eof(f_) then done := true
			else begin
			  blockreadm(filebuf_[0], blkunit);

                          Status.TranSize:=Status.TranSize+Blkunit*128;

			  if eof(f_) and (RecCount = 0) then done := true;
			  Fill_EOF_Code(filebuf_[0],RecCount);
			end;
		  end;
		  if (inch <> CAN) and (Not Terminated^) and not done then begin
			if blocknum = 0 then begin
			  rslt := send1block(1, blocknum);
			  acknak(inch, 10);
			end
			else begin
			  rslt := send1block(blkunit, blocknum);
			end;
		  end;
		  if rslt = 0 then begin
//			if hoststat = cn then write(cr + 'Sent #', blocknum:4);
			inc(blocknum);
		  end;
		  if done then rslt := 1;
		until (inch = CAN) or (rslt <> 0) or Terminated^;
		successful := (rslt = 1);
		tries := 0;
		if successful and (Not Terminated^) then repeat
		  xmitchar(chr(EOT));
		  acknak(inch, 60);
		  inc(tries);
		until (inch=ACK) or (tries > 10) or Terminated^;
		closeFile(F_);
	  end
	  else begin
		if (Not Terminated^) then xmitblock(cancan, sizeof(cancan));
		waiting(1000);
		successful := false;
	  end;

         Sleep(30) ;//application.processMessages;

	if (Not Terminated^) and (Ybatch and successful) then begin
	  acknak(inch, 10);
	  clearbuff;
	  rslt := send1block(1, 0);
	end;
	if (Not Terminated^) and (inch <> CAN) and not successful then
	  xmitblock(cancan, sizeof(cancan));
	waiting(1000);
  end;


Procedure TFileTran.Mdownload(var successful:boolean);
(* The resource版から書き直し HAL*)


  Procedure setMheader;
	var i	  : integer;
 		s	  : string;
		DT	  : TDateTime;
		wk	  : string;
                Year, Month, Day, Hour, Min, Sec, MSec: Word;

	begin
	  s := Status.SendFileName + ' ';
	  DT:=FileDateToDateTime(FileAge(Status.filename));
          DecodeDate(DT, Year, Month, Day);
          DecodeTime(DT, Hour, Min, Sec, MSec);

	  wk :=     Format('%.4d/%.2d/%.2d %.2d:%.2d:%.2d',
                           [Year,Month,Day,Hour,Min,Sec]  )+^m;
	  s := s + IntToStr(Get_File_Size) + ' ' + wk;
	  xmitblock(s[1],length(s));
        end;


  var
          Fsize          : integer;
	  inch		: byte;
	  blocknum	: integer;
	  temp		: line;
	  rslt		: integer;
	  wk		: byte;
	  wk1		: byte;
	  wk2		: word;
	  ch		: char;
	  fnam		: string;
	  error		: boolean;
	  sbyte		: word;
	  dir		: string;
	  name		: string;
	  results	: boolean;
	  success   : boolean;
      fmerr		: text;
         Tries :Integer;
  begin
    successful := true;
       Tries:=0;
       repeat;
          Inc(Tries);
	  blocknum := 0;
	  rslt := 0;

	  if not FileExists(Status.fileName) then
	    rslt := 8
	  else begin

               assignFile(F_,Status.FileName);
               reset(F_);

		acknak(inch, 60);
		if (Terminated^) or (inch <> ord(INI)) then rslt := 9;
		if rslt = 0 then begin
		  setMheader;
		  acknak(inch, 10);
		  fsize := Get_File_Size;
		  if inch <> INI then rslt := 9
		  else begin
			while (Not Terminated^) and (fsize > 0) and (rslt = 0) do begin
			  blockreadm(filebuf_[0], 8);  {最大1024bytes}
			  wk1 := 0;
			  while (wk1 < 8) and (fsize > 0) do begin
				if fsize < 128 then sbyte := fsize
							   else sbyte := 128;
				xmitblock(filebuf_[wk1 shl 7], sbyte);

                                Status.TranSize:=Status.TranSize+Sbyte;
				dec(fsize, sbyte);
				inc(wk1);
			  end;
			  inc(blocknum);
//			  if hoststat = cn then write(cr + 'M-LINK Sent #', blocknum:4);
			  if inready then begin
				inch := byte(recvchar);
				if (inch = ABT) or (inch = EXT)  then rslt := 9;
			  end;
			end;
			if (Not Terminated^) and (rslt = 0) then begin
			  acknak(inch, 10);
			  if (inch <> ETR) or Terminated^ then
				rslt := 9
			  else begin
     //				_DL(fls)[i].rslt := true;
			  end;
			end;
		  end;
		end;
		closeFile(F_);
	  end;
	  successful := (rslt = 0);
	  if not successful then begin
		{if cts then xmitchar(chr(ABT));
		waiting(seccnt);
		flowctrl(true);}
		waiting(10000);
		if (Not Terminated^) then xmitchar(#$0d);
		waiting(1000);
//		if rslt = 8 then lineout('Can''t found ' + dir + _DL(fls)[i].lfnam);
	  end;

     	until (tries>10)  or successful or Terminated^;
        //Application.ProcessMessages;
	xmitchar(chr($0D));
	acknak(inch, 60);
	waiting(1000);
  end;


Function TFileTran.recchar(var error: boolean): byte;
(*errorは１秒以内にデータがあれば偽*)
  var temp: byte;
  begin
	if Terminated^  then error := true
	else begin
	  if not timedin then error := true
	  else begin
		temp := byte(recvchar); { ch:0は使わないはず }
		calcCRC(temp);
		recchar := temp;
	  end;
	end;
  end;


Procedure TFileTran.clearline;
(*現在のブロックが終わるまで無視*)
  var junk: byte;
  begin
  	while timedin do junk := inbyte;

  end;


Function TFileTran.recv1block(var blkunit: integer; var blocknum: smallint): integer;
(*１ブロック受信。プロトコルエラーならNAKを送ってリトライする。
  0:ok	1:EOF  (2:ERROR)  9:FATAL-ERROR
  filebuf_ は 1026 バイトの前提でコーディングしてるので注意
*)
  var
	tries		: integer;
	locblock	: smallint;
	rslt		: integer;
	error		: boolean;
	opening		: integer;
	comp		: integer;
	wk		: word;
	byteloc		: integer;
	hicrc, locrc: byte;
	bytes		: word;
	sttm		: integer;
	wk1			: word;
  begin
	{while ProtocolStop do TransferNext;}
	locblock := blocknum;
	tries := 0;
	repeat
	  inc(tries);
	  rslt := 0;
	  error := false;
	  opening := recchar(error);
	  if not error then case opening of
		CAN : rslt := 9;
		EOT : begin
				rslt := 1;
			  end;
		SOH, STX :
			  begin
				if		opening = SOH then blkunit := 1
				else if opening = STX then blkunit := 8;
				if (Not Terminated^) then begin
				  blocknum := recchar(error);
				  comp	   := recchar(error);
				  if (comp + blocknum = $FF) and not error then begin
					clearCRC;
					if crcmode=CRC16 then bytes := blkunit*128+2
							 else bytes := blkunit*128+1;
					wk:=0;
					sttm := gettickcount;
					repeat				(*1block受信*)
					  wk1:=receiveblock(filebuf_[wk],bytes-wk);
					  if wk1<>0 then begin
						inc(wk,wk1);
						sttm := gettickcount;

					  end
					  else begin
						if gettickcount-sttm>1000 then
                                                   error:=true;
					  end;
					until (wk>=bytes) or error;


					if not error then begin
					  hicrc := byte(filebuf_[blkunit*128]);
					  calcblkCRC(filebuf_[0],blkunit*128);
					  if crcmode=CRC16 then begin
						locrc := byte(filebuf_[blkunit*128+1]);
						if (lo(_crc16)<>locrc)or(hi(_crc16)<>hicrc)then
						  rslt:=2;
					  end
					  else begin
						if chksum<>hicrc then
                                                   rslt:=2;
					  end;
					  if (lo(locblock) <> lo(blocknum)) and
						 (lo(locblock) <> lo(blocknum+1)) then rslt := 9;
					end;
				  end
				  else begin
					error := true;
				  end; {if $FF}
				end; {if cts}
			  end; {SOH,STX}
		else
		  error := true;
	  end; {case}

	  if error then begin
                                clearline; rslt := 2; end;
	  if rslt = 2 then begin
		if (not g_option) and (Not Terminated^) then begin
		  if not acknakout(NAK) then rslt := 9;
		end
		else rslt := 9;
	  end;
	  if tries > 6 then crcmode := CRC16;
	until (rslt=0) or (rslt=1) or (rslt=9) or Terminated^ ;
	recv1block := rslt;
  end;

//{$I-}




Procedure TFileTran.Xupload( var successful:boolean);
  var
	blocknum, byteloc	: smallint;
	locblock			: SmallInt;
	opening				: byte;
	rslt, rslt1			: integer;
	prtcl				: integer;
	wk					: SmallInt;
	blkunit				: integer;
	temp				: line;
	fnam				: string;
	success				: boolean;
  begin
    g_option := GOption;
	case Xprotocol of
	  SUM_128  : begin crcmode := SUM;	blkunit := 1; end;
	  CRC_128  : begin crcmode := CRC16;	blkunit := 1; end;
	  CRC_1024 : begin crcmode := CRC16;	blkunit := 8; end;
	  else       begin successful := false; Exit;       ; end;
	end;

      	flush;

       Try
        success:=true;
	assignFile(F_,Status.filename);
	rewrite(F_);
       Except
        success:=False;
       End;

	locblock := 1;

	if success then rslt:=0 else rslt := 9;
	if crcmode=CRC16 then opening := C
			 else opening := NAK;
	if (Not Terminated^) and (rslt = 0) and (not acknakout(opening)) then rslt := 9;
	while (Not Terminated^) and (rslt <> 1) and (rslt <> 9) do begin
	  blocknum := locblock;
	  rslt := recv1block(blkunit,blocknum);
	  if (lo(locblock) = blocknum) and (rslt = 0) then begin
		blockwrite(F_,filebuf_[0],blkunit*128,RecCount);
                Status.TranSize:=Status.TranSize+blkunit*128;
		if RecCount<>(blkunit*128) then rslt := 9;
		inc(locblock);
	  end;
	  if rslt = 9 then flush;
	  if rslt = 0 then begin
		if acknakout(ACK) then rslt := 0
						  else rslt := 9;
	  end;
	end; {while}
	if rslt = 9 then xmitblock(cancan, sizeof(cancan));
	if rslt = 1 then xmitchar(chr(ACK));
	closeFile(F_);
//	flowctrl(true);
	successful := success and (rslt = 1);
//	if not successful then eraseM;
  end;


  Procedure TFileTran.Yupload(var successful:boolean);
  var
	  blocknum, byteloc : smallint;
	  blkunit			: integer;
	  locblock			: integer;
	  opening			: byte;
	  rslt				: integer;
	  prtcl				: integer;
	  wk				: integer;
	  temp				: line;
	  fnam				: string;
	  pt				: word;
	  orgfname			: string[80];
	  orgfsize			: longint;
	  orgftime			: longint;
	  byt				: word;
	  success			: boolean;
	  dummy				: integer;
  begin
	crcmode  := CRC16;
	blkunit  := 8;
        g_option := Goption;

	if Ybatch then stringout('-BATCH');
	stringout(' ');

     Try
        success:=True;
	assignFile(F_,Status.filename);
	rewrite(F_,Status.FileName);
     Except
        success:=False;
     End;
      	flush;
	locblock := 0;
        blocknum := 0;

	if success then rslt:=0 else rslt:=9;
	if not g_option then opening := C else opening := G;
	if (Not Terminated^) and (rslt = 0) and (not acknakout(opening)) then rslt := 9;
	while (Not Terminated^) and (rslt <> 1) and (rslt <> 9) do begin
	  blocknum := locblock;
	  rslt := recv1block(blkunit, blocknum);
	  if (lo(locblock) = blocknum) and (rslt = 0) then begin
		if locblock > 0 then begin	(*ブロック０は無視*)
		  byt := blkunit * 128;
		  if orgfsize<byt then byt := orgfsize;
		  if byt<>0 then begin
                      blockwrite(F_,filebuf_[0], byt,RecCount);
                      Status.TranSize:=Status.TranSize+Byt;
                   End;
		  if RecCount<>byt then rslt := 9;
		  orgfsize := orgfsize-byt;
		end
		else if locblock = 0 then begin(*ﾌﾞﾛｯｸ0のｵﾘｼﾞﾅﾙ･ﾌｧｲﾙ情報を得る*)
		  pt := 0;
		  orgfsize := 0;
		  orgftime := 0;
		  repeat
			byt := filebuf_[pt];
			inc(pt);
			orgfname[pt] := chr(byt);
		  until byt=0;
		  orgfname[0] := chr(pt-1);
                  Status.GetFileName := orgfname;   //
		  while (filebuf_[pt]>=ord('0'))
			and (filebuf_[pt]<=ord('9')) do begin
			orgfsize := orgfsize*10 + filebuf_[pt] - ord('0');
                        inc(pt);
		  end;
                  Status.FileSize := orgfsize;
		  if filebuf_[pt]=ord(' ') then begin
			inc(pt);
			while (filebuf_[pt]>=ord('0'))
			  and (filebuf_[pt]<=ord('9')) do begin
			  orgftime := orgftime*8 + filebuf_[pt] - ord('0');
			  inc(pt);
			end;
		  end;
		end;
		inc(locblock);
	  end;
	  if rslt = 9 then flush;
	  if rslt = 0 then begin
		if blocknum = 0 then begin
		  if not g_option then xmitchar(chr(ACK));
		  if acknakout(opening) then rslt:=0 else rslt:=9;
		end
		else if not g_option then begin
		  if acknakout(ACK) then rslt:=0 else rslt:=9;
		end;
	  end;
	end; {while}
	if rslt = 9 then xmitblock(cancan, sizeof(cancan));
	if rslt = 1 then xmitchar(chr(ACK));
	if orgftime<>0 then ;//FileSetDate(f_.handle,GMTtoPACKT(orgftime));
	closeFile(f_);
	successful := success and (rslt <= 1);
	if Ybatch then begin
	  blocknum := 0;
	  if acknakout(opening) then dummy := recv1block(blkunit,blocknum);
	  if not g_option then xmitchar(chr(ACK));
	end;
//	flowctrl(true);
//	if not successful then eraseM;
  end;

{$I+}


Procedure TFileTran.Mupload(var successful: boolean);
(* The resource版 から書き換え HAL *)
var
	wk	: word;

  Function detecthb(time: integer):boolean;
  (*time秒だけ入力を待つ。タイムアウト or 回線切れならfalseを返す。*)
  var loop, loopend, i: integer;
	  inch : byte;
  begin
	loopend := ACNT * time;
	loop := 0;
	repeat
	  waiting(100);		{wait 0.1sec}
	  inc(loop);
	until Terminated^ or inready or (loop >= loopend);
	if loop>=loopend then detecthb:=false else detecthb:=true;
	{if inready then begin
	  inch := byte(recvchar);
	  if inch = CAN then detecthb := false else detecthb := true;
	  wk := 0;
	end;}
  end;


  Function recm:byte;  (* CRC を計算しない *)
	var
	  temp: byte;
	  time: integer;
	begin
	  time:=gettickcount;
	  while (Not Terminated^) and (gettickcount-time<1000) and (not inready) do
		Sleep(30);//application.processmessages;
	  if inready then recm:=inbyte else cancelled:=true;
	end;


  Function getdigit(var st:string; var pt:word): integer;
	var num : integer;
begin
	  num:=0;
	  while (st[pt]>='0') and (st[pt]<='9') do begin
		num := num*10 + ord(st[pt]) - ord('0');
		inc(pt);
	  end;
	  getdigit:=num;
	end;


  var
	blocknum	: integer;
	opening		: byte;
	rslt		: integer;
	wk1			: word;
	rbyte		: word;
	sttime		: word;
	filebytes	: longint;
	bytes		: word;
	dumy		: word;
	inch		: byte;
	temp		: string;
	{fnam		: longname;}
	sttm		: integer;
//	DT			: TDateTime;
	PT			: longint;
	p			: word;
	error		: boolean;
	success		: boolean;
  begin
	  error:=false;
          success:=True;
          rslt:=0;
Try
	  assignFile(F_,Status.filename);
	  clearbuff;
	  flush;
	  rewrite(F_);
Except
	  rslt:=9;
          success:=False;
End;
	  if (rslt=0) and (Not Terminated^) then begin
 //		flowctrl( false );
		wk:=9;  (*10回待ちます *)
		waiting(6000); (*6秒間*)
		xmitchar(chr(INI));
		while (Not Terminated^) and (detecthb(10)=false) and (wk>0) and (rslt=0) do begin
		  xmitchar(chr(INI));
		  dec(wk);
		end;
		if wk=0 then rslt:=9;
		if (Not Terminated^) and (rslt=0) then begin
		  inch:=0;
                  temp:='';

		  repeat	  (* ファイル名を飛ばす *)
                	inch:=recm;
                        temp:=temp+chr(inch);
		  until Terminated^ or (inch=$20) or (inch=EXT) or (inch=CAN) or error;

                  Status.GetFileName := Copy(temp,1,length(temp)-1);

		  if (inch=EXT) or (inch=CAN) or error or Terminated^ then rslt:=9
		  else begin
			temp:='';
			dumy:=0;
			repeat	(* ファイルサイズを得る *)
			  dumy:=recm;
			  temp:=temp+chr(dumy);
			until Terminated^ or (dumy=$20) or error;
			temp:=Copy(temp,1,length(temp)-1);
			filebytes:=StrToIntDef(Temp,0);
                        Status.FileSize:=FileBytes;
			if filebytes=0 then rslt:=9
			else begin
			  temp:='';
			  repeat	(* IB の終わりまで *)
				dumy:=recm;
			  until Terminated^ or (dumy=$0D) or error ;
			end;
			if error or (rslt=9) then
                                 xmitchar(chr(ABT))
			else xmitchar(chr(INI));
			end;
		  end;
		  wk:=0;
		  blocknum:=0;
		  if (Not Terminated^) and (rslt=0) then begin
			repeat
			  if filebytes>=1024 then bytes:=1024
					 else bytes:=filebytes;
			  wk:=0;
			  sttm := gettickcount;
			  repeat				(*1block受信*)
				//Application.ProcessMessages;
				wk1:=receiveblock(filebuf_[wk],bytes-wk);
				if wk1<>0 then begin
				  inc(wk,wk1);
				  sttm := gettickcount;
				end
				else begin
				  if gettickcount-sttm>1000 then error:=true;
				end;
			  until (wk>=bytes) or error;
			  dec(filebytes,bytes);
                          if error  then
                           rslt:=9
			  else begin
				blockwrite(f_,filebuf_[0], bytes,RecCount);
				inc(blocknum);
                                Status.TranSize:=Status.TranSize+Bytes;
                           End;
			      //	if hoststat = cn then
			      //	  write(cr + 'M-LINK Received #', blocknum:4);
//			  end;
			until Terminated^ or (rslt=9) or (filebytes<=0);
                        if (Not Terminated^) and (rslt=9) then begin
                           xmitchar(chr(ABT));
                           clearline;
                        end
								else xmitchar(chr(ETR));
		  end;
	  end;
//	  flowctrl( true );
//	  _^.CnStat:=zfile;
// 	  if hoststat = 0 then dispstatus(cn);
//	  PackTime(DT,PT);
//	  setfiletimeM(PT);
	  closeFile(f_);
	  Stringout(#13);
	  successful := success and (rslt = 0);
//	if not successful then eraseM;
	error:=false;
  end;


Procedure TFileTran.storebuff(var buffernum: byte; var paused, aborted: boolean);
  var loop: byte;
	  rslt: integer;
  begin
	loop := 0;
	while (loop < buffernum) and not aborted do begin
	  blockwrite(F_,filebuf_[loop shl 7], 128,RecCount);
	  if RecCount<>128 then aborted := true;
	  inc(loop);
	end;
	buffernum := 0;
	paused := false;
  end;


Function TFileTran.Ztimedin:boolean;
  (* １０秒以内に受信データがあれば真を返す。used in ZMODEM *)
  var
	begcnt	: integer;
  begin
	begcnt:=gettickcount;
    //	if boolean(begcnt and 1) then application.processmessages;
    while (not inready) and (Not Terminated^) and ((gettickcount-begcnt)<10000)  do
	 Sleep(30) ;//application.processmessages;
	Ztimedin:=inready;
  end;


 {




{ ---以下ZMODEM関係--- }
{----------- zmodem support routine -------------}


Function TFileTran.Zfromunixdate(s:string):TDateTime;
  var
	dt : TDateTime;
	secspast, datenum : longint;
	n  : word;
  begin
	secspast:=0;
	for n:=1 to length(s) do secspast:=(secspast shl 3)+ord(s[n])-$30;
	Zfromunixdate:=GMTtoPACKT(secspast);
 end;


Procedure TFileTran.Zmakepackedheader(htype:byte;datas:longint;var hdr:headertype);
  begin
	hdr[0]:=htype;
	hdr[1]:=byte(datas);
	hdr[2]:=byte(datas shr 8);
	hdr[3]:=byte(datas shr 16);
	hdr[4]:=byte(datas shr 24);
  end;



Function TFileTran.Zmakeunpackedheader(var hdr:headertype):longint;
  var
	l:longint;
  begin
	l:=hdr[4];
	l:=(l shl 8) or hdr[3];
	l:=(l shl 8) or hdr[2];
	l:=(l shl 8) or hdr[1];
	Zmakeunpackedheader:=l;
  end;

Function TFileTran.ZcheckfileCRC(crcreq:longint):longint;
  var
    dumy:byte;
    loop:word;
    fbuf:filbuffer;
    len :integer;
    success:boolean;
  begin
    clearCRC;
    seekM2(0,success);
    dec(crcreq);
    repeat
      //Application.processmessages;
      blockreadm(fbuf,1);
	  len:=RecCount;
	  if len>crcreq then len:=crcreq;
      calcblkCRC(fbuf[0],len);
      dec(crcreq,len);
    until (crcreq=0) or (len=0);
    seekM2(0,success);
    ZcheckfileCRC:=takeCRC xor $FFFFFFFF;
  end;

Procedure TFileTran.Zcancel;
  var
	loop:byte;
  begin
  	flush;
	for loop:=0 to 7 do begin
	  xmitchar(chr(CAN));
	  Sleep(100);//waiting(100);
	end;
	for loop:=0 to 7 do xmitchar(chr(8)); { backspaces }
  end;


Procedure TFileTran.Zsendstring(p:string);
  var
	loop:word;
  begin
	for loop:=1 to length(p) do begin
	  case p[loop] of
		#221 : begin end; { Not support send break }
		#222 : waiting(2000);
		else	 xmitchar(p[loop]);
	  end;
	end;
  end;


Procedure TFileTran.Zsendhex(b:byte);
  const
	hex:array[0..15] of char='0123456789abcdef';
  begin
	xmitchar(hex[b shr 4]);		{ ASCII hex code output }
	xmitchar(hex[b and $0F]);
  end;


Procedure TFileTran.Zsendhexheader(header:headertype);
  var
	loop:byte;
	bkup:crctype;
  begin
	bkup:=crcmode;
	crcmode:=crc16;
	xmitchar(char(_PAD));
	xmitchar(char(_PAD));
	xmitchar(char(_DLE));
	xmitchar(char(_HEX));
	clearCRC;
	Zsendhex(header[0]);
	Zsendhex(header[1]);
	Zsendhex(header[2]);
	Zsendhex(header[3]);
	Zsendhex(header[4]);
	calcblkCRC(header[0],5);
	Zsendhex(Hi(_crc16));
	Zsendhex(lo(_crc16));
	xmitchar(chr(13)); xmitchar(chr(10));
	crcmode:=bkup;
  end;

Function TFileTran.ZcatchZDL:word;	(*エラーのとき_ZR_ERRを返す by Seishi*)
  var
	temp:byte;
  begin
	if Ztimedin then begin
	  temp:=byte(recvchar);
	  if temp<>_DLE then begin
		ZcatchZDL:=temp;
		exit;
	  end;
	  if Ztimedin then begin {元は if inready だったby Seishi}
		temp:=byte(recvchar);
		case temp of
		  CAN,_CRCE,_CRCG,_CRCQ,_CRCW :
				  ZcatchZDL:=temp or $0100; { sequense character }
		  _RUB0 : ZcatchZDL:=$7F;
		  _RUB1 : ZcatchZDL:=$FF;
		  else if (temp and $60)=$40 then
		    ZcatchZDL:=temp xor $40   { decode }
		  else
		    ZcatchZDL:=_ZR_ERR;
		end;
	  end
	  else ZcatchZDL:=_ZR_ERR;
	end
	else ZcatchZDL:=_ZR_ERR;
  end;


Function TFileTran.Zgethex(var err : boolean) : byte;
  var
    temp, wk : byte;
  begin
    if not err and Ztimedin then begin
      temp := byte(recvchar);
      case chr(temp) of
        '0'..'9': wk := (temp - $30) shl 4;
        'a'..'f', 'A'..'F': wk := ((temp and $F) + 9) shl 4;
        else err := true;
      end;
      if Ztimedin and not err then begin
        temp := byte(recvchar);
        case chr(temp) of
          '0'..'9': inc(wk, temp - $30);
          'a'..'f', 'A'..'F': inc(wk, (temp and $F) + 9);
          else err := true;
        end;
      end;
    end else err := true;
    Zgethex := wk;
  end;


Procedure TFileTran.Zgethexheader(var header:headertype;var err:boolean);
  var
	loop:byte;
	temp:byte;
	dumy:char;
  begin
	clearCRC;
	header[0]:=Zgethex(err);	{ Ztype and four Zflags }
	header[1]:=Zgethex(err);
	header[2]:=Zgethex(err);
	header[3]:=Zgethex(err);
	header[4]:=Zgethex(err);
	calcblkCRC(header[0],5);
	temp:=Zgethex(err); calcCRC(temp); { CRC check }
	temp:=Zgethex(err); calcCRC(temp); { CRC check }
	if takeCRC<>matchCRC then err:=true;
	if Ztimedin then dumy:=recvchar; { CR/LF receive }
	if Ztimedin then dumy:=recvchar; { CR/LF receive }
  end;


Procedure TFileTran.Zgetbinheader(var header:headertype;var err:boolean);
  var
	loop:word;
	temp:word;
	dumy:byte;
  begin
	clearCRC;
	loop:=0;
	repeat
          //Application.ProcessMessages;
			{ Ztype and four Zflags }
	  temp:=ZcatchZDL;
	  if temp<256 then begin
		header[loop]:=byte(temp);
		calcCRC(byte(temp));
	  end
	  else err:=true;
	  inc(loop);
	until (loop=5) or err or Terminated^;
	loop:=0;
	if crcmode=crc16 then begin
	  repeat
		temp:=ZcatchZDL;
		if temp<256 then calcCRC(byte(temp))
		else err:=true;
		inc(loop);
	  until (loop=2) or err or Terminated^;
	end
	else begin
	  repeat
		temp:=ZcatchZDL;
		if temp<256 then calcCRC(byte(temp))
		else err:=true;
		inc(loop);
	  until (loop=4) or err or Terminated^;
	end;
	if takeCRC<>matchCRC then err:=true;
  end;


Function TFileTran.Zgetheader(var header:headertype; var num:longint; var err :boolean):byte;
(* 判断がいまいちいい加減 :-) *)
  var
    temp : byte;
    pass : boolean;
    bkup : crctype;
    cancount : integer;
  begin
    err := false;
    pass := false;
    cancount := 2;
    bkup := crcmode;
    crcmode := crc16;
    repeat
      //Application.ProcessMessages;
      if Ztimedin then
        temp := byte(recvchar)
      else
        err := true;
      case temp of
        _PAD: begin  (* 始めに１つ以上の ZPAD ('*') を受ける *)
            pass := true;
            cancount := 2;
          end;
        _DLE: begin  (* ZPAD の次に来ないと無効 *)
            if pass then begin
              if Ztimedin then
                temp := byte(recvchar)
              else
                header[0] := CAN;  (* ^X の中断入力と見る (ZDLE=CAN) *)
              case temp of
                _BIN: Zgetbinheader(header, err);
                _BIN32: begin  { use in CRC32bit mode }
                    crcmode := crc32;
                    Zgetbinheader(header, err);
                  end;
                _HEX: Zgethexheader(header, err);
                CAN: header[0] := CAN  (* 連打 ^X (ｲﾁﾞﾒﾅｲﾃﾞﾈ) *)
                else
                  pass := false;
              end;
            end else begin
              dec(cancount);
              if cancount <= 0 then
                header[0] := CAN
              else
                temp := $00;
            end
          end
        else begin
          pass := false;
          cancount := 2;
        end;
      end;
    until (temp in [CAN, _BIN, _BIN32, _HEX]) or err or Terminated^;
    if err then
      header[0] := _CAN
    else
      num := Zmakeunpackedheader(header);
    crcmode := bkup;
    Zgetheader := temp;
  end;


Procedure TFileTran.Zsendbyte(b:byte);
  begin
	if ((b and $7F) in [16,17,19,24]) or
	  (((b and $7F)=13) and ((lastsent and $7F)=$40)) then begin
	  xmitchar(chr(_DLE));			 { pers character }
	  lastsent:=b xor $40; { encode }
	end
	else lastsent:=b;
	xmitchar(chr(lastsent));
  end;


Procedure TFileTran.Zsendblkbyte(var b; cnt:word);		{ｲﾝﾌﾟﾘﾒﾝﾄ by Seishi		 }
  type byt = array[1..1024] of byte;
  var  n,m   : word;
       buf : pchar;

  begin

        GetMem(buf,cnt*2);    //  最大で cnt*2 　必要だから(^^;;;
        m:=0;

	for n:=1 to cnt do begin
	  if ((byt(b)[n] and $7F) in [16,17,19,24]) or
		(((byt(b)[n] and $7F)=13) and ((lastsent and $7F)=$40)) then begin

       //		xmitchar(chr(_DLE));		 { pers character }
                Buf[m]:=chr(_DLE);//  .... あまりにも遅いのでまとめて送信　　By MYO 97.5.5
                inc(m);
		lastsent:=byt(b)[n] xor $40; { encode }
	  end
	  else lastsent:=byt(b)[n];
	//  xmitchar(chr(lastsent));
                Buf[m]:=chr(lastsent);//  ....
                inc(m);
        end;
        Write(Buf,m);
        FreeMem(Buf);
  end;

Procedure TFileTran.Zsendbinheader(header:headertype);
  var
	loop:word;
	wk:byte;
  begin
	clearCRC;
	xmitchar(chr(_PAD));
	xmitchar(chr(_DLE));
	if crcmode=crc16 then xmitchar(chr(_BIN)) else xmitchar(chr(_BIN32));
	Zsendblkbyte(header[0],5);
(*
	Zsendbyte(header[0]);
	Zsendbyte(header[1]);
	Zsendbyte(header[2]);
	Zsendbyte(header[3]);
	Zsendbyte(header[4]);
*)
	calcblkCRC(header[0],5);
	if crcmode=crc16 then begin
	  Zsendbyte(Hi(_crc16));
	  Zsendbyte(Lo(_crc16));
	end
	else begin
	  _crc32:=not _crc32;
	  Zsendblkbyte(_crc32,4);		{ﾌﾞﾛｯｸ転送に変えた}
(*
	  for loop:=0 to 3 do begin
		Zsendbyte(byte(_crc32[cn]));
		_crc32[cn]:=_crc32[cn] shr 8;
	  end;
*)
	end;
  end;

(* 長いよ、ちょっとぉ.. *)
{----------- end of zmodem support -------------}


Procedure TFileTran.Zupload(var successful:boolean);
  (* The Resource 版からインプリメント by Seishi *)
  var
	blocknum : longint;  (* バイト単位 *)
	retry	 : byte;
	recurs	 : byte;
	error	 : boolean;
	temp	 : headertype;
	orgftime : longint;
	orgftime2: longint;
	success  : boolean;


  Procedure Zreceivedata(var p; var count:word; var frame:byte;
						  var err:boolean);
(* 最適化：ループ関係の大幅書き変え、goto文を１カ所導入 by Seishi *)
	type bt = array [0..1023] of byte;
	label crcfoo;
	var
	  temp	:word;
	  lcnt	:word;
	  loopflag	:boolean;
	  _count:word;
	  _err  :boolean;
	begin
	  _err := err;
	  _count := 0;
	  clearCRC;
	  clearbuff;
	  loopflag := not _err;
	  while loopflag do begin
		temp := ZcatchZDL;
		if temp < 256 then begin
		  if _count >= 1024 then begin
			_err := true;  {overrun}
			loopflag := false;  {exit while}
		  end else begin
			bt(p)[_count] := byte(temp);
			  calcCRC(byte(temp));
			inc(_count);
				end;
		end else begin
crcfoo:
		  case byte(temp) of
			_CRCE, _CRCW, _CRCG, _CRCQ: begin
				frame := byte(temp);
				calcCRC(byte(temp));
				if crcmode = crc16 then
				  lcnt := 2
				else
				  lcnt := 4;
				repeat
				  temp := ZcatchZDL;
				  if temp < 256 then
					calcCRC(byte(temp))
				  else
					goto crcfoo;
				  dec(lcnt);
				until (lcnt = 0) or Terminated^;
				if takeCRC <> matchCRC then
				  _err := true;  { CRC error }
				loopflag := false;  {exit while}
			  end;
			CAN: begin
				frame := _CAN;  (*Sender Canceled*)
				loopflag := false;  {exit while}
			  end
			else begin
			  _err := true;  (*_ZR_ERR, etc.*)
			  loopflag := false;  {exit while}
				  end;
				end;
			end;
		  end;
	  count := _count;
	  err := _err;  (* 呼び出し側に情報を渡す *)
	end;


  Procedure Zendrecv;
	var
	  loop:word;
	  temp:headertype;
	  inret:byte;
	begin
	  Zmakepackedheader(_FIN,blocknum,temp);
	  loop:=4;
	  repeat
		Zsendhexheader(temp);  (* Binary header はまずいのだろうか *)
		if Ztimedin then begin
		  inret:=byte(recvchar);
		  case inret of
			79:begin   (* Over and Out 'OO' receive *)
				 if Ztimedin then inret:=byte(recvchar);
				 exit;
			end
			else begin
			   dec(loop);
			end;
		  end;
		end;
	  until (loop=0) or Terminated^;   (* ZFIN で終了出来なくてもよしとした *)
	end;


  Function Zinitreceiver(var err:boolean):byte;


	Function getdrivename(s:string):char;
	  begin
		if pos(':',s)>0 then getdrivename:=s[pos(':',s)-1]
		else getdrivename:='@';
	  end;

	var
	  temp:headertype;
	  sufs:byte;
	  blks:word;
	  loop:byte;
	  test:boolean;
	  glbs:boolean;
	  dumy:longint;
	  pt  :word;
          S_myo : String; // By MYO ファイルサイズ拾得のため
	begin
	  test:=false;
	  loop:=10;   { retry count at 10 }
	  repeat
		Zmakepackedheader(_RINIT,0,temp);
		temp[4]:=
		  CANFDX or CANOVIO or CANFC32;  { full duplex,overlay I/O,CRC32 }
		Zsendhexheader(temp);
		repeat
		  glbs:=false;
		  blks:=0;	  { dumy }
		  sufs:=Zgetheader(temp,dumy,err);
		  if sufs=_BIN32 then crcmode:=crc32;
		  case temp[0] of
			_FILE : begin
					(* この時 temp[4] には属性 (ZCBIN など) が入っているが *)
					(* 今回は無視（＝無条件に ZCBIN）					   *)
					(* 実の所、ZCBIN 以外は良く分からないので :-)		   *)
					clearbuff;
					Zreceivedata(filebuf_[0],blks,sufs,err);
					Zinitreceiver:=_FILE;
					orgftime := 0;		(* 日付情報を得る by Seishi *)
					pt:=0;
                                        Status.GetFileName:='';
					while filebuf_[pt]<>0 do
                                         Begin
                                           Status.GetFileName:=Status.GetFileName+char(FileBuf_[pt]);
                                           inc(pt);
                                         End;
					inc(pt);
                                        S_myo:='';
					while filebuf_[pt]>$20 do
                                         Begin
                                           S_myo:=S_myo+Char(FileBuf_[pt]);
                                           inc(pt);
                                         End;
                                        Status.FileSize := StrToIntDef(S_Myo,0);
					inc(pt);
					while (filebuf_[pt]>=ord('0'))
					  and (filebuf_[pt]<=ord('9')) do begin
					  orgftime := orgftime*8 + filebuf_[pt] - ord('0');
					  inc(pt);
					end;				(* 日付情報があれば orgftime<>0 *)
					if sufs=_CRCW then test:=true { check ok }
					else begin
					  Zmakepackedheader(_NAK,0,temp);
					  Zsendhexheader(temp);
					end;
			end;
			_RQINIT : begin
					glbs:=true;
			end;
			_RINIT : begin end;  { pass it }
			_SINIT : begin	 (* これも良く分からない *)
					Zreceivedata(filebuf_[0],blks,sufs,err);
					if sufs=_CRCW then begin
					  Zmakepackedheader(_ACK,0,temp);
					  Zsendhexheader(temp);
					end
					else begin
					  Zmakepackedheader(_NAK,0,temp);
					  Zsendhexheader(temp);
					end;
			end;
{			_FREECNT : begin  (* こんなの本当に呼び出されるのかなあ *)
					Zmakepackedheader(_ACK,diskfree(byte(getdrivename(fsect[_^.board]^.drv))and $1F),temp);
					Zsendhexheader(temp);
			end;
}
			_COMMAND : begin  (* 誰かぁ日本語の仕様書くれぇ *)
					Zreceivedata(filebuf_[0],blks,sufs,err);
					if sufs=_CRCW then begin
					  repeat
						Zmakepackedheader(_COMPL,0,temp);
						Zsendhexheader(temp);
						blks:=0;	{ dumy }
						dumy:=Zgetheader(temp,dumy,err);
						dec(retry);
					  until (temp[0]=_FIN) or (retry=0) or err or Terminated^;
					  Zinitreceiver:=_COMPL;
					  test:=true;
					end
					else begin
					  Zmakepackedheader(_NAK,0,temp);
					  Zsendhexheader(temp);
					end;
			end;
			_COMPL,_FIN : begin
					Zinitreceiver:=_COMPL;
					test:=true;
			end;
			CAN,_CAN : begin
					Zinitreceiver:=temp[0];
					test:=true;
			end
			else begin
					glbs:=true;
					dec(loop);
					if loop=0 then err:=true;
			end;
		  end;
		until test or glbs or err or Terminated^;
	  until test or err or Terminated^;
	end;


  Procedure Zrecvwrite(var p; count:word; num:longint; var err:boolean);
	begin
	  seekM2(num,success);	{ファイル上の書き込み位置を変更することもできる}
	  blockwrite(f_,filbuffer(p),count,RecCount);

          Status.TranSize:=num+Count;

	  err := count <> RecCount;
	end;


  Function Zreceivefile(var err:boolean):byte;
	(* 良く考えたら、正常終了は ZEOF でしか帰らないな *)
	var
	  retry:byte;
	  loop :byte;
	  temp:headertype;
	  sufs:byte;
	  blks:word;
	  reload:boolean;
	  rehdr:boolean;
	  complete:boolean;
	  rslt:longint;
	  error:boolean;
	  dumy:byte;
	  leng:word;
	begin
	  retry:=10;
	  blocknum:=0;
	  leng:=0;
	  complete:=false;
	  repeat
		Zmakepackedheader(_RPOS,blocknum,temp);  (* スタート＆ずれ修正 *)
		Zsendbinheader(temp);
		repeat
		  rehdr:=false;
		  error:=false;
		  dumy:=Zgetheader(temp,rslt,error);
		  if error then begin
			dec(retry);
                        inc(Status.ErrCount);// (Status)
			if retry=0 then err:=true;	{ retry over }
		  end
		  else case temp[0] of
			_DATA : begin
					if blocknum<>rslt then begin  (* ブロックずれ *)
					  dec(retry);
					  if retry=0 then err:=true;  { retry over }
					end
					else begin
					  repeat
						reload:=false;
						error:=false;
						Zreceivedata(filebuf_[0],blks,sufs,error);
														(* データ本体 *)
						if sufs=_CAN then begin
						 // if HostStat=cn then begin
						 //   writeln; writeln('User abort');
						 // end;
						  err := true;
						end
						else if error then begin
						  xmitchar(chr(_PAD));
						  clearline;  (* 止まるまで待つ *)
						  dec(retry);
						  if retry=0 then err:=true;  { retry over }
						end
						else if sufs in [_CRCW,_CRCE,_CRCG,_CRCQ] then begin
						  if leng=0 then leng:=blks;
						  retry:=10;
						  Zrecvwrite(filebuf_[0],blks,blocknum,err);
						  if not err then begin
							inc(blocknum,blks);
							if sufs in [_CRCW,_CRCQ] then begin
							  Zmakepackedheader(_ACK,blocknum,temp);
							  Zsendbinheader(temp);
							end;
							if sufs in [_CRCQ,_CRCG] then reload:=true
							else rehdr:=true;
							//if hoststat=cn then write(cr+'ZMODEM '+
							//  crcstr[crcmode[cn]],' (',(blks):4,
							//  ') Received #',(blocknum div leng):4);
						  end;
						end;
					  until not reload or err or Terminated^;
					end;
			end;
			_FILE : begin	(* 読むだけ読んで無視 *)
				   Zreceivedata(filebuf_[0],blks,sufs,err);
			end;
			_EOF : begin
				   if rslt=blocknum then begin
					 Zreceivefile:=_EOF;
					 complete:=true;
				   end;
			end
			else begin
				   xmitchar(chr(_PAD));
				   clearline;  (* 止まるまで待つ *)
				   dec(retry);
				   if retry=0 then err:=true;  { retry over }
			end;
		  end;
		until not rehdr or complete or err or Terminated^;
	  until complete or err or Terminated^;
	end;

  begin { of Zupload }
	lastsent:=0;
	crcmode:=crc16;
	flush;

        Try
          Success:=True;
       	  assignFile(F_,Status.FileName);
	  rewrite(f_);
        Except
          Success:=False;
        End;

	if success then begin
	  blocknum:=0; { cannot resume }
	  retry:=4;  (* タイムオーバーの為に４回待つ *)
	  error:=false;
	  repeat
		recurs:=Zinitreceiver(error);
		dec(retry);
	  until (recurs in [CAN,_FILE,_COMPL]) or (retry=0) or
		not error or Terminated^;
	  if not error then
		case recurs of
		  _FILE : begin
					recurs:=Zreceivefile(error);		{ main }
				  end;	  (* 戻ってくると ZEOF or error *)
		  _COMPL : begin end
		  else error:=true;
		end;
	  orgftime2 := orgftime;
	  retry:=4;
	  if not error then repeat
		recurs:=Zinitreceiver(error);
		if recurs=_FILE then begin	(* バッチアップロードは出来ない *)
		  Zmakepackedheader(_SKIP,0,temp);
		  Zsendhexheader(temp);
		end
		else dec(retry);
	  until (recurs=_COMPL) or (retry=0) or error or Terminated^;
	  if not error then Zendrecv else Zcancel;
	end
	else error:=true;
	successful := not error and fileexists(Status.FileName) and (Not Terminated^);
	//if orgftime2<>0 then setfiletimeM(GMTtoPACKT(orgftime2));
	closeFile(f_);
	//if not successful then eraseM;
        flush;		(* Break check を初期化しておく *)
        clearline;
(* 途中でエラーが発生するとバッファに溜っているのでクリア *)
	//flowctrl(true);
  end;


Procedure TFileTran.Zdownload(var successful:boolean);
  (* The Resource 版からインプリメント by Seishi	*)
  (* コメントは The Resource の Comserve さん		*)
  var
	retry	 : byte;
	blocknum : longint;  (* バイト単位 *)
	temp	 : string;
	rslt	 : byte;
	fnam	 : string;
	pack	 : headertype;
    results	 : boolean;
    success  : boolean;
  Procedure Zsenddata(var p; count:word; frame:byte);
	type bt = array [0..1023] of byte;
	var
	  loop:word;
	  blk :word;
	begin
	  clearCRC;
	  //if hoststat = 0 then dispstatus(cn);

	  Zsendblkbyte(p,count);
	  calcblkCRC(byte(p),count);

          Sleep(50);

//	  for loop :=0 to 9 do transfernext;
(*
	  blk:=0;
	  while (blk<count) do begin
		Zsendbyte(bt(p)[blk]);
		calcCRC(bt(p)[blk]);
		inc(blk);
	  end;
*)
	  xmitchar(chr(_DLE));	 (* セパレータ *)
	  xmitchar(chr(frame));  (* CRC 種別   *)
	  calcCRC(frame);
	  if crcmode=crc16 then begin
		Zsendbyte(Hi(_crc16));
		Zsendbyte(lo(_crc16));
	  end
	  else begin
		_crc32:=not _crc32;
		Zsendblkbyte(_crc32,4);		{ﾌﾞﾛｯｸ転送に変えた}
(*
		for loop:=0 to 3 do begin
		  Zsendbyte(byte(_crc32[cn]));
		  _crc32[cn]:=_crc32[cn] shr 8;
		end;
*)
	  end;
//	  _^.CnStat:=zfile;
//	  if hoststat = 0 then dispstatus(cn);
          //Application.ProcessMessages;
	  if frame=_CRCW then
           begin
		xmitchar(chr(17));
		Sleep(250);
	   end;
	end;


  Function Zendsend:boolean;
	var
	  temp:headertype;
	  test:boolean;
	  dumy:longint;
	begin
	  test:=false;
	  dumy:=0;
	  crcmode:=crc16;
	  Zmakepackedheader(_FIN,dumy,temp);
	  Zsendbinheader(temp);
	  dumy:=Zgetheader(temp,dumy,test);
	  if temp[0]<>_FIN then test:=true;
	  Zendsend:=not test;
	end;


  Function Zgetrecvinfo(var err:boolean):byte;
	var
	  loop:word;
	  temp:headertype;
	  test:boolean;
	  dumy:longint;
	  dumy2:byte;
	begin
	  loop:=8;
	  test:=false;
	  repeat
		dumy2:=Zgetheader(temp,dumy,err);
                //AppliCation.ProcessMessages;
		case temp[0] of
		  _CHALLENGE:begin	(* 何のパケットか分からない *)
					 Zmakepackedheader(_ACK,blocknum,temp);
					 Zsendhexheader(temp);	(* ZACK を返せばいいらしい *)
		  end;
		  _COMMAND	:begin	(* これもよく分からない *)
					 Zmakepackedheader(_RQINIT,0,temp);
					 Zsendhexheader(temp);	(* これは ZRQINIT だそうだ *)
		  end;
		  _RINIT	:begin	(* ファイル転送準備 *)
					 Zgetrecvinfo:=_RINIT;
					 crcmode:=crc16;
					 if (temp[4] and CANFC32)>0 then
					   crcmode:=crc32;
					 test:=true;
		  end;
		  _RQINIT	:begin end; { pass it }
		  CAN,_CAN	:begin
					 Zgetrecvinfo:=temp[0];
					 test:=true;
		  end
		  else begin  (* 受け取ったパケットが不正 *)
					 Zmakepackedheader(_NAK,0,temp);  (* 再送要求 *)
					 Zsendhexheader(temp);
		  end;
		end;
		dec(loop);
	  until test or (loop=0) or err or Terminated^;
	  err:=not test or err;
	end;


  Function Zsyncrecv(var err:boolean):byte;
	var
	  loop:byte;
	  temp:headertype;
	  test:boolean;
	  error:boolean;
	  dumy:byte;
	begin
	  loop:=8;
	  test:=false;
	  if not err then repeat
		dumy:=Zgetheader(temp,blocknum,error);
		if error then dec(loop)
		else case temp[0] of
		  _CAN,_ABORT,_FIN : err:=true; (* こんなの知らん :-) *)
		  _RPOS : begin  (* エラー発見のため、位置補正 *)
				  seekM2(blocknum,success);
				  if success then begin
					Zsyncrecv:=_RPOS;
					test:=true;
				  end
				  else begin
					err:=true;
					Zmakepackedheader(_FERR,0,temp);
					Zsendhexheader(temp);
				  end;
		  end;
		  CAN,_SKIP,_RINIT,_ACK : begin  (* CAN,ZSKIP,ZRINIT,ZACK は素通り *)
				  Zsyncrecv:=temp[0];
				  test:=true;
		  end;
		  else begin  (* 受け取ったパケットが不正 *)
				  Zmakepackedheader(_NAK,0,temp); (* 再送要求 *)
				  Zsendbinheader(temp);
                                  Inc(Status.ErrCount);
		  end;
		end;
		dec(loop);
	  until test or (loop=0) or err or Terminated^;
	  if loop=0 then err:=true;
	end;


  Function Zsendfiledata(var err:boolean):byte;
	(* 転送本体																*)
	(* プログラムの頭部で転送終了を判断しているのは、こちらが全て転送した	*)
	(* 後でも、エラー訂正のためのパケットが来る可能性があるから				*)
	(* （これに気が付くのに物凄く苦労した :-)								*)
	var
	  loop:word;
	  temp:byte;
	  pack:headertype;
	  test:boolean;
	  frame:byte;
	  retry:byte;
	  wk  : word;
	begin
 	  flush;
	  clearline;
	  retry:=10; (* 再送信１０回 *)
	  if not err then repeat
		if eof(f_) or inready then begin
		  repeat
			temp:=Zsyncrecv(err);
			if temp=_RPOS then begin  (* エラーディテクト（位置補正）*)
			  dec(retry);
			  if retry=0 then begin		 (* １０回の間に成功しなかった *)
				err:=true;
			  end
			  else begin
			      	 flush;
			  end;
			end
			else begin
			  if temp<>CAN then retry:=10;
			  case temp of
				_ACK  : begin end; { pass it }
				_SKIP : begin
						Zsendfiledata:=_SKIP;
						exit;
				end;
				_RINIT: begin
						Zsendfiledata:=0;
						exit;
				end
				else err:=true;
			  end;
			end;
		  until (temp in [_ACK,_RPOS]) or err or Terminated^;
		end;
		Zmakepackedheader(_DATA,blocknum,pack);
		Zsendbinheader(pack);
		if not err then repeat
		  {$I-} blockreadm(filebuf_[0],8); {$I+}
                  Status.TranSize:=Status.TranSize+8*128;
		  inc(blocknum,RecCount);
		  if eof(f_) then frame:=_CRCE
		             else frame:=_CRCG;
		  Zsenddata(filebuf_[0],RecCount,frame);
	     //	  if hoststat=cn then
	     //		write(cr+'ZMODEM '+crcstr[crcmode[cn]]+' (',
	     //		RecCount[cn]:4,') Sent #',((blocknum+1023) div 1024):4);
		until (frame<>_CRCG) or inready or err or Terminated^;
		if not err and (frame=_CRCE) then begin
		  Zmakepackedheader(_EOF,blocknum,pack);
		  Zsendbinheader(pack);
	    //	  if hoststat=cn then begin
		//	writeln;writeln(' EOF sent.');
	      //	  end;
		end;
	  until err or Terminated^;
	  inoutres := 0;
	end;


  Function Zsendfile(var err:boolean):byte;
	var
	  loop:byte;
	  temp:headertype;
	  test:boolean;
	  dumy:byte;
	begin
	  if not err then repeat
		dumy:=Zgetheader(temp,blocknum,err);
		case temp[0] of
		  _CAN,_FIN,_ABORT :
                                  err:=true;
		  _CRC	: begin
				  Zmakepackedheader(_CRC,ZcheckfileCRC(blocknum),temp);
				  Zsendhexheader(temp);
		  end;
		  _SKIP : begin
				  Zsendfile:=_SKIP;
				  exit
		  end;
		  _RPOS : begin  (* 初めの位置ぎめ (for ZMODEM resume) *)
				 // cleareofM;
				  seekM2(blocknum,success);
				  if success then begin
					Zsendfile:=Zsendfiledata(err);	{ main transfer }
					exit
				  end
				  else begin
					err:=true;
					Zmakepackedheader(_FERR,0,temp);
					Zsendhexheader(temp);
				  end;
		  end;
		end;
	  until ((temp[0]<>_RINIT) and (temp[0]<>_CRC)) or err or Terminated^;
	end;


  Procedure setZheader;
	var
	  tmp  : string;
	  sdek : string;
	begin
	  clearbuff;
	  tmp := Status.SendFileName + #$00;
	  sdek:=IntToStr(Get_File_Size);	{byte単位でﾌｧﾙｻｲｽﾞ}
	  tmp := tmp + sdek + ' ' + time1970(FileDateToDateTime(fileage(Status.FileName)));
	  tmp := AnsiLowerCase(tmp);		{小文字化(MS漢字はｽﾙｰ)}
	  Move(tmp[1], filebuf_[0], length(tmp));
	end;

 begin  { of Zdownload }

	(* ちょっと、複雑過ぎやしません？ Omen Technology inc. さん....			*)
	(* とても圧縮までサポート出来ない。ここまで来てやる気が半減している :-) *)
//	stringout('ZMODEM ');
//	lineout(_Dlstartstr);
 //	lineout(_Abortstr);

	flush;
//	flowctrl(false);

        if FileExists(Status.FileName) then
          Begin
              lastsent:=0;
              successful := true;
              assignfile(f_,Status.FileName);
              reset(f_);
		blocknum:=0; { not resume }
		retry:=4;  (* タイムオーバーの為に４回待つ *)

		repeat
		  temp:='rz'+#13;
		  Zsendstring(temp);
		  Zmakepackedheader(_RQINIT,0,pack);
		  Zsendhexheader(pack);
		  rslt:=Zgetrecvinfo(successful);
		  successful:=not successful;
		  dec(retry);
		until (rslt=CAN) or (retry=0) or successful or Terminated^;

		if successful and (rslt=_RINIT) then
                 begin
               	    successful:=false;
		    setZheader;
		    Zmakepackedheader(_FILE,0,pack);
		    pack[4]:=_CRESUM;
		    Zsendbinheader(pack);
		    Zsenddata(filebuf_[0],128,_CRCW);
		    successful:=false;
		    rslt:=Zsendfile(successful); { main }
		    successful:= not successful; (* ｲﾝｼﾞｹｰﾀｰは ｴﾗｰだからひっくり返す *)
		    if not successful then
                        Zcancel;
		 end
		  else 	(* ﾀｲﾑｵｰﾊﾞｰ（ZMODEM の起動が遅かった）又は ｷｬﾝｾﾙ *)
		    successful:=false;
	      closeFile(F_);
	  end
	  else
           begin
		Zcancel;
                flush;
//		flowctrl(true);
		waiting(1000);
//		lineout(cr + _^.lf+'Can''t found '+dir+_DL(fls)[i].lfnam);
		successful:=false;
	   end;

	if successful then
          begin
             successful:=Zendsend;
             temp:='OO';
             Zsendstring(temp);
	  end;

 //	flowctrl(true);
	waiting(1000);

 end;

{ ------------------- }

Procedure TFileTran.waiting(tcount: integer);
(*tcountだけwaitする。n秒なら waiting(n*seccnt) *)
  var begcnt : integer;
  begin
	begcnt := gettickcount;
	while (gettickcount-begcnt < tcount) and not(Terminated^) do
                 Sleep(10);
  end;


Procedure TFileTran.xmitchar(ch: char);
(*シリアル出力ポートがレディならchを出力する（ローカルモードなら出力しない）
  Terminated^ なら何もせずに戻る *)
  begin
    if not(Terminated^) then write(@ch,1);

  end;



Function TFileTran.receiveblock(var rpt; len:integer) : word;
var
 recvlen:integer;
 i      : integer;
 p:pchar;
begin

  p:=@rpt;

  if (wp<>rp) and (Len>0)  then
     begin
       For i:=0 to len-1 do
        begin
         p[i]:=RecvBuf[rp];
         rp := (rp+1) mod High(RecvBuf);
         if wp=rp then
          begin
            result:=i+1;
            exit;
          end;
        End;
       Result:=len;
     End
     else Result:=0;
end;

Procedure TFileTran.stringout(s:String);
Begin

      TMtbbs(FOwner).Write(Pchar(s),Length(s));


End;


Function TFileTran.RecvChar: Char;
begin

      if wp=rp then
         While (Rp=Wp) and (Not Terminated^) do
            Sleep(50);//Application.ProcessMessages;

      result:=RecvBuf[rp];
      Rp := (Rp+1) mod High(RecvBuf);

end;
Function TFileTran.Get_File_Size : integer;
Var
    Fs: File of Byte;
begin
    if Fileexists(Status.FileName) then Begin
       AssignFile(Fs,Status.FileName);
       Reset(Fs);
       Result := FileSize(Fs);
       CloseFile(Fs);
     end
     Else Result:=0;

End;

Procedure TFileTran.blockreadM(var filebrock; n:word);
Begin
  BlockRead(F_,FileBrock,n*128,RecCount)
End;

Procedure TFileTran.blockreadM2(var filebrock; n:word);
Begin
  BlockRead(f_,FileBrock,n,reccount);
End;

Procedure TFileTran.flush;
begin
	rp:=wp;
end;

Procedure TFileTran.seekM2(n:longint; var rslt : boolean);
  begin

	  {$I-}
	  seek(F_,n);
	  {$I+}
	  rslt := IOResult=0;

  end;

end.
