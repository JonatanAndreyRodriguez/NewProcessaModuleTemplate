function Get-ConfigFile {
<#
.SYNOPSIS
Obtiene la ruta de acceso del archivo de configuración.

.DESCRIPTION
Si existiera un archivo Debug se devuelve la ruta de ese archivo. De lo contrario se utliza la ruta predeterminada.

.PARAMETER Path
Ruta de acceso predeterminada del archivo.

.EXAMPLE
'C:\MyConfig.config' | Get-ConfigFile

.OUTPUTS
Ruta de acceso en -Path o un archivo con el nombre .Debug si existiera.
'C:\MyConfig.config' | Get-ConfigFile
'C:\MyConfig.Debug.config' si existiera, de lo contrario 'C:\MyConfig.config'

.NOTES
Autor: Atorrest
#>
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        $Path
    )

    try {

        $Extension = [System.IO.Path]::GetExtension($Path)
        $DebugFile = [System.IO.Path]::ChangeExtension($Path, '.Debug{0}' -f $Extension)

        if (Test-Path -Path $DebugFile -PathType Leaf) {
            $DebugFile | Write-Output
            return
        }

        $Path | Write-Output
    }
    catch {
        throw
    }
}

