unit regsm;
{
Copyright (�) 1997  Tony BenBrahim
This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation
This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public License along
with this library; if not, write to the:

Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.
}
interface

uses
  Addrbook, Inetmail, Classes,DsgnIntf,SmDialog;

procedure Register;

implementation

procedure Register;
begin
        RegisterComponents('Freeware',[SendMail]);
        RegisterComponents('Freeware',[TAddressBook,TAddressBookViewer]);
        RegisterComponents('Freeware', [SendMailDialog]);
        RegisterComponentEditor(SendMailDialog,SendMailDialogEditor);
end;

end.
