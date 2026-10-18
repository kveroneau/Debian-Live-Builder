unit autoconf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dos;

type

  { TConfiguration }

  TConfiguration = class(TComponent)
  private
    FISOVolume: string;
    FUsername, FUserFull: string;
    FAutoLogin, FAutoLoginX: boolean;
    FUserGroups: TStringList;
    FBootAppend: string;
    function UserGroups: string;
  public
    property ISOVolume: string read FISOVolume write FISOVolume;
    property Username: string read FUsername write FUsername;
    property UserFull: string read FUserFull write FUserFull;
    property AutoLogin: boolean read FAutoLogin write FAutoLogin;
    property AutoLoginX: Boolean read FAutoLoginX write FAutoLoginX;
    property BootAppend: string read FBootAppend write FBootAppend;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddUserGroup(grp: string);
    procedure SaveConfig(build_dir: string);
  end;

implementation

function Bool2Str(value: boolean): string;
begin
  if value then
    Result:='true'
  else
    Result:='false';
end;

{ TConfiguration }

function TConfiguration.UserGroups: string;
var
  i: Integer;
begin
  Result:='audio cdrom dip floppy video plugdev netdev powerdev';
  for i:=0 to FUserGroups.Count-1 do
    Result:=Result+' '+FUserGroups.Strings[i];
end;

constructor TConfiguration.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FISOVolume:='Debian Live';
  FUsername:='user';
  FUserFull:='Live User';
  FAutoLogin:=True;
  FAutoLoginX:=True;
  FUserGroups:=TStringList.Create;
  FBootAppend:='hostname=rogstick quiet splash';
end;

destructor TConfiguration.Destroy;
begin
  FUserGroups.Free;
  inherited Destroy;
end;

procedure TConfiguration.AddUserGroup(grp: string);
begin
  FUserGroups.Add(grp);
end;

procedure TConfiguration.SaveConfig(build_dir: string);
var
  f: TStringList;
begin
  f:=TStringList.Create;
  try
    f.Add('!#/bin/sh'#10);
    f.Add('lb config noauto \');
    f.Add('        -b iso -d bookworm --apt-indices false \');
    f.Add('        --apt-recommends false --memtest none \');
    f.Add('        --iso-volume "'+FISOVolume+'" \');
    f.Add('        --iso-preparer "Kevin Veroneau" \');
    f.Add('        --iso-publisher "Kevin Veroneau Consulting" \');
    f.Add('        --bootappend-live "boot=live config '+FBootAppend+'" \');
    f.Add('        --archive-areas "main contrib non-free" \');
    f.Add('        "${@}"');
    f.SaveToFile(build_dir+'/auto/config');
    f.Clear;
    f.Add('LIVE_USERNAME="'+FUsername+'"');
    f.Add('LIVE_USER_FULLNAME="'+FUserFull+'"');
    f.Add('LIVE_USER_DEFAULT_GROUPS="'+UserGroups+'"');
    f.Add('LIVE_CONFIG_NOAUTOLOGIN="'+Bool2Str(not FAutoLogin)+'"');
    f.Add('LIVE_CONFIG_NOX11AUTOLOGIN="'+Bool2Str(not FAutoLoginX)+'"');
    f.Add('LIVE_TIMEZONE="America/Edmonton"');
    Exec('/bin/mkdir', '-p '+build_dir+'/config/includes.chroot_after_packages/etc/live');
    f.SaveToFile(build_dir+'/config/includes.chroot_after_packages/etc/live/config.conf');
  finally
    f.Free;
  end;
end;

end.

