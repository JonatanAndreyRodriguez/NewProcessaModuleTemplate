function Get-ConfigFile {
<#
.SYNOPSIS
Obtiene la ruta de acceso del archivo de configuraci�n.

.DESCRIPTION
Si el archivo de configuraci�n especificado no existe, se crea.

.PARAMETER Path
Ruta de acceso predeterminada del archivo.

.EXAMPLE
'C:\MyConfig.config' | Get-ConfigFile

.OUTPUTS
Ruta de acceso del archivo de confoguraci�n.

.NOTES
Autor: Atorrest
#>
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Path
    )

    $ConfigPath = Get-ConfigPath -Path $Path

    if (-not (Test-Path -Path $ConfigPath -PathType 'Leaf')) {
@"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <connectionStrings>
  </connectionStrings>
  <appSettings>
  </appSettings>
</configuration>
"@ | Set-Content -Path $ConfigPath -Encoding 'UTF8' -ErrorAction Stop
    }

    $ConfigPath | Write-Output

}
