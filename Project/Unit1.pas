unit Unit1;

interface

uses
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, Data.DB, System.SysUtils, System.UITypes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Vcl.Dialogs, System.Classes, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef;

type
  TForm1 = class(TForm)
    FDConnectionSQLite: TFDConnection;
    FDQuery1: TFDQuery;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    EditID: TEdit;
    EditName: TEdit;
    EditPrice: TEdit;
    EditCategoryID: TEdit;
    ButtonAdd: TButton;
    ButtonEdit: TButton;
    ButtonDelete: TButton;
    ButtonSave: TButton;
    TreeView1: TTreeView;
    ButtonLoadCategories: TButton;
    ButtonSalesReport: TButton;
    FDConnectionSQLServer: TFDConnection;
    procedure FormCreate(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure ButtonSyncClick(Sender: TObject);
    procedure ButtonLoadCategoriesClick(Sender: TObject);
    procedure ButtonSalesReportClick(Sender: TObject);
  private
    { Private declarations }
    IsNewRecord: Boolean;
    LastSyncDate: TDateTime;
    procedure LoadProducts;
    procedure AddProduct;
    procedure EditProduct;
    procedure DeleteProduct;
    procedure SaveChanges;
    procedure SynchronizeDatabases;
    procedure LoadCategories;
    procedure GenerateSalesReport;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDConnectionSQLite.DriverName := 'SQLite';
  FDConnectionSQLite.Params.Database := 'C:\Test\mydatabase.db';
  FDConnectionSQLite.Connected := True;


  FDConnectionSQLServer.DriverName := 'MSSQL';
  FDConnectionSQLServer.Params.Database := 'master';
  FDConnectionSQLServer.Params.ConnectionDef := 'localhost\SQLEXPRESS';
  FDConnectionSQLServer.Params.UserName := 'username';
  FDConnectionSQLServer.Params.Password := 'password';
  FDConnectionSQLServer.Connected := True;

  LoadProducts;
  LoadCategories;
  IsNewRecord := True;

  LastSyncDate := Now;
end;

procedure TForm1.LoadProducts;
begin
  FDQuery1.SQL.Text := 'SELECT * FROM Products';
  FDQuery1.Open;
end;

procedure TForm1.AddProduct;
var
  Price: Double;
  CategoryID: Integer;
begin
  if not TryStrToFloat(EditPrice.Text, Price) then
  begin
    ShowMessage('Invalid price format');
    Exit;
  end;

  if not TryStrToInt(EditCategoryID.Text, CategoryID) then
  begin
    ShowMessage('Invalid category ID format');
    Exit;
  end;

  FDQuery1.SQL.Text := 'INSERT INTO Products (name, price, category_id) VALUES (:name, :price, :category_id)';
  FDQuery1.ParamByName('name').AsString := EditName.Text;
  FDQuery1.ParamByName('price').AsFloat := Price;
  FDQuery1.ParamByName('category_id').AsInteger := CategoryID;
  FDQuery1.ExecSQL;
  ShowMessage('Product added successfully');
  LoadProducts;
end;

procedure TForm1.EditProduct;
var
  Price: Double;
  CategoryID: Integer;
begin
  if not TryStrToFloat(EditPrice.Text, Price) then
  begin
    ShowMessage('Invalid price format');
    Exit;
  end;

  if not TryStrToInt(EditCategoryID.Text, CategoryID) then
  begin
    ShowMessage('Invalid category ID format');
    Exit;
  end;

  FDQuery1.SQL.Text := 'UPDATE Products SET name = :name, price = :price, category_id = :category_id WHERE id = :id';
  FDQuery1.ParamByName('name').AsString := EditName.Text;
  FDQuery1.ParamByName('price').AsFloat := Price;
  FDQuery1.ParamByName('category_id').AsInteger := CategoryID;
  FDQuery1.ParamByName('id').AsInteger := StrToInt(EditID.Text);
  FDQuery1.ExecSQL;
  ShowMessage('Product updated successfully');
  LoadProducts;
end;

procedure TForm1.DeleteProduct;
var
  ProductID: Integer;
begin
  if not TryStrToInt(EditID.Text, ProductID) then
  begin
    ShowMessage('Invalid ID format');
    Exit;
  end;

  FDQuery1.SQL.Text := 'DELETE FROM Products WHERE id = :id';
  FDQuery1.ParamByName('id').AsInteger := ProductID;
  FDQuery1.ExecSQL;
  ShowMessage('Product deleted successfully');
  LoadProducts;
end;

procedure TForm1.SaveChanges;
begin
  if IsNewRecord then
    AddProduct
  else
    EditProduct;
end;

procedure TForm1.ButtonAddClick(Sender: TObject);
begin
  AddProduct;
end;

procedure TForm1.ButtonEditClick(Sender: TObject);
begin
  EditProduct;
end;

procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
  DeleteProduct;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
begin
  SaveChanges;
end;

procedure TForm1.DBGrid1CellClick(Column: TColumn);
begin
  EditID.Text := FDQuery1.FieldByName('id').AsString;
  EditName.Text := FDQuery1.FieldByName('name').AsString;
  EditPrice.Text := FDQuery1.FieldByName('price').AsString;
  EditCategoryID.Text := FDQuery1.FieldByName('category_id').AsString;
  IsNewRecord := False;
end;

procedure TForm1.SynchronizeDatabases;
begin
  try

    FDConnectionSQLServer.Connected := True;
    FDQuery1.Connection := FDConnectionSQLServer;
    FDQuery1.SQL.Text := 'SELECT * FROM Products';
    FDQuery1.Open;


    FDConnectionSQLite.Connected := True;
    FDQuery1.Connection := FDConnectionSQLite;


    FDQuery1.SQL.Text := 'DELETE FROM Products';
    FDQuery1.ExecSQL;


    while not FDQuery1.Eof do
    begin
      FDQuery1.SQL.Text := 'INSERT INTO Products (id, name, price, category_id) VALUES (:id, :name, :price, :category_id)';
      FDQuery1.ParamByName('id').AsInteger := FDQuery1.FieldByName('id').AsInteger;
      FDQuery1.ParamByName('name').AsString := FDQuery1.FieldByName('name').AsString;
      FDQuery1.ParamByName('price').AsFloat := FDQuery1.FieldByName('price').AsFloat;
      FDQuery1.ParamByName('category_id').AsInteger := FDQuery1.FieldByName('category_id').AsInteger;
      FDQuery1.ExecSQL;
      FDQuery1.Next;
    end;

    FDConnectionSQLServer.Connected := True;
    FDQuery1.SQL.Text := 'SELECT * FROM Products WHERE LastModified > :LastSyncDate';
    FDQuery1.ParamByName('LastSyncDate').AsDateTime := LastSyncDate;
    FDQuery1.Open;

    FDConnectionSQLite.Connected := True;
    FDQuery1.Connection := FDConnectionSQLite;

    while not FDQuery1.Eof do
    begin
      if FDQuery1.FieldByName('id').IsNull then
      begin
        FDQuery1.SQL.Text := 'INSERT INTO Products (id, name, price, category_id) VALUES (:id, :name, :price, :category_id)';
      end
      else
      begin
        FDQuery1.SQL.Text := 'UPDATE Products SET name = :name, price = :price, category_id = :category_id WHERE id = :id';
      end;

      FDQuery1.ParamByName('id').AsInteger := FDQuery1.FieldByName('id').AsInteger;
      FDQuery1.ParamByName('name').AsString := FDQuery1.FieldByName('name').AsString;
      FDQuery1.ParamByName('price').AsFloat := FDQuery1.FieldByName('price').AsFloat;
      FDQuery1.ParamByName('category_id').AsInteger := FDQuery1.FieldByName('category_id').AsInteger;
      FDQuery1.ExecSQL;
      FDQuery1.Next;
    end;

    LastSyncDate := Now;
  except
    on E: Exception do
      ShowMessage('Synchronization error: ' + E.Message);
  end;
end;

procedure TForm1.ButtonSyncClick(Sender: TObject);
begin
  SynchronizeDatabases;
end;

procedure TForm1.LoadCategories;
var
  TreeItem: TTreeNode;
begin
  FDQuery1.SQL.Text := 'WITH RECURSIVE CategoryTree AS (' +
                       'SELECT id, name, parent_id FROM ProductCategories WHERE parent_id IS NULL ' +
                       'UNION ALL ' +
                       'SELECT c.id, c.name, c.parent_id ' +
                       'FROM ProductCategories c ' +
                       'INNER JOIN CategoryTree ct ON c.parent_id = ct.id) ' +
                       'SELECT * FROM CategoryTree';
  FDQuery1.Open;

  TreeView1.Items.Clear;

  FDQuery1.First;
  while not FDQuery1.Eof do
  begin
    if FDQuery1.FieldByName('parent_id').IsNull then
    begin
      TreeItem := TreeView1.Items.Add(nil, FDQuery1.FieldByName('name').AsString);
    end
    else
    begin
      TreeItem := TreeView1.Items.AddChildObjectFirst(
        TreeView1.Items.GetFirstNode,
        FDQuery1.FieldByName('name').AsString,
        TObject(FDQuery1.FieldByName('id').AsInteger)
      );
    end;

    FDQuery1.Next;
  end;
end;

procedure TForm1.ButtonLoadCategoriesClick(Sender: TObject);
begin
  LoadCategories;
end;

procedure TForm1.GenerateSalesReport;
var
  SalesFile: TextFile;
  Line: string;
begin
  AssignFile(SalesFile, 'C:\Test\sales_report.csv');
  try
    Rewrite(SalesFile);
    WriteLn(SalesFile, 'Date,Product ID,Quantity,Total Price');
    FDQuery1.SQL.Text := 'SELECT date, product_id, quantity, total_price FROM Sales';
    FDQuery1.Open;

    while not FDQuery1.Eof do
    begin
      Line := Format('%s,%d,%d,%.2f',
        [FDQuery1.FieldByName('date').AsString,
         FDQuery1.FieldByName('product_id').AsInteger,
         FDQuery1.FieldByName('quantity').AsInteger,
         FDQuery1.FieldByName('total_price').AsFloat]);
      WriteLn(SalesFile, Line);
      FDQuery1.Next;
    end;

    ShowMessage('Sales report generated and saved successfully.');
  finally
    CloseFile(SalesFile);
  end;
end;

procedure TForm1.ButtonSalesReportClick(Sender: TObject);
begin
  GenerateSalesReport;
end;

end.

