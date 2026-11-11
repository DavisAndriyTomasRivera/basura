# Basura ♻️

Aplicación móvil desarrollada con Flutter para la **clasificación inteligente de residuos**. El proyecto forma parte del pipeline de Ingeniería del Conocimiento y utiliza un modelo TensorFlow Lite para realizar la clasificación en el dispositivo.


## Características

- Clasificación de residuos mediante un modelo TensorFlow Lite incluido en el proyecto.
- Selección de imágenes para su análisis con `image_picker`.
- Historial local de clasificaciones.
- Secciones de inicio, educación ambiental y ajustes.
- Recursos y animaciones incluidos en `assets/`.

La disponibilidad y el detalle de cada categoría dependen del modelo y de los datos que lo acompañan.

## Tecnologías

- [Flutter](https://flutter.dev/) y Dart.
- [TensorFlow Lite](https://www.tensorflow.org/lite) mediante `tflite_flutter`.
- `image_picker` para seleccionar imágenes.
- `shared_preferences` para preferencias o datos locales.

## Requisitos

- Flutter SDK compatible con la restricción del proyecto (`^3.13.5` de Dart en `pubspec.yaml`).
- Dart SDK incluido con Flutter.
- Android Studio o VS Code con las herramientas de Flutter.
- Un dispositivo o emulador compatible para ejecutar la aplicación.

Comprueba que Flutter esté instalado y configurado:

```bash
flutter doctor
```

## Instalación y ejecución

Clona el repositorio y entra al directorio del proyecto:

```bash
git clone https://github.com/DavisAndriyTomasRivera/basura.git
cd basura
```

Instala las dependencias y ejecuta la aplicación:

```bash
flutter pub get
flutter run
```

Para listar los dispositivos disponibles:

```bash
flutter devices
```

## Modelo y recursos

Los recursos de la aplicación se encuentran en `assets/`. El proyecto incluye archivos de modelo TensorFlow Lite (`.tflite`) y datos auxiliares. La configuración de Flutter registra los recursos de `assets/`, `assets/model/` y `assets/animations/`.

Si modificas o sustituyes el modelo, verifica que su ruta, sus entradas y salidas y las etiquetas de clasificación coincidan con lo que espera el servicio del clasificador.

## Comandos útiles

```bash
# Ejecutar pruebas
flutter test

# Analizar el código
flutter analyze

# Crear un APK de lanzamiento para Android
flutter build apk --release
```

## Estructura del proyecto

```text
lib/
├── app/          # Aplicación, navegación y tema
├── core/         # Componentes y utilidades compartidas
└── features/     # Funcionalidades organizadas por módulo
    ├── classifier/
    ├── education/
    ├── history/
    ├── home/
    └── settings/
assets/
├── animations/
└── model/
test/             # Pruebas
```

## Contribuciones

Las contribuciones son bienvenidas:

1. Crea un fork del repositorio.
2. Crea una rama para tu cambio (`git checkout -b feat/mi-cambio`).
3. Ejecuta `flutter analyze` y `flutter test`.
4. Abre un pull request describiendo el cambio y cómo probarlo.

## Estado del proyecto

Proyecto académico en desarrollo. Algunas funcionalidades, categorías de residuos o instrucciones pueden cambiar a medida que evolucione el modelo y la aplicación.

## Licencia

No se ha especificado una licencia en el repositorio. Salvo que se añada una, el código no concede permisos adicionales de uso, modificación o distribución.

## Autoría

Proyecto de **Ingeniería del Conocimiento** desarrollado en el repositorio [DavisAndriyTomasRivera/basura](https://github.com/DavisAndriyTomasRivera/basura).
