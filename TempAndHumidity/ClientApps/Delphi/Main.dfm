object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Temp & Humidity Client'
  ClientHeight = 336
  ClientWidth = 641
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object gbEndPoint: TGroupBox
    Left = 0
    Top = 0
    Width = 641
    Height = 65
    Caption = 'End Point'
    TabOrder = 0
    object ebHost: TEdit
      Left = 16
      Top = 24
      Width = 505
      Height = 23
      TabOrder = 0
      Text = 'http://192.168.9.37'
    end
    object spPort: TSpinEdit
      Left = 527
      Top = 24
      Width = 98
      Height = 24
      MaxValue = 65536
      MinValue = 0
      TabOrder = 1
      Value = 8080
    end
  end
  object gbData: TGroupBox
    Left = 0
    Top = 71
    Width = 641
    Height = 66
    Caption = 'Temperature && Humidity'
    TabOrder = 1
    object lbData: TLabel
      Left = 16
      Top = 24
      Width = 34
      Height = 15
      Caption = 'lbData'
      Visible = False
    end
    object btnGetData: TButton
      Left = 550
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Get'
      TabOrder = 0
      OnClick = btnGetDataClick
    end
  end
  object gbResolution: TGroupBox
    Left = 0
    Top = 143
    Width = 641
    Height = 74
    Caption = 'Resolution'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 67
      Height = 15
      Caption = 'Temperature'
    end
    object Label2: TLabel
      Left = 192
      Top = 24
      Width = 50
      Height = 15
      Caption = 'Humidity'
    end
    object cbTemperatureResolution: TComboBox
      Left = 16
      Top = 40
      Width = 145
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '14 Bit'
      Items.Strings = (
        '14 Bit'
        '11 Bit')
    end
    object cbHumidityResolution: TComboBox
      Left = 192
      Top = 40
      Width = 145
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = '14 Bit'
      Items.Strings = (
        '14 Bit'
        '11 Bit'
        '8 Bit')
    end
    object btnSetResolution: TButton
      Left = 550
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Set'
      TabOrder = 2
      OnClick = btnSetResolutionClick
    end
  end
  object gb7SegDisplay: TGroupBox
    Left = 0
    Top = 223
    Width = 641
    Height = 66
    Caption = '7 Segment Display'
    TabOrder = 3
    object cb7Segment: TComboBox
      Left = 16
      Top = 24
      Width = 226
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Temperature Resolution'
      Items.Strings = (
        'Temperature Resolution'
        'Humidity Resolution')
    end
    object btnSetDisplay: TButton
      Left = 550
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Set'
      TabOrder = 1
      OnClick = btnSetDisplayClick
    end
  end
  object btnClose: TButton
    Left = 558
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 4
    OnClick = btnCloseClick
  end
end
