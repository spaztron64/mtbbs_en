{
  FileList - File ListView components for Delphi 2
  © Amedeo Lanza <amldc@tin.it>

 note for Delphi 3 users:
  I did not test it with Delphi 3 nor NT, but some users reported me this
  works fine with them.
  I had a report (and fixed upon suggestion) of a warning message under NT (see
  v2.0 release notes)
  Also I had a report (for Delphi 3) of GPF starting the program with
  the MultiSelect property set to true. I did not fix this as I tested it with
  new version (and Delphi 2), and did not find such problem.

description:
 TFileView is a ListView which links system image lists on creation and can
 accept files dropped from Windows' Explorer.
 TFileList is a FileView descendant wich encapsulates some system functions to
 mix ancestor's capability with the FileListBox's Directory and Mask properties.
 Thus specifying a path name and a file mask, the control will be filled with
 the list of matching files, showing proper icons and a customizable set of file
 informations (more than found in the Explores's file window).

 The reference section of this source was removed, so PLEASE SEE DOCUMENTATION
 FOR REFERENCE about the controls in this source.

copyright & license
 This source is Copyright © of Amedeo Lanza di Casalanza. You may freely use,
 modify and distribute this software for non commercial purposes and for writing
 freeware and/or shareware software. You MAY NOT SELL this software although you
 may include it in software collection you distribute, provided there is no
 charge for the software itself. Please leave the copyright information and any
 additional information (readme.* ecc.) provided with the original author's
 copy.
 Use of this software for building of commercial programs should be expressely
 authorized by the author.
 Any use of this software for illegal activities is prohibited.

 If you enhance this software or fix any bug, please send the new source to
 the author.

usage:
  Drop a TFileList and some controls to handle Directory and File Mask
  selections, then add some line of code to set the Directory and Mask
  properties of TFileList upon selection from other controls ...just as you
  where using a TFileListBox control :-)

dependencies:
  Marcus Stephany's MASKSEARCH utility unit is needed. You may find it on DSP
  in the MSTGREP.ZIP archive in Delphi 2.0 freeware section.

comments:
  uses FindFirstFile, FindNextFile and FindClose API calls from Windows unit to
  retrieve file list with better performances and ShGetFileInfo to retrieve
  extended informations.
  To find help about TWin32FindData look for WIN32_FIND_DATA in the Win32
  Programmer's Reference and TWin32FindData in Windows unit (if you have the
  RTL sources you can find it in the source\rtl\win directory.

current known limitations :
  Tested only with Delphi 2.0 and Win95, requires anyway Win32s,Win95 or WinNT
  as uses Win32 API calls.
  Handles only File Items, System Resources cannot be displayed as in an
  Explorer's window.
  Columns order is fixed, and settings of columns' width and caption is quite
  trivial; I hope I (or someone else) will be able to add a property editor for
  that.
  I had several requests about speeding up the item loading and display; i
  will try to implement a more effective algorithm but i'm not expert with
  threads and specific optimizing techniques. Any help is welcome!



DISCLAIMER:
 I ASK NO FEE and I GIVE NO WARRANTY for this software, either expressed or
 implied. Use it AT YOUR OWN RISK.

suggestions, bug reports & comments to the author:
 Amedeo Lanza di Casalanza
 from: Torino, Italy
 mailto:amldc@tin.it
 http://volftp.tin.it/IT/IT/COLLABORAZIONI/LANZA/index.htm

WARNING FOR EMAIL ABUSE:
 *BORLAND DELPHI* related messages are WELCOME, any other use of the author's
 email address for unsolicited ADVERTISING is STRICTLY PROHIBITED.

aknowledgement:
 Portions of this software come from freeware examples by
  Markus Stephany
  MirBir.St@T-Online.de
  http://home.t-online.de/home/MirBir.St/
 wich I found on Delphi Super Page (http://SunSITE.icm.edu.pl/delphi/)

also thanks for hints to the very good "Unofficial Newsletter of Delphi Users"
(UNDU) at http://www.informant.com/undu/index.htm

history:

 v2.4 28-nov-1997 - amldc@tin.it
   + fixed bug in the UpdateFileList routine (a missing begin-end couple)
     thanks to James F. Wendel

 v2.3 14-nov-1997 - amldc@tin.it
   + moved BeginUpdate before sort order change
   + fixed wrong icon display for '..' directories

 v2.2 03-nov-1997 - amldc@tin.it
   + Fixed CheckAttributes routine. Was tested Archive attribute instead of
     ReadOnly.

 v2.1 20-oct-1997 - amldc@tin.it
   + moved SetupFileColumns from Protected to Public. This allow runtime
     creation and proper build of display columns. After creating a TFileList
     you should call its SetupFileColumns method.

 v2.0a 09-oct-1997 - amldc@tin.it
   + intermediate release for beta tester
   + added boolean function  IsDirectory (Item :TListItem), returns if the
     specified item is a directory
   + added boolean property DisplayParentDir to enable or disable display of
     parent directories ("..") - has a little bug: parents for 1st level folders
     (e.g. root pointers) get wrong system icon index. I'll try to fix it by
     forcing correct value.

 v2.0 25-sep-1997 - amldc@tin.it
   + Wrong item was reported when "\" leaking at end of used path. Fixed by
     ensuring loaded path strings always end with a "\".
   + Added check to prevent SortColumn being set to unused column.
   + Splitted code, inserted TFileListView as ancestor and TFileView.
     TFileListView embeds System Image List handling and File Drop
   + AddFile is now a virtual method for both types and behave quite in a
     different way: in TFileView provides to get the needed informations
   + Added OnFileAdd property
   + Added ability to get files dropped from Explorer
   + Added fix to avoid warning message under WinNT when setting directory to an
     empty drive (thanks to Sebastian Hildebrandt <hildebrandt@t0.or.at>)
   + Updated for my modified version of MaskSearch (with case match handling).
     This feature is not fully tested.

 v1.1 14-sep-1997 - amldc@tin.it
   + Added SetupFileColumns in SetColWidth, needed if changing widths when
     component visible.
   + Modified SetDirectory to allow empty directory and skipping of directory
     scan.
   + Added support for directory list specification.
   + Added usage of Marcus Stephany's MaskSearch unit (see dependencies note
     above) for file search and support for file mask list specification.
   + Added FileTypes property for file attribute based filtering
   + DOS file name (cAlternateFilename) forced to Win file name (cFilename) when
     returned empty (in Win32FindData) from FindFirstFile and FindNextFile.
   + Added fiDosExt column (mainly for DOS extension based sorting)
   + Added fiAll (display all columns) and modified default set of columns to
     reflect the Explorer's one.

 v1.0 10-aug-1997 - amldc@tin.it
   + first development

}

