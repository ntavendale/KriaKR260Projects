unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Spin, Vcl.StdCtrls,
  EndPointClient, RestClasses;

type
  TfmMain = class(TForm)
    gbEndPoint: TGroupBox;
    ebHost: TEdit;
    spPort: TSpinEdit;
    gbData: TGroupBox;
    btnGetData: TButton;
    lbData: TLabel;
    gbResolution: TGroupBox;
    Label1: TLabel;
    cbTemperatureResolution: TComboBox;
    Label2: TLabel;
    cbHumidityResolution: TComboBox;
    btnSetResolution: TButton;
    gb7SegDisplay: TGroupBox;
    cb7Segment: TComboBox;
    btnSetDisplay: TButton;
    btnClose: TButton;
    procedure btnGetDataClick(Sender: TObject);
    procedure btnSetResolutionClick(Sender: TObject);
    procedure btnSetDisplayClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.btnGetDataClick(Sender: TObject);
begin
  var LData := String.Empty;
  var LEndPoint := TEndPointClient.Create(ebHost.Text, spPort.Value, string.Empty, 'api/get_data');
  try
    LData := LEndPoint.Get;
  finally
    LEndPoint.Free;
  end;

  try
    var LHygrometerData := THygrometerData.FromJson(LData);
    try
      lbData.Caption := String.Format('Temperature: %.2f deg C, Humidity: %.2f %%', [LHygrometerData.Temperature, LHygrometerData.Humidity]);
      lbData.Visible := TRUE;
    finally
      LHygrometerData.Free;
    end;
  except
    on E:Exception do
    begin
      lbData.Caption := E.Message;
      lbData.Visible := TRUE;
    end;
  end;
end;

procedure TfmMain.btnSetResolutionClick(Sender: TObject);
begin
  var LResolutionData := String.Empty;
  var LResolution := TResolution.Create;
  try
    case cbTemperatureResolution.ItemIndex of
      1: LResolution.TemperatureResolution := tr11Bit;
    else
      LResolution.TemperatureResolution := tr14Bit;
    end;
    case cbHumidityResolution.ItemIndex of
      1: LResolution.HumidityResolution := hr11Bit;
      2: LResolution.HumidityResolution := hr8Bit;
    else
      LResolution.HumidityResolution := hr14Bit;
    end;
    LResolutionData := LResolution.ToJson;
  finally
    LResolution.Free;
  end;

  var LEndPoint := TEndPointClient.Create(ebHost.Text, spPort.Value, string.Empty, 'api/set_resolution');
  try
    LEndPoint.Post(LResolutionData);
  finally
    LEndPoint.Free;
  end;
end;

procedure TfmMain.btnSetDisplayClick(Sender: TObject);
begin
  var LDispalySetData := String.Empty;
  var LLDispalySetting := TDisplaySetting.Create;
  try
    case cb7Segment.ItemIndex of
      1: LLDispalySetting.DisplayResolution := drHumidity;
    else
      LLDispalySetting.DisplayResolution := drTemperature;
    end;
    LDispalySetData := LLDispalySetting.ToJson;
  finally
    LLDispalySetting.Free;
  end;

  var LEndPoint := TEndPointClient.Create(ebHost.Text, spPort.Value, string.Empty, 'api/set_display');
  try
    LEndPoint.Post(LDispalySetData);
  finally
    LEndPoint.Free;
  end;
end;

procedure TfmMain.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
