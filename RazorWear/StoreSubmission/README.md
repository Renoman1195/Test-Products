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

Still needed before final submission:

- Microsoft Partner Center developer account
- Reserved app name in Partner Center
- Publisher identity from Partner Center
- Small `RazorWear.exe` launcher or native app build
- Final MSIX package generated with MSIX Packaging Tool or Visual Studio
- Public privacy policy URL
- Store screenshots

## Recommended Store Name

RazorWear

## Package Type

MSIX packaged desktop app.

The final package should launch `RazorWear.exe`. The current development version launches `RazorWear-GUI.ps1` through `Run-RazorWear.bat`, which is fine for testing but not the best final Store entry point.

## Important

Do not submit the ZIP file directly to the Microsoft Store. The Store submission needs an MSIX, MSIXBundle, or upload package generated with approved Windows packaging tooling.
