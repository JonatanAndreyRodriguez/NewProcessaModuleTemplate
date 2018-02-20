function Set-CustomAlias {
<#
.SYNOPSIS
Crea un alias para una función si el alias no existe.

.DESCRIPTION
El alias se pierde al salir de la sesión o cerrar Windows PowerShell.

.PARAMETER Name
Especifica el nombre del nuevo alias.
Puede usar caracteres alfanuméricos en un alias, pero el primer carácter no puede ser un número.

.PARAMETER Value
Especifica el nombre del cmdlet o elemento de comando que vincula al alias.

.PARAMETER Scope
Especifica el alcance en el que este alias es válido.
Los valores aceptables para este parámetro son:

Valor | Descripción
----- | -------------
Global | El alcance que está vigente cuando se inicia PowerShell.
Local | El alcance actual.
Script | El ámbito que se crea mientras se ejecuta un archivo de script.

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