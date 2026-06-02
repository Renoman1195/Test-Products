# Certification Notes

RazorWear is a local Windows cleanup utility.

## Privacy

The app does not collect, transmit, sell, share, or store personal data outside the user's device.

The app does not require an account.

The app does not connect to the internet automatically. Microsoft update checks run only when the user chooses them.

The app does not include ads, analytics, telemetry, or third-party trackers.

## Cleanup Scope

Regular cleanup starts with:

- User temp folder
- Windows temp folder

Optional user-selected cleanup targets include:

- Browser cache
- Old logs and crash dumps
- Windows Update cache and Delivery Optimization leftovers
- Old installer-looking folders inside temp locations
- Browser cookies and history

The app does not delete files from:

- Desktop
- Documents
- Downloads
- Pictures
- Music
- Videos
- OneDrive
- Program Files
- Browser password stores

Recycle Bin cleanup is optional and disabled by default.

Downloads clutter and duplicate files are report-only. RazorWear does not auto-delete files from Downloads.

## User Control

Users can run preview mode before deleting anything.

Clean mode requires a confirmation action.

Skipped or protected files are logged locally.

## Local Logs

Logs are plain text files saved under `%LOCALAPPDATA%\TraceWear\RazorWear\logs`. They are not uploaded.

## Updates

The app can check Windows Update and Microsoft Store app updates only after a user action.

The app does not run a background updater, silently install app updates, or modify its installed package files.
