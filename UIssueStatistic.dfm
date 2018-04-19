object fIssueStatistic: TfIssueStatistic
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'fIssueStatistic'
  ClientHeight = 488
  ClientWidth = 697
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    697
    488)
  PixelsPerInch = 96
  TextHeight = 12
  object Shape2: TShape
    Left = 0
    Top = 0
    Width = 697
    Height = 487
    Anchors = [akTop, akRight, akBottom]
    Brush.Style = bsClear
    Pen.Color = clNavy
    Pen.Width = 3
  end
  object lCaption: TLabel
    Left = 169
    Top = 7
    Width = 350
    Height = 43
    Caption = #1057#1090#1072#1090#1080#1089#1090#1080#1082#1072' '#1087#1086' '#1079#1072#1076#1072#1095#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -39
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object reIssueStatistic: TRichEdit
    Left = 16
    Top = 56
    Width = 669
    Height = 336
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Ctl3D = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object bOK: TButton
    Left = 16
    Top = 406
    Width = 669
    Height = 71
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -25
    Font.Name = 'Times New Roman'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
    TabStop = False
  end
end
