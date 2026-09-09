# Verification record

What has actually been proven on a Windows machine, when, on which build, and what was observed.
[testing.md](testing.md) is the procedure; this file is the record. A step that is not listed here
has not been run. Every row names the date, the commit the tested build was published from, and the
observation itself, so a later reader can tell a proven claim from a plausible one.

Add a new dated section for every pass. Do not edit old sections except to correct a factual error.

## Environment used for the passes below

- Windows 11 Pro, version 10.0.26200 (build 26200.9278), x64, one display of 3440 × 1440 at 150 %
  (144 DPI). Input languages en-US and ar-KW; United States-International was added only for 2.3.
- The keyboard under test was always the self-contained win-x64 publish
  (`dotnet publish src/OpenOsk/OpenOsk.csproj -c Release -r win-x64 -o out`), which bundles .NET 8.
  The machine has only the .NET 9 SDK and runtime, so the core tests ran with `RollForward=Major`.
- Target applications: Windows 11 Notepad (a scratch `.txt` tab), Calculator, Microsoft Edge, an
  elevated `cmd.exe`.
- The keyboard was driven by scripts: UI Automation to find keys by label, `SendInput` for clicks and
  drags, `keybd_event` for physical keys, and `WM_INPUTLANGCHANGEREQUEST` to switch a window's input
  language. Results were read back through UI Automation text patterns, Win32 window queries,
  screenshots, the registry, and Core Audio session peak meters.

## Pass 1 — 2026-09-08 and 2026-09-09, sections 0 to 10

Builds were published from the working tree between `be479fa` and `e4a2bdd`; every step that failed
was re-tested on the build containing its fix. At the end of the pass the core suite was 62 tests,
all passing.

