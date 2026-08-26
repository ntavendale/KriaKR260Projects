unit UartMain;

interface

uses
  System.IOUtils, System.SysUtils, System.Variants, System.Classes, System.UITypes,
  Winapi.Windows, Winapi.Messages, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, OoMisc, AdPort, Vcl.ComCtrls;

type
  TfmUartMain = class(TForm)
    gbCOMSettings: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cbDataBits: TComboBox;
    cbParity: TComboBox;
    cbFlowControl: TComboBox;
    cbPort: TComboBox;
    cbBaudRate: TComboBox;
    comPort: TApdComPort;
    btnInitialize: TButton;
    tbCharValue: TTrackBar;
    btnWrite: TButton;
    lbCharValue: TLabel;
    lbOutput: TLabel;
    cbLetters: TComboBox;
    btnSendChar: TButton;
    ebHex: TEdit;
    btnSendHex: TButton;
    lbCount: TLabel;
    procedure btnInitializeClick(Sender: TObject);
    procedure tbCharValueChange(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure comPortTriggerAvail(CP: TObject; Count: Word);
    procedure btnSendCharClick(Sender: TObject);
    procedure btnSendHexClick(Sender: TObject);
  private
    { Private declarations }
    procedure InitializePort;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  fmUartMain: TfmUartMain;

implementation

{$R *.dfm}

constructor TfmUartMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  cbBaudRate.ItemIndex := 12;
  cbPort.ItemIndex := 3;
  cbDataBits.ItemIndex := 1;
  cbParity.ItemIndex := 0;
  cbFlowControl.ItemIndex := 0;
  comPort.LogName :=  String.Format('%s\APRO.LOG', [ TPath.GetDirectoryName(ParamStr(0)) ]);
  comPort.TraceName := String.Format('%s\APRO.TRC', [ TPath.GetDirectoryName(ParamStr(0)) ]);
end;

destructor TfmUartMain.Destroy;
begin
  comPort.Open := FALSE;
  inherited Destroy;
end;

procedure TfmUartMain.InitializePort;
begin
  comPort.ComNumber := cbPort.ItemIndex + 1;
  comPort.Baud := StrToIntDef(cbBaudRate.Items[cbBaudRate.ItemIndex], 115200);
  case cbDataBits.ItemIndex of
  0: comPort.DataBits := 7;
  else
    comPort.DataBits := 8;
  end;
  case cbParity.ItemIndex of
  1: comPort.Parity := pOdd;
  2: comPort.Parity := pEven;
  3: comPort.Parity := pMark;
  4: comPort.Parity := pSpace;
  else
    comPort.Parity := pNone;
  end;

  comPort.Logging := tlOn;
  comPort.Tracing := tlOn;
  comPort.PromptForPort := FALSE;
  comPort.Open := TRUE;
 end;

procedure TfmUartMain.btnInitializeClick(Sender: TObject);
begin
  if not comPort.Open then
  begin
    InitializePort;
    MessageDlg(String.Format('COM%d initialized', [comPort.ComNumber]), mtInformation, [mbOK], 0);
  end
  else
    MessageDlg(String.Format('COM%d already open', [comPort.ComNumber]), mtError, [mbOK], 0);
end;

procedure TfmUartMain.tbCharValueChange(Sender: TObject);
begin
  if comPort.Open then
  begin
    var c := AnsiChar(tbCharValue.Position);
    comPort.Output := c;
  end;
  lbCharValue.Caption := String.Format('0x%.4x', [tbCharValue.Position]);
end;

procedure TfmUartMain.btnSendCharClick(Sender: TObject);
begin
  if cbletters.ItemIndex = -1 then
    EXIT;

  try
    var c := cbletters.Items[cbletters.ItemIndex];
    comPort.Output := c;
  except on E:Exception do
    MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfmUartMain.btnWriteClick(Sender: TObject);
begin
  try
    var c := AnsiChar(tbCharValue.Position);
    comPort.Output := c;
  except on E:Exception do
    MessageDlg(E.Message, mtError, [mbOK], 0);
  end;

end;

procedure TfmUartMain.comPortTriggerAvail(CP: TObject; Count: Word);
begin
  for var i := 0 to (Count - 1) do
  begin
    var b := Ord(comPort.GetChar);
    lbOutput.Caption := String.Format('Output: 0x%.4x', [b]);
  end;
end;

procedure TfmUartMain.btnSendHexClick(Sender: TObject);
begin
  var LHexString := '0x' + ebHex.Text;
  var LHexInt := StrToUIntDef(LHexString, 0);

  try
    var b: Byte := LHexInt and $000000FF;
    var c := AnsiChar(b);
    comPort.Output := c;

    b :=  (LHexInt shr 8) and $000000FF;
    c := AnsiChar(b);
    comPort.Output := c;

    b :=  (LHexInt shr 16) and $000000FF;
    c := AnsiChar(b);
    comPort.Output := c;

    b :=  (LHexInt shr 24) and $000000FF;
    c := AnsiChar(b);
    comPort.Output := c;
  except on E:Exception do
    MessageDlg(E.Message, mtError, [mbOK], 0);
  end;

end;

end.