unit FileList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ShellApi, MaskSearch;

type

  
  

  // callback for Drop file
  TFileDropEvent = procedure(Files: Tstrings; X, Y: Integer) of object;
  // System ListView

  TTypeIconList = class (TStringList)
  public
    procedure AddType (WinType :string; IconIndex :integer);
    function IconOf (Wintype :string) :integer;
  end;

  TFileListView = class(TCustomListView)
  private
    FAcceptFiles: Boolean;
    FOnFileDrop: TFileDropEvent;
    FTypeIconList :TTypeIconList;
    procedure GetSystemImageList; // load LargeImages and SmallImages
    procedure WMDROPFILES(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure SetAcceptFiles(Accept: Boolean);
  protected
    { Protected declarations }
    constructor Create (aOwner :TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
  public
    function AddFile (FileName :TFileName) :TListItem; virtual;
    function AddDir  (FileName :TFileName) :TListItem; virtual; // add a directory
  published
    { Published inherited declarations }
    property Align;
    property BorderStyle;
    property Color;
    property ColumnClick;
    property OnClick;
    property OnDblClick;
    property Ctl3D;
    property DragMode;
    property ReadOnly;
    property Font;
    property HideSelection;
    property IconOptions;
    property Items;
    property AllocBy;
    property MultiSelect;
    property OnChange;
    property OnChanging;
    property OnColumnClick;
    property OnCompare;
    property OnDeletion;
    property OnEdited;
    property OnEditing;
    property OnEnter;
    property OnExit;
    property OnInsert;
    property OnDragDrop;
    property OnDragOver;
    property DragCursor;
    property OnStartDrag;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property ParentShowHint;
    property ShowHint;
    property PopupMenu;
    property ShowColumnHeaders;
    property SortType;
    property TabOrder;
    property TabStop default True;
    property ViewStyle;
    property Visible;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    {class specific published properties}
    property AcceptFiles: Boolean read FAcceptFiles write SetAcceptFiles;
    property OnFileDrop: TFileDropEvent read FOnFileDrop write FOnFileDrop;
  end;

  // Just exports the needed inherited properties
  TFileView = class(TFileListView)
  published
    { Published inherited declarations }
    property Columns;
  end;

  ///////////////
  // TFileList //
  ///////////////

  // specialized list for patterns handling
  TPatternList = class (TStringList)
  public
    procedure AddPatterns(S :string);
  end;

  // file attributes
  TFileType =({ftDirectory,}ftArchive,ftReadonly,
              ftSystem,ftHidden,{ftCompressed,}ftTemporary,ftAll);
  TFileTypes = Set of TFileType;

  // file informations (display columns)
  TFileInfo = (fiName,fiSize,fiType,
               fiModified,fiCreated,fiLastAccess,
               fiAttributes,fiDosName,fiDosExt,fiPath,fiAll);
  TFileInfos = Set of TFileInfo;

  // Column settings structure
  TColumnInfo = record
    Caption   :TCaption;   // Column caption
    Width     :integer;    // Column Width
    Alignment :TAlignment; // Column Alignement
    Column    :integer;    // Column Number
  end;
  TColumnInfos = array [TFileInfo] of TColumnInfo;
  TInfoColumn = array [0..Ord(Pred(fiPath))] of TFileInfo;


  // callback for items insertion
  TFlInsertEvent = procedure (Sender: TObject; Item: TListItem; Path: string; FindData :TWin32FindData) of object;

  // TFileList is a TListView clone wich behaves like Windows Explorer's file window
  TFileList = class(TFileListView)
  private
    { Private declarations }
    fFileTypes        :TFileTypes;      // file attributes
    fDirectory        :TPatternList;    // current directory
    fFileMask         :TStringList;     // file specifications list
    fDisplayDir       :boolean;         // include directories in file scan
    fDisplayParentDir :boolean;         // show '..' directory
    fViewColumns      :TFileInfos;      // visible columns
    fSortColumn       :TFileInfo;       // current sort column
    fOnFileAdd        :TFLInsertEvent;  // chance to add custom info
    procedure UpdateFileList;       // scan the directory and load file list
    procedure SetupFileColumnInfos; // dynamic creation of columns
  protected
    { Protected declarations }
    procedure ColClick(Column: TListColumn); override;
    procedure Loaded; override;
    function  GetMask :string;  // Get file specifications
    function  GetPath :string;  // Get search path list
    procedure SetDisplayDir  (Display :boolean);  // enable/disable list of dirs
    procedure SetDisplayParentDir  (Display :boolean);  // enable/disable list of dirs
    procedure SetFileTypes (FT :TFileTypes);
    procedure SetMask (Mask :string); // Set file specifications
    procedure SetPath (Path :string); // Set search path specifications
    procedure SetSortColumn  (Column :TFileInfo);
    procedure SetViewColumns (Columns :TFileInfos);
    procedure AddFileData (NewItem :TListItem; Path :string; FindData :TWin32FindData); // add a file
  public
    { Public declarations }
    constructor Create (aOwner :TComponent); override;
    destructor Destroy; override;
    function  AddFile   (FileName :TFileName) :TListItem; override; // add a file
    procedure AddMask   (Mask :string); // Add file specifications
    procedure AddPath   (Path :string); // Add search path specifications
    function  IsDirectory (Item :TListItem) :boolean;
    procedure SetColCaption (Col: TFileInfo; Value :string); // set column caption
    procedure SetColWidth   (Col: TFileInfo; Value :integer); // set column width
    procedure SetupFileColumns;
  published
    {class specific published properties}
    // The Directory property lets you specify a directory or a list of directories.
    // Upon change the specified paths will be used to retrieve and load matching files.
    // Use the Mask property to specify a file mask or a list of file masks.
    // List of paths and/or file masks may be separated by commas or semicolumns.
    // Setting the Directory property to a null string will prevent directory scan and
    // allow manual file loading.
    property Directory :string read GetPath write SetPath;
    property FileTypes :TFileTypes read fFileTypes write SetFileTypes;
    property DisplayDirectory :boolean read fDisplayDir write SetDisplayDir default true;
    property DisplayParentDir :boolean read fDisplayParentDir write SetDisplayParentDir default true;
    property Mask :string read GetMask write SetMask;
    property OnFileAdd :TFLInsertEvent read fOnfileAdd write fOnFileAdd;
    property SortColumn :TFileInfo read fSortColumn write SetSortColumn default fiName;
    property ViewColumns :TFileInfos read fViewColumns write SetViewColumns;
  end;

procedure Register;

implementation

var
  InvertSort :boolean; // used to invert sorting when column clicked twice
  fColumnInfos  :TColumnInfos;  // columns informations
  fInfoColumn   :TInfoColumn;   // columns informations
  DirShellInfo :TShFileInfo;
  WinDir :PChar;

////////////////////////////////////////////////////////////////////////////////
// utility List subclasses
////////////////////////////////////////////////////////////////////////////////

// TPATTERNLIST
// add patterns from the specified string
// in format aaa;bbb;ccc ecc.
procedure TPatternList.AddPatterns(S :string);
var
  Pattern :string;
  Rest    :string;
  P :integer;
begin
  if S = '' then Exit; // avoid empty patterns
  Rest := S;
  Pattern := '';
  P := Pos(';',Rest);
  while (Rest <> '') and (P > 0) do
  begin
    Pattern := Copy(Rest,1,P-1);
    Rest    := Copy(Rest,P+1,Length(Rest));
    // ensure all paths have an ending backslash
    if Pattern[Length(Pattern)] <> '\' then Pattern := Pattern + '\';
    Add(Pattern);
    P := Pos(';',Rest);
  end;
  if Rest[Length(Rest)] <> '\' then Rest := Rest + '\';
  Add(Rest);
end;

// TTYPEICONLIST
procedure TTypeIconList.AddType (WinType :string; IconIndex :integer);
begin
  Add (format('%s=%d',[WinType,IconIndex]));
end;

function TTypeIconList.IconOf (WinType :string) :integer;
var
  S :string;
begin
  S := Values[WinType];
  if S = '' then
    S := '-1';
  Result := StrToInt(S);
end;

////////////////////////////////////////////////////////////////////////////////
// UTILITIES
////////////////////////////////////////////////////////////////////////////////

//
// Sorting Routine
//
function SortProc (Item1,Item2 :TListItem; ColIndex :integer) :integer; stdcall;
var
  Caption1,Caption2,
  String1,String2,
  Attributes1,Attributes2 :string;
begin
  Result := 0; // Defaults to equal
  // Tests Column[1] (Size) to force Directories before Files
  if (Item1.SubItems[0] = '') and (Item2.SubItems[0] <> '') then Result := -1
  else
    // Tests Column[1] (Size) to force Directories before Files
    if (Item1.SubItems[0] <> '') and (Item2.SubItems[0] = '') then Result := 1
    else
    //
    // both items are directory or file
    //
    begin
      // if ColIndex is 0, just a sort by NAME is required
      if ColIndex < 1 then
      begin
        // Converts NAME to uppercase to ignore case
        Caption1 := AnsiUpperCase(Item1.Caption);
        Caption2 := AnsiUpperCase(Item2.Caption);
        // Compare NAMES
        if Caption1 > Caption2 then Result := 1 else
        if Caption1 < Caption2 then Result := -1;
      end
      else
      begin
        // checks for invalid column specified (1st item)
        if Item1.SubItems.Count < ColIndex then String1 := ''
        else String1 := AnsiUpperCase(Item1.SubItems[ColIndex-1]);
        // checks for invalid column specified (2nd item)
        if Item2.SubItems.Count < ColIndex then String2 := ''
        else String2 := AnsiUpperCase(Item2.SubItems[ColIndex-1]);

        // compare the selected values
        if String1 > String2 then Result := 1 else
          if String1 < String2 then Result := -1 else
          {if String1 = String2 then} // stings are equal, try to sort on Caption
            begin
              // Converts NAME to uppercase to ignore case
              Caption1 := AnsiUpperCase(Item1.Caption);
              Caption2 := AnsiUpperCase(Item2.Caption);
              // Compare NAMES
              if Caption1 > Caption2 then Result := 1 else
              if Caption1 < Caption2 then Result := -1
            end;
      end;
    // invert Sort if requested
    if InvertSort then Result := Result * -1; // is sort reverted ?
    // Date-Time field sorted in reverse order
    if fColumnInfos[fiCreated].Column = ColIndex then Result := Result * -1
    else if fColumnInfos[fiModified].Column = ColIndex then Result := Result * -1
    else if fColumnInfos[fiLastAccess].Column = ColIndex then Result := Result * -1;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// STRING ROUTINES
////////////////////////////////////////////////////////////////////////////////

// Get Shell Info for the specified file
// procedure GetShellFileInfo (FileName :TFileName; var ShFileInfo :TShFileInfo);
// begin
//  ShGetFileInfo (PChar(FileName),0,ShFileInfo,SizeOf (ShFileInfo),
//                 shgfi_SysIconIndex or shgfi_Icon or
//                 shgfi_DisplayName or shgfi_TypeName or
//                 shgfi_SmallIcon);
// end;

// Convert Size for Sort
function SizeStr (Size,Typ :integer ) :string;
begin
  if (Typ and file_attribute_Directory) = file_attribute_Directory then
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
function GetLocalTime(a:tfiletime):string;
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

////////////////////////////////////////////////////////////////////////////////
// CLASS METHODS FOR TSystemFileList
////////////////////////////////////////////////////////////////////////////////
constructor TFileListView.Create (aOwner :TComponent);
begin
  inherited Create (aOwner);
  FAcceptFiles := False;
  FTypeIconList := TTypeIconList.Create;
  GetSystemImageList;    // get system icon list
end;

destructor TFileListView.Destroy;
begin
  // SmallImages.Free; // needed ?
  // LargeImages.Free; // needed ?
  FTypeIconList.Free;
  inherited Destroy;
end;
procedure TFileListView.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, FAcceptFiles);
end;

procedure TFileListView.WMDROPFILES(var Msg: TWMDropFiles);
var
  i, DropCount, BufSize: integer;
  FileName: pChar;
  FileList: TStrings;
  Point: TPoint;
begin
  BufSize := 0;
  DropCount := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, BufSize);
  FileList := TStringList.Create;
  try
  for i := 0 to DropCount - 1 do begin
    BufSize := DragQueryFile(Msg.Drop, i, nil, BufSize) + 1;
    FileName := StrAlloc(BufSize + 1);
    try
      DragQueryFile(Msg.Drop, i, FileName, BufSize);
      FileList.Add(FileName);
      DragQueryPoint(Msg.Drop, Point);
    finally
      StrDispose(FileName);
    end;
  end;
  DragFinish(Msg.Drop);
  if Assigned(FOnFileDrop) then
    FOnFileDrop(FileList, Point.X, Point.Y)
  finally
    FileList.Free;
  end;
