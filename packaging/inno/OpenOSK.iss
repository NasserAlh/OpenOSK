; OpenOSK per-user installer (Inno Setup 6).
;
; Built by .github/workflows/build.yml with:
;   ISCC /DAppVersion=0.1.0 /DArch=win-x64 /DPublishDir=..\..\publish\win-x64 OpenOSK.iss
;
; Installs to %LOCALAPPDATA%\Programs\OpenOSK without administrator rights, adds a Start menu
; entry and an "Installed apps" entry with Uninstall, and upgrades in place when a newer
; setup is run. The application itself is unchanged: it still keeps its data in
; %LOCALAPPDATA%\OpenOSK and uses the same Run key for "start at sign-in".

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef Arch
  #define Arch "win-x64"
#endif
#ifndef PublishDir
  #define PublishDir "..\..\publish\" + Arch
#endif

#define AppName "OpenOSK"
#define AppExeName "OpenOSK.exe"
#define AppPublisher "OpenOSK contributors"
#define AppURL "https://github.com/NasserAlh/OpenOSK"
#define IconFile "..\..\src\OpenOsk\Assets\OpenOSK.ico"

[Setup]
; Stable per-product id: upgrades and uninstalls find the existing install through it.
AppId={{8F6E3B0A-5C2D-4B1F-9E7A-3D2C1B0A9F8E}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={localappdata}\Programs\{#AppName}
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
#if Arch == "win-arm64"
ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64
#else
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#endif
MinVersion=10.0.17763
OutputDir=..\..\publish\installer
OutputBaseFilename=OpenOSK-Setup-{#Arch}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
; A running keyboard is closed (via Restart Manager) before files are replaced on upgrade.
; Do not add AppMutex: with it Setup refuses to continue while the keyboard runs instead of
; closing it, which made the first upgrade test fail.
CloseApplications=yes
RestartApplications=no
#ifexist IconFile
SetupIconFile={#IconFile}
#endif
LicenseFile=..\..\LICENSE

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "startup"; Description: "Start {#AppName} when I sign in"; GroupDescription: "Options:"; Flags: unchecked
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Options:"; Flags: unchecked

[Files]
Source: "{#PublishDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\LICENSE"; DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Comment: "On-screen keyboard"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Registry]
; Same value the application writes from its own Options dialog, so both stay in step.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppName}"; ValueData: """{app}\{#AppExeName}"""; Flags: uninsdeletevalue; Tasks: startup

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[Code]
// On an interactive uninstall, offer to remove settings and learned words as well. A silent
// uninstall (winget, scripts) keeps them so an upgrade-by-reinstall never loses user data.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    DataDir := ExpandConstant('{localappdata}\OpenOSK');
    if DirExists(DataDir) and not UninstallSilent then
    begin
      if MsgBox('Also delete your OpenOSK settings and learned words?' + #13#10 + DataDir,
                mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
        DelTree(DataDir, True, True, True);
    end;
  end;
end;
