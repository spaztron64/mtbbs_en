unit Abook;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Addrbook, Buttons, StdCtrls;

type
  TAddressBook = class(TForm)
    AddBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
    CompactBtn: TSpeedButton;
    ExpandedBtn: TSpeedButton;
    SortLB: TComboBox;
    AddressBookViewer: TAddressBookViewer;
    procedure AddBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure CompactBtnClick(Sender: TObject);
    procedure ExpandedBtnClick(Sender: TObject);
    procedure SortLBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses AddEdtFm,Main;

procedure TAddressBook.AddBtnClick(Sender: TObject);
var
        d: TAddEdit;
        s: TAddressBookEntry;
begin
        try
                d:=TAddEdit.Create(self);
                d.Caption:='Add entry to address book';
                if d.ShowModal=mrOk then
                begin
                        s.LastName:=d.LastEdt.Text;
                        s.FirstName:=d.FirstEdt.Text;
                        s.HomeMail:=d.HomeEdt.Text;
                        s.WorkMail:=d.WorkEdt.Text;
                        s.NickName:=d.NickEdt.Text;
                        s.Organization:=d.OrgEdt.Text;
                        MainForm.AddressBook.AddEntry(s);
                        AddressBookViewer.Update;
                end;
        finally
                d.Free;
        end;
end;

procedure TAddressBook.FormShow(Sender: TObject);
begin
        AddressBookViewer.AddressBook:=MainForm.AddressBook;
        AddressBookViewer.View:=abvExpanded;
        AddressBookViewer.SortOrder:=absLastName;
        SortLB.ItemIndex:=0;
end;

procedure TAddressBook.CompactBtnClick(Sender: TObject);
begin
        AddressBookViewer.View:=abvCompact;
end;

procedure TAddressBook.ExpandedBtnClick(Sender: TObject);
begin
        AddressBookViewer.View:=abvExpanded;
end;

procedure TAddressBook.DeleteBtnClick(Sender: TObject);
begin
        if AddressBookViewer.ItemIndex<>-1 then
        begin
                MainForm.AddressBook.DeleteEntry(AddressBookViewer.ItemIndex);
                AddressBookViewer.Update;
        end;
end;

procedure TAddressBook.EditBtnClick(Sender: TObject);
var
        d: TAddEdit;
        s: TAddressBookEntry;
        num: integer;
begin
        num:=AddressBookViewer.ItemIndex;
        if num=-1 then Exit;
        try
                s:=MainForm.AddressBook.Items[num];
                d:=TAddEdit.Create(self);
                d.Caption:='Edit entry';
                d.LastEdt.Text:=s.LastName;
                d.FirstEdt.Text:=s.FirstName;
                d.HomeEdt.Text:=s.HomeMail;
                d.WorkEdt.Text:=s.WorkMail;
                d.NickEdt.Text:=s.NickName;
                d.OrgEdt.Text:=s.Organization;
                if d.ShowModal=mrOk then
                begin
                        s.LastName:=d.LastEdt.Text;
                        s.FirstName:=d.FirstEdt.Text;
                        s.HomeMail:=d.HomeEdt.Text;
                        s.WorkMail:=d.WorkEdt.Text;
                        s.NickName:=d.NickEdt.Text;
                        s.Organization:=d.OrgEdt.Text;
                        MainForm.AddressBook.ModifyEntry(num,s);
                        AddressBookViewer.Update;
                end;
        finally
                d.Free;
        end;
end;

procedure TAddressBook.SortLBClick(Sender: TObject);
begin
        case SortLB.ItemIndex of
        0: AddressBookViewer.SortOrder:=absLastName;
        1: AddressBookViewer.SortOrder:=absFirstName;
        2: AddressBookViewer.SortOrder:=absEMail;
        end;
end;

procedure TAddressBook.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
        Action:=caFree;
end;

procedure TAddressBook.FormActivate(Sender: TObject);
begin
        MainForm.FormActivate(self);
end;

end.
