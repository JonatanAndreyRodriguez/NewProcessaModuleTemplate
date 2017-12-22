function Invoke-Build {
<#
.SYNOPSIS
Genera los archivos Markdown de documentación del módulo.

.EXAMPLE
Invoke-Build

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>
#>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param()

	Import-Module -Name 'PlatyPS'
	Import-Module -Name '..\<%=$PLASTER_PARAM_ModuleName%>' -Force
	$OutputFolder = Resolve-Path -Path $PSScriptRoot
	New-MarkdownHelp -Module '<%=$PLASTER_PARAM_ModuleName%>' -OutputFolder $OutputFolder -Force
}

Invoke-Build
