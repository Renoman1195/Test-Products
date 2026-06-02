# Microsoft Store Packaging Checklist

## Partner Center

- Create or sign in to a Microsoft Partner Center developer account.
- Reserve or confirm the app name: `RazorWear`.
- Complete the IARC age rating questionnaire.
- Select category: `Utilities & tools`.
- Confirm package identity values in `Package.appxmanifest.template.xml`.
- Confirm developer name: `Jacob Brown`.
- Confirm publisher display name: `TraceWear™`.

## Packaging

- Install Visual Studio with Windows app packaging tools, or install MSIX Packaging Tool.
- Build or verify the final `RazorWear.exe` launcher.
- Package RazorWear as a desktop MSIX app with `StoreSubmission/Build-StorePackage.ps1`.
- Sign the package with a certificate whose subject matches the manifest publisher.
- Use the generated assets from `Assets`.
- Include the Store screenshot from `Screenshots`.
- Verify the app launches from the package.
- Verify preview mode runs.
- Verify clean mode asks for confirmation.
- Verify regular cleanup skips Recycle Bin.
- Run Windows App Certification Kit on the final signed package from an elevated shell.

## Local Commands

Build unsigned package:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\StoreSubmission\Build-StorePackage.ps1
```

Build and sign with a local test certificate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\StoreSubmission\Build-StorePackage.ps1 -Sign -CertificateThumbprint YOUR_CERT_THUMBPRINT
```

Run WACK from an elevated shell:

```powershell
& "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe" test -appxpackagepath ".\StoreSubmission\Packages\RazorWear-0.5.2.0.msix" -reportoutputpath ".\StoreSubmission\Packages\WACK\RazorWear-WACK.xml"
```

## Privacy

- Host `PrivacyPolicy.html` publicly.
- Add the public privacy policy URL in Partner Center.
- Keep the Store listing privacy text aligned with the app behavior.

## Store Listing

- Add app description from `StoreListing.md`.
- Add screenshots of the GUI.
- Add support contact.
- Add trademark notice: `RazorWear™ and TraceWear™ are trademarks of Jacob Brown.`
- Select Windows Desktop package target.

## Final Verification

- No telemetry.
- No account requirement.
- No background service.
- No personal folder cleanup.
- Local logs only under `%LOCALAPPDATA%\TraceWear\RazorWear\logs`.
- Update checks are user-triggered only.