end;

procedure TFileListView.setAcceptFiles(Accept: Boolean);
begin
  if not (csDesigning in ComponentState) then
    DragAcceptFiles(Handle, Accept);
  FAcceptFiles := Accept;
end;

// Get System Image List
procedure TFileListView.GetSystemImageList;
var
  SysImageList :uint;      // temporary handle for System ImageLists
  ShFileInfo :TShFileInfo; // Shell File Info structure
begin
  LargeImages := TImageList.Create(self);
  SysImageList := ShGetFileInfo('',0,ShFileInfo,SizeOf(ShFileInfo),shgfi_SysIconIndex or shgfi_LargeIcon);
  if SysImageList <> 0 then
  begin
    LargeImages.Handle := SysImageList;
    LargeImages.ShareImages := true; // Avoid freeing of System Image List !
  end;
  SmallImages := TImageList.Create(self);
  SysImageList := ShGetFileInfo('',0,ShFileInfo,SizeOf(ShFileInfo),shgfi_SysIconIndex or shgfi_SmallIcon);
  if SysImageList <> 0 then
  begin
    SmallImages.Handle := SysImageList;
    SmallImages.ShareImages := true; // Avoid freeing of System Image List !
  end;
end;

// adds a file and returns the newly added item

function TFileListView.AddFile (FileName :TFileName) :TListItem;
var
  ShFileInfo :TShFileInfo;
