# RazorWear Microsoft Store Submission Kit

This folder contains the files and notes needed to prepare RazorWear for Microsoft Store submission.

RazorWear is currently a lightweight Windows desktop utility built with PowerShell and Windows Forms. To publish it in the Microsoft Store, package it as an MSIX desktop app and submit it through Microsoft Partner Center.

## Store Status

Prepared:

- Store listing draft
- Privacy policy HTML
- Safety/certification notes
- MSIX app manifest template
- Asset generation script
- Packaging checklist
- Submission status checklist
- Desktop Store screenshot
- Native `RazorWear.exe` launcher

Still needed before final submission:

- Microsoft Partner Center developer account
- Reserved app name in Partner Center
- Publisher identity from Partner Center
- Final MSIX package generated with MSIX Packaging Tool or Visual Studio
- Public privacy policy URL
- Windows App Certification Kit pass on the final package

## Recommended Store Name

RazorWear

## Package Type

MSIX packaged desktop app.

The final package should launch `RazorWear.exe`. The native launcher starts the current PowerShell/Windows Forms GUI from the app folder.

## Important

Do not submit the ZIP file directly to the Microsoft Store. The Store submission needs an MSIX, MSIXBundle, or upload package generated with approved Windows packaging tooling.
