Import-Module -Name PSScriptAnalyzer
Import-Module -Name PSCodeHealth

$Path = "$PSScriptRoot"
$ReleasePath = "$PSScriptRoot\Installer\Release"
Remove-Item -Path $ReleasePath -Force -Recurse -ErrorAction 'SilentlyContinue' | Out-Null
Invoke-ScriptAnalyzer -Path $Path -ExcludeRule 'PSUseBOMForUnicodeEncodedFile' -Recurse
$HtmlReportPath = Join-Path -Path $Path -ChildPath 'PSCodeHealth\PSCodeHealth-Report.html'
New-Item -Path (Split-Path -Path $HtmlReportPath -Parent) -ItemType 'Directory' -ErrorAction 'Ignore' | Out-Null
Invoke-PSCodeHealth -Path $Path -TestsPath '.\Pester' -HtmlReportPath $HtmlReportPath -Recurse -Exclude '*Installer*','*FunctionsToExport*','*Startup*','Invoke-Build*','Build.ps1'

if (Test-Path -Path $HtmlReportPath){
    Invoke-Item -Path $HtmlReportPath
}
