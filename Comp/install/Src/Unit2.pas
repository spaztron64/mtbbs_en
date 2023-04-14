unit BoardConv;
Uses Windows, SysUtils, Classes;


interface
Type

    TBoardInfo =
      Record
        Kind  : Integer;
        Title : TDateTime;
        WriteURL : String;
      End;

    TBoardMessageInfo =
      Record
        MessageNo : Integer;
        DateTime  : TDateTime;
        FromName  : String[20];
        FromMail  : String[40];
        Title     : String[80];
      End;

    TOnGetBoardInfo = Procedure(Sender : TObject;Info : TBoardInfo) of object;
    TOnGetMessage = Procedure(Sender : TObject;MesInfo: TBoardInfo;mes : string) of object;


 TBoardConv = class(TComponent)
  private

     FHTML : string;
     FboardKind : Integer;

     FOnGetBoardInfo : TOnGetBoardInfo;
     FOnGetMessage   : TOnGetMessage;

     Rp : integer;
     UCHTML : string;


  protected
  public

    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;

  published

    property HTML   : String Read  FHTML
                            write  FHTML;

    property BoardKind   : Integer Read  FBoardKind
                                  write  FBoardKind;

    property OnGetBoardInfo : TOnGetBoardInfo read FOnGetBoardInfo
                                             write FOnGetBoardInfo;
    property OnGetMessage   : TOnGetMessage read FOnGetMessage
                                           write FOnGetMessage;


  end;


implementation

Function TBoardConv.Search(start : integer;searchstr : string):integer;
var
   i,j : integer;
   b: boolean;
Begin
  result := 0;
    for i:=start to length(UCHTML) do
      if UCHTML[i]=searchstr[1] then
       Begin
         b := true;
         for j:=2 to length(searchstr) do
             if  UCHTML[i+j-1]<>searchstr[j] then
               b := false;
         if b then
           Begin
             result := i;
             break;
           End;
       End;
End;

Function TBoardConv.Move(searchstr : string):boolean;
Begin

     rp := Search(rp,searchstr);
     result := rp>0;

End;

Procedure TBoardConv.MoveToTag(searchstr : string):boolean;
Begin
     rp := Search(rp,'<'+searchstr);
     result := rp>0;

End;


Function TBoardConv.GetTagText(s : string): string;
Begin
     Move('<'+s);
     Move('>');
     inc(rp);
     result := copy(HTML,rp,search(rp,'</')-rp);
End;

Function TBoardConv.GetLinkURL: string;
Begin
     Move('<A ');
     Move('HREF="');
     rp := rp + 6;
     result := copy(HTML,rp,search(rp,'"')-rp);
End;

Function TBoardConv.GetFormActionURL: string;
Begin
     Move('<FORM ');
     Move('ACTION=');
     rp := rp + 7;
     result := copy(HTML,rp,search(rp,'"')-rp);
End;

Function TBoardConv.KanjiStrToDateTime(S : string): TDateTime;
Var
  year,dumyy : integer;
Begin
    year := Get('”N');
    if year=0 then
       DecodeDate(Now,
    EncodeDate(year,Get('ŒŽ'),Get('“ú')

End;



Procedure TBoardConv.Conv;
Var
   MesInfo : TBoardMessageInfo;
   Mes     : String;
   s : string;
Begin


     Rp := 0;
     UCHTML := UpperCase(FHTML);

     BoardInfo.Title   := GetTagText('TITLE');
     Conv_BoardComment := GetTagText('P');
     Move('“Še');
     Conv_WriteURL     := GetFormActionURL;

     While Move('“ŠeŽÒF') do
      begin
           MesInfo.FromName := GetTagText('A');
           MoveBack('“ŠeŽÒF');
           MesInfo.FromMail := GetLinkURL('A');
           MesInfo.DateTime := KanjiStrToDateTime(GetTagText('FONT'));
           Copy(a,Pos('“Še“úF',s)+8,98);
           Copy(a,Pos(' ',s)+8,98);




           MoveToTag('BLOCKQUOTE');
           Mes := GetTagText('FONT');
      end;

End;





end.
