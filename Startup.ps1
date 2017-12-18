<#
.SYNOPSIS
Este código se ejecuta tan pronto finaliza la carga del módulo.

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>   
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[CmdletBinding()]
Param()

Start-Log -Source ($Script:ModuleName)
Set-Variable -Name 'PSProcessa-CurrentModule' -Option 'AllScope' -Value ($Script:ModuleName) -Scope 'Global'

if ((Get-Configuration).Configured) {
    Test-Configuration
    return
}
function private:Out-Help {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Text,
        
        [Parameter()]
        [string]
        $Padding = ' '
    )

    if ($Host.Name -eq 'ConsoleHost') {
        ($Text).PadRight(95, $Padding) | Write-Host -ForegroundColor Black -BackgroundColor Green
        return
    }

    ($Text).PadRight(95, $Padding) | Out-Default
}

'=' | Out-Help -Padding '='
'Antes de continuar debe establecer la configuración del módulo.' | Out-Help
'1) Abra una instancia de PowerShell como un usuario Administrador.' | Out-Help
'2) Importe nuevamente este módulo.' | Out-Help
'3) Digite Set-Configuration y presione Enter.' | Out-Help
'4) Se mostrará un cuadro de dialogo donde podrá establecer los valores de configuración.' | Out-Help
'5) Ingrese los valores de configuración.' | Out-Help
'6) Si esta ventana sigue abierta, vuelva a importar el módulo utilizando el parámetro -Force' | Out-Help
'=' | Out-Help -Padding '='
