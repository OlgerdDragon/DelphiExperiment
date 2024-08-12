object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 676
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object ButtonConnect: TButton
    Left = 464
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 24
    Width = 249
    Height = 120
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object ButtonAdd: TButton
    Left = 160
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 2
  end
  object ButtonDelete: TButton
    Left = 253
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 3
  end
  object ButtonSave: TButton
    Left = 160
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 4
  end
  object ButtonEdit: TButton
    Left = 253
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Edit'
    TabOrder = 5
    OnClick = ButtonEditClick
  end
  object EditID: TEdit
    Left = 8
    Top = 185
    Width = 121
    Height = 23
    TabOrder = 6
    Text = 'ID'
  end
  object EditName: TEdit
    Left = 8
    Top = 223
    Width = 121
    Height = 23
    TabOrder = 7
    Text = 'Name'
  end
  object EditPrice: TEdit
    Left = 8
    Top = 257
    Width = 121
    Height = 23
    TabOrder = 8
    Text = 'Price'
  end
  object EditCategoryID: TEdit
    Left = 8
    Top = 297
    Width = 121
    Height = 23
    TabOrder = 9
    Text = 'CategoryID'
  end
  object TreeView1: TTreeView
    Left = 286
    Top = 24
    Width = 172
    Height = 120
    Indent = 19
    TabOrder = 10
  end
  object ButtonLoadCategories: TButton
    Left = 360
    Top = 160
    Width = 98
    Height = 25
    Caption = 'Load Categories'
    TabOrder = 11
  end
  object ButtonSalesReport: TButton
    Left = 464
    Top = 119
    Width = 75
    Height = 25
    Caption = 'Sales Report'
    TabOrder = 12
  end
  object FDConnectionSQLite: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=C:\Test\newdatabase.db')
    Connected = True
    Left = 592
    Top = 16
  end
  object FDQuery1: TFDQuery
    Connection = FDConnectionSQLite
    Left = 592
    Top = 88
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 592
    Top = 160
  end
  object FDConnectionSQLServer: TFDConnection
    Params.Strings = (
      'DriverID=MSSQL')
    Left = 592
    Top = 240
  end
end
