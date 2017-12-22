function Get-SqlScriptContent {
<#
.SYNOPSIS
Obtiene el contenido de un archivo en la carpeta de SQLScripts.
.DESCRIPTION
Obtiene el contenido de un archivo en la carpeta de SQLScripts.
.PARAMETER FileName
Nombre del archivo como aparace en el carpeta SQLScripts.
#>
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileName
    )

    begin {
    }

    process {
        foreach ($Item in $FileName) {
            $FullName = Join-Path -Path $Script:SQLScriptPath -ChildPath $Item
            Get-Content -Path $FullName -Raw
        }
    }

    end {
    }
}