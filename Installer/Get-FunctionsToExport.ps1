function Get-FunctionsToExport {
<#
.SYNOPSIS
Genera la lista de funciones que se deben exportar (públicas) del módulo.

.EXAMPLE
Get-FunctionsToExport

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>
#>

    $PrivateFunctions = Get-Content -Path '..\Private-Functions.txt'
    $FunctionsFiles = Get-ChildItem -Path '..\Functions' -Filter '*.ps1' | Sort-Object -Property 'Name'
    for ($Index = 0; $Index -lt $FunctionsFiles.Count; $Index++) {
        $FunctionName = [System.IO.Path]::GetFileNameWithoutExtension($FunctionsFiles[$Index])
        if ($FunctionName -notin $PrivateFunctions) {
            $Format = $Index | Invoke-Ternary -Condition {$PSItem -eq $FunctionsFiles.Count-1} -TrueBlock {"'{0}'"} -FalseBlock {"'{0}',"}
            ($Format -f $FunctionName)
        }
    }
}

Get-FunctionsToExport