# Trufi Cochabamba App

Esta es la aplicación oficial de Trufi para Cochabamba, Bolivia. Ha sido completamente reconstruida usando la arquitectura moderna de Trufi Core v5.2.0.

## 📋 Características

- **Mapas Offline**: 4 estilos de mapas offline (OSM Liberty, OSM Bright, Dark Matter, Fiord Color)
- **Mapas Online**: 4 estilos de mapas online desde maps.trufi.app
- **Routing Offline**: Planificación de rutas offline usando GTFS
- **Routing Online**: Planificación de rutas online usando OTP 2.8.1 y OTP 1.5.0
- **POI Layers**: 12 categorías de puntos de interés (educación, salud, transporte, etc.)
- **Navegación**: Navegación paso a paso para transporte público
- **Lugares Guardados**: Guarda tus lugares favoritos
- **Lista de Transporte**: Explora todas las rutas de transporte
- **Tarifas**: Información sobre tarifas de transporte
- **Feedback**: Envía comentarios y sugerencias

## 🏗️ Arquitectura

La app usa la arquitectura modular de Trufi Core v5.2.0 con los siguientes paquetes:

- `trufi_core_maps` - Gestión de mapas (offline y online)
- `trufi_core_routing` - Planificación de rutas (GTFS y OTP)
- `trufi_core_poi_layers` - Capas de puntos de interés
- `trufi_core_navigation` - Navegación paso a paso
- `trufi_core_home_screen` - Pantalla principal
- `trufi_core_saved_places` - Lugares guardados
- `trufi_core_transport_list` - Lista de transporte
- `trufi_core_fares` - Información de tarifas
- `trufi_core_feedback` - Sistema de feedback
- `trufi_core_about` - Información de la app
- `trufi_core_settings` - Configuración

## 📱 Identificadores de la App

- **Android**: `app.trufi.navigator`
- **iOS**: `app.trufi.navigator`
- **Nombre**: Trufi Cochabamba
- **Deep Link Scheme**: `trufiapp://`

## 📂 Estructura de Assets

```
assets/
├── routing/
│   └── cochabamba.gtfs.zip          # Datos GTFS para routing offline
├── search/
│   └── search.json                  # Índice offline de calles y esquinas (tools/search-bolivia-cochabamba)
├── offline/
│   ├── cochabamba.mbtiles           # Tiles de mapa offline
│   ├── styles/                      # Estilos de mapas
│   │   ├── osm-bright/
│   │   ├── osm-liberty/
│   │   ├── dark-matter/
│   │   └── fiord-color/
│   └── fonts/                       # Fuentes para mapas
│       ├── OpenSansRegular/
│       ├── OpenSansBold/
│       ├── OpenSansItalic/
│       ├── RobotoRegular/
│       ├── RobotoMedium/
│       └── RobotoCondensedItalic/
└── pois/                            # POIs en formato GeoJSON
    ├── education.geojson
    ├── emergency.geojson
    ├── finance.geojson
    ├── food.geojson
    ├── government.geojson
    ├── healthcare.geojson
    ├── recreation.geojson
    ├── religion.geojson
    ├── shopping.geojson
    ├── tourism.geojson
    ├── transport.geojson
    └── metadata.json
```

## 🔧 Configuración

### Endpoints de Servicios (de input/domains.txt)

- **Photon (Geocoding)**: https://photon.trufi.app
- **OTP 2.8.1**: https://otp281.trufi.app
- **OTP 1.5.0**: https://otp150.trufi.app
- **MapLibre Styles**: https://maps.trufi.app/styles/

### Coordenadas del Centro

- Latitud: -17.3988354
- Longitud: -66.1626903

### Redes Sociales

- Facebook: https://www.facebook.com/trufiapp/
- Instagram: https://www.instagram.com/trufi.app
- WhatsApp: https://wa.me/59167835296

## 🚀 Desarrollo

### Requisitos

- Flutter SDK **3.47.8**, la versión fijada en `.github/workflows/flutter.yml` (`FLUTTER_VERSION`); con fvm: `fvm install 3.47.8`
- Android SDK (para Android)
- Xcode (para iOS)

### Instalación

1. Clona el repositorio
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la app:
   ```bash
   # Android
   flutter run --debug

   # iOS
   flutter run --debug

   # Web (sin mapas/routing offline)
   flutter run -d chrome
   ```

### Integración continua

`.github/workflows/flutter.yml` corre en cada pull request y en cada push a `main`: `flutter pub get`, la comprobación de que `lib/l10n` está sincronizado con los ARB (`flutter gen-l10n` + `git diff --exit-code`), `flutter analyze --no-fatal-infos` y `flutter test`. Flutter se fija a la versión de `FLUTTER_VERSION` en ese archivo (hoy 3.47.8), nunca a un canal: es el único sitio donde vive la versión. Las herramientas Node de `tools/` no corren en el CI.

Para subir la versión de Flutter:

1. Instala la nueva versión localmente (`fvm install <versión>`) y repite los cuatro pasos con ella: `~/fvm/versions/<versión>/bin/flutter pub get`, `flutter gen-l10n` (sin cambios en `lib/l10n`), `flutter analyze --no-fatal-infos` y `flutter test`.
2. Si `pub get` cambió `pubspec.lock`, commitea el lock: la caché de pub del CI se renueva con él.
3. Cambia `FLUTTER_VERSION` en `.github/workflows/flutter.yml` y los dos «3.47.8» de este README (requisitos y esta sección), y comprueba que el check del PR queda en verde.

## 📝 Cambios desde trufi-app (v4.0.1)

### ✅ Actualizado

1. **Arquitectura**: De monolítica a modular con paquetes independientes
2. **Trufi Core**: De v4.0.0 a v5.2.0
3. **Mapas Offline**: Nuevo soporte con MapLibre y MBTiles
4. **Routing Offline**: Nuevo soporte con GTFS local
5. **POI Layers**: Sistema dinámico con GeoJSON
6. **API**: Completamente nueva y más simple

### 🔄 Mantenido

1. **Bundle IDs**: `app.trufi.navigator` (Android e iOS)
2. **App Icons**: Iconos originales de trufi-app
3. **Ciudad**: Cochabamba, Bolivia
4. **Datos GTFS**: cochabamba.gtfs.zip

### ❌ Removido

- Código legacy de trufi-app (incompatible con v5.2.0)
- Dependencias antiguas
- Configuraciones obsoletas

## 🔍 Comparación de Versiones

| Aspecto | trufi-app (v4.0.1) | cochabamba-app (v5.0.0) |
|---------|-------------------|------------------------|
| Trufi Core | v4.0.0 | v5.2.0 |
| Arquitectura | Monolítica | Modular |
| Mapas Offline | ❌ | ✅ (4 estilos) |
| Routing Offline | ❌ | ✅ (GTFS) |
| POI Layers | Estático | Dinámico (12 categorías) |
| Flutter SDK | >=2.18.2 <3.0.0 | ^3.10.0 |

## 📦 Dependencias Principales

```yaml
flutter_bloc: ^9.1.1
provider: ^6.1.5+1
go_router: ^17.0.1
latlong2: ^0.9.1
maplibre: ^0.3.3+2
maplibre_gl: ^0.25.0
```

## 📞 Contacto

- Email: feedback@trufi.app
- Feedback Form: https://forms.gle/QMLhJT7N44Bh9zBN6
- Website: https://www.trufi.app/

## 📄 Licencia

Copyright © Trufi Association
