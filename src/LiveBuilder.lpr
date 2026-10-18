program LiveBuilder;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, BuilderWindow, autoconf
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Live Builder';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TBuilderForm, BuilderForm);
  Application.Run;
end.