begin
  Result := Items.Add;
  // Get Windows file name and system icon index
  ShGetFileInfo (PChar(FileName),0,ShFileInfo,SizeOf (ShFileInfo),
                 shgfi_SysIconIndex or {shgfi_Icon or}
                 shgfi_DisplayName  or shgfi_SmallIcon);
  Result.Caption := ShFileInfo.szDisplayName; // Set the item caption
  Result.ImageIndex := ShFileInfo.IIcon;      // Set file icon index
end;

function TFileListView.AddDir (FileName :TFileName) :TListItem;
var
  ShFileInfo :TShFileInfo;
begin
  Result := Items.Add;
  Result.Caption := '????';
  Result.ImageIndex := DirShellInfo.IIcon;      // Set file icon index
end;

////////////////////////////////////////////////////////////////////////////////
// CLASS METHODS FOR TFileList
////////////////////////////////////////////////////////////////////////////////

// Object creation
constructor TFileList.Create (aOwner :TComponent);
begin
  inherited Create(aOwner);
  fDisplayDir := true;   // include directory in display
  fFileTypes  := [ftArchive,ftReadonly]; // default searched file type
  fSortColumn := fiName; // set default sort to Name
  fViewColumns := [fiName,fiSize,fiType,fiModified]; // columns useb by Explorer

  SetupFileColumnInfos;  // load column configuration
  InvertSort := false;   // default is normal sort

  fDirectory := TPatternList.Create;   // Search Path list
  fDirectory.Sorted := true;          // sorted and
  fDirectory.Duplicates := dupIgnore; // ignore duplicates

  fFileMask := TStringList.Create;     // File Specifications list
  fFileMask.Sorted := true;            // sorted and
  fFileMask.Duplicates := dupIgnore;   // ignore duplicates
  fFileMask.Add('*.*');
