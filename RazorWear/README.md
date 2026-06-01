# RazorWear

RazorWear is a small Windows cleanup utility for quick laptop and PC maintenance. It is intentionally lightweight: no accounts, no ads, no data collection, and no background service.

It is designed to be safe by default:

- Preview mode shows what would be cleaned before deleting anything.
- Clean mode removes temporary files older than 1 day.
- The Recycle Bin is not cleared unless you choose the separate Recycle Bin option.
- It skips files that are locked or unavailable.
- It writes a local cleanup log to the `logs` folder on your computer.
- The desktop app includes an Info tab explaining the no-tracking, no-data-collection promise.
- The polished desktop UI includes a clear status area, branded header, and simple cleanup controls.

## What It Cleans

- Current user's temp folder
- Windows temp folder

It does not delete personal files from Desktop, Documents, Pictures, Downloads, Music, Videos, or OneDrive.

## How To Use

Double-click:

- `Run-RazorWear.bat` to open the friendly desktop app.
- `Run-Preview.bat` to see what can be cleaned.
- `Run-Clean.bat` to perform the regular safe cleanup.
- `Run-Clean-With-Recycle-Bin.bat` to also clear the Recycle Bin.

You can also run the PowerShell script directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\RazorWear.ps1 -Preview
powershell -ExecutionPolicy Bypass -File .\RazorWear.ps1 -Clean
powershell -ExecutionPolicy Bypass -File .\RazorWear.ps1 -Clean -IncludeRecycleBin
```

## Privacy

RazorWear does not collect, upload, sell, or transmit any information. It does not connect to the internet. Logs are saved only on your computer so you can review what happened.

The Info tab inside the app explains this in plain language for users: no info grabbing, no tracking, safe cleanup, simple and reliable.

## Microsoft Store Prep

Store submission planning files are in `StoreSubmission`. The Microsoft Store version should be packaged as an MSIX desktop app before submission.

## Notes

Some Windows temp files require administrator permissions. RazorWear will skip anything it cannot safely remove.
