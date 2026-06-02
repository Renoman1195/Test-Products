# RazorWear

RazorWear is a small Windows cleanup utility for quick laptop and PC maintenance. It is intentionally lightweight: no accounts, no ads, no data collection, and no background service.

It is designed to be safe by default:

- Preview mode shows what would be cleaned before deleting anything.
- Clean mode removes selected safe cleanup categories older than 1 day by default.
- The Recycle Bin is not cleared unless you choose the separate Recycle Bin option.
- Downloads clutter and duplicate files are reported only and are never auto-deleted.
- Browser cookies and history require an explicit user choice.
- It skips files that are locked or unavailable.
- It writes a local cleanup log to the `logs` folder on your computer.
- The desktop app includes an Info tab explaining the no-tracking, no-data-collection promise.
- The polished desktop UI includes a clear status area, branded header, and simple cleanup controls.

## What It Cleans

- Current user's temp folder
- Windows temp folder
- Browser cache folders when selected
- Old logs, crash dumps, and setup logs when selected
- Windows Update cache and Delivery Optimization leftovers when selected
- Old installer-looking folders inside temp locations when selected
- Browser cookies and history only when explicitly selected
- Recycle Bin only when explicitly selected

## What It Reports Only

- Large or old files in Downloads
- Duplicate files in Downloads

It does not auto-delete personal files from Desktop, Documents, Pictures, Downloads, Music, Videos, or OneDrive.

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
powershell -ExecutionPolicy Bypass -File .\RazorWear.ps1 -Preview -IncludeBrowserCache -IncludeOldLogs -AnalyzeDownloads
```

## Privacy

RazorWear does not collect, upload, sell, or transmit any information. It does not connect to the internet. Logs are saved only on your computer so you can review what happened.

The Info tab inside the app explains this in plain language for users: no info grabbing, no tracking, safe cleanup, simple and reliable.

## Microsoft Store Prep

Store submission planning files are in `StoreSubmission`. The Microsoft Store version should be packaged as an MSIX desktop app before submission.

## Notes

Some Windows temp files require administrator permissions. RazorWear will skip anything it cannot safely remove.
