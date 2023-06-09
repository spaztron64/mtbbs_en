unit MaskSearch;

interface
uses Classes,SysUtils,Windows,ShellAPI;

// String routines
procedure GetShellFileInfo (FileName :TFileName; var ShFileInfo :TShFileInfo);
function SizeStr (Size,Typ :integer ) :string;
function AttrStr(Attr:integer):string;
function GetTimeModified(a:tfiletime):string;

// File Search utility
procedure setfilters (a:string;grep_list:tstringlist;findfile : boolean; MatchCase :boolean);
function cmpmask(a:string;grep_list:tstringlist;findfile : boolean; MatchCase :boolean):boolean;
function cmpfile(a:string;grep_list:tstringlist; MatchCase :boolean):boolean;

implementation

//
// STRING ROUTINES
//
// Get Shell Info for the specified file
procedure GetShellFileInfo (FileName :TFileName; var ShFileInfo :TShFileInfo);
begin
  ShGetFileInfo (PChar(FileName),0,ShFileInfo,SizeOf (ShFileInfo),
                 shgfi_SysIconIndex or shgfi_Icon or
                 shgfi_DisplayName or shgfi_TypeName or
                 shgfi_SmallIcon);
end;

// Convert Size for Sort
function SizeStr (Size,Typ :integer ) :string;
begin
  if (Typ and faDirectory) = faDirectory then
    Result := ''
  else
    Result := Format ('%10d',[Size]);
end;

// returns a string with file attributes (DRSH)
function AttrStr(Attr:integer):string;
begin
  Result := '';
  if (Attr and file_attribute_Directory)  > 0 then Result := Result + 'D';
  if (Attr and file_attribute_Archive)    > 0 then Result := Result + 'A';
  if (Attr and file_attribute_Readonly)   > 0 then Result := Result + 'R';
  if (Attr and file_attribute_System)     > 0 then Result := Result + 'S';
  if (Attr and file_attribute_Hidden)     > 0 then Result := Result + 'H';
//  if (Attr and FILE_ATTRIBUTE_COMPRESSED) > 0 then Result := Result + 'C';
  if (Attr and file_attribute_Temporary)  > 0 then Result := Result + 'T';
end;

// File Date & Time
function GetTimeModified(a:tfiletime):string;
// This function retrieves the last time, the given file was written to disk
var
  mtm :TSystemTime;
  at  :TFileTime;
  ds,ts:ShortString;
begin
  // Time must get converted, else there is an error of one hour
  // Does anybody know what this function does ?
  // Maybe something like summertime/wintertime (or what you call it out of Germany) ?
  filetimetolocalfiletime(a,at);
  filetimetosystemtime(at,mtm);
  SetLength(ds, GetDateFormat(LOCALE_USER_DEFAULT, 0, @mtm, NIL, @ds[1], 255) - 1);
  SetLength(ts, GetTimeFormat(LOCALE_USER_DEFAULT, time_noseconds, @mtm, NIL,
                                               @ts[1], 255)  - 1);
  Result:=ds+'  '+ts;
end; // End getmod

function CaseAware (S :string; Match :boolean) :string;
begin
  if Match then
    Result := S
  else Result := AnsiLowerCase(S);
end;
//
// Original File Search Routine by Marcus Stephany
//
procedure setfilters (a:string;grep_list:tstringlist;findfile : boolean; MatchCase :boolean);
// fills the grep_list with the parts of 'a' (divided by ',' or ';')
// findfile describes whether to use for find files or text in files
// + aml modified : Match Case

var ct : integer;
begin
     grep_list.clear;
     grep_list.sorted := false;
     if a = '' then begin
        grep_list.add('*');
        exit;
     end;
     // replace all ',' by ';'
     ct := pos (',',a);
     while ct > 0 do begin
           a[ct] := ';';
           ct:=pos(',',a);
     end;
     if a[length(a)] <> ';' then a:=a+';';
     // divide the string
     ct := pos(';',a);
     while ct > 0 do begin
           grep_list.add(CaseAware(trim(copy(a,1,ct-1)),MatchCase));
           a:=copy(a,ct+1,maxint);
           ct:=pos(';',a);
     end;
     // replace a 'xxx' term (without a '.') with '*xxx*' (for compatibility
     // with win95's file-search-dialog)
     // only if findfile
     if findfile then begin
      if grep_list.count > 0 then for ct := 0 to pred(grep_list.count) do begin
        a:=grep_list[ct];
        if (pos('*',a) = 0) and (pos('?',a) = 0) and (pos('.',a) = 0) then
           grep_list[ct]:='*'+a+'*'
        else
        if pos('.',a) = 0 then if a[length(a)] <> '*' then
           grep_list[ct]:=a+'*';
      end;
     end;
     grep_list.sorted := true;
     grep_list.duplicates := dupignore;
