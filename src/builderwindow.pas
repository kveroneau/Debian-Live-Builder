unit BuilderWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileUtil,
  ScriptSystem, dos, process, console, autoconf;

type

  { TBuilderForm }

  TBuilderForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    ModList: TListBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ModListDblClick(Sender: TObject);
  private
    FScript: TScriptSystem;
    FCurMod: string;
    FProc: TProcess;
    FDepMods, FMods: TStringList;
    FLog: TKConsole;
    FPkgList, FHooks, FRCLocal: TStringList;
    FConfig: TConfiguration;
    procedure AddModDep(fname: string);
    procedure RunModule(fname: string);
    procedure PrintOut(data: string);
    procedure ExtractMod;
    procedure PlaceFile(where: string);
    procedure PlacePackage;
    procedure AddPackageList;
    procedure AddPackage(pkg: string);
    procedure SetSplash(sname: string);
    procedure DoOp(op: char);
    procedure LoadModList(fname: string);
    procedure AddHook(cmdline: string);
    procedure AddRCLocal(cmdline: string);
  public

  end;

var
  BuilderForm: TBuilderForm;

implementation

const
  BUILD_DIR = '/srv/builder';
  MOD_DIR = '/home/kveroneau/mods/';

{$R *.lfm}

{ TBuilderForm }

procedure TBuilderForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FindAllFiles(ModList.Items, MOD_DIR, '*.mod', False, faNormal);
  for i:=0 to ModList.Items.Count-1 do
    ModList.Items.Strings[i]:=ExtractFileName(ModList.Items.Strings[i]);
  ModList.Sorted:=True;
  FScript:=TScriptSystem.Create(Self);
  FScript.OnOutput:=@PrintOut;
  FScript.OnOpCode:=@DoOp;
  FScript.OnRunFile:=@AddModDep;
  FProc:=TProcess.Create(Self);
  FProc.CurrentDirectory:=BUILD_DIR+'/config';
  FProc.Executable:='/usr/bin/tar';
  FProc.Parameters.Add('-xzf');
  FProc.Parameters.Add('/dev/null');
  FDepMods:=TStringList.Create;
  FMods:=TStringList.Create;
  FLog:=TKConsole.Create(Self);
  FLog.AddLog('Welcome!');
  FPkgList:=Nil;
  FHooks:=Nil;
  FConfig:=Nil;
  FRCLocal:=Nil;
  SaveDialog1.InitialDir:=MOD_DIR;
  OpenDialog1.InitialDir:=MOD_DIR;
end;

procedure TBuilderForm.FormDestroy(Sender: TObject);
begin
  FDepMods.Free;
  FMods.Free;
end;

procedure TBuilderForm.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  if DirectoryExists(BUILD_DIR+'/config') then
    Exec('/bin/rm', '-rf '+BUILD_DIR+'/config');
  CreateDir(BUILD_DIR+'/config');
  FProc.Parameters.Strings[1]:=MOD_DIR+'base.tgz';
  FProc.Execute;
  FProc.WaitOnExit;
  FDepMods.Clear;
  FMods.Clear;
  FConfig:=TConfiguration.Create(Self);
  for i:=0 to ModList.Count-1 do
    if ModList.Selected[i] then
      RunModule(ModList.Items.Strings[i]);
  if FDepMods.Count > 0 then
  begin
    repeat
      RunModule(FDepMods.Pop);
    until FDepMods.Count = 0;
  end;
  if Assigned(FPkgList) then
  begin
    FPkgList.SaveToFile(BUILD_DIR+'/config/package-lists/extra.list.chroot');
    FreeAndNil(FPkgList);
  end;
  if Assigned(FHooks) then
  begin
    FHooks.Add('');
    FHooks.Add('exit 0');
    FHooks.SaveToFile(BUILD_DIR+'/config/hooks/normal/9999-livebuilder.hook.chroot');
    FreeAndNil(FHooks);
  end;
  if Assigned(FRCLocal) then
  begin
    FRCLocal.Add('');
    FRCLocal.Add('exit 0');
    FRCLocal.SaveToFile(BUILD_DIR+'/config/includes.chroot_after_packages/etc/rc.local');
    FreeAndNil(FRCLocal);
    Exec('/bin/chmod', '+x '+BUILD_DIR+'/config/includes.chroot_after_packages/etc/rc.local');
  end;
  FConfig.SaveConfig(BUILD_DIR);
  FreeAndNil(FConfig);
  FLog.AddLog(' ****** BUILD ENVIRONMENT READY ********');
end;

procedure TBuilderForm.Button2Click(Sender: TObject);
var
  i: integer;
  lst: TStringList;
begin
  if not SaveDialog1.Execute then
    Exit;
  lst:=TStringList.Create;
  try
    for i:=0 to ModList.Count-1 do
      if ModList.Selected[i] then
        lst.Add('R'+ExtractFileNameWithoutExt(ModList.Items.Strings[i])+'~');
    lst.Add('X');
    lst.SaveToFile(SaveDialog1.FileName);
  finally
    lst.Free;
  end;
end;

procedure TBuilderForm.Button3Click(Sender: TObject);
var
  f: TStringList;
begin
  if not OpenDialog1.Execute then
    Exit;
  FScript.OnRunFile:=@LoadModList;
  f:=TStringList.Create;
  try
    f.LoadFromFile(OpenDialog1.FileName);
    FScript.Script:=f.Text;
  finally
    f.Free;
  end;
  FConfig:=TConfiguration.Create(Self);
  FScript.Run;
  FreeAndNil(FConfig);
  FScript.OnRunFile:=@AddModDep;
