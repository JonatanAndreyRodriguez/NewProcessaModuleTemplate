Properties {
    $Publish           = $false
    $NugetPath         = $env:NUGET_PATH
    $InformationAction = 'SilentlyContinue'
    $ModuleName        = '<%=$PLASTER_PARAM_ModuleName%>'
    $ProGetApiKey      = 'bc3401ac-c269-4b77-8b12-f88398600043'
}

Task Default -Depends CreateNugetPackage, PublishNugetPackage

Task PublishNugetPackage -Depends CreateNugetPackage -Precondition {return $Publish} {
    # ¿De dónde viene este valor?
    # http://proget/administration/feeds/manage-feed?feedId=5

    # ¿De dónde viene este valor?
    # Línea de comandos: nuget source list
    # ¿Cómo se configura este valor?
    # Línea de comandos: nuget source add -Name "Processa GT" -Source "http://proget/nuget/PowerShell"
    $NugetSourceName = 'Processa GT'
    $PackageFilePath = Join-Path -Path $PSScriptRoot -ChildPath ('ModuleName.{0}.nupkg' -f $ReleaseVersion)
    $PushPackageCommand = '& "{0}" push "{1}" "{2}" -Source "{3}"' -f $NugetCompiler, $PackageFilePath, $ProGetApiKey, $NugetSourceName
    Write-Information -MessageData "$PushPackageCommand" -InformationAction $InformationAction
    Invoke-Expression -Command $PushPackageCommand
}

Task CreateNugetPackage -Depends UpdateModuleVersion {
    $OutputDirectory = Split-Path $NugetFilePath -Parent
    $CompileNugetCommand = '& "{0}" pack "{1}" -OutputDirectory "{2}"' -f $NugetCompiler, $NugetFilePath, $OutputDirectory
    Invoke-Expression -Command $CompileNugetCommand -OutVariable PackResult | Out-Null
	$PackageFilePath = Join-Path -Path $PSScriptRoot -ChildPath ('{0}.{1}.nupkg' -f $ModuleName, $Script:ReleaseVersion)
    Write-Information -MessageData (-join($PackResult | Select-Object -Unique)) -InformationAction $InformationAction
	Write-Information -MessageData $PackageFilePath -InformationAction $InformationAction
	Assert (Test-Path -Path  $PackageFilePath) 'Error packing nupkg file. Check nuspec file'
}

Task UpdateModuleVersion -Depends GenerateModuleVersion {
    $UTF8 = [System.Text.Encoding]::UTF8
    $StreamReader = [System.IO.StreamReader]::New($NugetFilePath, $UTF8)
    $NugetContent = [System.Xml.Linq.XElement]::Load($StreamReader)
    $NugetContent.Element("metadata").Element("version").Value = $ReleaseVersion
    $StreamReader.Dispose()
    $NugetContent.Save($NugetFilePath)

    $PSData = @{
        LicenseUri   = $NugetContent.Element('metadata').Element('licenseUrl').Value
        ProjectUri   = $NugetContent.Element('metadata').Element('projectUrl').Value
        IconUri      = $NugetContent.Element('metadata').Element('iconUrl').Value
        ReleaseNotes = $NugetContent.Element('metadata').Element('releaseNotes').Value
        Tags         = $NugetContent.Element('metadata').Element('tags').Value -split ' '
    }
    $ReleaseManifestFile = (Resolve-Path -Path ("$DestinationPath\$ModuleName.psd1")).Path
    Update-ModuleManifest -Path $ReleaseManifestFile -ModuleVersion ([Version]$ReleaseVersion) -PrivateData $PSData -AliasesToExport '*'
    Write-Information -MessageData "$ReleaseManifestFile" -InformationAction $InformationAction
}

Task GenerateModuleVersion -Depends CopyScripts {
    $EpochDate = Get-Date -Year 2000 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
    $Build = ((Get-Date) - $EpochDate).TotalDays.ToString('F0')
    $Revision = ((Get-Date) - (Get-Date).Date).TotalSeconds.ToString('F0')

    $ReleaseManifestFile = (Resolve-Path -Path ("$DestinationPath\$ModuleName.psd1")).Path
    $ReleaseManifestData = Import-PowerShellDataFile -Path $ReleaseManifestFile
    $CurrentVersion =  [Version]$ReleaseManifestData.ModuleVersion
    $Script:ReleaseVersion = (New-Object -TypeName 'Version' -ArgumentList $CurrentVersion.Major, $CurrentVersion.Minor, $Build, $Revision).ToString()
    Write-Information -MessageData "Module Version: $ReleaseVersion" -InformationAction $InformationAction
}

Task CopyScripts -Depends CopyLibraries {
    $RootModulePath = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath '..')
    $Filter = @(
        '*.config',
        '*.psd1',
        '*.psm1',
        '*.ps1xml',
        '*.ps1',
        'ReleaseNotes.*')

    $Filter |  ForEach-Object {
        Write-Information -MessageData "$RootModulePath\$PSItem" -InformationAction $InformationAction
        Get-ChildItem -Path $RootModulePath -Filter $PSItem |
            Where-Object -Property Name -notmatch 'Debug' |
            Where-Object -Property Name -notmatch 'Invoke-ScriptAnalyzer' |
            Copy-Item -Destination $DestinationPath
    }

    $Folder = @(
        '..\Functions',
        '..\Classes',
        '..\Resources',
        '..\SQLScripts')

    $Folder | ForEach-Object {
        $FolderPath = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath $PSItem)
        Write-Information -MessageData "$FolderPath\*" -InformationAction $InformationAction
        Copy-Item -Path $FolderPath -Destination $DestinationPath -Recurse -Force
    }
}

Task CopyLibraries -Depends CreateDeployFolder {
    $BinSource = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath '..\bin\')
    Copy-Item -Path $BinSource.Path -Destination $DestinationPath -Recurse -Force
    Write-Information -MessageData "$BinSource*" -InformationAction $InformationAction
}

Task CreateDeployFolder -Depends CheckEnvironment {
    Remove-Item -Path $DestinationPath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Information -MessageData $DestinationPath -InformationAction $InformationAction
}

Task CheckEnvironment {
    Add-Type -AssemblyName 'System.Xml.Linq'
    Assert ($NugetPath) 'Missing NUGET_PATH environment variable'
    $Script:NugetCompiler = Join-Path -Path $NugetPath -ChildPath 'nuget.exe'
    $Script:NugetFilePath = Resolve-Path -Path "$PSScriptRoot\$ModuleName.nuspec"
    $Script:DestinationPath = Join-Path -Path "$PSScriptRoot" -ChildPath 'Release'
    Assert (Test-Path -Path $Script:NugetCompiler) 'Missing nuget.exe file'
    Assert (Test-Path -Path $Script:NugetFilePath) 'Missing nuspec file'
}
