function Initialize-Database {
<#
.SYNOPSIS
Crea los objetos en la base de datos de SQLite.
.DESCRIPTION
Crea los objetos en la base de datos de SQLite, si no se han creado anteriormente.
.EXAMPLE
Initialize-Database
.NOTES
Autor: <%=$PLASTER_PARAM_ModuleAuthor%>
#>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param()

    try {
        $InformationAction = $PSBoundParameters | Get-DictionaryKey -Key 'InformationAction' -DefaultValue 'Continue'
        $DBFilePath = $Script:DBFilePath
        $DbVersion = Get-AppSetting -Path ($Script:AppConfig) -Key 'DBVersion' -DefaultValue '00.00.00'
        $CurrentDbVersion = [System.Version]::New($DbVersion)

        # Ejecutar cada script necesario (en orden).
        Get-ChildItem -Path ($Script:SQLSchemaPath) -Filter '??.??.??.sql' | Sort-Object -Property 'Name' | ForEach-Object {
            # Solo se ejecuta el script si la versión de DB actual es menor.
            ("Checking {0}" -f $PSItem.Name) | Write-Verbose
            $FileVersion = [System.Version]::New([System.IO.Path]::GetFileNameWithoutExtension($PSItem.Name))
            $RequiresUpgrade = $CurrentDbVersion -lt $FileVersion
            if ($RequiresUpgrade) {
                $Query = Get-Content -Path $PSItem.FullName -Raw
                ("Executing {0}" -f $PSItem.Name) | Write-Verbose
                Invoke-SqliteQuery -Query $Query -DataSource $DBFilePath -ErrorAction 'Stop' | Out-Null
                Write-Log -Message ('Se ejecutó el script {0} en la base de datos' -f $PSItem.Name) -Level 'Warning'
                $CurrentDbVersion = $FileVersion
            }
        }
        Set-AppSetting -Path ($Script:AppConfig) -Key 'DBVersion' -Value ($CurrentDbVersion.ToString())
    }
    catch [System.Security.SecurityException] {
        Write-Message -Title 'Security Exception' -Message $PSItem.Exception.Message -Type 'Error' -InformationAction $InformationAction
    }
    catch {
        Write-Log -ErrorRecord $PSItem
        throw
    }
    finally {
        $Script:ConfigurationCache = $null
    }
}