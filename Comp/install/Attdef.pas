unit Attdef;
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

type TMIMEAttachment=record
        Name: string[255];
        MimeType: string[80];
        Disposition: string[30];
        Description: string[255];
        Size: LongInt;
        ContentID: string[40];
        Location: string[255];
        Stored: Boolean;
end;

type TAttachmentPtr=^TMimeAttachment;

implementation

end.
