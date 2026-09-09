# Packaging and distribution

OpenOSK ships in two forms from every release, both built by `.github/workflows/build.yml`
on GitHub's Windows runners with no tooling beyond the .NET SDK and Inno Setup:

| File | What it is | Use it when |
|---|---|---|
| `OpenOSK-Setup-win-x64.exe`, `OpenOSK-Setup-win-arm64.exe` | Per-user installer | You want a Start menu entry, an "Installed apps" entry with Uninstall, and in-place updates. |
| `OpenOSK-win-x64.exe`, `OpenOSK-win-arm64.exe` | Portable single file | You want to run it from a folder or USB stick with nothing installed. |

Each file has a `.sha256` beside it.

## The installer

`packaging/inno/OpenOSK.iss` is an [Inno Setup 6](https://jrsoftware.org/isinfo.php) script.

- Installs to `%LOCALAPPDATA%\Programs\OpenOSK` and needs **no administrator rights**. The
  setup wizard offers an all-users install to `Program Files` if you run it elevated.
- Adds `OpenOSK` to the Start menu and to Settings → Apps → Installed apps, with Uninstall.
- Offers *Start OpenOSK when I sign in* and a desktop shortcut during setup. The sign-in option
  writes the same `HKCU\...\Run\OpenOSK` value the application's own Options dialog uses, so
  either place can turn it on or off.
- **Updating** is running the newer setup: it closes a running keyboard, replaces the file and
  keeps your settings. Nothing in the application checks for updates; that is deliberate (see
  [privacy.md](privacy.md)). `winget upgrade` does the same from the command line once the
  package is in the winget repository.
- **Uninstalling** removes the program and the Start menu entry, and asks whether to delete
  `%LOCALAPPDATA%\OpenOSK` (settings and learned words). A silent uninstall keeps them.

Build it locally with Inno Setup installed:

```powershell
dotnet publish src\OpenOsk\OpenOsk.csproj -c Release -r win-x64 -o publish\win-x64; & "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" /DAppVersion=0.1.0 /DArch=win-x64 "/DPublishDir=$PWD\publish\win-x64" packaging\inno\OpenOSK.iss
```

The result is `publish\installer\OpenOSK-Setup-win-x64.exe`. A per-user Inno Setup install
(`winget install JRSoftware.InnoSetup --scope user`, no administrator rights) puts `ISCC.exe` in
`%LOCALAPPDATA%\Programs\Inno Setup 6` instead of Program Files (x86); adjust the path above.
Silent install and uninstall use the
standard Inno switches: `/VERYSILENT /NORESTART` and, for uninstall,
`"%LOCALAPPDATA%\Programs\OpenOSK\unins000.exe" /VERYSILENT`.

## winget

The installer is the right artefact for a [winget-pkgs](https://github.com/microsoft/winget-pkgs)
manifest (`InstallerType: inno`, `Scope: user`, one installer entry per architecture, SHA-256
from the release's `.sha256` files, `ProductCode` `{8F6E3B0A-5C2D-4B1F-9E7A-3D2C1B0A9F8E}_is1`).
Manifests for submission live under `packaging/winget/` once a release exists; validate with
`winget validate` and test with `winget install --manifest <folder>` before opening the PR.

## Code signing

Neither file is signed yet, so Windows shows a SmartScreen "unknown publisher" warning the first
time each is run. Signing the two setup files and the two portable files with a certificate from
[SignPath's open-source programme](https://signpath.org/) or Azure Trusted Signing removes that
warning and needs only a `signtool` step added to the `installer` and `publish` jobs. It costs
nothing in code, and it is the one item on this page that is not yet done.

## MSIX, and why not yet

An MSIX package was evaluated. It would work (WPF full-trust package, `StartupTask` extension
in place of the Run key, data redirected to `%LOCALAPPDATA%\Packages\...`), but it only installs
when its certificate is trusted, so without a real certificate every user would first have to
import one, which is a worse first run than the installer above. It also removes the "run as
administrator" workaround for typing into elevated windows unless the `allowElevation`
capability is granted. Revisit once signing exists; until then the installer covers the
install, uninstall and update experience.
