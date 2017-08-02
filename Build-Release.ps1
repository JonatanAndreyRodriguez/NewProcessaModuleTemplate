$Manifest = [xml](Get-Content -Path "$pwd\PlasterManifest.xml" -Raw)
$Version = $Manifest.plasterManifest.metadata.version
$DestinationPath = Join-Path -Path $env:TEMP -ChildPath "NewProcessaModuleTemplate_$Version.zip"
Compress-Archive -Path $pwd -DestinationPath $DestinationPath
$DestinationPath | Out-Default
