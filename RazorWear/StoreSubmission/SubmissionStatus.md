# RazorWear Store Submission Status

Last checked: 2026-06-01

## Summary

RazorWear™ has the core local submission materials started, including listing copy, privacy/certification notes, app logos, a desktop screenshot, and a native executable launcher. The remaining blockers are mostly Microsoft Partner Center actions and the final Store package identity/signing flow.

Store-facing identity:

- App name: RazorWear™
- Developer: Jacob Brown
- Publisher display name: TraceWear™
- Trademark notice: RazorWear™ and TraceWear™ are trademarks of Jacob Brown.

## Required Checklist

| # | Requirement | Status | Evidence / Next Step |
|---|---|---|---|
| 1 | Unique app name reserved in Partner Center | Ready to confirm | Reserve or confirm `RazorWear` in Microsoft Partner Center. Use `RazorWear™` only for customer-facing listing/display text if Partner Center accepts the trademark symbol. |
| 2 | Valid app package: MSIX, APPX, EXE, or MSI | Partially done | `RazorWear.exe` now exists as a native launcher. Manifest template now has `Name="RazorWear"`, `Publisher="CN=Jacob Brown"`, and `PublisherDisplayName>TraceWear™</PublisherDisplayName>`. Final package still needs Partner Center validation/signing. |
| 3 | App icons and logos in required sizes | Mostly done | Assets exist in `StoreSubmission/Assets`: 44x44, 50x50, 150x150, 300x300, and 310x150. Run WACK/package validation after final packaging. |
| 4 | Screenshots of the app running | Done | `StoreSubmission/Screenshots/RazorWear-Desktop-Home.png` is 1366x768 PNG. |
| 5 | Written description of what the app does | Done | `StoreSubmission/StoreListing.md` contains the short description, full description, features, search terms, and privacy text. |
| 6 | Age rating questionnaire completed | Not done | Complete the IARC age rating questionnaire in Partner Center. Expected answers should match a utility app with no mature content. |
| 7 | Category selected | Ready to enter | Recommended category: `Utilities & tools`. Alternative: `Productivity` if Partner Center wording fits better. |
| 8 | Developer account in Microsoft Partner Center | Not done | Create or sign in to a Partner Center developer account. This is an external account step. |
| 9 | Compliance with Microsoft Store policies | Partially done | `CertificationNotes.md`, `PRIVACY.md`, and `SAFETY.md` document privacy, user control, and cleanup scope. Final compliance requires WACK/certification testing. |
| 10 | Working app launches without crashing during certification | Locally verified | `RazorWear.exe` launches the current GUI. Final verification should run from the packaged app, not only the repo folder. |

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
3. Build the final MSIX package using `RazorWear.exe` as the entry point.
4. Run Windows App Certification Kit on the final package.
5. Upload the package, screenshot, listing text, privacy URL, category, and age rating answers in Partner Center.
