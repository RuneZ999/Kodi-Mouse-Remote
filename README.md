# Kodi Secondary Mouse Remote

This AutoHotKey v1 script uses a secondary, or primary mouse as a remote Kodi media player running under Windows.

## Usage

| Action | Function |
|--------|----------|
| Left Click | `Space` |
| Long Left Click | `Enter` |
| Right Click | `Backspace` |
| Long Right Click | Volume Control |
| Scroll Up | `Up Arrow` (Vertical mode), `Right Arrow` (Horizontal mode), `Volume Up` (Volume mode) |
| Scroll Down | `Down Arrow` (Vertical mode), `Left Arrow` (Horizontal mode), `Volume Down` (Volume mode) |
| Middle Click | `Left Click` |
| Long Middle Click | Toggle scroll mode between Vertical and Horizontal |

## Features
- This script works only with Kodi for Windows as AHK is not supported under Linux (`interception-tools` is a alternative that can be used with Python or any language of your likeing)
- Uses the **AutoHotInterception** library and **Interception driver** for handling mouse events.
- Supports **long press detection** for mouse buttons.
- Toggles **scroll modes** dynamically: Vertical, Horizontal, and Volume control.

## Installation
1. Install the Interception driver from [GitHub](https://github.com/oblitum/Interception/releases):  
   ```sh
   install-interception.exe /install

2. Restart

3. Install AutoHotKey version 1 from [AutoHotKey](https://www.autohotkey.com/)

## Uninstall
  Uninstall the Interception driver:  
   ```sh
   install-interception.exe /uninstall
