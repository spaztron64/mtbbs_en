unit doit;
(*$o- *)
(*@/// interface *)
interface
uses
  tcpip,sysutils,classes;

const
  nr_of_comics=19;
(*@///   comics:array[0..nr_of_comics-1,1..3] of string = (); *)
comics:array[0..nr_of_comics-1,1..3] of string =
  (
   ('dilbert','dt','Dilbert'),
   ('peanuts','pe','Peanuts'),
   ('reality','rc','Reality Check'),
   ('nancy','nc','Nancy'),
   ('buckets','bu','The Buckets'),
   ('robotman','rm','Robotman'),
   ('tommy','tm','Tommy'),
   ('betty','bt','Betty'),
   ('committed','cd','Committed'),
   ('hedge','oh','Over the hedge'),
   ('bignate','bn','Big Nate'),
   ('jumpstart','jt','Jump Start'),
   ('roseisrose','rr','Rose is Rose'),
   ('luann','lu','Luann'),
   ('arlonjanis','aj','Arlo && Janis'),
   ('marmaduke','ma','Marmaduke'),
   ('drabble','dr','Drabble'),
   ('alleyoop','ao','Alleyoop'),
   ('bornloser','bl','Born Loser')
   );
(*@\\\0000001601*)
type
  t_trace = procedure(const s:shortstring);
const
  trace: t_trace = NIL;

procedure action(mode:byte; const target:string; http:T_HTTP);
(*@\\\0000000D39*)
(*@/// implementation *)
implementation

(*@/// function search_for_comic(const s:string; mode:byte):string; *)
function search_for_comic(const s:string; mode:byte):string;
var
  t: integer;
begin
  t:=pos('href="/comics/'+comics[mode,1]+'/archive/images/',lowercase(s));
  if t=0 then
    result:=''
  else begin
    result:=copy(s,t+length('href="/comics/'+comics[mode,1]+'/archive/images/'),length(s));
    result:=copy(result,1,pos('gif',result)+2);
    end;
  end;
(*@\\\*)
(*@/// function search_for_archive(const s:string; mode:byte):string; *)
function search_for_archive(const s:string; mode:byte):string;
var
  t: integer;
begin
  t:=pos('href="/comics/'+comics[mode,1]+'/archive/'+comics[mode,1],lowercase(s));
  if t=0 then
    result:=''
  else begin
    result:=copy(s,t+length('href="'),length(s));
    result:=copy(result,1,pos('"',result)-1);
    end;
  end;
(*@\\\0000000501*)
(*@/// function file_exists(const s:string; const path:string; mode:byte):boolean; *)
function file_exists(const s:string; const path:string; mode:byte):boolean;
begin
  try
    result:=fileexists(path+comics[mode,2]+s+'.gif');
  except
    result:=false;
    end;
  end;
(*@\\\0000000401*)
(*@/// procedure action(mode:byte; const target:string; http:T_HTTP); *)
procedure action(mode:byte; const target:string; http:T_HTTP);
var
  temp,list_archive,list_comic: TStringList;
  i: integer;
  s,url: string;
  nocache: boolean;
(*@/// procedure search(stream:TStream; no_archive: boolean); *)
procedure search(stream:TStream; no_archive: boolean);
var
  i:integer;
begin
  temp:=TStringList.Create;
  temp.loadfromstream(http.stream);
  for i:=temp.count-1 downto 0 do begin
    s:=temp.strings[i];
    if not no_archive then begin
      url:=search_for_archive(s,mode);
      if url<>'' then
        list_archive.add(url);
      end;
    url:=search_for_comic(s,mode);
    if url<>'' then
      list_comic.add(url);
    end;
  temp.free;
  end;
(*@\\\000000011B*)
begin
  list_archive:=TStringList.Create;
  list_comic:=TStringList.Create;
  nocache:=http.nocache; (* remember it since it is overwritten here *)
  http.url:='http://www.unitedmedia.com/comics/'+comics[mode,1]+'/';
  http.nocache:=true;   (* this one always uncached since it changes daily *)
  if assigned(trace) then trace('Getting '+http.url);
  http.action;
  search(http.stream,false);
  http.url:='http://www.unitedmedia.com/comics/'+comics[mode,1]+'/archive/';
  http.nocache:=true;   (* this one always uncached since it changes daily *)
  if assigned(trace) then trace('Getting '+http.url);
  http.action;
  search(http.stream,false);
  for i:=list_archive.count-1 downto 0 do begin
    s:=list_archive.strings[i];
    if file_exists(copy(s,length(s)-10,6),target,mode) then
      list_archive.delete(i);
    end;
  http.nocache:=nocache;
  for i:=list_archive.count-1 downto 0 do begin
    http.url:='http://www.unitedmedia.com'+list_archive.strings[i];
    if assigned(trace) then trace('Getting '+http.url);
    http.action;
    search(http.stream,true);
    end;
  for i:=list_comic.count-1 downto 0 do begin
    s:=list_comic.strings[i];
    if file_exists(copy(s,3,6),target,mode) then
      list_comic.delete(i)
    else begin
      http.url:='http://www.unitedmedia.com/comics/'+comics[mode,1]+'/archive/images/'+s;
      if assigned(trace) then trace('Getting '+http.url);
      http.action;
      if http.stream.size>0 then
        TMemorystream(http.stream).savetofile(target+copy(s,1,8)+copy(s,pos('.',s),4));
      end;
    end;
  list_archive.free;
  list_comic.free;
end;
(*@\\\0000000139*)
(*@\\\0000000639*)
end.
(*@\\\0000000401*)
