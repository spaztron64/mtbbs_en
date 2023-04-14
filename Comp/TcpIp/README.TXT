TCP/IP Component Pack  (Version 0.2beta of 1997-06-30)

After a few bad experiences with the Internet controls that Borland ships since
Delphi 2.01 and a unsuccessful search through the net for any better
components I decided to create my own ones. They are still in a beta phase but
as they work quite nice already I decided to release them to the public.

So what's better with my components:
 - you don't need to ship any additional DLL or OCX files, it's all in one EXE
 - everything is made directly with the winsock API calls, no utility units
   like dwinsock is needed
 - full source is included, so in case of an emergency you can fix any
   problems directly (only exception is the winsock in Delphi 1 which I didn't
   add as it is 99% the same as the one from Borland supplied with Delphi 2 -
   I just want to avoid copyright problems.)
 - example applications for most of the components (instead of a real
   documentation I must admit)

The following components are in available:

the communication components
T_Time     to get the date and time from any timeserver
T_RExec    to execute a program remotely (AFAIK only UNIX server know this)
T_RSh      a RExec without the need of a password
T_HTTP     to download any file using the standard WWW protocol
T_FTP      nearly everything needed for a FTP client
T_SMTP     to send emails to any SMTP server
T_POP3     to receive emails from a POP server
T_NNTP     the network news protocol to build your own newsreader
T_Finger   query users on other computers
T_FingerD  a finger demon to provide a finger service from your computer
T_lpr      remote printing protocol

utility components
T_Mail     generate a email to be inserted into a T_SMTP
T_News     generate a news article to be inserted into a T_NNTP
T_Mime     add binary files to a eMail or News article

