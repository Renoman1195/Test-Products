# Test-Products

This is where all the small test software comes to grow.

## Projects

- `RazorWear` - a lightweight Windows cleanup tool focused on safe temp-file cleanup, no tracking, and no data collection.

## Verification

Run the safe project check from the repo root:

```powershell
.\scripts\check.ps1
```

The check parses the PowerShell scripts, verifies launcher files, runs
RazorWear preview mode only, builds the native `RazorWear.exe` launcher, tests
that launcher in preview mode, and confirms Store asset files exist.

Build the native launcher:

```powershell
.\scripts\build-razorwear.ps1
```

Build a development MSIX package:

```powershell
.\scripts\package-msix.ps1
```

The development MSIX is unsigned. Final Store submission still needs Partner
Center identity values, signing, screenshots, support contact, and a public
privacy policy URL.

Store readiness is tracked in:

`RazorWear\StoreSubmission\SubmissionReadiness.md`
