function Set-CustomAlias {
<#
.SYNOPSIS
Crea un alias para una funci�n si el alias no existe.

.DESCRIPTION
El alias se pierde al salir de la sesi�n o cerrar Windows PowerShell.

.PARAMETER Name
Especifica el nombre del nuevo alias.
Puede usar caracteres alfanum�ricos en un alias, pero el primer car�cter no puede ser un n�mero.

.PARAMETER Value
Especifica el nombre del cmdlet o elemento de comando que vincula al alias.

.PARAMETER Scope
Especifica el alcance en el que este alias es v�lido.
Los valores aceptables para este par�metro son:

Valor | Descripci�n
----- | -------------
Global | El alcance que est� vigente cuando se inicia PowerShell.
Local | El alcance actual.
Script | El �mbito que se crea mientras se ejecuta un archivo de script.

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>
#>
    [CmdletBinding()]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [Parameter()]
        [ValidateSet('Global','Local','Script')]
        [string]
        $Scope = 'Script'
    )

    $Path = 'Alias:{0}' -f $Name
    if (!(Test-Path -Path $Path)) {
        Set-Alias -Scope $Scope -Name $Name -Value $Value
    }
}