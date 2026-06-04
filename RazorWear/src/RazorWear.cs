using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace RazorWear
{
    internal static class Program
    {
        [STAThread]
        private static int Main(string[] args)
        {
            string appRoot = ResolveAppRoot();
            string scriptName = args.Length == 0 ? "RazorWear-GUI.ps1" : "RazorWear.ps1";
            string scriptPath = Path.Combine(appRoot, scriptName);

            if (!File.Exists(scriptPath))
            {
                Console.Error.WriteLine("RazorWear could not find " + scriptName + " in " + appRoot + ".");
                return 2;
            }

            return RunPowerShell(scriptPath, ConvertArguments(args), args.Length > 0);
        }

        private static string ResolveAppRoot()
        {
            string exeDir = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

            if (File.Exists(Path.Combine(exeDir, "RazorWear.ps1")) ||
                File.Exists(Path.Combine(exeDir, "RazorWear-GUI.ps1")))
            {
                return exeDir;
            }

            string parent = Directory.GetParent(exeDir) != null ? Directory.GetParent(exeDir).FullName : exeDir;
            if (File.Exists(Path.Combine(parent, "RazorWear.ps1")) ||
                File.Exists(Path.Combine(parent, "RazorWear-GUI.ps1")))
            {
                return parent;
            }

            return exeDir;
        }

        private static int RunPowerShell(string scriptPath, IEnumerable<string> scriptArgs, bool captureOutput)
        {
            string powerShell = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.System),
                "WindowsPowerShell",
                "v1.0",
                "powershell.exe");

            if (!File.Exists(powerShell))
            {
                powerShell = "powershell.exe";
            }

            StringBuilder arguments = new StringBuilder();
            arguments.Append("-NoProfile -ExecutionPolicy Bypass -File ");
            arguments.Append(Quote(scriptPath));

            foreach (string arg in scriptArgs)
            {
                arguments.Append(" ");
                arguments.Append(Quote(arg));
            }

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = powerShell;
            startInfo.Arguments = arguments.ToString();
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = captureOutput;
            startInfo.RedirectStandardOutput = captureOutput;
            startInfo.RedirectStandardError = captureOutput;

            using (Process process = Process.Start(startInfo))
            {
                if (process == null)
                {
                    Console.Error.WriteLine("RazorWear could not start PowerShell.");
                    return 2;
                }

                if (captureOutput)
                {
                    process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs eventArgs)
                    {
                        if (eventArgs.Data != null)
                        {
                            Console.Out.WriteLine(eventArgs.Data);
                        }
                    };
                    process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs eventArgs)
                    {
                        if (eventArgs.Data != null)
                        {
                            Console.Error.WriteLine(eventArgs.Data);
                        }
                    };

                    process.BeginOutputReadLine();
                    process.BeginErrorReadLine();
                }

                process.WaitForExit();
                return process.ExitCode;
            }
        }

        private static IEnumerable<string> ConvertArguments(string[] args)
        {
            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];
                string lowered = arg.ToLowerInvariant();

                if (lowered == "--preview")
                {
                    yield return "-Preview";
                    continue;
                }
                if (lowered == "--clean")
                {
                    yield return "-Clean";
                    continue;
                }
                if (lowered == "--include-recycle-bin")
                {
                    yield return "-IncludeRecycleBin";
                    continue;
                }
                if (lowered == "--older-than-days")
                {
                    yield return "-OlderThanDays";
                    continue;
                }
                if (lowered.StartsWith("--", StringComparison.Ordinal))
                {
                    yield return "-" + ToPascalCase(lowered.Substring(2));
                    continue;
                }

                yield return arg;
            }
        }

        private static string ToPascalCase(string value)
        {
            string[] parts = value.Split(new[] { '-' }, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder result = new StringBuilder();
            foreach (string part in parts)
            {
                if (part.Length == 0)
                {
                    continue;
                }

                result.Append(Char.ToUpperInvariant(part[0]));
                if (part.Length > 1)
                {
                    result.Append(part.Substring(1));
                }
            }

            return result.ToString();
        }

        private static string Quote(string value)
        {
            return "\"" + value.Replace("\"", "\\\"") + "\"";
        }
    }
}