end;

function cmpmask1(a,b:string;findfile:boolean):boolean;
// tests whether the string 'a' fits to the search mask in 'b'
var sr             : string;
    ps1,ps2,ps3    : integer;
    dontcare       : boolean;
    onechar        : char;
    tmp_list       : tstrings;
begin
     result := true;
     if b = '*' then exit; // fits always
     if b = '*.*' then if pos('.',a) > 0 then exit; // fits, too
     if (pos('*',b) = 0) and (pos('?',b)=0) then
        if not findfile then begin
           if pos(b,a) > 0
              then exit;
           // searched text was found (searchstring IN text)
        end else
           if a=b then exit;
           // searched file was found (searchstring IS text)


     result   := false;
     if b = '' then exit;
     try
        tmp_list := tstringlist.create;
        // divide partial strings ('?','*' or text) to tmp_list
        repeat
              onechar := b[1];
              if (onechar='*') or (onechar='?') then begin
                 tmp_list.add(onechar);
                 delete(b,1,1);
              end else begin
                  ps1 := pos('?',b);
                  if ps1 = 0 then ps1 := maxint;
                  ps2 := pos('*',b);
                  if ps2 = 0 then ps2 := maxint;
                  if ps2 > ps1 then ps2 := ps1;
                  tmp_list.add(copy(b,1,ps2-1));
                  b:=copy(b,ps2,maxint);
              end;
        until b = '';
        // now compare the string with the partial search masks
        dontcare := false;
        ps2      := 1;
        if tmp_list.count > 0 then for ps1 := 0 to pred(tmp_list.count) do begin
           sr := tmp_list[ps1];
           if sr = '?' then begin
              inc(ps2,1);
              if ps2 > length(a) then exit;
           end else
           if sr = '*' then
              dontcare := true
           else begin
                if not dontcare then begin
                   if copy(a,ps2,length(sr)) <> sr then exit;
                   dontcare := false;
                   ps2 := ps2+length(sr);
                end else begin
                   ps3:= pos(sr,copy(a,ps2,maxint));
                   if ps3 = 0 then exit;
                   ps2 := ps3+length(sr);
                   dontcare := false;
                end;
           end;
        end;
        if not dontcare then if ps2 <> length(a)+1 then exit;
        result := true;
     finally
            tmp_list.free;
     end;
end;

function cmpmask(a:string;grep_list:tstringlist;findfile:boolean; MatchCase :boolean):boolean;
// tests whether the string 'a' fits to the search masks in grep_list
var ct : integer;
begin
     result := true;
     if a = '' then exit; // if no search string, the always return TRUE
     a:=CaseAware(a,MatchCase);
     result:=false;
     if (grep_list = nil) or (grep_list.count < 1) then exit;
     result := true;
     for ct := 0 to pred(grep_list.count) do
         if cmpmask1(a,grep_list[ct],findfile) then exit; // compare with the whole
                                                          // grep_list until one fits
     result := false;
end;

function cmpfile(a:string;grep_list:tstringlist; MatchCase :boolean):boolean;
// tests whether a file's contents fit to the specified mask;
var
   fl:string;
   ts:tfilestream;
   ct:integer;
begin
     result := true;
     // different handling between filefind an textfind
     // true if no or each text is wanted
     if (grep_list.count < 1) or (grep_list[0] = '*') then exit;

     result := false;
     try
       ts := tfilestream.create(a,fmopenread or fmsharedenynone);
     except
       exit;
     end;
     try
       setlength(fl,ts.size+1);
       ts.position := 0;
       ts.read(fl[1],ts.size);
       ts.free;
       result := cmpmask(CaseAware(fl,MatchCase),grep_list,false,MatchCase);
     finally
       setlength(fl,0);
     end;
end;


end.
