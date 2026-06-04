# Launcher Requirements

The current RazorWear desktop GUI is built with PowerShell and Windows Forms. That is useful for rapid development, but the Microsoft Store package should use a normal executable entry point.

## Final Launcher

`RazorWear.exe` is now built from `RazorWear\src\RazorWear.cs` with:

```powershell
.\scripts\build-razorwear.ps1
```

It:

- Opens the same friendly GUI.
- Uses the same safe cleanup rules.
- Does not collect data.
- Does not start a background service.
- Does not require administrator access for regular cleanup.
- Stores logs locally.
- Supports command-line preview mode for safe automated verification.

## Store Entry Point

The MSIX manifest should launch `RazorWear.exe` as the full-trust desktop
application entry point.

## Current Packaging Blockers

- Partner Center package identity values are still placeholders.
- The development MSIX is unsigned.
- Final Store screenshots, support contact, and public privacy policy URL are
  still required before submission.
