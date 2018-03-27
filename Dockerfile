From microsoft/windowsservercore

# Setting Container Settings
RUN powershell Set-TimeZone """AUS Eastern Standard Time"""; Set-Culture en-AU; Set-WinSystemLocale en-AU;
Run powershell Set-ExecutionPolicy Bypass -Scope Process -Force; IEx ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet SDK
Run powershell Invoke-WebRequest -Uri 'https://dot.net/v1/dotnet-install.ps1' -OutFile 'C:\dotnet-install.ps1' -Verbose
Run powershell ./dotnet-install.ps1 -Channel 2.0 -InstallDir C:\cli

# Install NuGet CommandLine
Run powershell Choco Install Nuget.CommandLine -Y
Run powershell Choco Install NodeJs -Y

# Install Tools
Run powershell Nuget Install OpenCover -Version 4.6.519 -OutputDirectory Tools
Run powershell NuGet Install MSBuild.SonarQube.Runner.Tool -Version 4.0.2.1 -OutputDirectory Tools

Run powershell [Environment]::SetEnvironmentVariable('PATH', 'C:\Tools\OpenCover.4.6.519\tools\;C:\Tools\MSBuild.SonarQube.Runner.Tool.4.0.2.1\tools\;C:\cli;' + $env:PATH, [EnvironmentVariableTarget]::Machine);

# Installing JavaRuntimer (Required for SonarQube Scanner)
RUN powershell (New-Object System.Net.WebClient).DownloadFile('https://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185', 'C:\jre-8u91-windows-x64.exe')
RUN powershell Start-Process -FilePath C:\jre-8u91-windows-x64.exe -Passthru -Wait -Argumentlist "/s,INSTALLDIR=c:\Java\jre1.8.0_91,/L,install64.log"
RUN del C:\jre-8u91-windows-x64.exe

ENV JAVA_HOME c:\\Java\\jre1.8.0_91

EntryPoint [ "powershell", "C:\\Project\\build\\analyze.ps1" ]