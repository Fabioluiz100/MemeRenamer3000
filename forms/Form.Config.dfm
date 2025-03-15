object fmConfig: TfmConfig
  Left = 0
  Top = 0
  BorderIcons = [biMaximize]
  Caption = 'Configura'#231#245'es'
  ClientHeight = 154
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object pnMain: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 154
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 500
    ExplicitHeight = 148
    object pnButtons: TPanel
      Left = 1
      Top = 112
      Width = 504
      Height = 41
      Align = alBottom
      TabOrder = 0
      ExplicitTop = 106
      ExplicitWidth = 498
      DesignSize = (
        504
        41)
      object btCancel: TButton
        Left = 422
        Top = 9
        Width = 63
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Cancelar'
        TabOrder = 0
        OnClick = btCancelClick
        ExplicitWidth = 57
      end
      object btSave: TButton
        Left = 330
        Top = 9
        Width = 63
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Salvar'
        TabOrder = 1
        OnClick = btSaveClick
        ExplicitWidth = 57
      end
    end
    object pcConfig: TPageControl
      Left = 1
      Top = 1
      Width = 504
      Height = 111
      ActivePage = tsConfig
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 498
      ExplicitHeight = 105
      object tsConfig: TTabSheet
        Caption = 'Configura'#231#245'es'
        DesignSize = (
          496
          81)
        object lbVCLPath: TLabel
          Left = 16
          Top = 16
          Width = 125
          Height = 15
          Caption = 'Caminho do VCL Player'
        end
        object lbGetVLCPlayer: TLabel
          Left = 342
          Top = 59
          Width = 127
          Height = 15
          Cursor = crHandPoint
          Anchors = [akTop, akRight]
          BiDiMode = bdRightToLeft
          Caption = 'Visitar p'#225'gina no Github'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsUnderline]
          ParentBiDiMode = False
          ParentFont = False
          OnClick = lbGetVLCPlayerClick
        end
        object edVCLPath: TEdit
          Left = 16
          Top = 37
          Width = 453
          Height = 23
          Cursor = crHandPoint
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
          OnClick = edVCLPathClick
          ExplicitWidth = 447
        end
      end
    end
  end
  object fodFolder: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 446
  end
end