end;

procedure TFileList.Loaded;
begin
  inherited Loaded;
  SetupFileColumns;     // build listview columns
end;

// Object deletion
destructor TFileList.Destroy;
begin
  fFileMask.Free;      // releases child component
  fDirectory.Free;    // releases child component
  inherited Destroy;
end;
////////////////////////////////////////////////////////////////////////////////
// INITIALIZATION
////////////////////////////////////////////////////////////////////////////////

procedure TFileList.SetColCaption (Col: TFileInfo; Value :string);
begin
  if fColumnInfos[Col].Caption = Value then Exit;
  fColumnInfos[Col].Caption := Value;
end;
procedure TFileList.SetColWidth (Col: TFileInfo; Value :integer);
begin
  if fColumnInfos[Col].Width = Value then Exit;
  fColumnInfos[Col].Width := Value;
  SetupFileColumns; // V1.1: needed if changing widths when component visible
end;

// Sets up columns infos for ListView
procedure TFileList.SetupFileColumnInfos;
begin
  // column properties for NAME
  fColumnInfos[fiName].Caption := 'Name';
  fColumnInfos[fiName].Width := 150;
  fColumnInfos[fiName].Alignment := taLeftJustify;
  // column properties for SIZE
  fColumnInfos[fiSize].Caption := 'Size';
  fColumnInfos[fiSize].Width := 60;
  fColumnInfos[fiSize].Alignment := taRightJustify;
  // column properties for Type
  fColumnInfos[fiType].Caption := 'Type';
  fColumnInfos[fiType].Width := 130;
  fColumnInfos[fiType].Alignment := taLeftJustify;
  // column properties for Modified
  fColumnInfos[fiModified].Caption := 'Modified';
  fColumnInfos[fiModified].Width := 100;
  fColumnInfos[fiModified].Alignment := taLeftJustify;
  // column properties for Created
  fColumnInfos[fiCreated].Caption := 'Created';
  fColumnInfos[fiCreated].Width := 100;
  fColumnInfos[fiCreated].Alignment := taLeftJustify;
  // column properties for Last Access
  fColumnInfos[fiLastAccess].Caption := 'Last Access';
  fColumnInfos[fiLastAccess].Width := 85;
  fColumnInfos[fiLastAccess].Alignment := taLeftJustify;
  // column properties for Attributes
  fColumnInfos[fiAttributes].Caption := 'Attributes';
  fColumnInfos[fiAttributes].Width := 60;
  fColumnInfos[fiAttributes].Alignment := taLeftJustify;
  // column properties for DosName
  fColumnInfos[fiDosName].Caption := 'Dos Name';
  fColumnInfos[fiDosName].Width := 130;
  fColumnInfos[fiDosName].Alignment := taLeftJustify;
  // column properties for DosName
  fColumnInfos[fiDosExt].Caption := 'Dos Ext';
  fColumnInfos[fiDosExt].Width := 60;
  fColumnInfos[fiDosExt].Alignment := taLeftJustify;
  // column properties for Path
  fColumnInfos[fiPath].Caption := 'Path';
  fColumnInfos[fiPath].Width := 200;
  fColumnInfos[fiPath].Alignment := taLeftJustify;
