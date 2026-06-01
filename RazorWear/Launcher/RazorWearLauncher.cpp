#include <windows.h>

#include <string>

static std::wstring Quote(const std::wstring& value) {
    return L"\"" + value + L"\"";
}

int WINAPI wWinMain(HINSTANCE, HINSTANCE, PWSTR, int) {
    wchar_t modulePath[MAX_PATH];
    DWORD length = GetModuleFileNameW(nullptr, modulePath, MAX_PATH);
    if (length == 0 || length == MAX_PATH) {
        MessageBoxW(nullptr, L"RazorWear could not find its install folder.", L"RazorWear", MB_ICONERROR);
        return 1;
    }

    std::wstring exePath(modulePath);
    std::wstring::size_type lastSlash = exePath.find_last_of(L"\\/");
    std::wstring appDir = (lastSlash == std::wstring::npos) ? L"." : exePath.substr(0, lastSlash);
    std::wstring scriptPath = appDir + L"\\RazorWear-GUI.ps1";

    DWORD attributes = GetFileAttributesW(scriptPath.c_str());
    if (attributes == INVALID_FILE_ATTRIBUTES || (attributes & FILE_ATTRIBUTE_DIRECTORY)) {
        MessageBoxW(nullptr, L"RazorWear-GUI.ps1 was not found next to RazorWear.exe.", L"RazorWear", MB_ICONERROR);
        return 1;
    }

    std::wstring command =
        L"powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File " + Quote(scriptPath);

    STARTUPINFOW startupInfo = {};
    startupInfo.cb = sizeof(startupInfo);
    startupInfo.dwFlags = STARTF_USESHOWWINDOW;
    startupInfo.wShowWindow = SW_SHOWNORMAL;

    PROCESS_INFORMATION processInfo = {};
    std::wstring mutableCommand = command;
    BOOL started = CreateProcessW(
        nullptr,
        &mutableCommand[0],
        nullptr,
        nullptr,
        FALSE,
        CREATE_NEW_CONSOLE,
        nullptr,
        appDir.c_str(),
        &startupInfo,
        &processInfo);

    if (!started) {
        MessageBoxW(nullptr, L"RazorWear could not launch PowerShell.", L"RazorWear", MB_ICONERROR);
        return 1;
    }

    WaitForSingleObject(processInfo.hProcess, INFINITE);

    DWORD exitCode = 0;
    GetExitCodeProcess(processInfo.hProcess, &exitCode);
    CloseHandle(processInfo.hProcess);
    CloseHandle(processInfo.hThread);

    return static_cast<int>(exitCode);
}
