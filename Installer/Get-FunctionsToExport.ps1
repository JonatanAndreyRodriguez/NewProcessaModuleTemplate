function Get-FileNameWithoutExtension {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string]
        $InputObject,

        [string]
        $LastItem,

        [switch]
        $Enquote

    )

    begin {
    }   

    process {
        foreach ($Item in $InputObject) {
            $FileName = [System.IO.Path]::GetFileNameWithoutExtension($Item)

            $Format = "{0}"

            if ($Enquote.IsPresent) {
                $Format = "'{0}',"
                if ($LastItem -eq $FileName) {
                    $Format = "'{0}'"
                }
            }

            $Format -f $FileName | Write-Output
            return
        }
    } 
    end {
    }
}

$PrivateFunctions = Get-Content -Path '..\Private-Functions.txt'
$FunctionsToExport = Get-ChildItem -Path '..\Functions' -Filter '*.ps1' | Where-Object {($PSItem | Get-FileNameWithoutExtension) -notin $PrivateFunctions}
$LastFunction = $FunctionsToExport | Select-Object -Property @{L = 'Name'; E = {$PSItem | Get-FileNameWithoutExtension}} -Last 1 
 
$FunctionsToExport | 
    Select-Object -Property @{L = 'Name'; E = {$PSItem | Get-FileNameWithoutExtension -Enquote -LastItem ($LastFunction.Name)}} | 
    Select-Object -ExpandProperty 'Name'    
