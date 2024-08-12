program Project;

uses
  Vcl.Forms,
  Unit1 in 'C:\Users\Vlad B\OneDrive\Документы\Embarcadero\Studio\Projects\Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
