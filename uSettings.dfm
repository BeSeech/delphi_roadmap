object fSettings: TfSettings
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 411
  ClientWidth = 703
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -26
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    703
    411)
  PixelsPerInch = 96
  TextHeight = 29
  object sClient: TShape
    Left = 0
    Top = 0
    Width = 703
    Height = 411
    Anchors = [akLeft, akTop, akRight, akBottom]
    Brush.Style = bsClear
    Pen.Color = clNavy
    Pen.Width = 3
    ExplicitWidth = 957
    ExplicitHeight = 513
  end
  object Label1: TLabel
    Left = 111
    Top = 8
    Width = 387
    Height = 29
    Caption = #1050#1086#1083#1086#1085#1082#1080'                         '#1055#1088#1077#1092#1080#1082#1089#1099
  end
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 539
    Height = 411
    Anchors = [akLeft, akTop, akRight, akBottom]
    Brush.Style = bsClear
    Pen.Color = clNavy
    Pen.Width = 3
    ExplicitWidth = 793
    ExplicitHeight = 513
  end
  object bOK: TButton
    Left = 544
    Top = 238
    Width = 152
    Height = 79
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -26
    Font.Name = 'Times New Roman'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    TabStop = False
  end
  object bCancel: TButton
    Left = 544
    Top = 320
    Width = 152
    Height = 79
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
    TabStop = False
  end
  object mColumns: TMemo
    AlignWithMargins = True
    Left = 23
    Top = 42
    Width = 330
    Height = 357
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    Lines.Strings = (
      'TMCA_1:clBlue'
      'TMCA_2:clBlue'
      'MTS:$0066FF'
      'TN:clRed'
      'CC:clGray'
      'TN.Support:clGreen')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object mPrefixes: TMemo
    AlignWithMargins = True
    Left = 357
    Top = 42
    Width = 164
    Height = 357
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'TN'
      'UK'
      'CLEV'
      'CART'
      'DES')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object Button1: TButton
    Left = 544
    Top = 8
    Width = 152
    Height = 60
    Caption = #1040#1089#1089#1086#1094#1080#1080#1088#1086#1074#1072#1090#1100' '#1089' erm '#1092#1072#1081#1083#1072#1084#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    WordWrap = True
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 544
    Top = 72
    Width = 152
    Height = 60
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1072#1089#1089#1086#1094#1080#1072#1094#1080#1102' '#1089' erm '#1092#1072#1081#1083#1072#1084#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    WordWrap = True
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 545
    Top = 136
    Width = 152
    Height = 60
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1074' Default.erm'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    WordWrap = True
    OnClick = Button3Click
  end
end
