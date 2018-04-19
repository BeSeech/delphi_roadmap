object fLogin: TfLogin
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103' Jira'
  ClientHeight = 202
  ClientWidth = 700
  Color = clWhite
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    700
    202)
  PixelsPerInch = 96
  TextHeight = 13
  object sClient: TShape
    Left = 0
    Top = 0
    Width = 700
    Height = 202
    Anchors = [akLeft, akTop, akRight, akBottom]
    Brush.Style = bsClear
    Pen.Color = clNavy
    Pen.Width = 3
    ExplicitWidth = 751
    ExplicitHeight = 301
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 76
    Height = 31
    Caption = #1051#1086#1075#1080#1085':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 85
    Width = 90
    Height = 31
    Caption = #1055#1072#1088#1086#1083#1100':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object Shape1: TShape
    Left = 102
    Top = 116
    Width = 391
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    Pen.Color = clGrayText
    ExplicitWidth = 586
  end
  object Shape2: TShape
    Left = 103
    Top = 53
    Width = 391
    Height = 1
    Anchors = [akLeft, akTop, akRight]
    Brush.Color = clGrayText
    Pen.Color = clGrayText
    ExplicitWidth = 586
  end
  object Shape4: TShape
    Left = 102
    Top = 179
    Width = 391
    Height = 1
    Anchors = [akLeft, akTop, akRight]
    Pen.Color = clGrayText
    ExplicitWidth = 586
  end
  object lUrl: TLabel
    Left = 8
    Top = 148
    Width = 59
    Height = 31
    Caption = 'URL:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object Shape3: TShape
    Left = 508
    Top = 0
    Width = 3
    Height = 202
    Anchors = [akTop, akRight, akBottom]
    Brush.Style = bsClear
    Pen.Color = clNavy
    Pen.Width = 3
    ExplicitLeft = 702
  end
  object eLogin: TEdit
    Left = 110
    Top = 8
    Width = 394
    Height = 39
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 589
  end
  object ePassword: TEdit
    Left = 104
    Top = 77
    Width = 393
    Height = 39
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
    ExplicitWidth = 588
  end
  object Button1: TButton
    Left = 519
    Top = 8
    Width = 173
    Height = 75
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 2
    TabStop = False
    ExplicitLeft = 556
  end
  object Button2: TButton
    Left = 519
    Top = 113
    Width = 173
    Height = 75
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 3
    TabStop = False
    ExplicitLeft = 533
  end
  object eUrl: TEdit
    Left = 102
    Top = 140
    Width = 393
    Height = 39
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    ExplicitWidth = 588
  end
end
