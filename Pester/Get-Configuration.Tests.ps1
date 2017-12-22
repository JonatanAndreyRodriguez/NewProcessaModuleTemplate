Import-Module ..\<%=$PLASTER_PARAM_ModuleName%> -Force

Describe 'Get-Configuration' {

	$PSDefaultParameterValues = @{'*:InformationAction'='SilentlyContinue'}

    It 'Dummy Test' {
        (Get-Configuration).Configured | Should Be $true
    }
}