| Step | Result | Observation | Fix |
|---|---|---|---|
| 0.1 | PASS | 54 core tests passed at `be479fa` (62 after the fixes below). Publish produced a single `out\OpenOSK.exe` of 72 MB and nothing else. | |
| 0.2 | PASS | 0.2 s after launch the window sat at (670,672)–(2770,1356) px: horizontally centred, 12 px above the taskbar, extended styles NOACTIVATE, TOPMOST, APPWINDOW, not foreground, with a taskbar button. | |
| 0.3 | PASS | A second launch left one process; the first window came back from minimised at the same place without taking focus. | |
| 1.1 | PASS | Clicking h-e-l-l-o put `hello` in Notepad; Notepad stayed foreground; OpenOSK never became foreground. | |
| 1.2 | PASS | A 100 px title-bar drag moved the window 101 px; Notepad stayed foreground throughout. | |
| 1.3 | FAIL → PASS | Before: a 2 s hold typed 34 characters (about 22 per second) against `KeyboardSpeed` 31 (30 per second). After the fix: 76 characters in 3 s and 16 in 1 s, exactly on rate. | `1a510e4` |
| 1.4 | PASS | Shift once then `a` typed `A`; both Shift keys showed the outlined latched state, then released. | |
| 1.5 | PASS | Shift twice then `abc` typed `ABC` with both Shift keys solid; a third tap released and `d` typed lower-case. | |
| 1.6 | PASS | Ctrl-a, Ctrl-c, a click, Ctrl-v gave `abcabc`. | |
| 1.7 | PASS (procedure corrected) | Fn showed F1–F12 on the number row; F5 inserted `11:50 PM 9/8/2026` in Notepad; the row reverted because Fn is one-shot like Shift. The step in testing.md assumed Fn stayed on and pressed F1; it now uses F5. | `70080a8` |
| 1.8 | PASS | Caps then `a` typed `A` with Caps solid and upper-case labels; a physical Caps Lock press turned the indicator off and the next `a` was lower-case. | |
| 1.9 | PASS | A held physical Shift lit both on-screen Shift keys and switched the labels to shifted symbols; release reverted them. | |
| 1.10 | PASS | Enter, Tab, Bksp, Home, Del, End, the four arrows and PgUp each produced the expected edit in Notepad. | |
| 1.11 | PASS | Win then `r` opened the Run dialog; Esc from OpenOSK closed it. | |
| 1.12 | PASS | `file:///c:/windows/win.ini` typed into an Edge address bar, then Enter; the tab title became `win.ini`. | |
| 2.1 | PASS | With Notepad switched to Arabic (HKL 0x4010401) the second row read ض ص ث ق ف غ ع ه خ ح ج د within 1.2 s. | |
| 2.2 | PASS | Tapping ض ص Space ش produced `ضص ش`. | |
| 3.1 | PASS | Ticking the numeric key pad added a 4-column block (NumLk / * - … 0 .) between the letters and the command column. | |
| 3.2 | PASS | 7 + 2 Enter on the pad gave Calculator `Display is 9`. | |
| 3.3 | FAIL → PASS | Before: with Num Lock off, pad 7 typed `7`. After: pad 7 moved the caret home (`zabc`), pad `.` deleted (`zbc`), and with Num Lock on pad 7 typed a digit again (`z7bc`). | `23625b2` |
| 4.1 | PASS | Mv Up put the window at y = 0; Mv Dn put its bottom edge at 1368, the work-area bottom. | |
| 4.2 | PASS | Dock made the window (0,684)–(3440,1368); a maximised Notepad shrank so its client area ended at the keyboard's top edge; the resize frame was removed and a title-bar drag did nothing; the Dock key was highlighted. | |
| 4.3 | PASS | Dock again returned the window to its previous 2100 × 684 place and Notepad regained its full height. | |
| 4.4 | FAIL → PASS | Before: the window never received the layered style (WPF strips it) and stayed opaque. After: translucent over VS Code with the pointer away, opaque with the pointer over it, solid after Fade off. | `12c7a63` |
| 4.5 | PASS | Nav gave a 1155 × 616 window titled `Navigation` with Tab, Esc, Home, arrows, PgUp/PgDn, Bksp, Ctrl, Del, Enter, Alt, Insert, End, Space, Menu, Shift, Win, F1–F12, Caps, Options, Help; Gen returned. | |
| 4.6 | PASS | The Nav placement (300,200) 1200 × 500 and the full placement (0,0) 2100 × 684 were each restored across two switches. | |
| 4.7 | PASS | Help opened an 840 × 780 window with its text and closed; Options opened and Cancel closed it. | |
| 4.8 | PASS | Unticking the command-key option removed Nav / Mv Up / Mv Dn / Dock / Fade; the gear button still opened Options; ticking restored the column. | |
| 5.1 | PASS (rendering fixed) | `th` produced the chips the that this they their there. The chip text was drawn half under the key rows because the row had a fixed height. | `e4a2bdd` |
| 5.2 | PASS | Clicking `that` inserted `that ` with the trailing space. | |
| 5.3 | PASS | `Th` gave That The This They Their There; `TH` gave THAT THE THIS THEY THEIR THERE. | |
| 5.4 | FAIL → PASS | `zorblax` was suggested first after typing it, but learned-words.txt stayed empty. After the fix the file held `zorblax	1` within 3 s. | `bc46af9` |
| 5.5 | PASS | Forget learned words emptied the file and `zo` no longer suggested it. | |
| 5.6 | PASS | Unticking predictions removed the row; ticking brought it back. | |
| 6.1 | FAIL → PASS | Before: after OK closed Options in hover mode, the dwell fired on the Options key still under the pointer and reopened the dialog. After: the dialog stayed closed and the title read `Hover`. | `a522325` |
| 6.2 | PASS | Resting on `a` filled the bar and typed one `a` at 1.5 s; the text was still one `a` at 3.5 s. | |
| 6.3 | PASS | Leaving `b` after 0.4 s typed nothing. | |
| 6.4 | PASS | Hovering Shift then `b` typed `B`. | |
| 6.5 | PASS | A click typed `c`. | |
| 7.1 | PASS | Title read `Scan` with speed 1.0 s, Space and mouse click selected. | |
| 7.2 | PASS | Rows highlighted 1, 2, 3, 4, 0, 1 at about 1 s each, the command-column key lit with each row. | |
| 7.3 | PASS | Space on the Caps row stepped Caps, a, s, d one per second. | |
| 7.4 | PASS | Space on `f` typed `f` and row scanning resumed. | |
| 7.5 | PASS | The Fn row (14 keys) was swept twice, then row scanning resumed; 28 s of scanning, 33 s measured including script overhead. | |
| 7.6 | PASS | A click on the keys entered the Shift row (Shift, z, x); a second click selected `x` and typed it. | |
| 7.7 | PASS | A physical Space during row scanning typed nothing; a second Space selected Fn, again typing nothing. | |
| 7.8 | PASS | Back in Click mode a physical Space typed a space. | |
| 8.1 | PASS | Dark then Light applied at once, Options dialog included. | |
| 8.2 | PASS | Following Windows, flipping `AppsUseLightTheme` to 1 turned the keyboard light within 3 s; restoring it turned it dark. | |
| 8.4 | FAIL → PASS | Before: Home, Insert, PrtScn, Mv Up, Dock and Options were cut to `Ho…` at 2100 px, and the bottom row was clipped at the 160 DIP minimum. After: every label fits at 2100 px, in Nav, with the pad and at the 630 × 300 px minimum; an edge drag resized 2100 → 1702 px with Notepad still focused. | `dfae981` |
| 8.6 | PASS (plumbing) | Unticking and ticking Use click sound wrote `clickSound` false then true; keys kept typing. Sound itself: see pass 2. | |
| 9.1 | PASS | After a move to (400,300) 1600 × 600, close and reopen, the window came back at exactly that rectangle. | |
| 9.2 | PASS | settings.json parsed as JSON with `window` and `navigationWindow` placements and the options set. | |
| 9.3 | PASS | Ticking the sign-in option wrote `HKCU\…\Run\OpenOSK` = the quoted exe path; unticking removed it. | |
| 9.4 | PASS | `--nav` started in Navigation; `--dock` started docked full-width at the bottom. | |
| 9.5 | PASS | With both start options ticked the next launch was docked and in Navigation. | |
| 10.1 | PASS | 471 on-screen clicks plus 6 injected physical keystrokes in 61 s produced 477 characters; click cadence 126 ms at the start and 125 ms at the end; 7.3 s CPU over the minute; working set 291 → 295 MB; process responding. | |
| 10.3 | PASS | With settings.json replaced by `{`, the keyboard started at the default bottom-centre place, typed, and rewrote valid JSON on the next option change. | |

