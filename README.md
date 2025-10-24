# Coin-Venture
Aplicación Flutter web y móvil para intercambio de criptomonedas. Usa Firebase para registro, inicio de sesión y cierre. Sigue Clean Architecture y BLoC. Muestra mercados actualizados cada 30 s desde una API pública, con filtros y orden. Incluye saldos, detalle con gráficos y volumen, y un flujo de trade con cálculo automático.

## Estructura del proyecto

```
lib/
├─ app.dart
├─ main.dart
├─ core/
│  ├─ config/
│  ├─ di/
│  ├─ error/
│  ├─ network/
│  ├─ routing/
│  ├─ security/
│  └─ utils/
├─ features/
│  ├─ auth/
│  ├─ markets/
│  ├─ wallet/
│  ├─ trade/
│  ├─ history/
│  └─ settings/
└─ shared/
```

Cada feature se divide en `domain`, `data` y `presentation` para mantener las responsabilidades separadas. Los blocs de cada módulo consumen *use cases* que a su vez interactúan con repositorios abstractos. La capa de datos dispone de *data sources* concretos (mock en este esqueleto) que permiten sustituir implementaciones reales por simulaciones controladas.

## Dependencias clave

- **Gestión de estado**: `flutter_bloc`, `equatable`
- **Inyección de dependencias**: `get_it`, `injectable`
- **Networking**: `dio`, `dio_smart_retry`
- **Firebase / autenticación**: `firebase_core`, `firebase_auth`, `google_sign_in`
- **UI**: `go_router`, `fl_chart`

## Cómo empezar

1. Instala Flutter (`>=3.3.0`).
2. Ejecuta `flutter pub get` para descargar las dependencias.
3. Lanza la aplicación con `flutter run -d chrome` o el dispositivo de tu preferencia.