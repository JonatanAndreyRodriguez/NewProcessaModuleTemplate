<#
.SYNOPSIS
Este c�digo se ejecuta tan pronto finaliza la carga del m�dulo.

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
'Antes de continuar debe establecer la configuraci�n del m�dulo.' | Out-Help
'1) Abra una instancia de PowerShell como un usuario Administrador.' | Out-Help
'2) Importe nuevamente este m�dulo.' | Out-Help
'3) Digite Set-Configuration y presione Enter.' | Out-Help
'4) Se mostrar� un cuadro de dialogo donde podr� establecer los valores de configuraci�n.' | Out-Help
'5) Ingrese los valores de configuraci�n.' | Out-Help
'6) Si esta ventana sigue abierta, vuelva a importar el m�dulo utilizando el par�metro -Force' | Out-Help
'=' | Out-Help -Padding '='
