#Requires -Version 5

<#
.SYNOPSIS
Carga de forma dinámica los archivos ps1 pertenecientes al módulo. 
La instrucción try/catch evita que el módulo se cargue si se presentará algún error al procesar los archivos ps1

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>  
#>

try {
    @('Classes', 'Functions') | ForEach-Object {
        $FullPath = Join-Path -Path $PSScriptRoot -ChildPath $_
        if (Test-Path -Path $FullPath) {
            "Importing files from $FullPath " | Write-Verbose
            $Filter = $PSItem + '\*.ps1'

            Get-ChildItem -LiteralPath $PSScriptRoot -Filter $Filter -File | 
                Select-Object -ExpandProperty FullName | 
                ForEach-Object { 
					$PSItem | Write-Verbose
					. $PSItem
				}
        }		
    }	

    "Importing Resources from $PSScriptRoot\Resources" | Write-Verbose
	$Script:Resx = Import-LocalizedData -BaseDirectory "$PSScriptRoot\Resources" -FileName 'Resources'
	$Script:AppConfig = "$PSScriptRoot\<%=$PLASTER_PARAM_ModuleName%>.config" | Get-ConfigFile

    # Procesar el archivo de inicialización (si existiera).
    Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'Startup.ps1' -File | 
        Select-Object -ExpandProperty FullName | 
        ForEach-Object { 
			$PSItem | Write-Verbose
			. $PSItem 
		} 
}
catch {
    throw
}