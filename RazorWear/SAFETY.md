# Safety Notes

RazorWear is built to avoid important files.

## Regular Cleanup

Regular cleanup targets only:

- Your Windows user temp folder
- The Windows temp folder

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
