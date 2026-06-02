# RazorWear Store Submission Status

Last checked: 2026-06-02

## Summary

RazorWear™ has the core local submission materials prepared, including listing copy, privacy/certification notes, app logos, a desktop screenshot, a native executable launcher, and a repeatable MSIX build script. The remaining blockers are mostly Microsoft Partner Center actions, final Partner Center identity matching, and an elevated final WACK run.

Store-facing identity:

- App name: RazorWear™
- Developer: Jacob Brown
- Publisher display name: TraceWear™
- Trademark notice: RazorWear™ and TraceWear™ are trademarks of Jacob Brown.

## Required Checklist

| # | Requirement | Status | Evidence / Next Step |
|---|---|---|---|
| 1 | Unique app name reserved in Partner Center | Ready to confirm | Reserve or confirm `RazorWear` in Microsoft Partner Center. Use `RazorWear™` only for customer-facing listing/display text if Partner Center accepts the trademark symbol. |
| 2 | Valid app package: MSIX, APPX, EXE, or MSI | Locally built | `StoreSubmission/Build-StorePackage.ps1` creates `StoreSubmission/Packages/RazorWear-0.5.2.0.msix`. Local test signing with `CN=Jacob Brown` verifies successfully. Final upload must use Partner Center identity/signing. |
| 3 | App icons and logos in required sizes | Mostly done | Assets exist in `StoreSubmission/Assets`: 44x44, 50x50, 150x150, 300x300, and 310x150. Package validation accepts the assets during `makeappx`. |
| 4 | Screenshots of the app running | Done | `StoreSubmission/Screenshots/RazorWear-Desktop-Home.png` is 1366x768 PNG. |
| 5 | Written description of what the app does | Done | `StoreSubmission/StoreListing.md` contains the short description, full description, features, search terms, support URL, privacy URL, and privacy text. |
| 6 | Age rating questionnaire completed | Not done | Complete the IARC age rating questionnaire in Partner Center. Expected answers should match a utility app with no mature content. |
| 7 | Category selected | Ready to enter | Recommended category: `Utilities & tools`. Alternative: `Productivity` if Partner Center wording fits better. |
| 8 | Developer account in Microsoft Partner Center | Not done | Create or sign in to a Partner Center developer account. This is an external account step. |
| 9 | Compliance with Microsoft Store policies | Mostly done | `CertificationNotes.md`, `PRIVACY.md`, and `SAFETY.md` document privacy, user control, cleanup scope, local logs, and user-triggered update checks. Final WACK rerun requires an elevated shell. |
| 10 | Working app launches without crashing during certification | Locally verified | Rebuilt `RazorWear.exe` launches the current GUI. Final verification should run from the packaged app after Partner Center identity/signing is confirmed. |

## Microsoft Docs Checked

- App name reservation: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/reserve-your-apps-name
- Package upload for MSIX apps: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/upload-app-packages
- Screenshots and Store images: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/screenshots-and-images
- Age ratings: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/age-ratings
- Categories: https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/categories-and-subcategories
- Store policies and certification: https://learn.microsoft.com/en-us/windows/apps/publish/store-policies-and-code-of-conduct

## Next Actions

1. Confirm `RazorWear` is reserved in Partner Center.
2. Confirm `Package.appxmanifest.template.xml` identity values exactly match Partner Center.
3. Confirm the manifest `Publisher` and package `Name` exactly match Partner Center.
4. Build/sign the final MSIX package using `StoreSubmission/Build-StorePackage.ps1`.
5. Run Windows App Certification Kit from an elevated shell on the final signed package.
6. Upload the package, screenshot, listing text, privacy URL, category, and age rating answers in Partner Center.
