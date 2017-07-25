<#===================================================================
1. Ejecute este script desde una línea de comandos de PowerShell estando ubicado en la carpeta contenedora del propio script (Installer).
1.1 En la carpeta Installer\Release se copiaran los archivos que componen el módulo de PowerShell (binarios y de texto).
1.2 Si necesita "emular" el estado final del módulo cárguelo desde esta carpeta. Estos son los archivos que se van a incluir en los instaladores.

# Archivos resultantes:
En la carpeta Installer se creará el archivo nuget que permite publicar el módulo en ProGet.

2 Publique el archivo nupkg resultante en el Feed de PowerShell del servidor ProGet interno en http://10.100.102.22:8020
2.1 También puede utilizar el parámetro $Publish del script para publicar en ProGet de forma automática.

NOTA: Omita los mensajes de advertencia que se generan cuando se crea el archivo nupkg (Paso 9).
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
	
    '[INFO] ' | Out-Default
    $Message | Out-Default
}

Import-Module PSProcessa -Force

try {

    ###############################################
    #NOTA: Coloque aquí el número de versión del módulo.
    #Formato:  Major, Minor, Build, Revision
    ###############################################
    $VersionFormat = '1.0.{0}.{1}'

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
	$Revision = ((Get-Date) - $EpochDate).TotalSeconds.ToString('F0')    
    $Version = $VersionFormat -f $Build, $Revision
	"Version: $Version" | Write-Info

    ###############################################
    #Paso 5: Reemplazar el número de versión en el archivo de instalación de Nuget.
    #Paso 5.1: Reemplazar el número de versión en el archivo psd1
    ###############################################
    $NugetFilePath = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '<%=$PLASTER_PARAM_ModuleName%>.nuspec') 
    $NewVersion = "<version>$Version</version>"
    $Pattern = '<version>\d{1,}\.\d{1,}\.\d{1,}[.0-9]{0,}</version>'
    (Get-Content -Path $NugetFilePath -Raw) -replace $Pattern, $NewVersion | Out-File -FilePath $NugetFilePath -Encoding UTF8

    $PSManifestFile = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Release\<%=$PLASTER_PARAM_ModuleName%>.psd1') 
    $ManifestContent = Get-Content -Raw -Path $PSManifestFile
    $RegexOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
	$ModuleVersionRegex = [Regex]::new("^(\t+|\s+)ModuleVersion.*={1}.*[0-9]+.*$", $RegexOptions)
    $ReplaceText = "ModuleVersion = '{0}'" -f $Version
    $ModuleVersionRegex.Replace($ManifestContent, $ReplaceText).Trim() | Out-File -FilePath $PSManifestFile -Encoding Default

    ###############################################
    #Paso 6: Crear/Compilar el instalador de Nuget.
    ###############################################
    $NugetCompiler = Join-Path -Path $NugetPath -ChildPath 'nuget.exe'
	$OutputDirectory = Split-Path $NugetFilePath -Parent
    $CompileNugetCommand = '& "{0}" pack "{1}" -OutputDirectory "{2}"' -f $NugetCompiler, $NugetFilePath, $OutputDirectory
    Invoke-Expression -Command $CompileNugetCommand

    ###############################################
    #Paso 7: Eliminar el indicador de configuración establecida y escribir los valores predeterminados de configuración.
    ###############################################
    $AppConfigFile = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Release\<%=$PLASTER_PARAM_ModuleName%>.config') 
    Remove-AppSetting -p $AppConfigFile -Key 'configured'
    Set-AppSetting -Path $AppConfigFile -Key 'MyKey' -Value 'MyValue'
    Set-ConnectionString -Path $AppConfigFile -Name 'Sql:Local' -ConnectionString 'Data Source=(local);Initial Catalog=master;Integrated Security=True' -Force

    ###############################################
    #Paso 8: Publicar en ProGet.
    ###############################################
	
	# ¿De donde viene este valor? 
	# http://10.100.102.22:8020/administration/feeds/manage-feed?feedId=5
	$ProGetApiKey = 'bc3401ac-c269-4b77-8b12-f88398600043'


	# ¿De donde viene este valor? 
	# Línea de comandos: nuget source list
	# ¿Cómo se configura este valor? 
	# Línea de comandos: nuget source add -Name "Processa GT" -Source "http://10.100.102.22:8020/nuget/PowerShell"
	$NugetSourceName = 'Processa GT'

	$PackageFilePath = Join-Path -Path $PSScriptRoot -ChildPath ('<%=$PLASTER_PARAM_ModuleName%>.{0}.nupkg' -f $Version)	
	$PushPackageCommand = '& "{0}" push "{1}" "{2}" -Source "{3}"' -f $NugetCompiler, $PackageFilePath, $ProGetApiKey, $NugetSourceName
	$PushPackageCommand  | Write-Info
	
	
    if ($Publish.IsPresent) {
        Invoke-Expression -Command $PushPackageCommand
    }
}
catch {
    throw
}
