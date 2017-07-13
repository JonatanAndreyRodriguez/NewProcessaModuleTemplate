Import-Module -Name PSScriptAnalyzer
$Path = "$PSScriptRoot"
$ReleasePath = "$PSScriptRoot\Installer\Release"
Remove-Item -Path $ReleasePath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Invoke-ScriptAnalyzer -Path $Path -ExcludeRule 'PSUseBOMForUnicodeEncodedFile' -Recurse
