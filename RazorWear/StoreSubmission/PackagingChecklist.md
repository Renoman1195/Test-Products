# Microsoft Store Packaging Checklist

## Partner Center

- Create or sign in to a Microsoft Partner Center developer account.
- Reserve the app name: `RazorWear`.
- Copy the package identity values from Partner Center.
- Replace placeholders in `Package.appxmanifest.template.xml`.

## Packaging

- Install Visual Studio with Windows app packaging tools, or install MSIX Packaging Tool.
- Build a final `RazorWear.exe` launcher.
- Package RazorWear as a desktop MSIX app.
- Use the generated assets from `Assets`.
- Verify the app launches from the package.
- Verify preview mode runs.
- Verify clean mode asks for confirmation.
- Verify regular cleanup skips Recycle Bin.

## Privacy

- Host `PrivacyPolicy.html` publicly.
- Add the public privacy policy URL in Partner Center.
- Keep the Store listing privacy text aligned with the app behavior.

## Store Listing

- Add app description from `StoreListing.md`.
- Add screenshots of the GUI.
- Add support contact.
- Select Windows Desktop package target.

## Final Verification

- No telemetry.
- No account requirement.
- No background service.
- No personal folder cleanup.
- Local logs only.