As many components have the same names as the ones supplied with D2 you have
to uninstall these first (as I think mine are better you won't miss them),
move the *.pas and *.dcr files into Delphi's search path and add tcpip.pas to
your component library. You will then find them in the Internet tab.

If you still use Delphi 1 you just need to make sure there is a winsock.dll in
your windows system directory (otherwise your component library may become
totally unusable), and then just move the *.pas and all the files in the
subdirectory 16 into the delphi source path path and add tcpip.pas to your
component library. There's at least one incompatible winsock.pas for D1
floating around, so be sure you use the one I supply. And please note that due
to the fact I used a lot of TStringLists many components have a 32k or 64k
size limitation, e.g. the email components.

They also seem to run in Borland's C++ Builder, there you only have
to add a "#pragma warn -dup" in winsock.hpp. I don't have the C++ Builder
so I can't answer any C++ specific questions.


For the quick start just put them onto a form, set the properties you see in
the object inspector and call the action method which most of the components
have. The return value is either in the property stream as a binary TStream or
as a TStringList in the property Mail or similar.

If that's not enough here's a complete listing of the component's properties,
methods and events:

all communication components:
  property OnTrace                  Event raised on each socket operation
                                    or sending or receiving of protocol data

T_Finger:
  property stream: TStream;         The data received
  procedure action;                 Get the finger data
  property Hostname: string;        The host to connect to
  property User: string;            The user to request info of (may be empty)

T_FingerD
  procedure action;                 Start the demon
  property OnFingerRequest:TFingerRequest
                                    Callback function called on a connection
                                    attempt
  property Answer:TStringList;      The text to be sent, may be changed in
                                    OnFingerRequest for user specific answers

T_Time:
  procedure action;                 Connect and get the time
  property time:TDateTime;          The time got from the serber
  property Hostname:string;         The host to take the time from
  property TimeMode:T_TimeMode;     Get as UTC or as local time

T_HTTP:
  property stream:TStream;          The data downloaded or to be uploaded
  property content_size:integer;    Size of data (what the http server thought)
  property content_type:string;     Type of data (what the http server thought)
  procedure action;                 Get the data of the given URL
  procedure Post;                   Post the data to the given URL
  property URL:string;              The URL, if going through a proxy the
                                    http:// or ftp:// is necessary!
  property Proxy:string;            The proxy server to use, hostname[:port]
  property Sender:string;           Optionally the name of the user who
                                    requests the data
  property Agent: string;           Optionally the name of the program which
                                    requests the data
  property Reference:string;        Optionally the reference (URL which linked
                                    to the current one)
  property NoCache: boolean;        Force the proxy server to reload it
  property ContentTypePost: string; The data type for the POST method, normally
                                    'application/x-www-form-urlencoded' for
                                    form reply posts
  procedure DoBasicAuthorization(username,password)
                                    Calculate the authentication in the basic
                                    authentication schemen
  property AuthorizationRequest: TStringList
                                    The authentications understood by the server
  property Authorization            The authentication string to be sent, for
                                    schemes not yet implemented

T_SMTP:
  procedure action;                 Send the email
  property Recipients:TStringlist;  List of all receipients
  property Message:TStringList;     The actual message, see RFC 822 for the
                                    necessary header lines
  property Sender: string;          The sender of the mail
  property Hostname: string;        The SMTP server

T_POP3:
  procedure action;                 Shortcut of login; Getmail(1); logout;
  procedure Login;                  Log in to the POP server
  procedure GetHeaders;             Get the From and Subject line of all
                                    messages in the mailbox
  procedure Logout;                 Log out and eventually really delete mails
  procedure GetMail(index:integer); Download mail #index
  procedure DeleteMail(index:integer);
                                    Delete mail #index
  property Hostname: string;        The POP server
  property UserName: string;        The username on the POP server
  property Password: string;        The password of username
  property Mail: TStringlist;       The retrieved mail or the from and subject
                                    lines from the mails after a GetHeaders

T_RExec:
  procedure action;                 Launch the command
  property stream: TStream;         The screen output of the program
  property Hostname: string;        Computer to run on
  property UserName: string;        Account to use
  property Password: string;        Password for the account
  property Command: string;         Command to launch

T_Rsh:
  procedure action;                 Launch the command
  property stream: TStream;         The screen output of the program
  property Hostname: string;        Computer to run on
  property LocalUser: string;       Username on the local computer (may be
                                    needed to be allowed to issue the command)
  property RemoteUser: string;      Username on the remote computer
  property Command: string;         Command to launch

T_lpr:
  procedure action;                 Send the print job
  property Hostname: string;        Print server
  property User: string;            Account to use
  property PrintQueue: string;      Print queue name
  property MailTo: string;          Optionally mail on jub finished
  property JobName: string;         For banner: jobname
  property PrintType:t_lpr_types;   Post processing on the server
  property CopyCount:integer;       Number of copies
  property PrintBanner:boolean;     Print a banner page
  property PrintTitle:string;       Title of the job (only for printtype
                                    lp_pr)

T_NNTP:
  property News: TStringlist;       The article retrieved / to be sent
  property NewsGroups: TStringlist; List of newsgroups retrieved
  procedure Login;                  Log in
  procedure Logout;                 Log out
  procedure GetArticle(const group:string; index:integer);
                                    To get an article from a URL like
                                    nntp://hostname/number
  procedure GetArticleID(const msgid:string);
                                    To get an article from a URL like
                                    news:msgid
  procedure PostArticle;            Post the article
  procedure GetAllNewsgroups;       Download all newsgroups available on the
                                    server (warning: takes long and much
                                    memory, in 16bit the Stringlist is too
                                    small)
  procedure GetNewNewsgroups(since:TDateTime);
                                    Download newsgroups added after the given
                                    date
  procedure SetGroup(const group:string; var low,high,count: integer);
                                    Jump to a group, gives back High and Low
                                    pointers
  procedure GetArticleNr(index:integer);
                                    Retrieve article #number in the current
                                    group
  procedure SetCurrentArticle(index:integer);
                                    Set current article to #number in current
                                    group
  procedure GetCurrentArticle;      Retrieve the current article
  procedure GetNextArticle;         Step the current article by one and
                                    retrieve the article
  procedure GetPreviousArticle;     Set the current article back by one and
                                    retrieve the article
  property Hostname: string;        The NNTP server

T_FTP:
  procedure changedir(const f_dir:string);
                                    Change to the directory given
  procedure removefile(const filename:string);
                                    Delete the file given
  procedure removedir(const dirname:string);
                                    Remove the directory given
  procedure makedir(const dirname:string);
                                    Create new directory with the name given
  procedure renamefile(const prior,after:string);
                                    Rename file from "prior" to "after"
  procedure getdir(const dirname:string);
                                    Get the directory listing of the directory
                                    given, use getdirentry to get the file
                                    data
  function getdirentry:t_filedata;  Get the next entry in the current
                                    directory, is "empty_filedata" after
                                    completion of the list
  property stream: TStream;         The (binary) data downloaded or to be
                                    uploaded
  procedure login;                  Log in
  procedure logout;                 Log out
  procedure download;               Download the file given by URI
  procedure upload;                 Upload the data in stream to a file named
                                    URI
  procedure abort;                  Abort current data transfer (asynchronous
                                    only)
  procedure noop;                   No operation - to keep the connection alive
  procedure action;                 Login, Upload/Download (depending on
                                    mode), logout
  property Hostname: string;        The FTP server
  property URI: string;             The filename
  property Username:string;         The Account to use (normally ftp or
                                    anonymous)
  property Password:string;         The login password (for anonymous ftp your
                                    email)
  property Passive:boolean;         Wether the server or the client should
                                    build the data connection (should be true
                                    if behind a firewall)
  property Port:word;               The port the ftp server uses (normally 21)
  property Mode:t_ftp_mode;         Download or Upload in action
  property Size;                    (readonly) size of the current transfer
  property Async:boolean;           Asynchronous ore blocking data transfer
                                    (communication socket is still blocking!)

T_MailNews: common things for Mail and News components
  property From: string;            Author of the mail
  property Sender: string;          User who sends the mail (as normally the
                                    same as the author can be left empty)
  property Body: TStringList;       The mail text (should be 7bit!)
  property Header: TStringList;     Additional header lines, e.g. "Keywords:"
  property Subject:string;          The subject of the mail/article
  property References:string;       Mails or articles (MSG-Ids) this one
                                    refers to
  property ReplyTo:string;          Where answers should be sent to

T_Mail:
  procedure action;                 Compile the email and call the action of
                                    the SMTP given
  property SMTP: T_SMTP;            The component for the sending
  property Disclose_Receipts:boolean;
                                    For mailing lists: should the recepient
                                    list be shown to everyone
  property Recipients:TStringlist;  The receipients of the mail
  property CC:TStringlist;          The carbon-copy receipients of the mail
  property BCC:TStringlist;         The blind carbon-copy receipients of the
                                    mail (invisible to all other recipients)

T_News:
  procedure action;                 Compile the article and post it through
                                    the given NNTP component
  property NNTP: T_NNTP;            The component for the posting
  property Newsgroups: TStringlist; The newsgroups to be posted in (limited to
                                    10 to avoid spamming)
  property Organization: string;    Optionally the organization you're in

T_Mime:
  function AttachFile(const filename:string):integer;
                                    Add the file to the list of attached files
                                    Return value is the number of the attachment
  function AttachText(text:TStringlist):integer;
                                    Add a text attachment
  procedure action;                 Compile the mail and send it through the
                                    given Mail or News component
  property Mail: T_MailNews;        The article/email component the files
                                    should be attached to
  procedure RemoveAllAttachments;   Clean the Attachments list
  property Attachment[index]:T_Attachment;
                                    To access attachments by number, may return
                                    NIL for an illegal index
  property NumberOfAttachments:integer;
                                    The name says it all
  procedure SetMail(mail: TStringlist);
                                    Import a mail, used to get the attachments
                                    out of a mail received via T_pop3

T_Attachment:   the internal type of the Attachments
  property Kind: string;            MIME type of the data, default is
                                    application/octet-stream for binary
                                    and text/plain for text
  property Disposition;             for options like the original filename
  property Encoding: T_Encoding;    ec_base64, ec_quotedprintable, ec_none
  property Text:TStringlist;        ASCII (may be 8bit) text (no ec_base64
                                    encoding)
  property Data:TStream;            binary data (encoding ec_base64 only!)


The demo applications:
dilbert     A automatic Dilbert downloader using the HTTP component and a
            little bit of HTML parsing (*)
httpdemo    A very simple http-URL downloader
demon       A finger demon
smtpdemo    A little EMail sending program using T_SMTP, T_Mail and T_Mime (*)
newsdemo    A simple Newsreader as a T_NNTP demo
timedemo    A client program using the T_Time component including the setting
            of the time (also shows how to set the date and time with D1 or D2)
pop_demo    A simple POP-Mail receiver
ftpdemo     A ftp directory dialog

(*) 32 bit only - I used some Win32 API calls or Win'95 controls in them

To compile the demos using Delphi 1 you have to move the *.res file out of
subdirectory 16, the one put into the main directory of the demo is the 32 bit
resource.

To do: there're still some protocol not covered by my components, e.g. the IMAP
as the successor of POP3 or IRC (currently in work). I plan to add some more
demon components in the future, and as a big project to convert all the
components from blocking calls to asynchronos ones (so you can continue with
your application while it is downloading a file, but you can simulate this by
using Threads); I already started this with the ftp component. I also plan to
add a file dialog based upon the ftp components similar to those from Windows
itself (look at the ftp demo to see what I mean). Maybe make further demo
applications or make the existing ones better. And of course if somebody has
a really good idea what should be done I may put it onto this list, too.

By the way: there are two further internet components by me, TPing and
TTraceroute (but these only for 32 bit), both in the package ICMP. I'll merge
both component packs once both are somewhat "completed", that means I give
them the 1.0 version number. (I've to update them soon as a few things changed
in the common unit ip_misc, you can only use both V0.1 or both V0.2)

If you wonder about some strange comment lines within the source code: these
are created by the editor I use, they contain folding information, so the
source is much easier to be searched. If you're interested - you can find a
shareware version (sorry, only German currently) of the editor at
  ftp://ftp.scp.de/pub/support/gimmick/fold0992.zip
Although a little bit ancient (still a DOS application) it IMHO raises
productivity quite a lot.


Acknowledgements:
A very good help to build these components was the book "Building Internet
applications with Delphi 2" by Davis Chapman et.al., Que Publishing. There you
can find a brief intoduction into the TCP/IP networking, the winsock
programming, the basic internet protocols and how to put it all together for
some applications.

Quite a lot of people already reported bugs, to name them all would make this
file too long, I just thank all of you (and to those who only sent kind words,
too), and keep on writing.


If you spot any bug, have any idea how to improve, want to let me know what a
great job I did :-), want to notify me of the use any part of this component
for your own one, want to hear from me when I throw something new into the
public, or for any other reason, you can mail me (I try to answer every mail,
as long as possible - if you don't get a answer I'm either too busy or still
trying to solve the problem you reported):

ah@scp.de                (at work)
andreas@hoerstemeier.de  (at home)
http://www.westend.de/~hoerstemeier
snail mail: Andreas H"orstemeier
            Mefferdatisstrasse 16-18
            52062 Aachen
            Germany

["o means the umlaut o, that is an o with two dots above]


The status of these components is not yet clear, they may either become
Public Domain like my other components or may become commercial as there's
already some interest to buy them. Until that thing is settled you may use
them freely, but be aware of the beta status.

If you feel they already deserve more than a thank you you can send me a nice
postcard from your hometown; if you still think that'd be not enough as they
saved you quite a lot of money you can of course sent me some money (by the way
the cheapest shareware internet components are AFAIK at about 50$), but note
this would be a gift and not a payment.


Andreas H"orstemeier