end;
// Builds columns for ListView
// NAME and SIZE column always created and just hidden if not
// required. Other columns are created only if requested
procedure TFileList.SetupFileColumns;
var
  Ind :integer;
  Inf :TFileInfo;
begin
  with Columns do
  begin
    Clear;
    // NAME
    with Add do // adds and sets up NAME column
    begin
      Caption   := fColumnInfos[fiName].Caption;
      Alignment := fColumnInfos[fiName].Alignment;
      fColumnInfos[fiName].Column    := 0; // set column index;
      if (fiName in fViewColumns) or (fiAll in fViewColumns) then
        Width := fColumnInfos[fiName].Width
      else
        Width := 0; // Hide column if not required
      fInfoColumn[0] := fiName;
    end;
    with Add do // adds and sets up SIZE column
    begin
      Caption   := fColumnInfos[fiSize].Caption;
      Alignment := fColumnInfos[fiSize].Alignment;
      fColumnInfos[fiSize].Column    := 1; // set column index;
      if (fiSize in fViewColumns) or (fiAll in fViewColumns) then
        Width := fColumnInfos[fiSize].Width
      else
        Width := 0; // Hide column if not required
      fInfoColumn[1] := fiSize;
    end;
    // all remaining columns
    Ind := 2; // start from column 2 (3rd column)
    for Inf := fiType  to Pred(fiAll) do
      if (Inf in fViewColumns) or (fiAll in fViewColumns) then
      begin
        with Add do // adds and sets up SIZE column
        begin
          Caption   := fColumnInfos[Inf].Caption;
          Alignment := fColumnInfos[Inf].Alignment;
          Width     := fColumnInfos[Inf].Width;
          fColumnInfos[Inf].Column := Ind; // set column index;
          // set
          fInfoColumn[Ind] := Inf;
          Inc(Ind);
        end;
      end
      else
        fColumnInfos[Inf].Column := -1; // reset column index if column not used
  end; {with columns do}
end;

////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
////////////////////////////////////////////////////////////////////////////////

// overrides ancestor's handler for column headers click:
//  calls first the Set Sort Column procedure and then
//  the inherited ColClick method.
procedure TFileList.ColClick(Column: TListColumn);
begin
  SetSortColumn(fInfoColumn[Column.Index]);
  inherited ColClick(Column);
end;

////////////////////////////////////////////////////////////////////////////////
// PROPERTIES INTERFACE
////////////////////////////////////////////////////////////////////////////////

// Set File Attributes
procedure TFileList.SetFileTypes (FT :TFileTypes);
begin
 if FT = fFileTypes then Exit;
 fFileTypes := FT;
 UpdateFileList;
end;

// Set File Specification
procedure TFileList.SetMask (Mask :string);
begin
  SetFilters (Mask,fFileMask,true,false);
  UpdateFileList; // Update File List View
end;
// Add specifications to File Specifications list
procedure TFileList.AddMask (Mask :string);
begin
  SetFilters(GetMask + ';' + Mask,fFileMask,true,false);
//  UpdateFileList; // Update File List View
end;
// Get File Specifications list
function TFileList.GetMask :string;
var
  I :integer;
begin
  Result := ''; // Default result to ''
  for I := 0 to Pred(fFileMask.Count) do
    Result := Result + fFileMask[I]  + ';';
  if Result[Length(Result)] = ';' then // remove last ';'
    Result := Copy(Result,1,Length(Result)-1);
end;

// Set Search Path List
procedure TFileList.SetPath (Path :string);
var
  I :integer;
begin
  fDirectory.Clear; // Clear search path list
  fDirectory.AddPatterns(Path);
  UpdateFileList; // Update File List View
end;
// Add specifications to Search Path List
procedure TFileList.AddPath (Path :string);
begin
  fDirectory.Addpatterns(Path);
  UpdateFileList; // Update File List View
  // modificare per caricre solo da Path
