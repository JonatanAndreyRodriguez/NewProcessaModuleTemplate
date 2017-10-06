function Get-ConfigPath {
<#
.SYNOPSIS
Obtiene la ruta de acceso del archivo de configuraci�n a partir del nombre del m�dulo que lo contiene.

.DESCRIPTION
Se hace de esta forma para que la informaci�n contenida en el archivo no se pierda entre actualizaciones del m�dulo.

.PARAMETER Path
Ruta de acceso de la raiz del m�dulo.

.NOTES
Author: <%=$PLASTER_PARAM_ModuleAuthor%>
#>

    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $Filename = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $Folder = $Path -split [regex]::Escape(([System.IO.Path]::DirectorySeparatorChar))
    $ConfigPath = ''
    $Found = $false
    foreach ($Item in $Folder) {
        $ConfigPath += $Item + [System.IO.Path]::DirectorySeparatorChar
        if ($Item -eq $Filename) {
            $Found = $true
            break
        }
    }

    if (!$Found) {
        throw 'Check module path!!!'
    }

    Join-Path -Path $ConfigPath -ChildPath ([System.IO.Path]::GetFileName($Path)) | Write-Output
}
