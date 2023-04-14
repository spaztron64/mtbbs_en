unit tcpip;

{ Copyright 1997 Andreas Hörstemeier              Version 0.2   1997-06-30   }
{ this component is public domain - please check the file readme.txt for     }
{ more detailed info on usage and distributing                               }

(*@/// interface *)
interface
  (*$x+ *)

(*@/// uses *)
uses
  sysutils,
  classes,
  controls,
  forms,
  winsock,
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  windows,
(*$endif *)
  messages,
  ip_misc;
(*@\\\*)

type
  t_socket_state = (invalid,valid,connected,state_unknown);
  t_timemode     = (tzUTC,tzLocal);
  t_ftp_mode     = (tftp_download,tftp_upload,tftp_getdir);
  t_filetype     = (ft_none, ft_dir, ft_file, ft_link);
  t_lpr_types    = (lp_plain, lp_ascii, lp_dvi, lp_plot, lp_ditroff, lp_ps,
                    lp_pr, lp_fortran, lp_troff, lp_raster, lp_cif);
  t_encoding     = (ec_base64, ec_quotedprintable, ec_none);
  TTraceLevel    = (tt_proto_sent, tt_proto_get, tt_socket);
(*@///   t_filedata=record ... end; *)
t_filedata=packed record
  filetype: t_filetype;
  size: integer;
  name: string;
  datetime: TDateTime;
  end;
(*@\\\*)
  ETcpIpError=class(Exception);
(*@///   ESocketError=class(ETcpIpError) *)
ESocketError=class(ETcpIpError)
  errornumber: word;
  constructor Create(number:word);
  end;
(*@\\\0000000301*)
(*@///   EProtocolError=class(ETcpIpError) *)
EProtocolError=class(ETcpIpError)
  errornumber: word;
  protocoll: string;
  constructor Create(const proto,Msg:String; number:word);
  end;
(*@\\\0000000401*)
(*@///   EProtocolBusy=class(ETcpIpError) *)
EProtocolBusy=class(ETcpIpError)
  constructor Create;
  end;
(*@\\\0000000201*)

  TTraceProc = procedure (const s:string; level:TTraceLevel) of object;
  TDataTransferProc = procedure (Sender:TObject; mode: t_ftp_mode; bytes: integer) of object;
  TFTPActionCompleteProc = procedure (Sender:TObject; mode: t_ftp_mode) of object;

  { The base component }
(*@///   T_TcpIp = class(TComponent) *)
T_TcpIp = class(TComponent)
protected
  f_handle: THandle;
  f_Socket: tsocket;
  f_hostname: string;
  f_tracer: TTraceProc;
  f_socket_number: smallint;
  ip_address: longint;  (* Network order! *)
  f_eof: boolean;
  f_newdata: boolean;
  f_stream: TStream;
  f_buffer: pointer;
  f_async: boolean;
  f_logged_in: boolean;
  procedure WndProc(var Msg : TMessage); virtual;
  function Create_Socket:TSocket;
  procedure connect_socket(var socket:TSocket; Socket_number:smallint;ip_address:longint);
  procedure bind_socket(var socket:TSocket; out_port_min,out_port_max: word);
  procedure open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); virtual;
  procedure open_socket_in(var socket:TSocket; Socket_number:smallint;ip_address:longint);
  procedure close_socket(var socket:TSocket);
  procedure close_socket_linger(var socket:TSocket);
  function accept_socket_in(socket:TSocket; var SockInfo:TSockAddr):TSocket;
  function socket_state(socket:TSocket):T_Socket_State;
  function Socket_by_name(const service:string):smallint;
  function read_line(f_socket:TSocket):string;
  procedure read_var(f_socket:TSocket; var buf; size:integer; var _ok:integer);
  procedure write_buf(f_socket:TSocket; const buf; size:integer);
  procedure write_s(f_socket:TSocket; const s:string);
  procedure SetStream(value:TStream); (* for the property write of f_stream *)
  procedure action; VIRTUAL;
{   property Async:boolean read f_async write f_async default false; }
  procedure SendCommand(const s:string); VIRTUAL;
public
  procedure Login; virtual;
  procedure Logout; virtual;
  property OnTrace:TTraceProc read f_tracer write f_tracer;
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  function eof(f_socket:TSocket):boolean; VIRTUAL;
  end;
(*@\\\0000002901*)

  { Finger client and demon      // RFC 1288 }
(*@///   T_Finger = class(T_TcpIp) *)
T_Finger = class(T_TcpIp)
protected
  f_user: string;
public
  constructor Create(Aowner:TComponent); override;
  property stream: TStream read f_stream;
  procedure action; override;
published
  property Hostname: string read f_hostname write f_hostname;
  property User: string read f_user write f_user;
  end;
(*@\\\0000000118*)
(*@///   T_Fingerd = class(T_TcpIp) *)
type
(*@///   TFingerInfo=record *)
TFingerInfo=record
  hostname: string;
  address: longint;
  request: string;
  end;
(*@\\\0000000203*)
  TFingerRequest=procedure (Sender:TObject; FingerInfo:TFingerInfo) of object;

T_Fingerd = class(T_TcpIp)
protected
  f_fingerrequest: TFingerRequest;
  f_answer: TStringList;
  procedure WndProc(var Msg : TMessage); override;
  procedure SetAnswer(Value: TStringList);
  procedure do_action; virtual;                    (* The real action *)
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;                      (* Only to set up *)
published
  property OnFingerRequest:TFingerRequest read f_fingerrequest write f_fingerrequest;
  property Answer: TStringList read f_answer write SetAnswer;
  end;
(*@\\\0000000503*)

  { HTTP and FTP - the file transfer protocols }
(*@///   T_HTTP = class(T_TcpIp)          // RFC 1945 (V1.0), RFC 2068 (V1.1) *)
T_HTTP = class(T_TcpIp)
protected
  f_url: string;
  f_path: string;   (* The real request string, calculated internally *)
  f_proxy: string;
  f_sender: string;
  f_reference: string;
  f_agent: string;
  f_nocache: boolean;
  f_status_nr: integer;
  f_status_txt: string;
  f_size: integer;
  f_type: string;
  f_author: string;
  f_do_author: TStringList;
  f_content_post: string;
  procedure GetHead;
  procedure GetBody;
  procedure sendrequest(const method,version: string);
  procedure getanswer;
public
  property stream: TStream read f_stream write SetStream;
  property content_size: integer read f_size;
  property content_type: string read f_type;
  property status_number: integer read f_status_nr;
  property status_text: string read f_status_txt;
  procedure action; override;                          (* the GET method *)
  procedure Post;                                      (* the POST method, untested!  *)
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure DoBasicAuthorization(const username,password:string);
  property AuthorizationRequest: TStringList read f_do_author;
  property Authorization: string read f_author write f_author;
published
  property URL: string read f_url write f_url;
  property Proxy: string read f_proxy write f_proxy;
  property Sender: string read f_sender write f_sender;
  property Agent: string read f_agent write f_agent;
  property Reference: string read f_reference write f_reference;
  property NoCache: boolean read f_nocache write f_nocache;
  property ContentTypePost: string read f_content_post write f_content_post;
  property OnTrace;
  end;
(*@\\\0000000C01*)
(*@///   T_FTP = class(T_TcpIp)           // RFC 959 *)
T_FTP = class(T_TcpIp)
protected
  f_url: string;
  f_status_nr: integer;
  f_status_txt: string;
  f_user: string;
  f_password: string;
  f_comm_socket: tsocket;
  f_passive: boolean;
  f_port: word;
  f_mode: t_ftp_mode;
  f_mode_intern: t_ftp_mode;
  f_cur_dir: TStringList;
  f_cur_dir_index: integer;
  f_size: integer;
  f_busy: boolean;
  f_onaction: TFTPActionCompleteProc;
  f_ondata_got: TDataTransferProc;
  f_dir_stream: TMemoryStream;
  f_async_data: boolean;
  procedure response;
  function read_line_comm:string;
  procedure SendCommand(const s:string); override;
  procedure get_datasocket;
  procedure WndProc(var Msg : TMessage); override;
  function do_write:boolean;
  function do_read:boolean;
  procedure finish_upload;
  procedure finish_download;
  procedure finish_getdir;
public   (* will become public once tested *)
  procedure changedir(const f_dir:string);
  procedure removefile(const filename:string);
  procedure removedir(const dirname:string);
  procedure makedir(const dirname:string);
  procedure renamefile(const prior,after:string);
  procedure getdir(const dirname:string);
  function getdirentry:t_filedata;
public
  property stream: TStream read f_stream write SetStream;
  property status_number: integer read f_status_nr;
  property status_text: string read f_status_txt;
  property busy: boolean read f_busy;
  procedure login; override;
  procedure logout; override;
  procedure download;
  procedure upload;
  procedure abort;
  procedure noop;
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;
  property Size:integer read f_size;
published
  property Hostname: string read f_hostname write f_hostname;
  property URI: string read f_url write f_url;
  property Password:string read f_password write f_password;
  property Username:string read f_user write f_user;
  property Passive:boolean read f_passive write f_passive default true;
  property Port:word read f_port write f_port default 21;
  property Mode:t_ftp_mode read f_mode write f_mode default tftp_download;
  property OnDataReceived:TDataTransferProc read f_ondata_got write f_ondata_got;
  property OnActionComplete:TFTPActionCompleteProc read f_onaction write f_onaction;
  property Async:boolean read f_async_data write f_async_data;
  property OnTrace;
end;
(*@\\\0000003501*)

  { Time, RExec, LPR - the most useful UNIX services }
(*@///   T_Time = class(T_TcpIp)          // RFC 868 *)
T_Time = class(T_TcpIp)
protected
  f_time: TDateTime;
  f_timemode: T_TimeMode;
public
  constructor Create(Aowner:TComponent); override;
  procedure action; override;
  property time: TDateTime read f_time;
published
  property Hostname: string read f_hostname write f_hostname;
  property TimeMode: T_TimeMode read f_timemode write f_timemode default tzUTC;
  end;
(*@\\\0000000103*)
(*@///   T_RCommon = class(T_TcpIp) *)
T_RCommon = class(T_TcpIp)
protected
  procedure open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); override;
public
  procedure action; override;
  property stream: TStream read f_stream;
published
  property Hostname: string read f_hostname write f_hostname;
  end;
(*@\\\0000000103*)
(*@///   T_RExec = class(T_RCommon) *)
T_RExec = class(T_RCommon)
protected
  f_user: string;
  f_pass: string;
  f_command: string;
  procedure login; override;
public
  constructor Create(Aowner:TComponent); override;
published
  property UserName: string read f_user write f_user;
  property Password: string read f_pass write f_pass;
  property Command: string read f_command write f_command;
  end;
(*@\\\0000000113*)
(*@///   T_Rsh = class(T_RCommon) *)
T_Rsh = class(T_RCommon)
protected
  f_user_r: string;
  f_user_l: string;
  f_command: string;
  procedure login; override;
public
  constructor Create(Aowner:TComponent); override;
published
  property LocalUser: string read f_user_l write f_user_l;
  property RemoteUser: string read f_user_r write f_user_r;
  property Command: string read f_command write f_command;
  end;
(*@\\\0000000111*)
(*@///   T_lpr = class(T_TcpIp)           // RFC 1179 *)
T_lpr = class(T_TcpIp)
protected
  f_printtype: t_lpr_types;
  f_banner: boolean;
  f_count: integer;
  f_user: string;
  f_queue: string;
  f_user_mail: string;
  f_jobname: string;
  f_title: string;
  procedure response;
  procedure open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); override;
public
  constructor Create(Aowner:TComponent); override;
  property stream: TStream read f_stream write SetStream;
  procedure action; override;
  procedure SendPrintData;
  procedure GetQueueStatus(detailed:boolean);
published
  property Hostname: string read f_hostname write f_hostname;
  property User: string read f_user write f_user;
  property PrintQueue: string read f_queue write f_queue;
  property MailTo: string read f_user_mail write f_user_mail;
  property JobName: string read f_jobname write f_jobname;
  property PrintType:t_lpr_types read f_printtype write f_printtype default lp_ascii;
  property CopyCount:integer read f_count write f_count default 1;
  property PrintBanner:boolean read f_banner write f_banner default false;
  property PrintTitle:string read f_title write f_title;
  end;
(*@\\\0000000103*)

  { The Mail and News protocols }
(*@///   T_SMTP = class(T_TcpIp)          // RFC 821 *)
T_SMTP = class(T_TcpIp)
protected
  f_user, f_host: string;
  f_status_nr: integer;
  f_status_txt: string;
  f_receipts, f_body: tstringlist;
  procedure SetBody(Value: TStringList);
  procedure SetRecipients(Value: TStringList);
  procedure response;
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;
  property Recipients: TStringlist read f_receipts write SetRecipients;
  property Message: TStringList read f_body write SetBody;
  property Sender: string read f_user write f_user;
published
  property Hostname: string read f_hostname write f_hostname;
  property OnTrace;
  end;
(*@\\\0000001001*)
(*@///   T_Pop3 = class(T_TcpIp)          // RFC 1725 *)
T_Pop3 = class(T_TcpIp)
protected
  f_user: string;
  f_pass: string;
  f_list: TList;
  f_mail: TStringList;
  procedure response;
public
  property Mail: TStringlist read f_mail;
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;     (* retrieval of first message *)
  procedure Login; override;
  procedure GetHeaders;
  procedure Logout; override;
  procedure GetMail(index: integer);
  procedure DeleteMail(index:integer);
published
  property Hostname: string read f_hostname write f_hostname;
  property UserName: string read f_user write f_user;
  property Password: string read f_pass write f_pass;
  property OnTrace;
end;
(*@\\\0000001701*)
(*@///   T_NNTP = class(T_TcpIp)          // RFC 977 *)
T_NNTP = class(T_TcpIp)
protected
  f_news: TStringList;
  f_newsgroups: TStringList;
  f_status_nr: integer;
  f_status_txt: string;
  procedure response;
  procedure action; override;     (* ??? *)
  procedure SetNews(value:TStringlist);
  procedure GetArticleInternally;
public
  property News: TStringlist read f_news write SetNews;
  property NewsGroups: TStringlist read f_newsgroups;
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure Login; override;
  procedure Logout; override;
    (* To get an article from a URL like nntp://hostname/number *)
  procedure GetArticle(const group:string; index:integer);
    (* To get an article from a URL like news:msgid *)
  procedure GetArticleID(const msgid:string);
  procedure PostArticle;
    (* Methods more for a Newsreader *)
  procedure GetAllNewsgroups;
  procedure GetNewNewsgroups(since:TDateTime);
  procedure SetGroup(const group:string; var low,high,count: integer);
  procedure GetArticleNr(index:integer);
  procedure SetCurrentArticle(index:integer);
  procedure GetCurrentArticle;
  procedure GetNextArticle;
  procedure GetPreviousArticle;
published
  property Hostname: string read f_hostname write f_hostname;
  property OnTrace;
end;
(*@\\\0000002301*)

  { Mail and News text components }
(*@///   T_MailNews = class(TComponent) *)
T_MailNews = class(TComponent)
protected
  f_from, f_sender, f_subject: string;
  f_body: TStringlist;
  f_add_header: TStringlist;
  f_message: TStringlist;
  f_references: string;
  f_replyto: string;
  procedure SetBody(Value: TStringList);
  procedure SetHeader(Value: TStringList);
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; VIRTUAL;
published
  property Sender: string read f_sender write f_sender;
  property From: string read f_from write f_from;
  property Body: TStringList read f_body write SetBody;
  property Header: TStringList read f_add_header write SetHeader;
  property Subject:string read f_subject write f_subject;
  property References:string read f_references write f_references;
  property ReplyTo:string read f_replyto write f_replyto;
end;
(*@\\\0000001001*)
(*@///   T_Mail = class(T_MailNews)       // RFC 822 *)
T_Mail = class(T_MailNews)
protected
  f_smtp: T_SMTP;
  f_receipts: TStringlist;
  f_cc: TStringlist;
  f_bcc: TStringlist;
  f_disclose_receipts: boolean;
  procedure SetRecipients(Value: TStringList);
  procedure SetCC(Value: TStringList);
  procedure SetBCC(Value: TStringList);
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;
published
  property SMTP: T_SMTP read f_smtp write f_smtp;
  property Disclose_Receipts: boolean read f_disclose_receipts write f_disclose_receipts default false;
  property Recipients: TStringlist read f_receipts write SetRecipients;
  property CC: TStringlist read f_cc write SetCC;
  property BCC: TStringlist read f_bcc write SetBCC;
end;
(*@\\\0000000601*)
(*@///   T_News = class(T_MailNews)       // RFC 850 *)
T_News = class(T_MailNews)
protected
  f_nntp: T_NNTP;
  f_newsgroups: TStringlist;
  f_organization: string;
  procedure SetNewsgroups(Value: TStringList);
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  procedure action; override;
published
  property NNTP: T_NNTP read f_nntp write f_nntp;
  property Newsgroups: TStringlist read f_newsgroups write SetNewsgroups;
  property Organization: string read f_organization write f_organization;
end;
(*@\\\0000000C14*)
(*@///   T_Attachment = class(TObject) *)
T_Attachment = class(TObject)
protected
  f_kind: string;
  f_disposition: string;
  f_data: TStream;
  f_text: TStringList;
  f_encoding: T_Encoding;
  procedure SetText(value:TStringList);
  procedure SetData(value:TStream);
public
  constructor Create;
  destructor Destroy; override;
  property Kind: string read f_kind write f_kind;
  property Disposition: string read f_disposition write f_disposition;
  property Encoding: T_Encoding read f_encoding write f_encoding;
  property Text:TStringlist read f_text write SetText;
  property Data:TStream read f_data write SetData;
end;
(*@\\\0000000D01*)
(*@///   T_Mime = class(TComponent)      // RFC 1521 *)
T_Mime = class(TComponent)
protected
  f_mail: T_MailNews;
  boundary: string;
  f_attachment: TList;
  function GetNumberOfAttachments: integer;
public
  constructor Create(Aowner:TComponent); override;
  destructor Destroy; override;
  function AttachFile(const filename:string):integer;
  function AttachText(text: TStringList):integer;
  procedure RemoveAllAttachments;
  procedure action;
  procedure SetMail(mail: TStringlist);
  function GetAttachment(index: integer):T_Attachment;
  procedure RemoveAttachment(index: integer);
  property Attachment[index:integer]:T_Attachment read GetAttachment;
  property NumberOfAttachments: integer read GetNumberOfAttachments;
published
  property Mail: T_MailNews read f_mail write f_mail;
end;
(*@\\\0000000A01*)

const
  uwm_socketevent = wm_user+$100; (* my magic message number *)

var
  lpr_count: integer;          (* the current job number *)

procedure Register;
(*@\\\0000003B03*)
(*@/// implementation *)
implementation

(*@/// Parse a FTP directory line into a filedata record (UNIX and DOS style only) *)
const month_string: array[0..11] of string =
  ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

(*@/// function getmonth(const s:string):integer;         Month -> Integer *)
function getmonth(const s:string):integer;
var
  i: integer;
begin
  result:=0;
  for i:=0 to 11 do
    if s=month_string[i] then begin
      result:=i+1;
      EXIT;
      end;
  end;
(*@\\\0000000301*)

const
  empty_filedata:t_filedata=
    (filetype:ft_none; size:0; name:''; datetime:0);

(*@/// function parse_line_unix(const s: string):t_filedata; *)
function parse_line_unix(const v: string):t_filedata;
(* known problems: filename with spaces (most unix's don't allow the anyway) *)
(*                 links aren't parsed at all                                *)
var
  t,date: string;
  y,m,d,h,n,s: word;
begin
  try
    case v[1] of
      'd': result.filetype:=ft_dir;
      '-': result.filetype:=ft_file;
      'l': result.filetype:=ft_link;
      end;
    result.name:=copy(v,posn(' ',v,-1)+1,length(v));
    t:=copy(v,12,length(v)-length(result.name)-12);
    date:=copy(t,length(t)-11,12);
    decodedate(now,y,m,d);
    h:=0; n:=0; s:=0;
    if pos(':',date)>0 then begin
      h:=strtoint(copy(date,8,2));
      n:=strtoint(copy(date,11,2));
      end
    else
      y:=strtoint(copy(date,9,4));
    d:=strtoint(trim(copy(date,5,2)));
    m:=getmonth(copy(date,1,3));
    t:=copy(t,1,length(t)-13);
    result.size:=strtoint(copy(t,posn(' ',t,-1)+1,length(t)));
    result.datetime:=encodedate(y,m,d)+encodetime(h,n,s,0);
  except
    result:=empty_filedata;
    end;
  end;
(*@\\\0000000201*)
(*@/// function parse_line_dos(const s: string):t_filedata; *)
function parse_line_dos(const v: string):t_filedata;
(* known problems: filename with spaces (why do something like that?) *)
var
  t: string;
  sd,st: string;
  ds: char;
begin
  ds:=DateSeparator;
  sd:=ShortdateFormat;
  st:=Shorttimeformat;
  try
    if pos('<DIR>',v)=0 then
      result.filetype:=ft_file
    else
      result.filetype:=ft_dir;
    result.name:=copy(v,posn(' ',v,-1)+1,length(v));
    t:=copy(v,1,length(v)-length(result.name)-1);
    result.size:=strtoint('0'+copy(t,posn(' ',t,-1)+1,length(t)));
    DateSeparator:='-';
    ShortDateFormat:='mm/dd/yy';
    Shorttimeformat:='hh:nnAM/PM';
    result.datetime:=strtodatetime(copy(t,1,17));
  except
    result:=empty_filedata;
    end;
  DateSeparator:=ds;
  ShortdateFormat:=sd;
  Shorttimeformat:=st;
  end;
(*@\\\0000000201*)

(*@/// function parse_ftp_line(const s:string):t_filedata; *)
function parse_ftp_line(const s:string):t_filedata;
begin
  if copy(s,1,5)='total' then     (* first line for some UNIX ftp server *)
    result:=empty_filedata
  else if s[1] in ['d','l','-','s'] then
    result:=parse_line_unix(s)
  else if s[1] in ['0'..'9'] then
    result:=parse_line_dos(s);
  end;
(*@\\\0000000301*)
(*@\\\0000000401*)

(*@/// procedure stream_write_s(h:TMemoryStream; const s:string);  // string -> stream *)
procedure stream_write_s(h:TMemoryStream; const s:string);
var
  buf: pointer;
begin
  buf:=@s[1];
  h.write(buf^,length(s));
  end;
(*@\\\0000000301*)

const
  back_log=2;  (* possible values 1..5 *)
  fingerd_timeout=5;
  buf_size=$7f00;     (* size of the internal standard buffer *)

(*@/// class EProtocolError(ETcpIpError) *)
constructor EProtocolError.Create(const proto,Msg:String; number:word);
begin
  Inherited Create(Msg);
  protocoll:=proto;
  errornumber:=number;
  end;
(*@\\\0000000301*)
(*@/// class ESocketError(ETcpIpError) *)
constructor ESocketError.Create(number:word);
begin
  inherited create('Error creating socket');
  errornumber:=number;
  end;
(*@\\\*)
(*@/// class EProtocolBusy(ETcpIpError) *)
constructor EProtocolBusy.Create;
begin
  inherited create('Protocol busy');
  end;
(*@\\\0000000301*)

(*@/// procedure parse_url(const url:string; var proto,user,pass,host,port,path:string); *)
procedure parse_url(const url:string; var proto,user,pass,host,port,path:string);

(* standard syntax of an URL:
   protocol://[user[:password]@]server[:port]/path              *)

var
  p,q: integer;
  s: string;
begin
  proto:='';
  user:='';
  pass:='';
  host:='';
  port:='';
  path:='';

  p:=pos('://',url);
  if p=0 then begin
    if lowercase(copy(url,1,7))='mailto:' then begin   (* mailto:// not common *)
      proto:='mailto';
      p:=pos(':',url);
      end;
    end
  else begin
    proto:=copy(url,1,p-1);
    inc(p,2);
    end;
  s:=copy(url,p+1,length(url));

  p:=pos('/',s);
  if p=0 then  p:=length(s)+1;
  path:=copy(s,p,length(s));
  s:=copy(s,1,p-1);

  p:=posn(':',s,-1);
  if p>length(s) then p:=0;
  q:=posn('@',s,-1);
  if q>length(s) then q:=0;
  if (p=0) and (q=0) then begin   (* no user, password or port *)
    host:=s;
    EXIT;
    end
  else if q<p then begin  (* a port given *)
    port:=copy(s,p+1,length(s));
    host:=copy(s,q+1,p-q-1);
    if q=0 then EXIT; (* no user, password *)
    s:=copy(s,1,q-1);
    end
  else begin
    host:=copy(s,q+1,length(s));
    s:=copy(s,1,q-1);
    end;
  p:=pos(':',s);
  if p=0 then
    user:=s
  else begin
    user:=copy(s,1,p-1);
    pass:=copy(s,p+1,length(s));
    end;
  end;
(*@\\\0000003C07*)

{ The base component }
(*@/// class t_tcpip(TComponent) *)
(*@/// constructor t_tcpip.Create(Aowner:TComponent); *)
constructor t_tcpip.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
{   f_buffer:=NIL; }
  getmem(f_buffer,buf_size);
  f_stream:=TMemorystream.Create;
  f_Socket:=INVALID_SOCKET;
  ip_address:=INVALID_IP_ADDRESS;
    (* A windows dummy handle to get messages *)
  f_handle:=AllocateHwnd(self.WndProc);
  f_async:=false;
  f_logged_in:=false;
  end;
(*@\\\0000000C03*)
(*@/// destructor t_tcpip.Destroy; *)
destructor t_tcpip.Destroy;
begin
  f_tracer:=NIL;
  if f_buffer<>NIL then
    freemem(f_buffer,buf_size);
  f_stream.free;
  if f_socket<>invalid_socket then
    logout;
  DeallocateHwnd(f_Handle);
  inherited destroy;
  end;
(*@\\\0000000301*)

(*@/// procedure t_tcpip.WndProc(var Msg : TMessage); *)
procedure t_tcpip.WndProc(var Msg : TMessage);
begin
  if msg.msg=uwm_socketevent then begin
    if msg.lparamhi=socket_error then
    else begin
      case msg.lparamlo of
(*@///         fd_read: *)
fd_read: begin
  f_newdata:=true;
  end;
(*@\\\0000000213*)
        end;
      end;
    end
  else
    dispatch(msg);
  end;
(*@\\\0000000701*)

(*@/// function t_tcpip.Create_Socket:TSocket; *)
function t_tcpip.Create_Socket:TSocket;
begin
  result:=Winsock.Socket(PF_INET,SOCK_STREAM,IPPROTO_IP);
  end;
(*@\\\*)
(*@/// procedure t_tcpip.bind_socket(var socket:TSocket; out_port_min,out_port_max: word); *)
procedure t_tcpip.bind_socket(var socket:TSocket; out_port_min,out_port_max: word);
var
  LocalAddress : TSockAddr;
  i: word;
begin
  with LocalAddress do begin
    Sin_Family:=PF_INET;
    Sin_addr.S_addr:=INADDR_ANY;
    end;
  i:=out_port_min;
  while i<=out_port_max do begin
    LocalAddress.Sin_Port:=Winsock.htons(i);
    if Winsock.bind(socket,LocalAddress,
      SizeOf(LocalAddress))<>SOCKET_ERROR then BREAK;
    inc(i);
    end;
  end;
(*@\\\0000000401*)
(*@/// procedure t_tcpip.connect_socket(var socket:TSocket; Socket_number:smallint;ip_address:longint); *)
procedure t_tcpip.connect_socket(var socket:TSocket; Socket_number:smallint;ip_address:longint);
var
  RemoteAddress : TSockAddr;
begin
  with RemoteAddress do begin
    Sin_Family:=PF_INET;
    Sin_Port:=Winsock.htons(Socket_number);
    Sin_addr:=TInAddr(ip_address);
    end;
  if Winsock.Connect(Socket,RemoteAddress,
     SizeOf(RemoteAddress))=SOCKET_ERROR then begin
    if winsock.WSAGetLastError<>wsaewouldblock then begin
      Close_Socket(socket);
      if assigned(f_tracer) then
        f_tracer('Failed to open output socket '+inttostr(Socket_number)+' to host '+
                 ip2string(ip_address),tt_socket);
      end
    end
  else
    if assigned(f_tracer) then
      f_tracer('Opened output socket '+inttostr(Socket_number)+' to host '+
               ip2string(ip_address)+' successfully; ID '+inttostr(socket),
               tt_socket);
  end;
(*@\\\000E00101C00101C00101C00101C*)
(*@/// procedure t_tcpip.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); *)
procedure t_tcpip.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint);
begin
  close_socket(socket);
  socket:=Create_Socket;
  connect_socket(socket,Socket_number,ip_address);
  end;
(*@\\\0000000501*)
(*@/// procedure t_tcpip.open_socket_in(var socket:TSocket; Socket_number:smallint;ip_address:longint); *)
procedure t_tcpip.open_socket_in(var socket:TSocket; Socket_number:smallint;ip_address:longint);
var
  LocalAddress : TSockAddr;
begin
  close_socket(socket);
  f_Socket:=Create_Socket;
(*@///   open the socket and let it listen *)
with LocalAddress do begin
  Sin_Family:=PF_INET;
  Sin_Port:=Winsock.htons(Socket_number);
  Sin_addr:=TInAddr(ip_address);
  end;
if Winsock.bind(socket,LocalAddress,
   SizeOf(LocalAddress))=SOCKET_ERROR then begin
  if assigned(f_tracer) then
    f_tracer('Failed to bind socket '+inttostr(Socket_number)+' for local ip '+
             ip2string(ip_address),tt_socket);
  Close_Socket(socket);
  EXIT;
  end
else
  if assigned(f_tracer) then
    f_tracer('Bound to socket '+inttostr(Socket_number)+' for local ip '+
             ip2string(ip_address),tt_socket);
if Winsock.Listen(Socket,back_log)=SOCKET_ERROR then begin
  Close_Socket(socket);
  if assigned(f_tracer) then
    f_tracer('Failed to set input socket '+inttostr(Socket_number)+
             ' to listening mode',tt_socket);
  end
else
  if assigned(f_tracer) then
    f_tracer('Set input socket '+inttostr(Socket_number)+
             ' to listening mode sucessfully; ID '+inttostr(socket),tt_socket);
(*@\\\0030000A18000A18001123*)
  end;
(*@\\\0000000701*)
(*@/// function t_tcpip.accept_socket_in(socket:TSocket; var SockInfo:TSockAddr):TSocket; *)
function t_tcpip.accept_socket_in(socket:TSocket; var SockInfo:TSockAddr):TSocket;
var
  x: u_int;
  LocalAddress : TSockAddr;
  temp_socket: TSocket;
begin
  x:=SizeOf(LocalAddress);
(*$ifndef ver100 *)
  temp_socket:=Winsock.Accept(Socket,LocalAddress,x);
(*$else *)       { Delphi 3 ARGH! }
  temp_socket:=Winsock.Accept(Socket,@LocalAddress,@x);
(*$endif *)
  if temp_socket=SOCKET_ERROR then begin
    (* no incoming call available *)
    temp_socket:=INVALID_SOCKET;
    if assigned(f_tracer) then
      f_tracer('No incoming connection found on socket ID '+inttostr(Socket),
               tt_socket);
    end
  else
    if assigned(f_tracer) then
      f_tracer('Incoming connection found on socket ID '+inttostr(Socket)+
               '; generated socket ID '+inttostr(temp_socket),tt_socket);
  accept_socket_in:=temp_socket;
  sockinfo:=LocalAddress;
  end;
(*@\\\0000001748*)
(*@/// function t_tcpip.socket_state(socket:TSocket):T_Socket_State; *)
function t_tcpip.socket_state(socket:TSocket):T_Socket_State;
var
  peer_adr: TSockAddr;
  x: u_int;
begin
  if socket=INVALID_SOCKET then
    socket_state:=invalid
  else begin
    x:=sizeof(TSockAddr);
    if winsock.getpeername(socket,peer_adr,x)=0 then
      socket_state:=connected
    else begin
      if winsock.WSAGetLastError<>WSAENOTCONN then
        socket_state:=state_unknown
      else
        socket_state:=valid
      end;
    end;
  end;
(*@\\\0000000D01*)
(*@/// procedure t_tcpip.close_socket(var socket:TSocket); *)
procedure t_tcpip.close_socket(var socket:TSocket);
begin
  if socket<>INVALID_SOCKET then begin
    Winsock.CloseSocket(socket);
    if assigned(f_tracer) then
      f_tracer('Closed socket ID '+inttostr(socket),tt_socket);
    socket:=INVALID_SOCKET;
    end;
  end;
(*@\\\0000000501*)
(*@/// procedure t_tcpip.close_socket_linger(var socket:TSocket); *)
procedure t_tcpip.close_socket_linger(var socket:TSocket);
var
  linger: TLinger;
begin
  if socket<>INVALID_SOCKET then begin
    linger.l_onoff:=1;
    linger.l_linger:=fingerd_timeout;
    winsock.setsockopt(socket,sol_socket,SO_LINGER,PChar(@linger),sizeof(linger));
    winsock.shutdown(socket,1);
    close_socket(socket);
    socket:=INVALID_SOCKET;
    end;
  end;
(*@\\\0000000842*)
(*@/// function t_tcpip.Socket_by_name(const service:string):smallint; *)
function t_tcpip.Socket_by_name(const service:string):smallint;
var
  service_entry : PServEnt;
  s: string;
begin
  s:=service+#0;
(*$ifdef ver80 *)
  service_entry:=Winsock.GetServByName(pchar(@s[1]),'tcp');
(*$else *)
 (*$ifopt h- *)
  service_entry:=Winsock.GetServByName(pchar(@s[1]),'tcp');
 (*$else *)
  service_entry:=Winsock.GetServByName(pchar(s),'tcp');
 (*$endif *)
(*$endif *)
  if service_entry=nil then
    result:=0
  else
    result:=winsock.htons(service_entry^.s_port);
  end;
(*@\\\0000000E02*)

(*@/// procedure t_tcpip.Login; *)
procedure t_tcpip.Login;
begin
  if f_logged_in then logout;
  ip_address:=lookup_hostname(f_hostname);
  if ip_address=INVALID_IP_ADDRESS then
    raise ETcpIpError.Create('Couldn''t resolve hostname '+f_hostname);
  open_socket_out(f_socket,f_Socket_number,ip_address);
  if f_socket=INVALID_SOCKET then
    raise ESocketError.Create(WSAGetLastError);
  f_eof:=false;
  f_logged_in:=true;
  end;
(*@\\\0000000315*)
(*@/// procedure t_tcpip.LogOut; *)
procedure t_tcpip.LogOut;
begin
  close_socket(f_socket);
  f_socket:=invalid_socket;
  f_logged_in:=false;
  end;
(*@\\\0000000501*)
(*@/// procedure t_tcpip.SendCommand(const s:string); *)
procedure t_tcpip.SendCommand(const s:string);
begin
  self.write_s(f_socket,s+#13#10);
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_sent);
  end;
(*@\\\0000000301*)


(*@/// function t_tcpip.eof(f_socket:TSocket):boolean;            !!! *)
function t_tcpip.eof(f_socket:TSocket):boolean;
begin
  eof:=f_eof or (socket_state(f_socket)<>connected);
  end;
(*@\\\0000000114*)
(*@/// procedure t_tcpip.read_var(f_socket:TSocket; var buf; size:integer; var _ok:integer); *)
procedure t_tcpip.read_var(f_socket:TSocket; var buf; size:integer; var _ok:integer);
var
  temp_buf: pointer;
  error: integer;
begin
  temp_buf:=NIL;
  try
    if @buf=NIL then
      getmem(temp_buf,size)  (* alloc for the -> /dev/null *)
    else
      temp_buf:=@buf;
    repeat
      _ok:=Winsock.recv(F_Socket,temp_Buf^,Size,0);
      if _ok<=0 then begin
        error:=Winsock.WSAGetLastError;
        (* listening socket is always non-blocking, but this causes
           problems with the recv command *)
        if error=wsaewouldblock then begin
          if f_async then begin
            f_newdata:=false;
            while not f_newdata do
              Application.ProcessMessages;
            end;
          end;
        f_eof:=error<>wsaewouldblock;
        end
      else
        if assigned(f_tracer) then
          f_tracer('Received '+inttostr(_ok)+' bytes on socket ID '+
                   inttostr(f_socket),tt_socket);
    until f_eof or (_ok>0);
  finally
    if @buf=NIL then
      freemem(temp_buf,size)
    end;
  end;
(*@\\\0000000601*)
(*@/// function t_tcpip.read_line(f_socket:TSocket):string; *)
function t_tcpip.read_line(f_socket:TSocket):string;
var
  x: char;
  ok: integer;
  s: string;
begin
  s:='';
  repeat
    read_var(f_socket,x,1,ok);
    if x=#13 then               (* at least NCSA 1.3 does send a #10 only *)
    else if x=#10 then begin
        result:=s;
        EXIT;
      end
    else begin
      s:=s+x;
      end;
  until eof(f_socket);
  end;
(*@\\\*)
(*@/// procedure t_tcpip.write_buf(f_socket:TSocket; const buf; size:integer); *)
procedure t_tcpip.write_buf(f_socket:TSocket; const buf; size:integer);
begin
  if Winsock.Send(F_Socket,pointer(@buf)^,size,0)=SOCKET_ERROR then
     EXIT  (* Error writing *)
  else
  if assigned(f_tracer) then
    f_tracer('Sent '+inttostr(size)+' bytes on socket ID '+
             inttostr(f_socket),tt_socket);
  end;
(*@\\\0000000801*)
(*@/// procedure t_tcpip.write_s(f_socket:TSocket; const s:string); *)
procedure t_tcpip.write_s(f_socket:TSocket; const s:string);
begin
(*$ifdef ver80 *)
  write_buf(f_socket,pchar(@s[1])^,length(s));
(*$else *)
(*$ifopt h- *)
  write_buf(f_socket,pchar(@s[1])^,length(s));
(*$else *)
  write_buf(f_socket,pchar(s)^,length(s));
(*$endif *)
(*$endif *)
  end;
(*@\\\0000000801*)

(*@/// procedure t_tcpip.SetStream(value:TStream); *)
procedure t_tcpip.SetStream(value:TStream);
begin
  TMemoryStream(f_stream).LoadFromStream(value);
  end;
(*@\\\0000000301*)

(*@/// procedure t_tcpip.action; *)
procedure t_tcpip.action;
var
  p: pointer;
  ok,ok2:integer;
begin
  login;
  TMemorystream(f_stream).clear;
  while not eof(f_socket) do begin
    read_var(f_socket,f_buffer^,buf_size,ok);
    p:=f_buffer;
    while ok>0 do begin   (* just to be sure everything goes into the stream *)
      ok2:=f_stream.write(p^,ok);
      dec(ok,ok2);
      p:=pointer(longint(p)+ok2);
      end;
    end;
  f_stream.seek(0,0);
  end;
(*@\\\0000000303*)
(*@\\\*)

{ Finger client and demon }
(*@/// class t_finger(t_tcpip) *)
(*@/// constructor t_finger.Create(Aowner:TComponent); *)
constructor t_finger.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=IPPORT_FINGER;  (* 79 *)
  end;
(*@\\\0000000403*)

(*@/// procedure t_finger.action; *)
procedure t_finger.action;
var
  p: pointer;
  ok,ok2:integer;
  s: string;
begin
  login;
  s:=f_user+#13#10;
  write_s(f_socket,s);
  TMemorystream(f_stream).clear;
  while not eof(f_socket) do begin
    read_var(f_socket,f_buffer^,buf_size,ok);
    p:=f_buffer;
    while ok>0 do begin   (* just to be sure everything goes into the stream *)
      ok2:=f_stream.write(p^,ok);
      dec(ok,ok2);
      p:=pointer(longint(p)+ok2);
      end;
    end;
  f_stream.seek(0,0);  (* set the stream back to start *)
  logout;
  end;
(*@\\\0000000D10*)
(*@\\\0000000301*)
(*@/// class t_fingerd(t_tcpip) *)
(*@/// constructor t_fingerd.Create(Aowner:TComponent); *)
constructor t_fingerd.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=IPPORT_FINGER;  (* 79 *)
  f_answer:=TStringList.Create;
  end;
(*@\\\0000000501*)
(*@/// destructor t_fingerd.Destroy; *)
destructor t_fingerd.Destroy;
begin
  f_answer.Free;
  inherited destroy;
  end;
(*@\\\0000000301*)
(*@/// procedure t_fingerd.do_action; *)
procedure t_fingerd.do_action;
var
  i: integer;
  temp_socket: TSocket;
  finger_info:TFingerInfo;
  sockinfo: TSockAddr;
  s: string;
begin
  temp_socket:=f_socket;
  self.f_socket:=accept_socket_in(f_socket,sockinfo);
  f_eof:=false;
  finger_info.address:=longint(sockinfo.Sin_addr);
  s:=self.read_line(f_socket);
  finger_info.request:=s;
  finger_info.hostname:='';   (* NYI !!! *)
  if assigned(f_fingerrequest) then
    f_fingerrequest(self,finger_info);
  for i:=0 to f_answer.count-1 do begin
    self.write_s(f_socket,f_answer.strings[i]+#13#10);
    end;
  close_socket_linger(f_socket);
  f_socket:=temp_socket;
  end;
(*@\\\000000131B*)
(*@/// procedure t_fingerd.SetAnswer(Value: TStringList); *)
procedure t_fingerd.SetAnswer(Value: TStringList);
begin
  if value=NIL then
    f_answer.clear
  else
    f_answer.assign(value);
  end;
(*@\\\0000000603*)
(*@/// procedure t_fingerd.WndProc(var Msg : TMessage); *)
procedure t_fingerd.WndProc(var Msg : TMessage);
begin
  if msg.msg<>uwm_socketevent then
    inherited wndproc(msg)
  else begin
    if msg.lparamhi=socket_error then
    else begin
      case msg.lparamlo of
        fd_accept: begin
          do_action;
          end;
        end;
      end;
    end;
  end;
(*@\\\0000000E09*)
(*@/// procedure t_fingerd.action; *)
procedure t_fingerd.action;
begin
  open_socket_in(f_socket,f_Socket_number,my_ip_address);
  if f_socket=INVALID_SOCKET then
    raise ESocketError.Create(WSAGetLastError);
  winsock.WSAAsyncSelect(f_socket,f_handle,uwm_socketevent,fd_accept);
  end;
(*@\\\000000010B*)
(*@\\\000000051C*)

{ HTTP and FTP - the file transfer protocols }
(*@/// class t_http(t_tcpip) *)
(*@/// constructor t_http.Create(Aowner:TComponent); *)
constructor t_http.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_content_post:='application/x-www-form-urlencoded';
  f_do_author:=TStringlist.Create;
  end;
(*@\\\0000000503*)
(*@/// destructor t_http.Destroy; *)
destructor t_http.Destroy;
begin
  f_do_author.free;
  inherited destroy;
  end;
(*@\\\*)

(*@/// procedure t_http.sendrequest(const method,version: string); *)
procedure t_http.sendrequest(const method,version: string);
begin
  SendCommand(method+' '+f_path+' HTTP/'+version);
  if f_sender<>'' then
    SendCommand('From: '+f_sender);
  if f_reference<>'' then
    SendCommand('Referer: '+f_reference);
  if f_agent<>'' then
    SendCommand('User-Agent: '+f_agent);
  if f_nocache then
    SendCommand('Pragma: no-cache');
  if method='POST' then begin
    SendCommand('Content-Length: '+inttostr(stream.size));
    if f_content_post<>'' then
      SendCommand('Content-Type: '+f_content_post);
    end;
  if f_author<>'' then begin
    self.write_s(f_socket,'Authorization: '+f_author+#13#10);
    if assigned(f_tracer) then
      f_tracer('Authorization: *****',tt_proto_sent);
    end;
  self.write_s(f_socket,#13#10);                          (* finalize the request *)
  end;
(*@\\\0000000301*)
(*@/// procedure t_http.getanswer; *)
procedure t_http.getanswer;
var
  s: string;
  proto,user,pass,port: string;
  field,data: string;
begin
  f_do_author.clear;
  f_type:='';
  f_size:=0;
  repeat
    s:=self.read_line(f_socket);
    if s<>'' then
      if assigned(f_tracer) then
        f_tracer(s,tt_proto_get);
    if false then
(*@///     else if left(s,8)='HTTP/1.0' then    http-status-reply *)
else if copy(s,1,8)='HTTP/1.0' then begin
  f_status_nr:=strtoint(copy(s,10,3));
  f_status_txt:=copy(s,14,length(s));
  if f_status_nr>=400 then EXIT;   (* HTTP error returned *)
  end
(*@\\\*)
(*@///     else if pos(':',s)>0         then    parse the response string *)
else if pos(':',s)>0 then begin
  field:=lowercase(copy(s,1,pos(':',s)-1));
  data:=copy(s,pos(':',s)+2,length(s));
  if false then
{   else if field='date' then }
{   else if field='mime-version' then }
{   else if field='pragma' then }
{   else if field='allow' then }
(*@///   else if field='location' then   change the uri !!! *)
else if field='location' then begin
  if proxy<>'' then
    f_path:=data            (* it goes via a proxy, so just change the uri *)
  else begin
    parse_url(data,proto,user,pass,f_hostname,port,f_path);
    if port<>'' then  f_Socket_number:=strtoint(port);
    end;
  end
(*@\\\0000000601*)
{   else if field='server' then }
{   else if field='content-encoding' then }
(*@///   else if field='content-length' then *)
else if field='content-length' then
  f_size:=strtoint(data)
(*@\\\*)
(*@///   else if field='content-type' then *)
else if field='content-type' then
  f_type:=data
(*@\\\*)
(*@///   else if field='www-authenticate' then *)
else if field='www-authenticate' then
  f_do_author.add(data)
(*@\\\000000020E*)
{   else if field='expires' then }
{   else if field='last-modified' then }
  end
(*@\\\0000000901*)
(*@///     else                                 some very strange response, ignore it *)
else;
(*@\\\*)
  until s='';
  if f_status_nr>=400 then
    raise EProtocolError.Create('HTTP',f_status_txt,f_status_nr);
  end;
(*@\\\0000001101*)

(*@/// procedure t_http.action; *)
procedure t_http.action;
var
  proto,user,pass,host,port,path: string;
begin
(*@///   parse url and proxy to f_hostname, f_path and f_socket_number *)
if f_proxy<>'' then begin
  parse_url(f_url,proto,user,pass,host,port,path);
  f_path:=f_url;
  if proto='' then
    f_path:='http://'+f_path;
  parse_url(f_proxy,proto,user,pass,host,port,path);
  if port='' then port:='8080';
  end
else begin
  parse_url(f_url,proto,user,pass,host,port,f_path);
  if port='' then port:='80';
  end;
if proto='' then  proto:='http';
if f_path='' then f_path:='/';

f_hostname:=host;
f_Socket_number:=strtoint(port);
(*@\\\0000000601*)
  gethead;   (* to process an eventually Location: answer *)
  getbody;
  end;
(*@\\\0000000501*)
(*@/// procedure t_http.GetHead; *)
procedure t_http.GetHead;
begin
  login;
  sendrequest('HEAD','1.0');
  getanswer;
  logout;
  end;
(*@\\\0000000701*)
(*@/// procedure t_http.GetBody; *)
procedure t_http.GetBody;
var
  p: pointer;
  ok,ok2:integer;
begin
  login;
  sendrequest('GET','1.0');
  getanswer;
(*@///   read the data *)
TMemorystream(f_stream).clear;
while not eof(f_socket) do begin
  read_var(f_socket,f_buffer^,buf_size,ok);
  p:=f_buffer;
  while ok>0 do begin   (* just to be sure everything goes into the stream *)
    ok2:=f_stream.write(p^,ok);
    dec(ok,ok2);
    p:=pointer(longint(p)+ok2);
    end;
  end;
f_stream.seek(0,0);  (* set the stream back to start *)
(*@\\\*)
  logout;
  end;
(*@\\\0000000901*)
(*@/// procedure t_http.Post; *)
procedure t_http.Post;
var
  p: pointer;
  ok,ok2:integer;
  proto,user,pass,host,port,path: string;
begin
(*@///   parse url and proxy to f_hostname, f_path and f_socket_number *)
if f_proxy<>'' then begin
  parse_url(f_proxy,proto,user,pass,host,port,path);
  f_path:=f_url;
  if port='' then port:='8080';
  end
else begin
  parse_url(f_url,proto,user,pass,host,port,f_path);
  if port='' then port:='80';
  end;
if proto='' then  proto:='http';
if path='' then path:='/';

f_hostname:=host;
f_Socket_number:=strtoint(port);
(*@\\\*)
  login;
  sendrequest('POST','1.0');
(*@///   Send the data *)
TMemorystream(f_stream).seek(0,0);
ok:=1;
while ok>0 do begin
  ok:=f_stream.read(f_buffer^,buf_size);
  write_buf(f_socket,f_buffer^,ok);
  end;
(*@\\\0000000607*)
  getanswer;
(*@///   read in the response body *)
TMemorystream(f_stream).clear;
while not eof(f_socket) do begin
  read_var(f_socket,f_buffer^,buf_size,ok);
  p:=f_buffer;
  while ok>0 do begin   (* just to be sure everything goes into the stream *)
    ok2:=f_stream.write(p^,ok);
    dec(ok,ok2);
    p:=pointer(longint(p)+ok2);
    end;
  end;
f_stream.seek(0,0);  (* set the stream back to start *)
(*@\\\0000000201*)
  logout;
  end;
(*@\\\*)

(*@/// procedure t_http.DoBasicAuthorization(const username,password:string); *)
procedure t_http.DoBasicAuthorization(const username,password:string);
var
  h: TMemoryStream;
  encoded: TStringlist;
begin
  f_author:=username+':'+password;
  h:=NIL;
  encoded:=NIL;
  try
    h:=TMemoryStream.Create;
    stream_write_s(h,f_author);
    encoded:=encode_base64(h);
    if encoded.count>0 then
      f_author:='Basic '+encoded.strings[0];
  finally
    h.free;
    encoded.free;
    end;
  end;
(*@\\\0000000C1D*)
(*@\\\0000000501*)
(*@/// class t_ftp(t_tcpip) *)
(*@/// constructor t_ftp.Create(Aowner:TComponent); *)
constructor t_ftp.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_port:=21;
  f_user:='ftp';
  f_password:='nobody@nowhere'; (* only to make it running without setting user/password *)
  f_passive:=true;
  f_mode:=tftp_download;
  f_cur_dir:=TStringlist.Create;
  f_comm_socket:=INVALID_SOCKET;
  f_busy:=false;
  f_dir_stream:=TMemorystream.Create;
  end;
(*@\\\*)
(*@/// destructor t_ftp.Destroy; *)
destructor t_ftp.Destroy;
begin
  f_cur_dir.free;
  f_dir_stream.free;
  inherited destroy;
  end;
(*@\\\0000000301*)

(*@/// procedure t_ftp.action; *)
procedure t_ftp.action;
begin
  login;
  TMemorystream(f_stream).clear;
  case f_mode of
    tftp_download: download;
    tftp_upload:   upload;
    tftp_getdir:   getdir('.');
    end;
  logout;
  end;
(*@\\\0000000303*)
(*@/// procedure t_ftp.response; *)
procedure t_ftp.response;
var
  s: string;
begin
  s:=self.read_line_comm;
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_get);
  try
    f_status_nr:=strtoint(copy(s,1,3));
  except
    f_status_nr:=999;
  end;
  f_status_txt:=copy(s,5,length(s));
  if f_status_nr>=400 then
    raise EProtocolError.Create('FTP',f_status_txt,f_status_nr);
  (* if the answer consists of several lines read and discard all the following *)
  while (pos('-',s)=4) or (pos(' ',s)=1) do begin
    s:=self.read_line_comm;
    if assigned(f_tracer) then
      f_tracer(s,tt_proto_get);
    end;
  end;
(*@\\\0000000701*)

(*@/// procedure t_ftp.login;                                // USER and PASS commands *)
procedure t_ftp.login;
begin
  f_socket_number:=f_port;
  inherited login;
  f_comm_socket:=f_socket;
  self.response;   (* Read the welcome message *)
  self.SendCommand('USER '+f_user);
  self.response;
{   self.SendCommand('PASS '+f_password); }
  write_s(f_comm_socket,'PASS '+f_password+#13#10);
  if assigned(f_tracer) then
    f_tracer('PASS ******',tt_proto_sent);
  self.response;
  self.SendCommand('TYPE I');  (* always use binary *)
  self.response;
  end;
(*@\\\0000000301*)
(*@/// procedure t_ftp.logout;                               // QUIT command *)
procedure t_ftp.logout;
begin
  if f_busy then  self.abort;
  if f_logged_in then begin
    if f_comm_socket<>INVALID_SOCKET then begin
      self.SendCommand('QUIT');
      self.response;
      end;
    if f_socket<>invalid_socket then
      closesocket(f_socket);
    f_socket:=f_comm_socket;
    f_comm_socket:=INVALID_SOCKET;
    end;
  inherited logout;
  end;
(*@\\\0000000406*)

(*@/// procedure t_ftp.getdir(const dirname:string);         // LIST command *)
procedure t_ftp.getdir(const dirname:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  if (dirname='') then EXIT;
  get_datasocket;
  self.SendCommand('TYPE A');
  self.response;
  self.SendCommand('LIST '+dirname);
  self.response;
  f_mode_intern:=tftp_getdir;
  f_busy:=true;
  TMemorystream(f_dir_stream).clear;
  if not f_async_data then begin
    while do_read do ;
    f_eof:=false;
    self.response;
    finish_getdir;
    end
  else begin
    winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,fd_read);
    f_eof:=false;
    f_async:=true;
    self.response;
    f_async:=false;
    winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,0);
    finish_getdir;
    end;
  end;
(*@\\\0000000501*)
(*@/// procedure t_ftp.download;                             // RETR command *)
procedure t_ftp.download;
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  if f_url<>'' then begin
    self.SendCommand('SIZE '+f_url);  (* can I use the path here? *)
    try
      self.response;
      f_size:=strtoint(f_status_txt);
    except
      f_size:=0;
      end;
    get_datasocket;
    self.SendCommand('RETR '+f_url);  (* can I use the path here? *)
    self.response;
    f_mode_intern:=tftp_download;
    f_busy:=true;
    TMemorystream(f_stream).clear;
    if not f_async_data then begin
      while do_read do ;
      f_eof:=false;
      self.response;
      finish_download;
      end
    else begin
      winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,fd_read);
      f_eof:=false;
      f_async:=true;
      self.response;
      f_async:=false;
      winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,0);
      finish_download;
      end;
    end;
  end;
(*@\\\0000000907*)
(*@/// procedure t_ftp.upload;                               // STOR command *)
procedure t_ftp.upload;
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  if f_url<>'' then begin
    get_datasocket;
    self.SendCommand('STOR '+f_url);  (* can I use the path here? *)
    self.response;
    f_mode_intern:=tftp_upload;
    f_busy:=true;
    f_size:=TMemorystream(f_stream).size;
    TMemorystream(f_stream).seek(0,0);
    if not f_async_data then begin
      while do_write do;
      finish_upload;
      end
    else begin
      winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,fd_read);
      finish_upload;
      winsock.WSAAsyncSelect(f_comm_socket,f_handle,uwm_socketevent,0);
      end;
    end;
  end;
(*@\\\0000000B0B*)

(*@/// procedure t_ftp.abort;                                // ABOR command *)
procedure t_ftp.abort;
begin
  if f_busy then begin
    self.SendCommand('ABOR');
    try
      self.response;
    except
      on EProtocolError do begin
        if f_status_nr<>426 then
          raise EProtocolError.Create('FTP',f_status_txt,f_status_nr)
        else begin
          self.response;
          f_busy:=false;
          end;
        end;
      end;
    end;
  end;
(*@\\\0000000301*)
(*@/// procedure t_ftp.noop;                                 // NOOP command *)
procedure t_ftp.noop;
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('NOOP');
  self.response;
  end;
(*@\\\0000000501*)
(*@/// procedure t_ftp.changedir(const f_dir:string);        // CWD command *)
procedure t_ftp.changedir(const f_dir:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('CWD '+f_dir);
  self.response;
  end;
(*@\\\*)
(*@/// procedure t_ftp.removefile(const filename:string);    // DELE command *)
procedure t_ftp.removefile(const filename:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('DELE '+filename);
  self.response;
  end;
(*@\\\*)
(*@/// procedure t_ftp.removedir(const dirname:string);      // RMD command *)
procedure t_ftp.removedir(const dirname:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('RMD '+dirname);
  self.response;
  end;
(*@\\\*)
(*@/// procedure t_ftp.makedir(const dirname:string);        // MKD command *)
procedure t_ftp.makedir(const dirname:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('MKD '+dirname);
  self.response;
  end;
(*@\\\*)
(*@/// procedure t_ftp.renamefile(const prior,after:string); // RNFR and RNTO commands *)
procedure t_ftp.renamefile(const prior,after:string);
begin
  if f_busy then  raise(EProtocolBusy.create);
  if not f_logged_in then login;
  self.SendCommand('RNFR '+prior);
  self.response;
  self.SendCommand('RNTO '+after);
  self.response;
  end;
(*@\\\*)

(*@/// function t_ftp.do_write:boolean; *)
function t_ftp.do_write:boolean;
var
  ok:integer;
begin
  result:=false;
  if f_socket=invalid_socket then EXIT;

  ok:=f_stream.read(f_buffer^,buf_size);
  if ok>0 then
    write_buf(f_socket,f_buffer^,ok);
  result:=ok>0;
  end;
(*@\\\0000000501*)
(*@/// function t_ftp.do_read:boolean; *)
function t_ftp.do_read:boolean;
var
  ok,ok2:integer;
  h:integer;
  p: pointer;
begin
  result:=false;
  if f_socket=invalid_socket then EXIT;
  read_var(f_socket,f_buffer^,buf_size,ok);
  p:=f_buffer;
  h:=ok;
  while ok>0 do begin   (* just to be sure everything goes into the stream *)
    ok2:=0;             (* Delphi 2 shut up! *)
    case f_mode_intern of
      tftp_download: ok2:=f_stream.write(p^,ok);
      tftp_getdir:   ok2:=f_dir_stream.write(p^,ok);
      end;
    dec(ok,ok2);
    p:=pointer(longint(p)+ok2);
    end;
  result:=h>0;
  if assigned(f_ondata_got) then
    f_ondata_got(self,f_mode_intern,h);
  end;
(*@\\\0000000901*)

(*@/// procedure t_ftp.finish_upload; *)
procedure t_ftp.finish_upload;
begin
  while do_write do ;
  f_eof:=false;
  shutdown(f_socket,1);
  closesocket(f_socket);
  f_async:=true;
  self.response;
  f_async:=false;
  if assigned(f_onaction) then
    f_onaction(self,f_mode_intern);
  f_busy:=false;
  end;
(*@\\\0000000901*)
(*@/// procedure t_ftp.finish_download; *)
procedure t_ftp.finish_download;
begin
  while do_read do ;
  f_eof:=false;
  shutdown(f_socket,1);
  closesocket(f_socket);
  f_stream.seek(0,0);  (* set the stream back to start *)
  if assigned(f_onaction) then
    f_onaction(self,f_mode_intern);
  f_busy:=false;
  end;
(*@\\\0000000701*)
(*@/// procedure t_ftp.finish_getdir; *)
procedure t_ftp.finish_getdir;
begin
  f_eof:=false;
  while do_read do ;
  f_eof:=false;
  shutdown(f_socket,1);
  closesocket(f_socket);
  self.SendCommand('TYPE I');  (* always use binary *)
  self.response;
  f_dir_stream.seek(0,0);  (* set the stream back to start *)
  f_cur_dir.clear;
  f_cur_dir.LoadFromStream(f_dir_stream);
  f_dir_stream.clear;
  f_cur_dir_index:=0;
  if assigned(f_onaction) then
    f_onaction(self,f_mode_intern);
  f_busy:=false;
  end;
(*@\\\0000000901*)

(*@/// procedure t_ftp.get_datasocket; *)
procedure t_ftp.get_datasocket;
var
  po: integer;
  ip: longint;
  s,t: string;
  temp_socket: TSocket;
  SockInfo:TSockAddr;
  f_data_socket_number: smallint;
begin
  f_socket:=INVALID_SOCKET;
(*@///   if self.passive then  ask for the port and open the socket active *)
if self.passive then begin
  self.SendCommand('PASV');
  self.response;
  if f_status_nr<>227 then
    raise EProtocolError.Create('FTP',f_status_txt,f_status_nr)
  else begin
    s:=copy(f_status_txt,pos('(',f_status_txt)+1,length(f_status_txt));
    s:=copy(s,1,pos(')',s)-1);

    po:=posn(',',s,4);
    t:=copy(s,1,po-1);
    while pos(',',t)<>0 do
      t[pos(',',t)]:='.';

(*@///     ip_address:=Winsock.Inet_Addr(PChar(t));  { try a xxx.xxx.xxx.xx } *)
(*$ifdef ver80 *)
  t:=t+#0;
  ip_address:=Winsock.Inet_Addr(PChar(@t[1]));  (* try a xxx.xxx.xxx.xx first *)
(*$else *)
 (*$ifopt h- *)
  t:=t+#0;
  ip_address:=Winsock.Inet_Addr(PChar(@t[1]));  (* try a xxx.xxx.xxx.xx first *)
 (*$else *)
  ip_address:=Winsock.Inet_Addr(PChar(t));  (* try a xxx.xxx.xxx.xx first *)
 (*$endif *)
(*$endif *)
(*@\\\0000000801*)
    s:=copy(s,po+1,length(s));
    try
      f_data_socket_number:=strtoint(copy(s,1,pos(',',s)-1))*256
                           +strtoint(copy(s,pos(',',s)+1,length(s)));
      f_socket:=self.create_socket;
      if f_async_data then
        winsock.WSAAsyncSelect(f_socket,f_handle,uwm_socketevent+1,
          fd_connect or fd_read or fd_write or fd_accept);
      self.connect_socket(f_socket, f_data_socket_number, ip_address);
    except
      f_socket:=INVALID_SOCKET;
      end;
    end;
  end
(*@\\\0000000F01*)
(*@///   else                  send the port and open the socket passive *)
else begin
  ip:=my_ip_address;
  self.SendCommand('PORT '+inttostr(ip and $000000ff       )+','+
                            inttostr(ip and $0000ff00 shr 8)+','+
                            inttostr(ip and $00ff0000 shr 16)+','+
                            inttostr(ip and $ff000000 shr 24)+','+
                            inttostr(f_port and $ff00 shr 8   )+','+
                            inttostr(f_port and $00ff         ));
  self.response;
  open_socket_in(f_socket,f_port,ip);
  (* take the first out of the queue and close the listening socket *)
  if not f_async_data then begin
    temp_socket:=accept_socket_in(f_socket,SockInfo);
    if temp_socket=INVALID_SOCKET then
      {do nothing}
    else begin
      close_socket(f_socket); (* no more listening necessary *)
      f_socket:=temp_socket;
      end;
    end;
  end;
(*@\\\0000000B01*)
  if f_async_data and (f_socket<>INVALID_SOCKET) then
    winsock.WSAAsyncSelect(f_socket,f_handle,uwm_socketevent+1,
      fd_connect or fd_read or fd_write or fd_accept);
  end;
(*@\\\0000000B01*)

(*@/// procedure t_ftp.WndProc(var Msg : TMessage); *)
procedure t_ftp.WndProc(var Msg : TMessage);
var
  temp_socket:TSocket;
  sockinfo: TSockAddr;
begin
  if msg.msg<>uwm_socketevent+1 then
    inherited WndProc(Msg)
  else begin
    if msg.lparamhi=socket_error then
    else begin
      case msg.lparamlo of
(*@///         fd_accept: *)
fd_accept: begin
  temp_socket:=f_socket;
  self.f_socket:=accept_socket_in(f_socket,sockinfo);
  close_socket(temp_socket);
  end;
(*@\\\0000000401*)
(*@///         fd_write: *)
fd_write: begin
  case f_mode_intern of
    tftp_download,
    tftp_getdir:   ;
    tftp_upload: do_write;
    end;
  end;
(*@\\\000000010B*)
(*@///         fd_read: *)
fd_read: begin
  case f_mode_intern of
    tftp_download,
    tftp_getdir:   do_read;
    tftp_upload: ;
    end;
  end;
(*@\\\0000000201*)
        fd_connect:  ;   (* can be ignored, a fd_write will come *)
(*@///         fd_close: *)
fd_close: begin
{   case f_mode_intern of }
{     tftp_download: finish_download; }
{     tftp_getdir:   finish_getdir; }
{     tftp_upload:   finish_upload; }
{     end; }
  end;
(*@\\\0000000701*)
        end;
      end;
    end;
  end;
(*@\\\0000000C01*)

(*@/// function t_ftp.getdirentry:t_filedata; *)
function t_ftp.getdirentry:t_filedata;
begin
  result:=empty_filedata;
  while (f_cur_dir_index<f_cur_dir.count) and ((result.filetype=ft_none)
      or (result.name='.') or (result.name='..')) do begin
    result:=parse_ftp_line(f_cur_dir[f_cur_dir_index]);
    inc(f_cur_dir_index);
    end;
  end;
(*@\\\0000000601*)

(*@/// function t_ftp.read_line_comm:string; *)
function t_ftp.read_line_comm:string;
begin
  result:=read_line(f_comm_socket);
  end;
(*@\\\0000000401*)
(*@/// procedure t_ftp.SendCommand(const s:string); *)
procedure t_ftp.SendCommand(const s:string);
begin
  write_s(f_comm_socket,s+#13#10);
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_sent);
  end;
(*@\\\0000000321*)
(*@\\\0000000C01*)

{ Time, RExec, LPR - the most useful UNIX services }
(*@/// class t_time(t_tcpip) *)
(*@/// constructor t_time.Create(Aowner:TComponent); *)
constructor t_time.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=37;
  f_time:=0;
  f_timemode:=tzUTC;
  end;
(*@\\\0000000601*)

(*@/// procedure t_time.action; *)
procedure t_time.action;
var
  ok:integer;
  b: byte;
  bias: integer;
begin
  login;
  f_time:=0;
  while not eof(f_socket) do begin
    read_var(f_socket,b,1,ok);
    if ok=1 then
      f_time:=f_time*256+b;
    end;
  f_time:=f_time/86400+encodedate(1900,1,1);
  if f_timemode<>tzUTC then begin
(* Alternative: use SystemTimeToTzSpecificLocalTime, but only works in NT *)
    bias:=TimeZoneBias;
    f_time:=f_time-bias/1440;  (* bias is in minutes *)
    end;
  end;
(*@\\\0000000901*)
(*@\\\0000000310*)
(*@/// class T_RCommon(t_tcpip) *)
(*@/// procedure t_rcommon.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); *)
procedure t_rcommon.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint);
begin
  close_socket(socket);
  socket:=Create_Socket;
  bind_socket(socket,512,1023);
  connect_socket(socket,Socket_number,ip_address);
  end;
(*@\\\0000000113*)
(*@/// procedure t_rcommon.action; *)
procedure t_rcommon.action;
var
  p: pointer;
  ok,ok2:integer;
begin
  login;
  while not eof(f_socket) do begin
    read_var(f_socket,f_buffer^,buf_size,ok);
    p:=f_buffer;
    while ok>0 do begin   (* just to be sure everything goes into the stream *)
      ok2:=f_stream.write(p^,ok);
      dec(ok,ok2);
      p:=pointer(longint(p)+ok2);
      end;
    end;
  f_stream.seek(0,0);  (* set the stream back to start *)
  logout;
  end;
(*@\\\0000000113*)
(*@\\\000000021B*)
(*@/// class t_rexec(t_rcommon) *)
(*@/// constructor t_rexec.Create(Aowner:TComponent); *)
constructor t_rexec.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=512;   (* rexec *)
  end;
(*@\\\0000000501*)
(*@/// procedure t_rexec.login; *)
procedure t_rexec.login;
begin
  inherited login;
  self.write_s(f_socket,f_user+#0);
  self.write_s(f_socket,f_pass+#0);
  self.write_s(f_socket,f_command+#0);
  end;
(*@\\\0000000410*)
(*@\\\0000000201*)
(*@/// class t_rsh(t_rcommon) *)
(*@/// constructor t_rsh.Create(Aowner:TComponent); *)
constructor t_rsh.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=514;   (* rsh *)
  end;
(*@\\\0000000401*)
(*@/// procedure t_rsh.login; *)
procedure t_rsh.login;
begin
  inherited login;
  self.write_s(f_socket,'0'+#0);        (* port for stderr, NYI *)
                                        (* must be a listening port on the
                                           client's side, within the reserved
                                           port range 512..1023 *)
  self.write_s(f_socket,f_user_r+#0);   (* remote *)
  self.write_s(f_socket,f_user_l+#0);   (* local *)
  self.write_s(f_socket,f_command+#0);  (* command to execute *)
  end;
(*@\\\0000000401*)
(*@\\\0000000201*)
(*@/// class T_lpr(t_tcpip) *)
(*@/// constructor t_lpr.Create(Aowner:TComponent); *)
constructor t_lpr.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=515;
  f_printtype:=lp_ascii;
  f_count:=1;
  end;
(*@\\\000000060E*)

(*@/// procedure t_lpr.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint); *)
procedure t_lpr.open_socket_out(var socket:TSocket; Socket_number:smallint;ip_address:longint);
begin
  close_socket(socket);
  socket:=Create_Socket;
  bind_socket(socket,512,1023);
  connect_socket(socket,Socket_number,ip_address);
  end;
(*@\\\0000000501*)
(*@/// procedure t_lpr.action; *)
procedure t_lpr.action;
begin
  login;
  SendPrintData;
  logout;
  end;
(*@\\\0000000501*)
(*@/// procedure t_lpr.SendPrintData; *)
procedure t_lpr.SendPrintData;
var
  ok:integer;
  i: integer;
  s: string;
  job_name: string;
  config_stream: TMemoryStream;
begin
  (* sanity checks *)
  if (f_queue='') or (f_stream.size=0) or (f_count=0) or (f_user='') then EXIT;
  s:=#02+f_queue+#10;
  write_s(f_socket,s);
  self.response;
  job_name:=inttostr(lpr_count+1000);
  job_name:=copy(job_name,length(job_name)-2,3)+my_hostname;
(*@///   collect and send the description data *)
config_stream:=NIL;
try
  config_stream:=TMemorystream.Create;
(*@///   H originating host *)
s:='H'+ip2string(my_ip_address)+#10;
stream_write_s(config_stream,s);
(*@\\\0000000120*)
(*@///   P responsible user *)
s:='P'+copy(f_user,1,31)+#10;
stream_write_s(config_stream,s);
(*@\\\*)
(*@///   M address to send the mail to *)
if f_user_mail<>'' then begin
  s:='M'+f_user_mail+#10;
  stream_write_s(config_stream,s);
  end;
(*@\\\0000000303*)
(*@///   J jobname (for banner) *)
if f_jobname<>'' then begin
  s:='M'+copy(f_jobname,1,99)+#10;
  stream_write_s(config_stream,s);
  end;
(*@\\\0000000401*)
(*@///   C class name = host name of sender (for banner) *)
s:='C'+copy(my_hostname,1,99)+#10;
stream_write_s(config_stream,s);
(*@\\\*)
(*@///   L banner page *)
if f_banner then begin
  s:='L'+f_user+#10;
  stream_write_s(config_stream,s);
  end;
(*@\\\0000000303*)
(*@///   T title (for lp_pr only) *)
if f_title<>'' then begin
  s:='T'+copy(f_title,1,79)+#10;
  stream_write_s(config_stream,s);
  end;
(*@\\\0000000303*)
(*@///   the print command itself *)
case f_printtype of
  lp_plain:   s:='l';
  lp_ascii:   s:='f';
  lp_dvi:     s:='d';
  lp_plot:    s:='g';
  lp_ditroff: s:='n';
  lp_ps:      s:='o';
  lp_pr:      s:='p';
  lp_fortran: s:='r';
  lp_troff:   s:='t';
  lp_raster:  s:='v';
  lp_cif:     s:='c';
  end;
s:=s+job_name+#10;
for i:=1 to f_count do
  stream_write_s(config_stream,s);
(*@\\\*)
(*@///   U unlink the file after the printing *)
s:='U'+jobname+#10;
stream_write_s(config_stream,s);
(*@\\\*)
(*@///   send the data *)
config_stream.seek(0,0);  (* set the stream back to start *)
s:=#02+inttostr(config_stream.size)+' cfA'+job_name+#10;
write_s(f_socket,s);
self.response;
ok:=1;
while ok>0 do begin
  ok:=config_stream.read(f_buffer^,buf_size);
  write_buf(f_socket,f_buffer^,ok);
  end;
write_s(f_socket,#0);   (* finish the config data *)
(*@\\\*)
finally
  config_stream.free;
  end;
(*@\\\0000001007*)
(*@///   send the data to print *)
s:=#03+inttostr(stream.size)+' dfA'+job_name+#10;
write_s(f_socket,s);
self.response;
f_stream.seek(0,0);  (* set the stream back to start *)
ok:=1;
while ok>0 do begin
  ok:=f_stream.read(f_buffer^,buf_size);
  write_buf(f_socket,f_buffer^,ok);
  end;
write_s(f_socket,#0);   (* finish the plot *)
(*@\\\000000081E*)
  inc(lpr_count);
  end;
(*@\\\0000001001*)
(*@/// procedure t_lpr.GetQueueStatus(detailed:boolean); *)
procedure t_lpr.GetQueueStatus(detailed:boolean);
var
  p: pointer;
  ok,ok2:integer;
  s: string;
begin
  if (f_queue='') then EXIT;
  if detailed then
    s:=#04+f_queue+#10
  else
    s:=#03+f_queue+#10;
  write_s(f_socket,s);
  while not eof(f_socket) do begin
    read_var(f_socket,f_buffer^,buf_size,ok);
    p:=f_buffer;
    while ok>0 do begin   (* just to be sure everything goes into the stream *)
      ok2:=f_stream.write(p^,ok);
      dec(ok,ok2);
      p:=pointer(longint(p)+ok2);
      end;
    end;
  f_stream.seek(0,0);  (* set the stream back to start *)
  end;
(*@\\\0000001503*)
(*@/// procedure t_lpr.response; *)
procedure t_lpr.response;
var
  b: byte;
  ok: integer;
begin
  read_var(f_socket,b,1,ok);
  if (ok<>1) or (b<>0) then
    raise EProtocolError.Create('LPR','',999);
  end;
(*@\\\0000000305*)

{ remove jobs }
{ get status }
(*@\\\0000000501*)

{ The Mail and News protocols }
(*@/// class t_smtp(t_tcpip) *)
(*@/// constructor t_smtp.Create(Aowner:TComponent); *)
constructor t_smtp.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_Socket_number:=25;
  f_receipts:=TStringList.Create;
  f_body:=TStringList.Create;
  end;
(*@\\\0000000501*)
(*@/// destructor t_smtp.Destroy; *)
destructor t_smtp.Destroy;
begin
  f_receipts.Free;
  f_body.Free;
  inherited destroy;
  end;
(*@\\\0000000501*)

(*@/// procedure t_smtp.action; *)
procedure t_smtp.action;
var
  i,j: integer;
  s: string;
begin
  if (f_receipts=NIL) or (f_receipts.count=0)
    or (f_body=NIL) or (f_body.count=0) or (f_user='') then  EXIT;
    (* not all necessary data filled in *)
  login;
  f_host:=my_hostname;
(*@///   Open Connection and submit header data *)
self.response;   (* Read the welcome message *)

self.SendCommand('HELO '+f_host);   (* open connection *)
self.response;
if f_status_nr>=300 then
  raise EProtocolError.Create('SMTP',f_status_txt,f_status_nr);

self.SendCommand('MAIL FROM: <'+address_from(f_user,1)+'>');   (* send header data *)
self.response;
if f_status_nr>=300 then
  raise EProtocolError.Create('SMTP',f_status_txt,f_status_nr);


for i:=0 to f_receipts.count-1 do begin
  j:=0;
  while true do begin
    inc(j);
    s:=address_from(f_receipts.strings[i],j);
    if s<>'' then begin
      self.SendCommand('RCPT TO: <'+s+'>');   (* submit the receipts *)
      self.response;
      (* Log error users for later check ? *)
      end
    else BREAK;
    end;
  end;

self.SendCommand('DATA');   (* ready to send the mail *)
self.response;
if f_status_nr=354 then begin
  for i:=0 to f_body.count-1 do begin
    if f_body.strings[i]='.' then f_body.strings[i]:=',';
    self.write_s(f_socket,f_body.strings[i]+#13#10);
    end;
  self.write_s(f_socket,'.'+#13#10);
  self.response;
  end;
if f_status_nr>=300 then
  raise EProtocolError.Create('SMTP',f_status_txt,f_status_nr);
(*@\\\*)
  end;
(*@\\\0000000A17*)
(*@/// procedure t_smtp.response; *)
procedure t_smtp.response;
var
  s: string;
begin
  s:=self.read_line(f_socket);
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_get);
  f_status_nr:=strtoint(copy(s,1,3));
  f_status_txt:=copy(s,5,length(s));
  (* if the answer consists of several lines read and discard all the following *)
  while pos('-',s)=4 do begin
    s:=self.read_line(f_socket);
    if assigned(f_tracer) then
      f_tracer(s,tt_proto_get);
    end;
  end;
(*@\\\0000000801*)

(*@/// procedure t_smtp.SetBody(Value: TStringList); *)
procedure t_smtp.SetBody(Value: TStringList);
begin
  if value=NIL then
    f_body.clear
  else
    f_body.assign(value);
  end;
(*@\\\0000000603*)
(*@/// procedure t_smtp.SetRecipients(Value: TStringList); *)
procedure t_smtp.SetRecipients(Value: TStringList);
begin
  if value=NIL then
    f_receipts.clear
  else
    f_receipts.assign(value);
  end;
(*@\\\0000000603*)
(*@\\\0000000401*)
(*@/// class t_pop3(t_tcpip) *)
type
(*@///   t_reply=class(TObject) *)
t_reply=class(TObject)
public
  index: integer;
  length: integer;
  from: string;
  subject: string;
  end;
(*@\\\0000000601*)

(*@/// constructor t_pop3.Create(Aowner:TComponent); *)
constructor t_pop3.Create(Aowner:TComponent);
begin
  inherited create(Aowner);
  f_list:=NIL;
  f_mail:=TStringlist.Create;
  f_list:=TList.Create;
  f_socket_number:=110;
  end;
(*@\\\0000000501*)
(*@/// destructor t_pop3.Destroy; *)
destructor t_pop3.Destroy;
begin
  f_mail.free;
  try
    if f_list<>NIL then
      while f_list.count>0 do begin
        TObject(f_list.items[0]).Free;
        f_list.delete(0);
        end;
  except
    end;
  f_list.free;
  inherited destroy;
  end;
(*@\\\0000000C01*)

(*@/// procedure t_pop3.action; *)
procedure t_pop3.action;
begin
  login;
  if f_list.count<>0 then
    getmail(1);
  logout;
  end;
(*@\\\0000000501*)
(*@/// procedure t_pop3.response; *)
procedure t_pop3.response;
var
  s: string;
begin
  s:=self.read_line(f_socket);
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_get);
  if copy(s,1,3)='+OK' then
    { everything OK }
  else if copy(s,1,4)='-ERR' then
    raise EProtocolError.Create('POP3',s,500)
  else
    raise EProtocolError.Create('POP3',s,999);
  end;
(*@\\\0000000701*)

(*@/// procedure t_pop3.Login;                         // USER, PASS, LIST *)
procedure t_pop3.Login;
var
  s: string;
  h: t_reply;
begin
  inherited login;
  self.response;
  self.SendCommand('USER '+f_user);   (* open connection *)
  self.response;
  self.write_s(f_socket,'PASS '+f_pass+#13#10);
  if assigned(f_tracer) then
    f_tracer('PASS *****',tt_proto_sent);
  self.response;
  self.SendCommand('LIST');   (* open connection *)
  self.response;
  while true do begin
    s:=self.read_line(f_socket);
    if s='.' then BREAK;
    h:=t_reply.Create;
    h.index:=strtoint(copy(s,1,pos(' ',s)-1));
    h.length:=strtoint(copy(s,pos(' ',s)+1,length(s)));
    h.from:='';
    h.subject:='';
    f_list.add(h);
    end;
  end;
(*@\\\*)
(*@/// procedure t_pop3.GetHeaders;                    // TOP *)
procedure t_pop3.GetHeaders;
var
  i: integer;
  h: t_reply;
  s: string;
begin
  f_mail.clear;
  for i:=f_list.count-1 downto 0 do begin
    h:=t_reply(f_list.items[i]);
    self.SendCommand('TOP '+inttostr(h.index)+' 1');
    try
      self.response;   (* this may give a EProtocolError on older POP server *)
      while true do begin
        s:=self.read_line(f_socket);
        if s='.' then BREAK;
        if pos('From:',s)=1 then
          h.from:=copy(s,7,length(s));
        if pos('Subject:',s)=1 then
          h.subject:=copy(s,10,length(s));
        end;
      if h.subject<>'' then
        f_mail.insert(0,h.from+#7+h.subject)
      else
        f_mail.insert(0,h.from)
    except
      on EProtocolError do
        f_mail.insert(0,inttostr(h.index));
      (* ignore errors due to unimplemented TOP *)
      end;
    end;
  end;
(*@\\\*)
(*@/// procedure t_pop3.Logout;                        // QUIT *)
procedure t_pop3.Logout;
begin
  if f_logged_in then begin
    self.SendCommand('QUIT');
    self.response;
    end;
  inherited logout;
  if f_list<>NIL then
    while f_list.count>0 do begin
      TObject(f_list.items[0]).Free;
      f_list.delete(0);
      end;
  end;
(*@\\\0000000401*)
(*@/// procedure t_pop3.GetMail(index: integer);       // RETR *)
procedure t_pop3.GetMail(index: integer);
var
  s: string;
begin
  if not f_logged_in then login;
  self.SendCommand('RETR '+inttostr(index));
  self.response;
  f_mail.clear;
  while true do begin
    s:=self.read_line(f_socket);
    if s='.' then BREAK;
    f_mail.add(s);
    end;
  end;
(*@\\\0000000601*)
(*@/// procedure t_pop3.DeleteMail(index:integer);     // DELE *)
procedure t_pop3.DeleteMail(index:integer);
begin
  if not f_logged_in then login;
  self.SendCommand('DELE '+inttostr(index));
  self.response;
  end;
(*@\\\0000000401*)
(*@\\\0000000801*)
(*@/// class t_nntp(t_tcpip) *)
(*@/// function nntpdate(date:TDateTime):string; *)
function nntpdate(date:TDateTime):string;
begin
  result:=formatdatetime('yymmdd hhnnss',date);
  end;
(*@\\\0000000330*)

(*@/// constructor t_nntp.Create(Aowner:TComponent); *)
constructor t_nntp.Create(Aowner:TComponent);
begin
  inherited create(Aowner);
  f_news:=TStringlist.Create;
  f_newsgroups:=TStringlist.Create;
  f_socket_number:=119;
  end;
(*@\\\0000000401*)
(*@/// destructor t_nntp.Destroy; *)
destructor t_nntp.Destroy;
begin
  f_news.free;
  f_newsgroups.free;
  inherited destroy;
  end;
(*@\\\0000000501*)
(*@/// procedure t_nntp.SetNews(value:TStringlist); *)
procedure t_nntp.SetNews(value:TStringlist);
begin
  if value=NIL then
    f_news.clear
  else
    f_news.assign(value);
  end;
(*@\\\0000000603*)

(*@/// procedure t_nntp.action; *)
procedure t_nntp.action;
begin
  login;
  (* ??? *)
  logout;
  end;
(*@\\\0000000401*)

(*@/// procedure t_nntp.Login; *)
procedure t_nntp.Login;
begin
  inherited login;
  self.response;
  self.SendCommand('MODE READER');   (* some NNTP servers need this *)
  try
    self.response;
  except
    (* ignore if the server doesn't understand this *)
    end;
  end;
(*@\\\0000000508*)
(*@/// procedure t_nntp.Logout;                                          // QUIT *)
procedure t_nntp.Logout;
begin
  if f_logged_in then begin
    self.SendCommand('QUIT');
    self.response;
    end;
  inherited logout;
  end;
(*@\\\0000000306*)

(*@/// procedure t_nntp.GetArticleID(msgid:string);                      // ARTICLE *)
procedure t_nntp.GetArticleID(const msgid:string);
begin
  if not f_logged_in then login;
  if msgid[1]<>'<' then
    self.SendCommand('ARTICLE <'+msgid+'>')
  else
    self.SendCommand('ARTICLE '+msgid);
  self.response;
  f_news.clear;
  GetArticleInternally;
  end;
(*@\\\0000000301*)
(*@/// procedure t_nntp.PostArticle;                                     // POST *)
procedure t_nntp.PostArticle;
var
  i:integer;
begin
  if not f_logged_in then login;
  self.SendCommand('POST');
  self.response;
  for i:=0 to f_news.count-1 do begin
    if f_news.strings[i]='.' then
      write_s(f_socket,'..'+#13#10)
    else
      write_s(f_socket,f_news.strings[i]+#13#10);
    end;
  write_s(f_socket,'.'+#13#10);
  self.response;
  end;
(*@\\\0000000601*)
(*@/// procedure t_nntp.GetAllNewsgroups;                                // LIST *)
procedure t_nntp.GetAllNewsgroups;
var
  s: string;
begin
  if not f_logged_in then login;
  f_newsgroups.clear;
  self.SendCommand('LIST');
  self.response;
  while true do begin
    s:=read_line(f_socket);
    if s<>'.' then
      f_newsgroups.add(copy(s,1,pos(' ',s)-1))
    else
      BREAK;
    end;
  end;
(*@\\\0000000601*)
(*@/// procedure t_nntp.GetNewNewsgroups(since:TDateTime);               // NEWGROUPS *)
procedure t_nntp.GetNewNewsgroups(since:TDateTime);
var
  s: string;
begin
  if not f_logged_in then login;
  f_newsgroups.clear;
  self.SendCommand('NEWGROUPS '+nntpdate(since));
  self.response;
  while true do begin
    s:=read_line(f_socket);
    if s<>'.' then
      f_newsgroups.add(copy(s,1,pos(' ',s)-1))
    else
      BREAK;
    end;
  end;
(*@\\\0000000601*)
(*@/// procedure t_nntp.SetGroup(group:string; low,high,count: integer); // GROUP *)
procedure t_nntp.SetGroup(const group:string; var low,high,count: integer);
var
  s1,s2,s3: integer;
begin
  if not f_logged_in then login;
  self.SendCommand('GROUP '+group);
  self.response;
  s1:=pos(' ',f_status_txt);
  s2:=posn(' ',f_status_txt,2);
  s3:=posn(' ',f_status_txt,3);
  count:=strtoint(copy(f_status_txt,1,s1-1));
  low:=strtoint(copy(f_status_txt,s1+1,s2-s1-1));
  high:=strtoint(copy(f_status_txt,s2+1,s3-s2-1));
  end;
(*@\\\0000000601*)
(*@/// procedure t_nntp.GetArticleNr(index:integer);                     // ARTICLE *)
procedure t_nntp.GetArticleNr(index:integer);
begin
  if not f_logged_in then login;
  self.SendCommand('ARTICLE '+inttostr(index));
  self.response;
  f_news.clear;
  GetArticleInternally;
  end;
(*@\\\0000000401*)
(*@/// procedure t_nntp.SetCurrentArticle(index:integer);                // STAT *)
procedure t_nntp.SetCurrentArticle(index:integer);
begin
  if not f_logged_in then login;
  self.SendCommand('STAT '+inttostr(index));
  self.response;
  end;
(*@\\\0000000401*)
(*@/// procedure t_nntp.GetCurrentArticle;                               // HEAD and BODY *)
procedure t_nntp.GetCurrentArticle;
begin
  if not f_logged_in then login;
  f_news.clear;
  self.SendCommand('HEAD');
  GetArticleInternally;
  f_news.add('');
  self.SendCommand('BODY');
  GetArticleInternally;
  end;
(*@\\\0000000401*)
(*@/// procedure t_nntp.GetNextArticle;                                  // NEXT *)
procedure t_nntp.GetNextArticle;
begin
  if not f_logged_in then login;
  self.SendCommand('NEXT');
  self.response;
  GetCurrentArticle;
  end;
(*@\\\0000000401*)
(*@/// procedure t_nntp.GetPreviousArticle;                              // LAST *)
procedure t_nntp.GetPreviousArticle;
begin
  if not f_logged_in then login;
  self.SendCommand('LAST');
  self.response;
  GetCurrentArticle;
  end;
(*@\\\0000000401*)

(*@/// procedure t_nntp.response; *)
procedure t_nntp.response;
var
  s: string;
begin
  s:=self.read_line(f_socket);
  if assigned(f_tracer) then
    f_tracer(s,tt_proto_get);
  try
    f_status_nr:=strtoint(copy(s,1,3));
  except
    f_status_nr:=999;
  end;
  f_status_txt:=copy(s,5,length(s));
  if f_status_nr>=400 then
    raise EProtocolError.Create('NNTP',f_status_txt,f_status_nr);
  end;
(*@\\\0000000D01*)
(*@/// procedure t_nntp.GetArticle(group:string; index:integer); *)
procedure t_nntp.GetArticle(const group:string; index:integer);
begin
  self.SendCommand('GROUP '+group);
  self.response;
  GetArticleNr(index);
  end;
(*@\\\0000000301*)
(*@/// procedure t_nntp.GetArticleInternally; *)
procedure t_nntp.GetArticleInternally;
var
  s: string;
begin
  while true do begin
    s:=read_line(f_socket);
    if s<>'.' then
      f_news.add(s)
    else
      BREAK;
    end;
  end;
(*@\\\0000000611*)
(*@\\\0000000D01*)

{ Mail and News text components }
(*@/// class t_mailnews(tcomponent) *)
(*@/// constructor t_mailnews.Create(Aowner:TComponent); *)
constructor t_mailnews.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_body:=TStringList.Create;
  f_add_header:=TStringList.Create;
  f_message:=TStringList.Create;
  end;
(*@\\\0000000603*)
(*@/// destructor t_mailnews.Destroy; *)
destructor t_mailnews.Destroy;
begin
  f_body.Free;
  f_add_header.Free;
  f_message.Free;
  inherited destroy;
  end;
(*@\\\0000000503*)

(*@/// procedure t_mailnews.SetBody(Value: TStringList); *)
procedure t_mailnews.SetBody(Value: TStringList);
begin
  if value=NIL then
    f_body.clear
  else
    f_body.assign(value);
  end;
(*@\\\0000000603*)
(*@/// procedure t_mailnews.SetHeader(Value: TStringList); *)
procedure t_mailnews.SetHeader(Value: TStringList);
begin
  if value=NIL then
    f_add_header.clear
  else
    f_add_header.assign(value);
  end;
(*@\\\0000000603*)

(*@/// procedure t_mailnews.action; *)
procedure t_mailnews.action;
begin
  f_message.insert(0,'From: '+f_from);           (* normally the first *)
  if f_sender<>'' then  f_message.add('Sender: '+f_sender);
  f_message.insert(1,'Message-ID: <'+inttostr(round((now-encodedate(1970,1,1))*86400))+'@'
     +my_hostname+'>');
  f_message.insert(2,'Date: '+internet_date(now));
  f_message.insert(3,'Subject: '+f_subject);
  if f_references<>'' then  f_message.add('References: '+f_references);
  if f_replyto<>'' then  f_message.add('Reply-To: '+f_replyto);
  f_message.addstrings(f_add_header);
  f_message.add('');  (* An empty line to separate header from body *)
  f_message.addstrings(f_body);
  end;
(*@\\\0000000B01*)
(*@\\\0000000701*)
(*@/// class t_mail(t_mailnews) *)
(*@/// constructor t_mail.Create(Aowner:TComponent); *)
constructor t_mail.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_smtp:=NIL;
  f_receipts:=TStringList.Create;
  f_cc:=TStringList.Create;
  f_bcc:=TStringList.Create;
  end;
(*@\\\0000000601*)
(*@/// destructor t_mail.Destroy; *)
destructor t_mail.Destroy;
begin
  f_receipts.Free;
  f_cc.free;
  f_bcc.free;
  inherited destroy;
  end;
(*@\\\0000000601*)

(*@/// procedure t_mail.SetRecipients(Value: TStringList); *)
procedure t_mail.SetRecipients(Value: TStringList);
begin
  if value=NIL then
    f_receipts.clear
  else
    f_receipts.assign(value);
  end;
(*@\\\0000000603*)
(*@/// procedure t_mail.SetCC(Value: TStringList); *)
procedure t_mail.SetCC(Value: TStringList);
begin
  if value=NIL then
    f_cc.clear
  else
    f_cc.assign(value);
  end;
(*@\\\0000000609*)
(*@/// procedure t_mail.SetBCC(Value: TStringList); *)
procedure t_mail.SetBCC(Value: TStringList);
begin
  if value=NIL then
    f_bcc.clear
  else
    f_bcc.assign(value);
  end;
(*@\\\0000000601*)

(*@/// procedure t_mail.action; *)
procedure t_mail.action;
var
  i: integer;
  clear_sender: boolean;
begin
  if (f_smtp=NIL) or (f_receipts=NIL) or (f_receipts.count=0)
    or (f_from='') then  EXIT;
  clear_sender:=(f_smtp.Sender='');
  if clear_sender then begin
    if f_sender<>'' then
      f_smtp.sender:=f_sender
    else
      f_smtp.sender:=f_from;
    end;

  if f_disclose_receipts then
    f_message.add('To: disclosed recipients list')
  else
    for i:=0 to f_receipts.count-1 do begin
      f_message.add('To: '+f_receipts.strings[i]);
      end;
  f_smtp.Recipients:=f_receipts;
  for i:=0 to f_cc.count-1 do begin
    f_message.add('CC: '+f_cc.strings[i]);
    f_smtp.Recipients.add(f_cc.strings[i]);
    end;
  for i:=0 to f_bcc.count-1 do begin
    f_smtp.Recipients.add(f_bcc.strings[i]);
    end;

  inherited action;
  f_smtp.message:=f_message;
  f_smtp.action;
  f_message.clear;
  if clear_sender then
    f_smtp.sender:='';
  end;
(*@\\\0000000B01*)
(*@\\\0000000801*)
(*@/// class t_news(t_mailnews) *)
(*@/// constructor t_news.Create(Aowner:TComponent); *)
constructor t_news.Create(Aowner:TComponent);
begin
  inherited create(AOwner);
  f_nntp:=NIL;
  f_newsgroups:=TStringList.Create;
  end;
(*@\\\0000000501*)
(*@/// destructor t_news.Destroy; *)
destructor t_news.Destroy;
begin
  f_newsgroups.Free;
  inherited destroy;
  end;
(*@\\\000000030F*)

(*@/// procedure t_news.SetNewsgroups(Value: TStringList); *)
procedure t_news.SetNewsgroups(Value: TStringList);
begin
  if value=NIL then
    f_newsgroups.clear
  else
    f_newsgroups.assign(value);
  end;
(*@\\\0000000603*)

(*@/// procedure t_news.action; *)
procedure t_news.action;
var
  s:string;
  i:integer;
begin
  if (f_nntp=NIL) or (f_newsgroups=NIL) or (f_newsgroups.count=0)
    or (f_newsgroups.count>10)  (* no spamming, please *)
    or (f_from='') then  EXIT;
  s:='Newsgroups: ';
  i:=0;
  while true do begin
    s:=s+f_newsgroups.strings[i];
    inc(i);
    if i<f_newsgroups.count then
      s:=s+',';
    f_message.add(s);
    if i>=f_newsgroups.count then  BREAK;
    s:='  ';
    end;
  if f_organization<>'' then  f_message.add(f_organization);
  inherited action;
  f_nntp.login;
  f_nntp.news:=f_message;
  f_nntp.PostArticle;
  f_nntp.logout;
  f_message.clear;
  end;
(*@\\\*)
(*@\\\0000000401*)

(*@/// class t_attachment(TObject) *)
(*@/// constructor t_attachment.Create; *)
constructor t_attachment.Create;
begin
  inherited create;
  f_text:=TStringlist.create;
  f_data:=TMemoryStream.Create;
  f_encoding:=ec_none;
  end;
(*@\\\0000000617*)
(*@/// destructor t_attachment.Destroy; *)
destructor t_attachment.Destroy;
begin
  f_text.free;
  f_data.free;
  inherited destroy;
  end;
(*@\\\*)

(*@/// procedure t_attachment.SetText(value:TStringList); *)
procedure t_attachment.SetText(value:TStringList);
begin
  if value=NIL then
    f_text.clear
  else begin
    f_text.assign(value);
    f_text.SaveToStream(TMemoryStream(f_data));
    end;
  end;
(*@\\\0000000701*)
(*@/// procedure t_attachment.SetData(value:TStream); *)
procedure t_attachment.SetData(value:TStream);
begin
  if value=NIL then
    TMemoryStream(f_data).clear
  else begin
    f_text.clear;
    TMemoryStream(f_data).LoadFromStream(value);
    end;
  end;
(*@\\\000000041A*)
(*@\\\*)
(*@/// class t_mime(TComponent) *)
(*@/// constructor t_mime.Create(Aowner:TComponent); *)
constructor t_mime.Create(Aowner:TComponent);
begin
  inherited Create(AOwner);
  f_attachment:=TList.Create;
  end;
(*@\\\000000040F*)
(*@/// destructor t_mime.Destroy; *)
destructor t_mime.Destroy;
begin
  if f_attachment<>NIL then begin
    try
      RemoveAllAttachments;
    except
      end;
    end;
  f_attachment.free;
  inherited Destroy;
  end;
(*@\\\0000000701*)

(*@/// function t_mime.AttachFile(const filename:string):integer; *)
function t_mime.AttachFile(const filename:string):integer;
var
  t: t_attachment;
  data: TFileStream;
begin
  t:=t_attachment.Create;
  t.kind:='application/octet-stream';
  t.encoding:=ec_base64;
  data:=NIL;
  try
    data:=TFileStream.Create(filename,fmOpenRead);
    t.data:=data;
    data.free;
  except
    data.free;
    t.free;
    raise;
    end;
  t.disposition:='attachment; filename="'+filename_of(filename)+'"';
  result:=f_attachment.add(t);
  end;
(*@\\\*)
(*@/// function t_mime.AttachText(text: TStringList):integer; *)
function t_mime.AttachText(text: TStringList):integer;
var
  t: t_attachment;
begin
  t:=t_attachment.Create;
  t.kind:='text/plain';
  t.encoding:=ec_quotedprintable;
  t.text:=text;
  t.disposition:='';
  result:=f_attachment.add(t);
  end;
(*@\\\000000060C*)
(*@/// procedure t_mime.RemoveAttachment(index: integer); *)
procedure t_mime.RemoveAttachment(index: integer);
begin
  if (index>=0) and (f_attachment.count>index) then begin
    TObject(f_attachment[index]).free;
    f_attachment.delete(index);
    end;
  end;
(*@\\\0000000301*)
(*@/// procedure t_mime.RemoveAllAttachments; *)
procedure t_mime.RemoveAllAttachments;
begin
  while f_attachment.count>0 do begin
    TObject(f_attachment[0]).free;
    f_attachment.delete(0);
    end;
  end;
(*@\\\000000031E*)
(*@/// function t_mime.GetNumberOfAttachments: integer; *)
function t_mime.GetNumberOfAttachments: integer;
begin
  result:=f_attachment.count;
  end;
(*@\\\0000000317*)

(*@/// procedure t_mime.action; *)
procedure t_mime.action;
var
  data, encoded: TStringList;
  i,j,p: integer;
  attach: t_attachment;
begin
  if f_mail=NIL then EXIT;
  boundary:=inttostr(round((now-encodedate(1970,1,1))*86400))+inttohex(my_ip_address,8)+'==';
  data:=NIL;
  p:=-1;
  try
    data:=TStringList.Create;
    f_mail.Header.add('MIME-Version: 1.0');
    f_mail.Header.add('Content-Type: multipart/mixed; boundary="'+boundary+'"');
    f_mail.Header.add('Content-Transfer-Encoding: 7bit');
    data.assign(f_mail.Body);
    if data.count>0 then begin
      f_mail.Body.clear;
      p:=AttachText(data);
      end;
    for i:=0 to f_attachment.count-1 do begin
      attach:=t_attachment(f_attachment[i]);
      f_mail.Body.Add('');
      f_mail.Body.Add('--'+boundary);
      f_mail.Body.Add('Content-Type: '+attach.kind);
      if attach.disposition<>'' then
        f_mail.Body.Add('Content-Disposition: '+attach.disposition);
      case attach.encoding of
        ec_base64:          f_mail.Body.Add('Content-Transfer-Encoding: base64');
        ec_quotedprintable: f_mail.Body.Add('Content-Transfer-Encoding: quoted-printable');
        end;
      f_mail.Body.Add('');
      case attach.encoding of
(*@///         ec_base64: *)
ec_base64: begin
  encoded:=encode_base64(attach.data);
  f_mail.Body.AddStrings(encoded);
  encoded.free;
  end;
(*@\\\0000000201*)
(*@///         ec_quotedprintable:  // only for text ! *)
ec_quotedprintable: begin
  for j:=0 to attach.text.count-1 do
    f_mail.Body.Add(eight2seven_quoteprint(attach.text[j]));
  end;
(*@\\\0000000315*)
(*@///         ec_none:             // only for text ! *)
ec_none: begin
  for j:=0 to attach.text.count-1 do
    f_mail.Body.Add(eight2seven_quoteprint(attach.text[j]));
  end;
(*@\\\0000000403*)
        end;
      end;
    f_mail.Body.Add('');
    f_mail.Body.Add('--'+boundary+'--');
    f_mail.action;
    if data.count>0 then
      f_mail.body:=data;
  finally
    data.free;
    RemoveAttachment(p);
    end;
  end;
(*@\\\0000002201*)
(*@/// procedure t_mime.SetMail(mail: TStringlist); *)
procedure t_mime.SetMail(mail: TStringlist);
(*@/// procedure strip_header(const line:string; var field,data: string); *)
procedure strip_header(const line:string; var field,data: string);
var
  h: integer;
begin
  h:=pos(':',line);
  if h>0 then begin
    field:=lowercase(copy(line,1,h-1));
    data:=trim(copy(line,h+1,length(line)));
    end
  else begin
    field:='';
    data:='';
    end;
  end;
(*@\\\0000000B12*)
var
  i,j: integer;
  s,field,data: string;
  attach: t_attachment;
begin
  boundary:='';
  RemoveAllAttachments;
(*@///   parse header lines and search for mime boundary *)
i:=0;
while (i<mail.count-1) and (mail.strings[i]<>'') do begin
  strip_header(mail.strings[i],field,data);
(*@///   if field='content-type' then *)
if field='content-type' then begin
  s:=copy(data,pos('boundary',data),length(data));
  s:=copy(s,pos('"',s)+1,length(s));
  boundary:=copy(s,1,pos('"',s)-1);
  end;
(*@\\\0000000201*)
  inc(i);
  end;
(*@\\\0000000401*)
  attach:=t_attachment.create;
  while true do begin
    inc(i);    (* ignore the empty line *)
    if i>=mail.count-1 then BREAK;
    while (i<mail.count-1) and (mail.strings[i]<>'--'+boundary) and
        (mail.strings[i]<>'--'+boundary+'--') do begin
      attach.text.add(mail.strings[i]);
      inc(i);
      end;
    case attach.encoding of
(*@///       ec_base64: *)
ec_base64: begin
  attach.data:=decode_base64(attach.text);
  attach.text:=NIL;
  end;
(*@\\\0000000301*)
(*@///       ec_quotedprintable: *)
ec_quotedprintable: begin
  for j:=0 to attach.text.count-1 do
    attach.text.strings[j]:=seven2eight_quoteprint(attach.text.strings[j]);
  end;
(*@\\\0000000301*)
      ec_none:             ;
      end;
    if mail.strings[i]='--'+boundary+'--' then  BREAK;  (* end of mime *)
    if i>=mail.count-1 then BREAK;
    if (attach.text.count>0) or (attach.data.size>0) then
      f_attachment.add(attach);
    attach:=t_attachment.create;
    inc(i);  (* ignore the empty line *)
    if i>=mail.count-1 then BREAK;
(*@///     parse mime block header *)
while (i<mail.count-1) and (mail.strings[i]<>'') do begin
  if s[1]<>' ' then
    strip_header(mail.strings[i],field,data)
  else
    data:=data+s;
  if false then
  else if field='content-type' then  attach.kind:=data
  else if field='content-disposition' then  attach.disposition:=data
(*@///   else if field='content-transfer-encoding' then begin *)
else if field='content-transfer-encoding' then begin
  data:=lowercase(data);
  if false then
  else if data='base64' then
    attach.encoding:=ec_base64
  else if data='quoted-printable' then
    attach.encoding:=ec_quotedprintable
  else
    attach.encoding:=ec_none;
  end;
(*@\\\0000000716*)
  inc(i);
  end;
(*@\\\0000000901*)
    end;
  f_attachment.add(attach);
  end;
(*@\\\0000001B33*)
(*@/// function t_mime.GetAttachment(index: integer):t_attachment; *)
function t_mime.GetAttachment(index: integer):t_attachment;
begin
  if index>f_attachment.count-1 then
    result:=NIL
  else
    result:=t_attachment(f_attachment[index]);
  end;
(*@\\\0000000306*)
(*@\\\0000000501*)

(*@/// procedure Register; *)
procedure Register;
begin
  RegisterComponents('TCP/IP', [t_finger]);
  RegisterComponents('TCP/IP', [t_fingerD]);
  RegisterComponents('TCP/IP', [t_http]);
  RegisterComponents('TCP/IP', [t_ftp]);
  RegisterComponents('TCP/IP', [t_lpr]);
  RegisterComponents('TCP/IP', [t_smtp]);
  RegisterComponents('TCP/IP', [t_mail]);
  RegisterComponents('TCP/IP', [t_nntp]);
  RegisterComponents('TCP/IP', [t_news]);
  RegisterComponents('TCP/IP', [t_time]);
  RegisterComponents('TCP/IP', [t_rexec]);
  RegisterComponents('TCP/IP', [t_rsh]);
  RegisterComponents('TCP/IP', [t_pop3]);
  RegisterComponents('TCP/IP', [t_mime]);
  end;
(*@\\\*)
(*@\\\0000003114*)
(*@/// initialization *)
begin
  lpr_count:=0;
  end.
(*@\\\*)
(*@\\\0001000011*)
