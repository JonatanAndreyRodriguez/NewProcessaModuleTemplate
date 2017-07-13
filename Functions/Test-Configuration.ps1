function Test-Configuration {
<#
.SYNOPSIS
Verifica la información de los datos de configuración del módulo.

.DESCRIPTION
Verifica la información de los datos de configuración del módulo de acuerdo a las comprobaciones que haya agregado el desarrollador.

.PARAMETER SaveFlag
Cuando se establece y las validaciones fallan, actualiza el valor de *No configurado* en el archivo <%=$PLASTER_PARAM_ModuleName%>.config

.EXAMPLE
Test-Configuration
Verifica la configuración del módulo (conexiones y demás elementos definidos por el desarrollador).

.EXAMPLE
Test-Configuration -SaveFlag
Verifica la configuración del módulo (conexiones y demás elementos definidos por el desarrollador). Si alguna verificación falla, establece el valor de *No configurado* en el archivo <%=$PLASTER_PARAM_ModuleName%>.config

.INPUTS
None

.LINK
[Set-Configuration](Set-Configuration.md)

.LINK
[Get-Configuration](Get-Configuration.md)

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>  
#>    
    [CmdletBinding()]
    [OutputType([System.Void])]
    Param(
        [switch]
        $SaveFlag
    )
    
    try {    

        $Configuration = Get-Configuration
        $MessageFormat = "[INFO] => {0}"

		# Agregue sus valiadaciones y quite las "dummy"
        $MessageFormat -f 'Connect-SqlLocal' | Write-Verbose       
        Test-SqlConnection -ConnectionString $Configuration.MySqlDummyConnectionString | Out-Null 

        if ($SaveFlag.IsPresent) {
            Set-AppSetting -Path $Script:AppConfig -Key 'configured' -Value '1'
        }
    }
    catch {
        Remove-AppSetting -Path $Script:AppConfig -Key 'configured'
        throw
    }
}
