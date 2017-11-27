<#===================================================================
1. Ejecute este script desde una línea de comandos de PowerShell estando ubicado en la carpeta contenedora del propio script (Installer).
1.1 En la carpeta Installer\Release se copiaran los archivos que componen el módulo de PowerShell (binarios y de texto).
1.2 Si necesita "emular" el estado final del módulo cárguelo desde esta carpeta. Estos son los archivos que se van a incluir en los instaladores.

# Archivos resultantes:
En la carpeta Installer se creará el archivo nuget que permite publicar el módulo en ProGet.

2 Publique el archivo nupkg resultante en el Feed de PowerShell del servidor ProGet interno en http://10.100.102.22:8020
2.1 También puede utilizar el parámetro $Publish del script para publicar en ProGet de forma automática.

NOTA: Omita los mensajes de advertencia que se generan cuando se crea el archivo nupkg (Paso 6).
===================================================================#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
param
(
    [switch]
    $Publish
)

function Write-Info {
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param
    (        
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Message
    )

	"[INFO] > $Message" | Out-Default	
}

Add-Type -AssemblyName 'System.Xml.Linq'

try {
    $NugetPath = $env:NUGET_PATH
    if (-not $NugetPath) {
        throw 'Set the NUGET_PATH environment variable before continue.'
        return
    }

    ###############################################
    #Paso 1: Crear la carpeta Release (allí se dejaran todos los archivos que componen el m??o).
    ###############################################
    $DestinationPath = Join-Path -Path "$PSScriptRoot" -ChildPath 'Release'
    "Remove directory $DestinationPath" | Write-Info
    Remove-Item -Path $DestinationPath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    "Create directory $DestinationPath" | Write-Info
    New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null


    ###############################################
    #Paso 2: Copiar todos los archivos binarios que componen el módulo (Post-Build del proyecto con la dll los deja en esta carpeta).
    ###############################################
    $BinSource = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath '..\bin\')
    'Copy bin folder' | Write-Info
    Copy-Item -Path $BinSource.Path -Destination $DestinationPath -Recurse -Force

    ###############################################
    #Paso 3: Copiar todos los archivos de PowerShell que componen el módulo (diferentes a binarios). La raíz del módulo.
    ###############################################
    'Copy PowerShell files' | Write-Info
    $RootModulePath = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath '..')
    $Filter = @(
        '*.config',
        '*.psd1',
        '*.psm1',
        '*.ps1xml',
        '*.ps1',
        'ReleaseNotes.*')
	
    $Filter |  ForEach-Object {
        Get-ChildItem -Path $RootModulePath -Filter $PSItem | 
            Where-Object -Property Name -notmatch 'Debug' | 
            Copy-Item -Destination $DestinationPath
    }

    $Folder = @(
        '..\Functions',
        '..\Classes',
        '..\Resources',
        '..\SQLScripts')
	
    $Folder | ForEach-Object {
        $FolderPath = Resolve-Path -Path (Join-Path -Path "$PSScriptRoot" -ChildPath $PSItem)
        Copy-Item -Path $FolderPath -Destination $DestinationPath -Recurse -Force
    }
	
    ###############################################
    #Paso 4: Determinar la versión del módulo.
    ###############################################
    $EpochDate = Get-Date -Year 2000 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
    $Build = ((Get-Date) - $EpochDate).TotalDays.ToString('F0')
    $Revision = ((Get-Date) - (Get-Date).Date).TotalSeconds.ToString('F0')

    $ReleaseManifestFile = (Resolve-Path -Path ("$PSScriptRoot\..\Release\<%=$PLASTER_PARAM_ModuleName%>.psd1")).Path
    $ReleaseManifestData = Import-PowerShellDataFile -Path $ReleaseManifestFile
    $CurrentVersion =  [Version]$ReleaseManifestData.ModuleVersion
    $ReleaseVersion = (New-Object -TypeName 'Version' -ArgumentList $CurrentVersion.Major, $CurrentVersion.Minor, $Build, $Revision).ToString()
    "Module Version: $ReleaseVersion" | Write-Info

    ###############################################
    #Paso 5: Reemplazar el número de versión en el archivo de instalación de Nuget.
    #Paso 5.1: Reemplazar el número de versión en el archivo psd1
    ###############################################
    $NugetFilePath = Resolve-Path -Path "$PSScriptRoot\<%=$PLASTER_PARAM_ModuleName%>.nuspec"
    $UTF8 = [System.Text.Encoding]::UTF8
	$StreamReader = [System.IO.StreamReader]::New($NugetFilePath,$UTF8)
	$NugetContent = [System.Xml.Linq.XElement]::Load($StreamReader)
    $NugetContent.Element("metadata").Element("version").Value = $ReleaseVersion
    $StreamReader.Dispose()
	$NugetContent.Save($NugetFilePath)

    $PSData = @{
        LicenseUri   = $NugetContent.Element("metadata").Element("licenseUrl").Value
        ProjectUri   = $NugetContent.Element("metadata").Element("projectUrl").Value
        IconUri      = $NugetContent.Element("metadata").Element("iconUrl").Value
        ReleaseNotes = $NugetContent.Element("metadata").Element("releaseNotes").Value
        Tags         = $NugetContent.Element("metadata").Element("tags").Value -split ' '
    }
    Update-ModuleManifest -Path $ReleaseManifestFile -ModuleVersion ([Version]$ReleaseVersion) -PrivateData $PSData

    ###############################################
    #Paso 6: Crear/Compilar el instalador de Nuget.
    ###############################################
    $NugetCompiler = Join-Path -Path $NugetPath -ChildPath 'nuget.exe'
	$OutputDirectory = Split-Path $NugetFilePath -Parent
    $CompileNugetCommand = '& "{0}" pack "{1}" -OutputDirectory "{2}"' -f $NugetCompiler, $NugetFilePath, $OutputDirectory
    Invoke-Expression -Command $CompileNugetCommand


    ###############################################
    #Paso 7: Publicar en ProGet.
    ###############################################
	
	# ¿De donde viene este valor? 
	# http://proget/administration/feeds/manage-feed?feedId=5
	$ProGetApiKey = 'bc3401ac-c269-4b77-8b12-f88398600043'


	# ¿De donde viene este valor? 
	# Línea de comandos: nuget source list
	# ¿Cómo se configura este valor? 
	# Línea de comandos: nuget source add -Name "Processa GT" -Source "http://proget/nuget/PowerShell"
	$NugetSourceName = 'Processa GT'

	$PackageFilePath = Join-Path -Path $PSScriptRoot -ChildPath ('<%=$PLASTER_PARAM_ModuleName%>.{0}.nupkg' -f $ReleaseVersion)	
	$PushPackageCommand = '& "{0}" push "{1}" "{2}" -Source "{3}"' -f $NugetCompiler, $PackageFilePath, $ProGetApiKey, $NugetSourceName
	$PushPackageCommand  | Write-Info
	
	
    if ($Publish.IsPresent) {
        Invoke-Expression -Command $PushPackageCommand
    }
}
catch {
    throw
}
