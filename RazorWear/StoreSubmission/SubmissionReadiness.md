# RazorWear Store Submission Readiness

Last updated: 2026-06-04

This file tracks what remains before RazorWear is ready for Microsoft Store
submission.

## Current Build State

- Product name: RazorWear
- Version: 0.5.2
- Store package type: MSIX packaged desktop app
- Store entry point: `RazorWear.exe`
- Native launcher source: `RazorWear\src\RazorWear.cs`
- Native launcher build: `.\scripts\build-razorwear.ps1`
- Development MSIX build: `.\scripts\package-msix.ps1`
- Verification: `.\scripts\check.ps1`

## Ready

- [x] Safe cleanup rules are implemented for approved temp folders only.
- [x] Recycle Bin cleanup is optional and off by default.
- [x] Local logs are written under Local AppData.
- [x] PowerShell fallback scripts parse successfully.
- [x] Native `RazorWear.exe` launcher builds on this machine.
- [x] Native launcher supports preview-mode command-line verification.
- [x] Development MSIX package builds with placeholder identity values.
- [x] Store assets exist.
- [x] Store listing draft exists.
- [x] Privacy policy HTML exists.
- [x] Certification notes exist.
- [x] MSIX manifest template exists.

## Still Needed Before Submission

- [ ] Create or open Microsoft Partner Center developer account.
- [ ] Reserve the app name `RazorWear`.
- [ ] Replace manifest placeholder identity values with Partner Center values.
- [ ] Build final Store MSIX or upload package with final identity values.
- [ ] Sign the package with the correct trusted certificate or Store workflow.
- [ ] Host the privacy policy at a public URL.
- [ ] Add final support contact.
- [ ] Capture Store screenshots from the native launcher.
- [ ] Install the signed package on a clean Windows profile or VM.
- [ ] Confirm preview mode, clean confirmation, log folder, and uninstall.
- [ ] Complete Partner Center age rating, properties, pricing, and listing.

## Validation Commands

Run from the repo root:

```powershell
.\scripts\check.ps1
.\scripts\package-msix.ps1
```

The default MSIX package is for development validation only. It uses placeholder
identity values and is unsigned.

## Official References

- https://learn.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview
- https://learn.microsoft.com/en-us/windows/msix/desktop/desktop-to-uwp-packaging-dot-net
- https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/upload-app-packages
- https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements
- https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/support-info?pivots=store-installer-msix
