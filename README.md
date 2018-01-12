# NewProcessaModuleTemplate
Plantilla de proyecto de Plaster para módulos de PowerShell

## Uso

1. Instalar el módulo Plaster

```powershell
Install-Module Plaster
```

2. Importar el módulo Plaster

```powershell
Import-Module Plaster
```

3. Crear un proyecto utilizando la plantilla

```powershell
# La ruta de la carpeta donde está el archivo PlasterManifest.xml
$MyFolderTemplate = 'RutaCarpetaDondeDescomprimioPlantilla'
$MyFolderDestination = 'C:\Temp\MyModule'

Invoke-Plaster -TemplatePath $MyFolderTemplate -DestinationPath $MyFolderDestination
```

--------------

[¿Qué es Plaster?](https://github.com/PowerShell/Plaster)

[¿Dónde está la plantilla?](https://github.com/RD-Processa/NewProcessaModuleTemplate/releases)
