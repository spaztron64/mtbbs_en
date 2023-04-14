unit Address;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Addrbook, Buttons, StdCtrls;

type TAddressForm = class(TForm)
        AddressBookViewer: TAddressBookViewer;
        ToList: TListBox;
        ccList: TListBox;
        BccList: TListBox;
        ToBtn: TButton;
        ToRemoveBtn: TButton;
        ccRemoveBtn: TButton;
        BccBtn: TButton;
        BccRemoveBtn: TButton;
        ccBtn: TButton;
        BitBtn1: TBitBtn;
        BitBtn2: TBitBtn;
        AddBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
        SortLB: TComboBox;
        Label1: TLabel;
        CompactBtn: TSpeedButton;
        ExpandedBtn: TSpeedButton;
        procedure AddBtnClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure CompactBtnClick(Sender: TObject);
        procedure ExpandedBtnClick(Sender: TObject);
        procedure SortLBClick(Sender: TObject);
        procedure ToListDragOver(Sender, Source: TObject; X, Y: Integer;
          State: TDragState; var Accept: Boolean);
        procedure ToListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ToBtnClick(Sender: TObject);
    procedure ToRemoveBtnClick(Sender: TObject);
    procedure ToListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DeleteBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
private
        procedure EliminateDuplicates(tag: integer;item: string);
end;

implementation

{$R *.DFM}

uses AddEdtFm,Main;

procedure TAddressForm.AddBtnClick(Sender: TObject);
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

procedure TAddressForm.FormShow(Sender: TObject);
begin
        AddressBookViewer.AddressBook:=MainForm.AddressBook;
        AddressBookViewer.View:=abvExpanded;
        AddressBookViewer.SortOrder:=absLastName;
        SortLB.ItemIndex:=0;
end;

procedure TAddressForm.CompactBtnClick(Sender: TObject);
begin
        AddressBookViewer.View:=abvCompact;
end;

procedure TAddressForm.ExpandedBtnClick(Sender: TObject);
begin
        AddressBookViewer.View:=abvExpanded;
end;

procedure TAddressForm.SortLBClick(Sender: TObject);
begin
        case SortLB.ItemIndex of
        0: AddressBookViewer.SortOrder:=absLastName;
        1: AddressBookViewer.SortOrder:=absFirstName;
        2: AddressBookViewer.SortOrder:=absEMail;
        end;
end;

procedure TAddressForm.ToListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
        if Sender is TAddressBookViewer then Accept:=True;
end;

procedure TAddressForm.ToListDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
        i: integer;
        a: TAddressBookEntry;
        item: string;
begin
        if Source is TAddressBookList then
        begin
                i:=AddressBookViewer.ItemIndex;
                a:=MainForm.AddressBook.Items[i];
                if a.HomeMail<>'' then
                begin
                        item:=a.HomeMail+'|'+a.FirstName+' '+a.LastName;
                        if (Sender as TListBox).Items.IndexOf(item)=-1 then (Sender as TListBox).Items.Add(item);
                        EliminateDuplicates((Sender as TListBox).tag,item);
                end;
                if a.WorkMail<>'' then
                begin
                        item:=a.WorkMail+'|'+a.FirstName+' '+a.LastName;
                        if (Sender as TListBox).Items.IndexOf(item)=-1 then(Sender as TListBox).Items.Add(item);
                        EliminateDuplicates((Sender as TListBox).tag,item);
                end;
        end;
end;

procedure TAddressForm.EliminateDuplicates(tag: integer;item: string);
var
        i: integer;
begin
        if tag<>1 then
        begin
                i:=ToList.Items.IndexOf(item);
                if i<>-1 then ToList.Items.Delete(i);
        end;
        if tag<>2 then
        begin
                i:=ccList.Items.IndexOf(item);
                if i<>-1 then ccList.Items.Delete(i);
        end;
        if tag<>3 then
        begin
                i:=BccList.Items.IndexOf(item);
                if i<>-1 then BccList.Items.Delete(i);
        end;
end;

procedure TAddressForm.ToBtnClick(Sender: TObject);
var
        LB: TListBox;
        i: integer;
        a: TAddressBookEntry;
        item: string;
begin
        if AddressBookViewer.ItemIndex<>-1 then
        begin
                i:=AddressBookViewer.ItemIndex;
                a:=MainForm.AddressBook.Items[i];
                case (Sender as TButton).tag of
                1: LB:=ToList;
                2: LB:=ccList;
                3: LB:=BccList;
                end;
                if a.HomeMail<>'' then
                begin
                        item:=a.HomeMail+'|'+a.FirstName+' '+a.LastName;
                        if LB.Items.IndexOf(item)=-1 then LB.Items.Add(item);
                        EliminateDuplicates((Sender as TButton).tag,item);
                end;
                if a.WorkMail<>'' then
                begin
                        item:=a.WorkMail+'|'+a.FirstName+' '+a.LastName;
                        if LB.Items.IndexOf(item)=-1 then LB.Items.Add(item);
                        EliminateDuplicates((Sender as TButton).tag,item);
                end;
        end;
end;

procedure TAddressForm.ToRemoveBtnClick(Sender: TObject);
var
        LB: TListBox;
begin
        case (Sender as TButton).tag of
        1: LB:=ToList;
        2: LB:=ccList;
        3: LB:=BccList;
        end;
        if LB.ItemIndex<>-1 then LB.Items.Delete(LB.ItemIndex);
end;

procedure TAddressForm.ToListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
        s,name,address: string;
begin
        with (Control as TListBox).Canvas do
        begin
                s:=(Control as TListBox).Items[Index];
                address:=Copy(s,1,Pos('|',s)-1);
                name:=Copy(s,Pos('|',s)+1,999);
                FillRect(Rect);
                TextOut(Rect.Left,Rect.Top,name+' ('+address+')');
        end;
end;

procedure TAddressForm.DeleteBtnClick(Sender: TObject);
begin
        if AddressBookViewer.ItemIndex<>-1 then
        begin
                MainForm.AddressBook.DeleteEntry(AddressBookViewer.ItemIndex);
                AddressBookViewer.Update;
        end;
end;

procedure TAddressForm.EditBtnClick(Sender: TObject);
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

end.