end;
// Get Search Path List
function TFileList.GetPath :string;
var
  I :integer;
begin
  Result := ''; // Default result to ''
  if fDirectory.Count < 1 then Exit;
  for I := 0 to Pred(fDirectory.Count) do
    Result := Result + fDirectory[I]  + ';';
  if Result[Length(Result)] = ';' then // remove last ';'
    Result := Copy(Result,1,Length(Result)-1);
end;

// Set current column set
procedure TFileList.SetViewColumns (Columns :TFileInfos);
begin
  if Columns = fViewColumns then Exit;
  fViewColumns := Columns;
  if ViewStyle = vsReport then
  begin
    SetupFileColumns;      // rebuild listview columns
    UpdateFileList;
  end;
end;

// Set current sort column
procedure TFileList.SetSortColumn (Column :TFileInfo);
begin
  if not ((Column in fViewColumns) or (fiAll in fViewColumns)) then
    Exit; // prevent unused columns to be set for sorting
  if Column = fiAll then
    Exit; // fiAll is not a valid sort column
  // invert sorting if the specified column was already selected
  if Column = SortColumn then InvertSort := not InvertSort
  else
    fSortColumn := Column;
  if ViewStyle = vsReport then
  begin
    CustomSort(@SortProc,fColumnInfos[SortColumn].Column); // Sorts on 0 based column index
  end;
end;

// Allows/Prevent loading of Directory Items in the file list
procedure TFileList.SetDisplayDir (Display :boolean);
begin
  if Display = fDisplayDir then Exit;
  fDisplayDir := Display;
  UpdateFileList;         // update file list
end;
// Allows/Prevent loading of Parent Directory Items in the file list
procedure TFileList.SetDisplayParentDir (Display :boolean);
begin
  if Display = fDisplayParentDir then Exit;
  fDisplayParentDir := Display;
  if fDisplayDir then // if currently showing directories then
    UpdateFileList;   // update file list
end;

////////////////////////////////////////////////////////////////////////////////
// PROCESSING & SERVICES ROUTINES
////////////////////////////////////////////////////////////////////////////////
function  TFileList.IsDirectory (Item :TListItem) :boolean;
begin
  if Item <> nil then
    try
      Result :=  (Item.SubItems[0] = '')
    except
      Result := false; // protection against index error
    end  
  else
    Result := false;
end;

function TFileList.AddFile (FileName :TFileName) :TListItem;
var
  Ret :boolean;
  FindHandle :THandle;
  FindData :TWin32FindData;
  S :string;
begin
  FindHandle := Windows.FindFirstFile(PChar(FileName),FindData);
  try // get file informations
    if (FindHandle <> INVALID_HANDLE_VALUE) then
    begin
      S := ExtractFilePath(FileName);
      if S[Length(S)] <> '\' then
        S := S + '\';

      if ((FindData.dwFileAttributes AND file_attribute_Directory) > 0)
      or (StrPas(FindData.cFileName) = '..') then
        Result := AddDir(FileName)
      else
        Result := inherited AddFile(FileName);

      AddFileData(Result,S,FindData);
    end;
  finally
    Windows.FindClose(FindHandle);
 end;
end;

// Add a file entry to the list view. The FindData structure should be
// returned from a FindFirstFile/FindNextFile call

