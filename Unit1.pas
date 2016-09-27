unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer,
  IdSocketHandle, ExtCtrls;
const
  AkipV7_78_1 = 'USB[0-9]*::0x164E::0x0DAD::?*INSTR';
type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    IdUDPServer2: TIdUDPServer;
    Timer1: TTimer;
    Edit3: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    SaveDialog1: TSaveDialog;
    procedure IdUDPServer2UDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  IP_POWER_SUPPLY_1:string;
  verify_send:boolean;
  Current:string;
  flagCur:boolean;
  TestRM:boolean;
  time:int64;
  onTime:cardinal;
  boolOn:boolean;
  offTime:cardinal;

  status:boolean;

  fileCurrent:text;
  closeFlag:boolean;
implementation

{$R *.dfm}

// ##############################################################################################################################
// �-�� �������� ������� �� �������� �������
// ##############################################################################################################################
function SendCommandToPowerSupply(NumberPowerSupply:integer;Command:string):String;
var
  pStrout:string;
begin
  pStrout:=Command+#13;
  if (NumberPowerSupply=1) then Form1.idUDPServer2.Send(IP_POWER_SUPPLY_1,4001,pStrout);
  sleep(100);
end;
// ##############################################################################################################################
// ����� ��������� �� �������� �������
// ##############################################################################################################################
function ResetVoltageOnPowerSupply(NumberPowerSupply:integer):byte;
begin
  SendCommandToPowerSupply(NumberPowerSupply,'SOUT 0');
  sleep(100);
  SendCommandToPowerSupply(NumberPowerSupply,'VOLT 0'+'0000');
  sleep(100);
  SendCommandToPowerSupply(NumberPowerSupply,'CURR 0'+'0000');
  sleep(100);
end;
// ##############################################################################################################################
// �-�� ��������� ���������� �� �������� �������
// ##############################################################################################################################
function SetVoltageOnPowerSupply(NumberPowerSupply:integer;V:string):byte;
begin
    SendCommandToPowerSupply(NumberPowerSupply,'VOLT 0'+V);
    sleep(100);
end;
// ##############################################################################################################################
// �-�� ��������� ���� �� �������� �������
// ##############################################################################################################################
function SetCurrentOnPowerSupply(NumberPowerSupply:integer;A:string):byte;
begin
    SendCommandToPowerSupply(NumberPowerSupply,'CURR 0'+A);
    sleep(100);
end;
// ##############################################################################################################################
// �-�� ��������� ������ ON ��������� �������
// ##############################################################################################################################
function SetOnPowerSupply(NumberPowerSupply:integer):byte;
begin
    SendCommandToPowerSupply(NumberPowerSupply,'SOUT 1');
    sleep(100);
end;
// ##############################################################################################################################
// �-�� ��������� ������ ON ��������� �������
// ##############################################################################################################################
function TurnOFFPowerSupply(NumberPowerSupply:integer):byte;
begin
    SendCommandToPowerSupply(NumberPowerSupply,'SOUT 0');
    sleep(100);
end;





procedure TForm1.IdUDPServer2UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
A:array[1..1000] of char;
A1:string;
I:double;
begin
{if ABinding.PeerIp = IP_POWER_SUPPLY_1 then
begin
  AData.Read(A,aData.size);
  if((verify_send=false) and (A[1]='O')) then
  begin
    verify_send:=true;
  end;
  if A[1] <> 'O' then
  begin
    A1:=A[5]+'.'+A[6]+A[7]+A[8];
    Current:=A1;
    flagCur:=true;
  end;
end;}
if ABinding.PeerIp = IP_POWER_SUPPLY_1 then
begin
    AData.Read(A,aData.size);
    if((verify_send=false) and (A[1]='O')) then
    begin
        verify_send:=true;
    end;
    if A[1] <> 'O' then
    begin
      A1:=A[5]+'.'+A[6]+A[7]+A[8];
      Current:=A1;
      //form1.Memo1.Lines.Add('��� '+current);
      writeln(fileCurrent,current{+' '+'����� '+intTostr(time)});
      //sleep(5000);
      //form1.Memo1.Lines.Add('����');
      flagCur:=true;
    end;
end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
if (status) then
begin
  if form1.SaveDialog1.Execute then
  begin
    //������
    assignFile(fileCurrent,form1.SaveDialog1.FileName{+'.txt'});
    Rewrite(fileCurrent);
    onTime:=StrToint(form1.Edit1.Text);
    offTime:=strToInt(form1.Edit2.Text);
    time:=onTime;

    if  (strToint(form1.Edit3.Text)>=1)and(strToInt(form1.Edit3.Text)<=9) then
    begin
       //��������� ���������� � �������������
       SetVoltageOnPowerSupply(1,'0'+form1.Edit3.Text+'00');
    end
    else
    begin
      SetVoltageOnPowerSupply(1,form1.Edit3.Text+'00');
    end;
    //��������� ������������� ���� �� ����
    //SetCurrentOnPowerSupply(1,'2200');
    //�������� ����
    //form1.Memo1.Lines.Add('���');
    //������ ����
    SetOnPowerSupply(1);
    boolOn:=true;
    form1.Timer1.Enabled:=true;
    form1.Button1.Caption:='����';
    status:=false;
    closeFlag:=false;
  end
  else
  begin
    //�� ������
    ShowMessage('���� �� ������!');
  end;
end
else
begin
  //��������� ����
  TurnOFFPowerSupply(1);
  form1.Timer1.Enabled:=false;
  form1.Button1.Caption:='�����';
  form1.Label8.Caption:='';
  status:=true;
  closeFile(fileCurrent);
  closeFlag:=true;
  ShowMessage('���� �������!');
end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
IP_POWER_SUPPLY_1:='192.168.0.178';
status:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
if boolOn then
begin
  if time=0 then
  begin
    boolOn:=false;
    time:=offTime;
    //��������� ����
    TurnOFFPowerSupply(1);
    writeln(fileCurrent,'');
  end
  else
  begin
    form1.Label7.Caption:='����� �� ����������';
    form1.Label8.Caption:=intTostr(time)+' ���.';
    Application.ProcessMessages;
    //������� ��� �����������
    SendCommandToPowerSupply(1, 'GETD'); // ������� ��� �����������
    dec(time);
  end;
end
else
begin
 if time=0 then
  begin
    boolOn:=true;
    time:=onTime;
    SetOnPowerSupply(1);
  end
  else
  begin
    form1.Label7.Caption:='����� �� ���������';
    form1.Label8.Caption:=intTostr(time)+' ���.';
    Application.ProcessMessages;
    dec(time);
  end;
end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
TurnOFFPowerSupply(1);
form1.Timer1.Enabled:=false;
Application.ProcessMessages;
sleep(20);
if not closeFlag then
begin
  closeFile(fileCurrent);
end;
end;

end.
