function Get-Configuration {
<#
.SYNOPSIS
Obtiene la informaci�n de los datos de configuraci�n del m�dulo.

.DESCRIPTION
Obtiene la informaci�n de los datos de configuraci�n del m�dulo a partir de los datos en el archivo <%=$PLASTER_PARAM_ModuleName%>.config

.INPUTS
None

.EXAMPLE
Get-Configuration
Obtiene la informaci�n de configuraci�n del m�dulo.

.EXAMPLE
Get-Configuration | Get-Member -MemberType Properties
Obtiene los nombres de las propiedades incluidas en el objeto de retorno.

.LINK
[Set-Configuration](Set-Configuration.md)

.LINK
[Test-Configuration](Test-Configuration.md)

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%> 
#>    
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param()
    
    try {

        if ($Script:ConfigurationCache) {
            'Get-Configuration From Cache' | Write-Verbose
            $Script:ConfigurationCache | Write-Output
            return
        }
    
        $ConnectionStrings = Get-ConnectionStringSection -Path $Script:AppConfig
        $AppSettings = Get-AppSettingSection -Path $Script:AppConfig

        $SqlScriptPath = Join-Path -Path (Get-ScriptDirectory -Parent) -ChildPath 'SQLScripts'

        # Agregue a continuaci�n los valores de configuraci�n del m�dulo.
        # Los valores que se muestran a continuaci�n son de car�cter demostrativo. Qu�telos al finalizar
        $Script:ConfigurationCache = [PSCustomObject] @{
            MySqlDummyConnectionString = $ConnectionStrings['Sql:Local']
            MyDummyKey                 = $AppSettings['MyKey']
			Configured                 = $AppSettings['configured']
            SqlDummyStatement          = Get-Content -Path (Join-Path -Path $SqlScriptPath -ChildPath 'Get-Dummy.sql') -Raw
        }

        $Script:ConfigurationCache | Write-Output
    }
    catch {
        throw
    }
}
