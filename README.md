# NewProcessaModuleTemplate
Plantilla de proyecto de Plaster para módulos de PowerShell

![Curent release](https://img.shields.io/badge/version-1.0.2-f39f37.svg)

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
$MyFolderTemplate = 'RutaCarpetaDondeDescomprimioPlantilla'
# La ruta de la carpeta donde está el archivo PlasterManifest.xml
Invoke-Plaster -TemplatePath $MyFolderTemplate -DestinationPath 'YourFolderDestination'
```

--------------

[¿Qué es Plaster?](https://github.com/PowerShell/Plaster)

[¿Dónde está la plantilla?](https://github.com/RD-Processa/NewProcessaModuleTemplate/releases)