Steps 2.3, 8.3, 8.5, 8.6 (audible), 10.2 and 10.4 needed a person and were carried to pass 2.

## Pass 2 — 2026-09-09, the person-dependent steps

Build published from `3c10466`. Every system setting changed during the pass was restored and
re-read afterwards: input methods en-US = 0409:00000409 and ar-KW = 3401:00000401, contrast theme
None (dark.theme, accessibility flags 126, apps in dark mode), no `Run\OpenOSK` value.

| Step | Result | Observation | Fix |
|---|---|---|---|
| 2.3 | PASS (procedure corrected) | With United States-International added and Notepad switched to it, `'` then `e` typed `é` and `'` then Space typed `'`. The key showed `'`, not `´`: `ToUnicodeEx` reports U+0027 as that dead key's standalone character on this layout. testing.md and feature-parity.md now say so. | `aded7eb` |
| 8.3 | PASS | With the Aquatic contrast theme applied from Settings › Accessibility › Contrast themes, the keyboard repainted in system colours (yellow caption, black keys, white text) and so did the Options dialog; setting the theme to None returned it to dark. The Alt+Shift+PrtScn shortcut could not be exercised: injected Print Screen opens the Snipping Tool on Windows 11. | |
| 8.5 | SKIPPED | One display attached. | |
| 8.6 | PASS (plumbing); sound not recorded | OpenOSK's audio session peaked at 0.571 on every click with the option on, 0.000 with it off, 0.571 again after re-enabling. Whether the click is audible was not recorded. | |
| 10.2 | PASS | Against an elevated `cmd.exe` (token integrity 0x3000, launched through Run + Ctrl+Shift+Enter and a UAC prompt accepted by hand) tapping a, b, c and Enter left an empty prompt; the elevated window stayed foreground; OpenOSK stayed responsive and no error.log was created. Notepad then received `ok`, Enter, `again`. Windows 11's packaged Notepad cannot serve this step: after Yes on UAC it still runs at medium integrity. | |
| 10.4 | PASS | The Run value was `"C:\Users\nasser\Dev\OpenOSK\out\OpenOSK.exe"`; executing that line with the keyboard minimised restored it with one process. After a sign-out and sign-in, one keyboard appeared (reported by hand) and the script saw one process and no error.log. | |

## Release v0.1.0 — 2026-09-10

Tag `v0.1.0` was placed on `1d0c905` and pushed on 2026-09-09 at 22:54 UTC. The Build workflow run
34414463547 (core tests on Ubuntu and Windows, publish win-x64 and win-arm64, GitHub release)
completed successfully and published the release at 22:58 UTC with four assets:
`OpenOSK-win-x64.exe`, `OpenOSK-win-arm64.exe` and their `.sha256` files.

| Check | Result | Observation |
|---|---|---|
| x64 checksum | PASS | `OpenOSK-win-x64.exe` (71,947,295 bytes) hashed to the value in `OpenOSK-win-x64.exe.sha256`. |
| x64 launch | PASS | On the pass-2 machine the released exe (file version 0.1.0.0) opened one window at its saved place, 1236 × 492 px, with the NOACTIVATE, TOPMOST and APPWINDOW styles, and reported responding. |
| x64 single instance | PASS | Launching the same exe a second time left one process. |
| x64 close | PASS | Closing through the window left zero processes, a valid settings.json and no error.log. |
| Arm64 | NOT RUN | No Arm64 device. |

## Pass 3 — 2026-09-10, the installer (section 11)

Installer built locally with Inno Setup 6.7.3 from the tree at `b912271` (icon added) and, for
11.2 onwards, from `75367ab` (the `AppMutex` fix). Every step ran without a UAC prompt
(`consent.exe` was polled throughout and never appeared).

