# .Net Core SonarQube Scanner with OpenCover on Docker Container

## Introduction

SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method ([More Info](https://docs.sonarqube.org/display/SONAR/Documentation)).

```SonarQube.Scanner.MSBuild.exe``` is required to analyze the .Net Core projects. Apart from that, if the test coverage result is required, then ```OpenCover.Console.exe``` must be engaged in the scanning process.

Unfortunately, OpenCover is not available on Linux yet. So, a Windows docker image has been chosen as the base image to run the scan.

## Usage Instruction

Based on the design, the project structure must follow the below patter.

```bash

.
├── build
│   └── analyze.ps1
└── src

```

Within the **analyze.ps1** file you need to use ```SonarQube.Scanner.MSBuild.exe```, ```dotnet``` and ```OpenCover.Console.exe``` to scan your project.

For example.

```powershell

Set-Location "Project/Src"

SonarQube.Scanner.MSBuild.exe begin /n:"ConsoleApp1" /k:"ConsoleApp1" /v:$env:PROJECT_VERSION /d:sonar.cs.opencover.reportsPaths="$(Get-Location)\opencover.xml" /d:sonar.host.url=SONAR_HOST_URL /d:sonar.login=SONAR_LOGIN_KEY

dotnet build "ConsoleApp1.sln" /p:DebugType=Full -p:AssemblyVersion=$env:PROJECT_VERSION

OpenCover.Console.exe -target:"dotnet.exe" -targetargs:"test --no-build --configuration Debug `"ConsoleApp1.Tests/ConsoleApp1.Tests.csproj`" --logger `"trx;LogFileName=Results.xml`"" -filter:"+[ConsoleApp1]* -[*.Tests*]*" -oldStyle -register:user -output:"opencover.xml"

SonarQube.Scanner.MSBuild.exe end  /d:sonar.login=SONAR_LOGIN_KEY

```

Here is the list of environment parameter used in above script.

|Parameter|Description|
|---|---|
|```PROJECT_VERSION```|The project version both for analyze and build.|
|```SONAR_HOST_URL```|The SonarQube server URL.|
|```SONAR_LOGIN_KEY```|The login token issued by SonarQube server.|

Note: To get more information about how to generate a token [Read This](https://docs.sonarqube.org/display/SONAR/User+Token).

## Usage Example

To run the docker container, use the below command.

```bash

docker run --name ds --rm -it -v "$(Get-Location):C:\Project" -e PROJECT_VERSION=1.0 -e SONAR_HOST_URL=http://localhost:9000 -e SONAR_LOGIN_KEY=56c7b02d541883cce692491a4b07c572e946f12e phorozan/sonarqube-scanner-dotnetcore-opencover

```