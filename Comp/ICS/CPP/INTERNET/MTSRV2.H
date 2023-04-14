//---------------------------------------------------------------------------
#ifndef mtsrv2H
#define mtsrv2H
//---------------------------------------------------------------------------
#include <vcl\Classes.hpp>
#include "WSocket.hpp"
//---------------------------------------------------------------------------
class TClientThread : public TThread
{
private:
    TWSocket *FClientSocket;
    TSocket  FClientHSocket;
    void __fastcall ServerWSocketDataAvailable(TObject *Sender, WORD Error);
    void __fastcall ServerWSocketSessionClosed(TObject *Sender, WORD Error);
protected:
    void __fastcall Execute();
public:
    __fastcall TClientThread(TSocket ClientHSocket);
    __fastcall ~TClientThread();
    void __fastcall Release();
};
//---------------------------------------------------------------------------
#endif