procedure TFileList.AddFileData (NewItem :TListItem; Path :string; FindData :TWin32FindData);
var
  ShFileInfo:TShFileInfo;
   // compute file size
  function FileSize (hi,lo: integer) :longint;
  begin
    Result := (hi * MAXDWORD) + lo;
  end;
  // actually adds subitems
  procedure AddInfo;
  var
    S :string;
  begin
    with FindData do
    begin
      // SIZE
      NewItem.SubItems.Add (SizeStr(FileSize(nFileSizeHigh,nFileSizeLow),dwFileAttributes));
      // TYPE
      if (fiType in fViewColumns) or (fiAll in fViewColumns) then
      begin
        ShGetFileInfo (PChar(Path + cFileName),0,ShFileInfo,SizeOf (ShFileInfo),
                       shgfi_DisplayName or shgfi_TypeName);
        if ((FindData.dwFileAttributes AND file_attribute_directory) > 0)
        or (NewItem.Caption = '..') then
          NewItem.SubItems.Add (DirShellInfo.szTypeName) //type
        else
          NewItem.SubItems.Add (ShFileInfo.szTypeName); //type

      end;
      // MODIFIED
      if (fiModified in fViewColumns) or (fiAll in fViewColumns) then
        NewItem.SubItems.Add (GetLocalTime(ftLastWriteTime));
      // CREATION
      if (fiCreated in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
        NewItem.SubItems.Add (GetLocalTime(ftCreationTime));
      // LAST ACCESS
      if (fiLastAccess in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
        NewItem.SubItems.Add (GetLocalTime(ftLastAccessTime));
      // ATTRIBUTES
      if (fiAttributes in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
        NewItem.SubItems.Add (AttrStr(dwFileAttributes));
      // DOS NAME
      S := cAlternateFileName;
      if S = '' then S := cFileName; // avoid empty DOS name
      if (fiDosName in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
      begin
        NewItem.SubItems.Add (S);
      end;
      // DOS EXTENSION
      S := cAlternateFileName;
      if S = '' then S := cFileName; // avoid empty DOS name
      if (fiDosName in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
      begin
        NewItem.SubItems.Add (ExtractFileExt(S));
      end;
    end; {with FindData}
    // PATH
    if (fiPath in fViewColumns) or (fiAll in fViewColumns) then // add subitem only if requested
      NewItem.SubItems.Add (Path);
      // user callback for OnAddFile
  end;

begin // AddFileData main
  AddInfo;                                        // adds file informations
  if Assigned(fOnFileAdd) then fOnFileAdd(Self,NewItem,Path,FindData);
end;

function CheckAttributes(Att :DWord; Typ :TFileTypes) :boolean;
begin
  if  (ftAll in Typ) then Result := true
  else
  begin
    Result := true;
    if (Att and file_attribute_Archive) = file_attribute_Archive then
      Result := Result and (ftArchive in Typ);
    if (Att and file_attribute_Readonly) = file_attribute_Readonly then
      Result := Result and (ftReadonly in Typ);
    if (Att and file_attribute_Hidden) = file_attribute_Hidden then
      Result := Result and (ftHidden in Typ);
    if (Att and file_attribute_System) = file_attribute_System then
      Result := Result and (ftSystem in Typ);
    if (Att and file_attribute_Temporary) = file_attribute_Temporary then
      Result := Result and (ftTemporary in Typ);
  end
end;

// Update File List with contents of the directory specified in
// fDirectory
procedure TFileList.UpdateFileList;
var
  OldViewStyle :TViewStyle;
  I :integer;
  // search single directory
  procedure GetDirList (Dir :string);
  var
    Ret :boolean;
    FindHandle :THandle;
    FindData :TWin32FindData;
    S :string;
    ErrMode :integer;
    NewDir :TListItem;
  begin
    ErrMode := SetErrorMode(SEM_FAILCRITICALERRORS);// set error handler
    FindHandle := Windows.FindFirstFile(PChar(Dir + '*'),FindData);
    Ret := (FindHandle <> INVALID_HANDLE_VALUE);
    try
      while Ret do with FindData do
      begin
        if CheckAttributes (dwFileAttributes,fFileTypes) then
        begin
          S := FindData.cFileName;
          if ((dwFileAttributes and file_attribute_Directory) > 0) then
          begin
            // adds directory entries only if required and not '.' or '..'
            if (S <> '.') then // valid dir or '..' (parent)
              if fDisplayDir then
              begin
                if (S = '..') then
                begin
                  if fDisplayParentDir then
                  begin
                    NewDir := AddDir (Dir + FindData.cFileName);
                    AddFileData (NewDir,Dir,FindData); // Directory entry - add to list
                    NewDir.Caption := '..';   // force caption to '..'
                  end;
                end
                else
                begin
                  NewDir := AddDir (Dir + FindData.cFileName);
                  AddFileData (NewDir,Dir,FindData); // Directory entry - add to list
                  NewDir.Caption := S;   // force caption to '..'
                end;
              end;
          end
          else
          // test if file name matches mask
          if CmpMask (AnsiUpperCase(FindData.cFileName),fFileMask,true,false) then
          begin
            AddFileData ((inherited AddFile (Dir + FindData.cFileName)),Dir,FindData); // adds matching file entry
          end;
        end;
        Application.ProcessMessages;
        Ret := Windows.FindNextFile(FindHandle,FindData) // get next entry
      end;
    finally
      Windows.FindClose(FindHandle); // Close FindNext context
      SetErrorMode(ErrMode); // Reset error handler
    end;
  end;

begin
  Items.BeginUpdate;   // prevents video refresh until end of list loading
  OldViewStyle := ViewStyle;
  Items.Clear;         // clear list view
  ViewStyle := vsIcon; // speeds up enumarating of contents
  Screen.Cursor := crHourGlass; // set cursor shape
  try
    with fDirectory do
      for I := 0 to Pred(Count) do
      begin
        GetDirList (Strings[I]);
        Application.ProcessMessages;
      end;
  finally
    // sort items by current sort item
    CustomSort(@SortProc,fColumnInfos[SortColumn].Column); // Sorts on 0 based column index
    ViewStyle := OldViewStyle;
    Items.EndUpdate; // finally updates visual control
    Screen.Cursor := crDefault; // reset cursor
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// class registration
////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
  RegisterComponents('Win95', [TFileView,TFileList]);
end;

initialization
  GetWindowsDirectory(@WinDir,SizeOf(WinDir));
  ShGetFileInfo (@WinDir,0,DirShellInfo,SizeOf (DirShellInfo),
                       shgfi_SysIconIndex or shgfi_TypeName or
                        shgfi_SmallIcon);

end.
