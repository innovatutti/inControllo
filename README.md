# Parental Control App

App di parental control cross-platform (Android/iOS) realizzata con Flutter.

## Caratteristiche

### Android
- ✅ Lista di tutte le app installate dall'utente
- ✅ Blocco/sblocco app tramite Device Administrator API
- ✅ Interfaccia semplice con switch on/off per ogni app

### iOS
- ⚠️ Supporto limitato (API Screen Time)
- ❌ Non è possibile bloccare app senza consenso utente
- ❌ Non è possibile listare app installate

## Requisiti

- Flutter SDK (3.9.2+)
- Android Studio / Xcode
- Dispositivo Android 5.0+ o iOS 15.0+

## Setup

### 1. Installare dipendenze
```bash
flutter pub get
```

### 2. Configurare Firebase (opzionale)
Per abilitare funzionalità cloud:
1. Crea un progetto su [Firebase Console](https://console.firebase.google.com/)
2. Scarica `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
3. Posiziona i file nelle rispettive cartelle:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 3. Eseguire l'app

**Android:**
```bash
flutter run
```

**iOS:**
```bash
cd ios
pod install
cd ..
flutter run
```

## Permessi

### Android
L'app richiede:
- **Device Administrator**: Per nascondere/mostrare app
- **QUERY_ALL_PACKAGES**: Per elencare app installate

### iOS
- **Family Controls**: Richiede consenso esplicito dell'utente
- Funzionalità molto limitate rispetto ad Android

## Limitazioni

### Android
- Richiede che l'utente accetti manualmente i permessi di Device Administrator
- Non può bloccare app di sistema
- Su alcuni dispositivi il blocco potrebbe non funzionare (dipende dal produttore)

### iOS
- Non può bloccare app senza consenso dell'utente
- Non può elencare le app installate
- Richiede iOS 15.0+
- L'utente può rimuovere i limiti in qualsiasi momento

## Struttura Progetto

```
lib/
├── main.dart                       # Entry point
├── screens/
│   └── app_list_screen.dart       # Schermata lista app
└── services/
    └── device_admin_service.dart  # Servizio Platform Channel

android/
└── app/src/main/kotlin/com/incontrollo/parental_control/
    ├── MainActivity.kt            # Platform Channel Android
    ├── DeviceAdminReceiver.kt     # Receiver per Device Admin
    └── res/xml/device_admin.xml   # Policy amministratore

ios/
└── Runner/
    └── AppDelegate.swift          # Platform Channel iOS
```

## Prossimi Passi

1. **Firebase Integration**: Aggiungere autenticazione e sync tra dispositivi
2. **Remote Control**: Permettere ai genitori di controllare da remoto
3. **Notifiche**: Avvisare i genitori quando un'app viene usata
4. **Statistiche**: Monitorare tempo di utilizzo app

## Note

- Questa è una versione base/prototipo
- Per la pubblicazione su Play Store/App Store, seguire le policy di ogni store riguardo app di parental control
- Testare sempre su dispositivi reali, non solo emulatori

