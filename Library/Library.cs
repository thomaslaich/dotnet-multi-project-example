namespace ProjectReferencesTest;

using Microsoft.Extensions.Configuration;
using System.Diagnostics;

public static class Library
{
    public static void Hello()
    {
        System.Console.WriteLine("Hello, World!");

        // string logPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), "log.txt");
        //
        // Console.WriteLine($"Writing to: {logPath}");
        //
        // TextWriterTraceListener logFile = new(File.CreateText(logPath));
        //
        // Trace.Listeners.Add(logFile);

        Trace.AutoFlush = true;

        Debug.WriteLine("Debug says, I am watching!");
        Trace.WriteLine("Trace says, I am watching!");

        Console.WriteLine("Reading from appsettings.json in {0}", arg0: Directory.GetCurrentDirectory());

        ConfigurationBuilder builder = new();

        builder.SetBasePath(Directory.GetCurrentDirectory());
        builder.AddJsonFile("appsettings.json",
            optional: true, reloadOnChange: true);

        IConfigurationRoot configuration = builder.Build();

        TraceSwitch ts = new(
          displayName: "Switch",
          description: "This switch is set via a JSON config.");

        configuration.GetSection("Switch").Bind(ts);

        Trace.WriteLineIf(ts.TraceError, "Trace error");
        Trace.WriteLineIf(ts.TraceWarning, "Trace warning");
        Trace.WriteLineIf(ts.TraceInfo, "Trace information");
        Trace.WriteLineIf(ts.TraceVerbose, "Trace verbose");

        Console.ReadLine();
    }
}
