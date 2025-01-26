object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Meme Renamer 3000'
  ClientHeight = 546
  ClientWidth = 956
  Color = clWindowFrame
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 13948116
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pnMain: TPanel
    Left = 0
    Top = 25
    Width = 956
    Height = 521
    Align = alClient
    BevelOuter = bvNone
    Color = 2500134
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 950
    ExplicitHeight = 515
    object splPreviewListFiles: TSplitter
      Left = 651
      Top = 33
      Width = 5
      Height = 429
      Align = alRight
      ExplicitLeft = 632
      ExplicitHeight = 439
    end
    object pnFolderSelected: TPanel
      Left = 0
      Top = 0
      Width = 956
      Height = 33
      Cursor = crHandPoint
      Align = alTop
      Caption = 'Selecione uma pasta para iniciar...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13948116
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 0
      OnClick = pnFolderSelectedClick
      ExplicitWidth = 950
    end
    object pnRenameOptions: TPanel
      Left = 0
      Top = 462
      Width = 956
      Height = 59
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 456
      ExplicitWidth = 950
      DesignSize = (
        956
        59)
      object lbSelectNewFileName: TLabel
        Left = 16
        Top = 8
        Width = 207
        Height = 15
        Caption = 'Informe o novo nome para o arquivo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13948116
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edNewFileName: TEdit
        Left = 16
        Top = 25
        Width = 921
        Height = 29
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13948116
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnKeyDown = edNewFileNameKeyDown
        ExplicitWidth = 915
      end
    end
    object pnPreview: TPanel
      Left = 0
      Top = 33
      Width = 651
      Height = 429
      Align = alClient
      Caption = 'Selecione um arquivo para visualizar...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13948116
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 2
      ExplicitWidth = 645
      ExplicitHeight = 423
      object pnVideo: TPanel
        Left = 1
        Top = 6
        Width = 649
        Height = 99
        TabOrder = 0
        Visible = False
        object pnVideoControls: TPanel
          Left = 1
          Top = 61
          Width = 647
          Height = 37
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitTop = 196
          DesignSize = (
            647
            37)
          object tbVolume: TTrackBar
            Left = 496
            Top = 6
            Width = 137
            Height = 21
            Anchors = [akTop, akRight]
            Ctl3D = True
            LineSize = 10
            Max = 100
            ParentCtl3D = False
            PageSize = 1
            TabOrder = 0
            TickStyle = tsNone
            OnChange = tbVolumeChange
          end
        end
        object pnVideoView: TPanel
          Left = 1
          Top = 1
          Width = 647
          Height = 60
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = 208
          ExplicitTop = 80
          ExplicitWidth = 185
          ExplicitHeight = 41
        end
      end
    end
    object pnFileList: TPanel
      Left = 656
      Top = 33
      Width = 300
      Height = 429
      Align = alRight
      TabOrder = 3
      ExplicitLeft = 650
      ExplicitHeight = 423
      object gridFileList: TDBGrid
        Left = 1
        Top = 1
        Width = 298
        Height = 427
        Align = alClient
        DataSource = dsFileList
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = 13948116
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDblClick = gridFileListDblClick
        Columns = <
          item
            Expanded = False
            FieldName = 'FILENAME'
            Title.Caption = 'Arquivo'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'FILEEXTENSION'
            Title.Caption = 'Extens'#227'o'
            Width = 55
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ORIGINALFILENAME'
            Title.Caption = 'Nome Original'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COMPLETEFILEPATH'
            Title.Caption = 'Caminho Completo'
            Width = 400
            Visible = True
          end>
      end
    end
  end
  object ambMain: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 956
    Height = 25
    UseSystemFont = False
    ActionManager = amMain
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
    ExplicitWidth = 950
  end
  object amMain: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Color = 13948116
            Action = acSelectFolder
            Caption = '&Selecionar pasta...'
          end
          item
            Items = <
              item
                Action = acToolConfig
              end>
            Caption = '&Ferramentas'
          end
          item
            Items = <
              item
                Action = acAjudaSobre
                Caption = '&Sobre...'
              end>
            Caption = '&Ajuda'
          end>
        ActionBar = ambMain
      end
      item
      end
      item
      end
      item
      end>
    Left = 904
    StyleName = 'Platform Default'
    object acSelectFolder: TAction
      Category = 'A'#231#245'es'
      Caption = 'Selecionar pasta...'
      OnExecute = acSelectFolderExecute
    end
    object acAjudaSobre: TAction
      Category = 'Ajuda'
      Caption = 'Sobre...'
      OnExecute = acAjudaSobreExecute
    end
    object acToolConfig: TAction
      Category = 'Ferramentas'
      Caption = 'Configura'#231#245'es...'
      OnExecute = acToolConfigExecute
    end
  end
  object dsFileList: TDataSource
    Left = 768
    Top = 2
  end
  object fodFolder: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 832
  end
end
