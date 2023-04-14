unit sjisconv;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;


Function ToSjis(sz:ansistring):ansistring;

implementation
var
  kio, sflg, cfg : char;
  cfg2 : array[0..9] of char;
  jmode, rcflg, url : integer;

//sz‚Ì•¶š—ñ‚Ì”»•Ê  •Ô‚è’l jmode:=  0:JIS, 1:EUC
function fgetc(sz:AnsiString; var fp:integer) : integer;
begin
  fgetc := ord(sz[fp]);
  inc(fp);
end;

function fgets(sz:AnsiString) : ansistring;
var
  fp,i : integer;
  j,j1,k,k2,ks1,ks2,ks3 : integer;
  c:AnsiString;
begin
  c:='';
  fp:=1;

  k:=ord(cfg);
  k2:=ord(cfg);
  i:=0;
  cfg:=#0;
  ks1:=jmode;
  ks2:=0;
  ks3:=0;
  if k=0 then jmode:=0; // 7bit JIS MODE
  while (i<=length(sz)) do begin
    if k<>0 then begin
      k:=ord(cfg2[i]);
      if k=0 then
        j:=fgetc(sz,fp)
      else
        j:=k;
    end else
      j:=fgetc(sz,fp);
    if (j=0) or (j=$1a) then begin
      rcflg:=0;
      if i=0 then
        fgets:=#0;
      break;
    end;
    if (j=ord('&')) and (url=1) then j:=10;
    if (j=ord('+')) and (url=1) then j:=32;
    if (j=ord('%')) and (url=1) then begin
      j:=fgetc(sz,fp);
      j1:=fgetc(sz,fp);
      if (j >=ord('0')) and (j <=ord('9')) then j  := j - ord('0');
      if (j1>=ord('0')) and (j1<=ord('9')) then j1 := j1- ord('0');
      if (j >=ord('A')) and (j <=ord('F')) then j  := j - ord('A');
      if (j1>=ord('A')) and (j1<=ord('F')) then j1 := j1- ord('A');
      if (j >=ord('a')) and (j <=ord('f')) then j  := j - ord('a');
      if (j1>=ord('a')) and (j1<=ord('f')) then j1 := j1- ord('a');
      j:=j*16+j1;
    end;
    if j=$00a then begin
      if (rcflg=1) and (i=0) then begin
        rcflg:=0;
        continue;
      end;
      rcflg:=0;
      break;
    end;
    if j=$00d then begin
      rcflg:=1;
      break;
    end else
      rcflg:=0;

    c:=c+chr(j and $ff);
    inc(i);

    if j> $07f then begin
      if ks2<>2 then
        if (ks2=1) and (j>$0a0) and (j<$0e0) then
          ks2:=2
        else
          ks2:=0;
      if j=$08e then begin
        ks2:=1;
        ks3:=1;
      end;
      if (jmode=0) and (k2=0) then
        jmode:=1;
      if (j<$0a0) and (j<>$08e) and (k2=0) then
        jmode:=2;
    end;
  end;

  if (j=0) or (i<length(sz)) then
    c:=c+#0
  else
    cfg:=chr(j and $ff);
  c:=c+#0;
  if (jmode=1) and (k2=0) then begin
    i:=1;
    while c[i]<>#0 do begin
      if (c[i]>#$07f) and (c[i+1]=#0) then begin
        jmode:=2;
        break;
      end;
      if (c[i]>#$07f) and (c[i+1]<>#0) then
        inc(i);
      inc(i);
    end;
  end;

  if (jmode=1) and (ks2=0) and (ks3=1) and (k2=0) then
    jmode:=2;
  if k2<>0 then
    jmode:=ks1;
  cfg2[0]:=#0;

  fgets := c;
end;


//‚i‚h‚r|‚r‚i‚h‚r•ÏŠ·
function jis_sjis(var a:array of char):integer;
var
  i,j,ia,ib:integer;
begin
  if (cfg<>#0)and((a[0]=#0)or(a[1]=#0)or(a[2]=#0)or(a[3]=#0)or(a[4]=#0)) then begin
    i:=0;
    while a[i]<>#0 do begin
      cfg2[i]:=a[i];
      inc(i);
    end;
    cfg2[i]:=#0;
    a[0]:=#0;
    jis_sjis:=0;
    exit;
  end;
  j:=0;
  a[0]:=chr(ord(a[0]) and $7f);
  if (a[0]=#14)or(a[0]=#15) then begin
    if a[0]=#14 then begin
      sflg:=#$80;
      kio:=#0;
    end else begin
      sflg:=#$00;
      kio:=#0;
    end;
    i:=1;
    while (a[i]<>#0)and(a[i]<>#$0a) do begin
      a[i-1]:=a[i];
      inc(i);
    end;
    a[i-1]:=#0;
    jis_sjis:=0;
    exit;
  end;

  if a[0]=#$1b then begin
    a[1]:=chr(ord(a[1]) and $7f);
    a[2]:=chr(ord(a[2]) and $7f);
    if (a[1]='$')and((a[2]='@')or(a[2]='B')) then begin
      sflg:=#00;
      kio:=#$80;
      j:=1;
    end;
    if a[1]='(' then begin
      if (a[2]='H')or(a[2]='B')or(a[2]='J') then begin
        sflg:=#00;
        kio:=#$00;
        j:=1;
      end;
      if a[2]='I' then begin
        sflg:=#$80;
        kio:=#$00;
        j:=1;
      end;
    end;
    if j=1 then begin
      j:=0;
      while a[j+3]<>#0 do begin
        a[j]:=a[j+3];
        inc(j);
      end;
      a[j]:=#0;
      jis_sjis:=0;
      exit;
    end;
  end;

  if kio=#0 then begin
    if sflg<>#0 then
      if (a[0]>#$20)and(a[0]<#$60) then
        a[0]:= chr(ord(a[0]) or $80);
    jis_sjis:=1;
    exit;
  end;

  if (a[0]<#$21)or(a[0]>#$7e) then begin
    jis_sjis:=1;
    exit;
  end;
  i:=((ord(a[0])-$21)*$5e)+ord(a[1])-$21;
  ia:=i div $bc;
  ib:=i mod $bc;
  ia:=ia+$81;
  if ia>$9f then ia:=ia+$40;
  ib:=ib+$40;
  if ib>$7e then inc(ib);
  a[0]:=chr(ia);
  a[1]:=chr(ib);
  jis_sjis:=2;
  exit;
end;

//‚d‚t‚b|‚r‚i‚h‚r•ÏŠ·
function euc_sjis(var a:array of char):integer;
var
  i,j,ia,ib:integer;
begin
  if (cfg<>#0)and((a[0]=#0)or(a[1]=#0)or(a[2]=#0)or(a[3]=#0)or(a[4]=#0)) then begin
    i:=0;
    while a[i]<>#0 do begin
      cfg2[i]:=a[i];
      inc(i);
    end;
    cfg2[i]:=#0;
    a[0]:=#0;
    euc_sjis:=0;
    exit;
  end;
  if a[0]<#$80 then
    if (a[0]=#$1b)and(a[1]=#$28) then
      if (a[1]='I')or(a[2]='J') then begin
        if a[2]='I' then
          sflg:=#$80
        else
          sflg:=#0;
        i:=3;
        while (a[i]<>#0)and(a[i]<>#$0a) do begin
          a[i-3]:=a[i];
          inc(i);
        end;
        a[i-3]:=#0;
        euc_sjis:=0;
        exit;
      end;
  if (a[0]=#14)or(a[0]=#15) then begin
    if a[0]=#14 then begin
      sflg:=#$80;
    end else begin
      sflg:=#$00;
    end;
    i:=1;
    while (a[i]<>#0)and(a[i]<>#$0a) do begin
      a[i-1]:=a[i];
      inc(i);
    end;
    a[i-1]:=#0;
    euc_sjis:=0;
    exit;
  end;

  if sflg<>#0 then begin
    if (a[0]>#$20)and(a[0]<#$60) then
      a[0]:=chr(ord(a[0]) or $80);
    euc_sjis:=1;
    exit;
  end;

  if (a[0]=#$8e)and(a[1]>#$a0)and(a[1]<#$e0) then begin
    i:=1;
    while (a[i]<>#0)and(a[i]<>#$0a) do begin
      a[i]:=a[i+1];
      inc(i);
    end;
    a[i]:=#0;
    euc_sjis:=1;
    exit;
  end;

  if (a[0]<#$a1)or(a[0]>#$fe) then begin
    a[0]:=chr(ord(a[0]) and $7f);
    euc_sjis:=1;
    exit;
  end;

  i:=((ord(a[0]) and $7f - $21)*$5e)+ord(a[1]) and $7f - $21;
  ia:=i div $bc;
  ib:=i mod $bc;
  ia:=ia+$81;
  if ia>$9f then ia:=ia+$40;
  ib:=ib+$40;
  if ib>$7e then inc(ib);
  a[0]:=chr(ia);
  a[1]:=chr(ib);
  euc_sjis:=2;
  exit;
end;

//‚d‚t‚bC‚i‚h‚rƒR[ƒh©“®”F¯‚r‚i‚h‚rƒRƒ“ƒo[ƒg
function ToSjis(sz:ansistring):ansistring;
var
  i:integer;
begin
  if length(sz)=0 then begin
    ToSjis:='';
    exit;
  end;
  cfg:=#0;
  rcflg:=0;
  jmode:=0;
  fgets(sz);
  case jmode of
    0: begin
         i:=1;
         while sz[i]<>#0 do begin
           i:=i+jis_sjis(sz[i]);
         end;
       end;
    1: begin
         i:=1;
         while sz[i]<>#0 do begin
           i:=i+euc_sjis(sz[i]);
         end;
       end;
  end;
  i:=1;
  if length(sz)>0 then begin
    while sz[i]<>#0 do inc(i);
    ToSjis:=copy(sz,1,i-1);
  end else
    ToSjis:='';

end;


end.
