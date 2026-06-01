# Launcher Requirements

The current RazorWear desktop GUI is built with PowerShell and Windows Forms. That is useful for rapid development, but the Microsoft Store package should use a normal executable entry point.

## Recommended Final Launcher

Create `RazorWear.exe` that:

- Opens the same friendly GUI.
- Uses the same safe cleanup rules.
- Does not collect data.
- Does not start a background service.
- Does not require administrator access for regular cleanup.
- Stores logs locally.

## Good Implementation Options

- .NET WPF app
- .NET WinForms app
- WinUI 3 desktop app

## Current Blocker On This Machine

This machine has .NET runtimes installed, but no .NET SDK. A final native executable build needs the .NET SDK or Visual Studio.