| Step | Result | Observation | Fix |
|---|---|---|---|
| 11.1 | PASS | The wizard offered *Install for me only*, installed to `%LOCALAPPDATA%\Programs\OpenOSK` (OpenOSK.exe, LICENSE.txt, unins000.*) and launched the keyboard from there. Start menu `OpenOSK.lnk` present; Installed apps showed "OpenOSK 0.1.0, OpenOSK contributors" with the blue keyboard icon; `Run\OpenOSK` = `"C:\Users\<user>\AppData\Local\Programs\OpenOSK\OpenOSK.exe"`. | |
| 11.2 | FAIL → PASS | Before: the 0.1.1 setup stopped at "Setup has detected that OpenOSK is currently running. Please close all instances…" (the `AppMutex` check). After the fix: no prompt, the keyboard process disappeared during the Installing page and Finish started a new one from the same path, `settings.json` was byte-identical before and after, Installed apps showed 0.1.1, the Run value was kept. | `75367ab` |
| 11.3 | PASS | `/VERYSILENT /NORESTART` with the keyboard running: exit code 0 after 2 s, no visible window from the setup process, keyboard closed and not relaunched, the four installed files present. | |
| 11.4 | PASS | Settings › Apps › Installed apps › … › Uninstall › Uninstall started the uninstaller. "Completely remove?" Yes, "Also delete settings and learned words?" No: program folder, Start menu entry, Run value and uninstall key gone, `%LOCALAPPDATA%\OpenOSK` kept. Reinstalled and repeated answering Yes: the data folder was removed as well. | |
| 11.5 | PASS | After a reinstall and one run, `unins000.exe /VERYSILENT` removed the program, Start menu entry, Run value and uninstall key with no window and kept `%LOCALAPPDATA%\OpenOSK`. | |

Also on 2026-09-10: the application icon (`b912271`) was seen in the main title bar, the taskbar
button, the Options window's title bar and Alt+Tab.

## Release v0.1.0 re-cut — 2026-09-10

The 2026-09-09 release (tag on `1d0c905`, four assets) was deleted together with its tag, and
`v0.1.0` was re-tagged on `297e810` so the release carries the installer and the icon. Workflow run
34418538912 succeeded and published the release at 23:54 UTC with eight assets:
`OpenOSK-Setup-win-x64.exe`, `OpenOSK-Setup-win-arm64.exe`, `OpenOSK-win-x64.exe`,
`OpenOSK-win-arm64.exe` and a `.sha256` for each.

| Check | Result | Observation |
|---|---|---|
| x64 setup checksum | PASS | `OpenOSK-Setup-win-x64.exe` (66,675,597 bytes) downloaded from the release hashed to the value in its `.sha256`. |
| x64 setup install | PASS | Installed without a UAC prompt; Installed apps shows "OpenOSK 0.1.0, OpenOSK contributors" with the keyboard icon; the Start menu entry exists and launched the keyboard from `%LOCALAPPDATA%\Programs\OpenOSK\OpenOSK.exe` (file version 0.1.0.0), which typed `release ok` into Notepad. No error.log. |
| Arm64 assets | NOT RUN | No Arm64 device. |

## Fixes made during verification

| Commit | Step | What changed |
|---|---|---|
| `1a510e4` | 1.3 | Key repeat is scheduled by a `KeyRepeater` in Core; late timer ticks send the repeats they owe. |
| `23625b2` | 3.3 | The stroke planner substitutes the navigation twin of a numpad key while Num Lock is off. |
| `12c7a63` | 4.4 | Fade uses `AllowsTransparency` and `Window.Opacity`; WPF strips `WS_EX_LAYERED` from other windows. |
| `bc46af9` | 5.4 | Learning a word schedules the debounced save. |
| `a522325` | 6.2 | After a dialog closes, the key under the pointer is ignored by hover mode until the pointer leaves it. |
| `dfae981` | 8.4 | Long labels shrink to fit; minimum window height 200 DIP. |
| `e4a2bdd` | 5.1 | The suggestion row sizes itself to its chips. |
| `70080a8`, `aded7eb` | 1.7, 2.3 | Procedure corrections; behaviour unchanged. |

## Not proven

- 8.5: no second display was available.
- 8.6: the click was never heard by the tester; only the session meter was read.
- The Arm64 build has never been run.
- `3c10466` (hide the corner label on small keys) was published for pass 2 but not looked at again
  at the minimum window size.
- 2.3 on a layout whose dead key is an accent (German `´`) was not tried.
- Hover and scan modes were driven with the mouse and the Space key only; no switch device.
- 10.4 rests on a hand report for the sign-in itself.
