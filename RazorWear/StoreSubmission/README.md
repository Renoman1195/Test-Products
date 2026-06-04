# RazorWear™ Microsoft Store Submission Kit

This folder contains the files and notes needed to prepare RazorWear™ for Microsoft Store submission.

RazorWear™ is currently a lightweight Windows desktop utility built with PowerShell and Windows Forms. To publish it in the Microsoft Store, package it as an MSIX desktop app and submit it through Microsoft Partner Center.

## Store Status

Prepared:

- Store listing draft
- Privacy policy HTML
- Safety/certification notes
- MSIX app manifest template
- Repeatable MSIX build script
- Asset generation script
- Native `RazorWear.exe` launcher source and build script
- Development MSIX packaging script
- Packaging checklist
- Submission status checklist
- Desktop Store screenshot
- Native `RazorWear.exe` launcher
- Submission readiness tracker

Still needed before final submission:

- Microsoft Partner Center developer account
- Reserved app name in Partner Center
- Publisher identity from Partner Center
- Partner Center package identity values confirmed against `Package.appxmanifest.template.xml`
- Public privacy policy URL confirmed in Partner Center
- Elevated Windows App Certification Kit pass on the final signed package
- Final signed MSIX package generated with Partner Center identity values
- Support contact

Track the full go/no-go list in `SubmissionReadiness.md`.

## Recommended Store Name

RazorWear™

## Developer

Jacob Brown

## Publisher Display Name

TraceWear™

## Package Type

MSIX packaged desktop app.

The final package should launch `RazorWear.exe`. The native launcher starts the current PowerShell/Windows Forms GUI from the app folder.

## Trademark

RazorWear™ and TraceWear™ are trademarks of Jacob Brown.

## Build Commands

From the repo root:

```powershell
.\scripts\check.ps1
.\scripts\build-razorwear.ps1
.\scripts\package-msix.ps1
```

The default MSIX package uses development identity values and is unsigned. For
Store submission, replace the package name, publisher, and display name with
the exact values from Partner Center, then sign/package using the approved
Store workflow.

## Important

Do not submit the ZIP file directly to the Microsoft Store. The Store submission needs an MSIX, MSIXBundle, or upload package generated with approved Windows packaging tooling.

## Local Package Build

From the `RazorWear` folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\StoreSubmission\Build-StorePackage.ps1
```

The script writes package output to `StoreSubmission\Packages`, which is intentionally ignored by git.
