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

3. Descargue y descomprima la plantilla desde la sección de [Releases](../../Release)

4. Crear un proyecto utilizando la plantilla

```powershell
# Ruta de la carpeta donde está el archivo PlasterManifest.xml
$MyFolderTemplate = 'C:\Plaster\Templates\Processa\NewModule'

# Ruta de la carpeta donde se creará el módulo 
$MyFolderDestination = 'C:\Temp\MyModule'

Invoke-Plaster -TemplatePath $MyFolderTemplate -DestinationPath $MyFolderDestination
```

--------------

[¿Qué es Plaster?](https://github.com/PowerShell/Plaster)

[¿Dónde está la plantilla?](https://github.com/RD-Processa/NewProcessaModuleTemplate/releases)