end;

procedure TBuilderForm.ModListDblClick(Sender: TObject);
var
  fname: string;
begin
  fname:=MOD_DIR+'Info/'+ExtractFileNameWithoutExt(ModList.GetSelectedText)+'.txt';
  if FileExists(fname) then
    Memo1.Lines.LoadFromFile(fname)
  else
    Memo1.Text:='No Info Available.';
end;

procedure TBuilderForm.AddModDep(fname: string);
begin
  if FMods.IndexOf(fname) > -1 then
    Exit;
  FLog.AddLog('Module Dep: '+fname);
  if FDepMods.IndexOf(fname+'.mod') = -1 then
    FDepMods.Add(fname+'.mod');
end;

procedure TBuilderForm.RunModule(fname: string);
var
  f: TStringList;
begin
  if FMods.IndexOf(fname) > -1 then
    Exit;
  FMods.Add(fname);
  FLog.AddLog(' * Running Module: '+fname+'...');
  Application.ProcessMessages;
  f:=TStringList.Create;
  try
    f.LoadFromFile(MOD_DIR+fname);
    FScript.Script:=f.Text;
    FCurMod:=ExtractFileNameWithoutExt(fname);
    FScript.Run;
  finally
    f.Free;
  end;
end;

procedure TBuilderForm.PrintOut(data: string);
begin
  FLog.AddLog(data);
  Application.ProcessMessages;
end;

procedure TBuilderForm.ExtractMod;
begin
  FLog.AddLog('Extracting data...');
  Application.ProcessMessages;
  FProc.Parameters.Strings[1]:=MOD_DIR+'Packages/'+FCurMod+'.tgz';
  FProc.Execute;
  FProc.WaitOnExit;
  if FProc.ExitStatus <> 0 then
    ShowMessage('Error extracting data for module: '+FCurMod);
end;

procedure TBuilderForm.PlaceFile(where: string);
begin
  FLog.AddLog('Placing important file...');
  Application.ProcessMessages;
  Exec('/bin/mkdir', '-p '+ExtractFileDir(BUILD_DIR+'/config/includes.chroot_after_packages'+where));
  CopyFile(MOD_DIR+'Files/'+FCurMod, BUILD_DIR+'/config/includes.chroot_after_packages'+where);
end;

procedure TBuilderForm.PlacePackage;
begin
  FLog.AddLog('Placing Package...');
  Application.ProcessMessages;
  CopyFile(MOD_DIR+'Packages/'+FCurMod+'.deb', BUILD_DIR+'/config/packages.chroot/'+FCurMod+'.deb');
end;

procedure TBuilderForm.AddPackageList;
begin
  FLog.AddLog('Adding Package List...');
  Application.ProcessMessages;
  CopyFile(MOD_DIR+'Lists/'+FCurMod+'.list', BUILD_DIR+'/config/package-lists/'+FCurMod+'.list.chroot');
end;

procedure TBuilderForm.AddPackage(pkg: string);
begin
  if not Assigned(FPkgList) then
    FPkgList:=TStringList.Create;
  FPkgList.Add(pkg);
end;

procedure TBuilderForm.SetSplash(sname: string);
begin
  AddPackage('plymouth');
  AddPackage('plymouth-theme-breeze');
  AddHook('plymouth-set-default-theme '+sname);
  if sname = 'breeze-text' then
    PlaceFile('/usr/share/plymouth/themes/breeze-text/breeze-text.plymouth');
  FConfig.BootAppend:='quiet splash';
end;

procedure TBuilderForm.DoOp(op: char);
begin
  case op of
    '>': ShowMessage(FCurMod);
    'T': ExtractMod;
    'C': PlaceFile(FScript.GetString);
    'D': PlacePackage;
    'L': AddPackageList;
    'A': AddPackage(FScript.GetString);
    #10: FScript.Running:=True; // Generate a NOP
    'V': FConfig.ISOVolume:=FScript.GetString;
    'U': FConfig.UserFull:=FScript.GetString;
    'u': FConfig.Username:=FScript.GetString;
    'a': FConfig.AutoLogin:=False;
    'G': FConfig.AddUserGroup(FScript.GetString);
    'H': AddHook(FScript.GetString);
    'B': AddRCLocal(FScript.GetString);
    'S': SetSplash(FScript.GetString);
    '%': FConfig.BootAppend:=FScript.GetString;
  else
    FScript.Running:=False;
  end;
end;

procedure TBuilderForm.LoadModList(fname: string);
var
  i: Integer;
begin
  i:=ModList.Items.IndexOf(fname+'.mod');
  if i = -1 then
    Exit;
  ModList.Selected[i]:=True;
end;

procedure TBuilderForm.AddHook(cmdline: string);
begin
  if not Assigned(FHooks) then
  begin
    FHooks:=TStringList.Create;
    FHooks.Add('#!/bin/sh');
    FHooks.Add('');
  end;
  FHooks.Add(cmdline);
end;

procedure TBuilderForm.AddRCLocal(cmdline: string);
begin
  if not Assigned(FRCLocal) then
  begin
    FRCLocal:=TStringList.Create;
    FRCLocal.Add('#!/bin/sh');
    FRCLocal.Add('');
  end;
  FRCLocal.Add(cmdline);
end;

end.

