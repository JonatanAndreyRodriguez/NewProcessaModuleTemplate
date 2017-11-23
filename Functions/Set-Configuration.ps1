function Set-Configuration {
<#
.SYNOPSIS
Establece la información de los datos de configuración del módulo.

.DESCRIPTION
Establece la información de los datos de configuración del módulo en el archivo <%=$PLASTER_PARAM_ModuleName%>..config. **Se requiere que el usuario tenga permisos de Administrador**.

.EXAMPLE
Set-Configuration
Muestra una ventana que permite al administrador establecer los valores de configuración. 

.INPUTS
None

.LINK
[Test-Configuration](Test-Configuration.md)

.LINK
[Get-Configuration](Get-Configuration.md)

.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>  
#>    
    [CmdletBinding()]
    [OutputType([System.Void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    Param()
    
    try {    
		# Agregue sus valores de configuración y quite los "dummy"
        $ConfigInfo = @(
            New-ConfigurationItem -Type 'ConnectionString' -ConfigKey 'Sql:Local' -FriendlyName 'SqlLocal' -DataType 'String' -Description 'Mi servidor de Sql Server' -Category 'Cadenas de conexión'
            New-ConfigurationItem -Type 'AppSetting' -ConfigKey 'MyKey' -FriendlyName 'UnValor' -DataType 'String' -Description 'Ingrese un valor cualquiera' -Category 'Configuraciones generales'
        )
    
        if (Set-ConfigurationFile -Path $Script:AppConfig -ConfigurationInfo $ConfigInfo) {
			Write-Information -MessageData 'Configuration saved' -InformationAction 'Continue'
            $Script:ConfigurationCache = $null
            Test-Configuration -SaveFlag
        }
    }
    catch {
        throw
    }
}
