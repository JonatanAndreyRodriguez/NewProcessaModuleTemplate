function Get-ScriptDirectory {
<#
.SYNOPSIS
Obtiene la ruta de acceso del archivo script que se está ejecutando.

.EXAMPLE
Get-ScriptDirectory

.PARAMETER Parent
Cuando se establece retorna la ruta de acceso del directorio padre.	

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%> 
#>
	
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [switch]
        $Parent
    )
	
    try {
        $CurrentPath = Split-Path -Parent -Path $PSCommandPath
	
        if ($Parent.IsPresent) {
            $CurrentPath = Split-Path -Parent -Path $CurrentPath
        }

        $CurrentPath | Write-Output
    }
    catch {
        throw
    }
}
