# Safety Notes

RazorWear is built to avoid important files.

## Regular Cleanup

Regular cleanup always starts with:

- Your Windows user temp folder
- The Windows temp folder

Optional cleanup targets include:

- Browser cache folders
- Old `.log`, `.dmp`, `.mdmp`, and `.etl` files in approved log locations
- Windows Update cache and Delivery Optimization leftovers
- Old installer-looking folders inside temp locations
- Browser cookies and history, only when the user explicitly selects that option

It does not clean:

- Desktop
- Documents
- Downloads
- Pictures
- Music
- Videos
- OneDrive folders
- Program folders
- Browser passwords or saved sign-ins

## Recycle Bin

The Recycle Bin is skipped by default because it may contain files someone still wants to restore.

Use `Run-Clean-With-Recycle-Bin.bat` only when you intentionally want to empty it.

## Report-Only Areas

RazorWear may report large or old Downloads files and duplicate files in Downloads. These areas are never auto-deleted. The user must review and remove those files manually.
