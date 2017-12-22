@{
    RootModule         = '.\<%=$PLASTER_PARAM_ModuleName%>.psm1'
    ModuleVersion      = '1.0.0.0'
    GUID               = '<%=$PLASTER_Guid1%>'
    Author             = '<%=$PLASTER_PARAM_ModuleAuthor%>'
    CompanyName        = 'Processa SAS'
    Copyright          = '(c) <%=$PLASTER_Year%> Processa SAS. All rights reserved.'
    PowerShellVersion  = '5.0'
    CLRVersion         = '4.0'
    RequiredModules    = @('Pscx', 'PSProcessa', 'NLog', 'PSSQLite')
    Description        = '<%=$PLASTER_PARAM_ModuleDesc%>'
    #RequiredAssemblies = @('.\bin\My.dll')
    FunctionsToExport  = @(
        'Get-Configuration',
        'Set-Configuration',
        'Test-Configuration')
    FormatsToProcess   = @('<%=$PLASTER_PARAM_ModuleName%>-Format.ps1xml')
}
