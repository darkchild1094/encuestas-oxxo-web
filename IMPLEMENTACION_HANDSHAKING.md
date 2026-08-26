# Implementación de Handshaking y Módulo PFS

## 📋 Descripción General

Se ha implementado un sistema robusto de sincronización de encuestas con:

1. **Handshaking bidireccional**: Asegura que las encuestas se carguen correctamente en el servidor
2. **Logging detallado de errores**: Registra cada intento, error y código de respuesta
3. **Reintentos automáticos**: Con backoff exponencial para mayor confiabilidad
4. **Módulo PFS**: Permite al personal de tienda ver y monitorear el estado de envío de encuestas

---

## 🔧 Backend (PHP)

### 1. Migración de Base de Datos

Ejecutar antes de usar los endpoints:

```bash
mysql -u usuario -p base_datos < sql/migracion_encuesta_sync_log.sql
```

**Tabla creada**: `encuesta_sync_log`
- Registra cada intento de sincronización
- Almacena handshake_id para confirmar recepción
- Guarda errores detallados (código HTTP, mensaje)
- Índices optimizados para búsquedas frecuentes

### 2. Nuevos Endpoints API

#### a) Iniciar Handshake
```http
POST /api/encuestas/sync/init-handshake
Authorization: Bearer {token}

{
  "encuesta_id": "uuid-encuesta",
  "detalles": [...]  // opcional
}

Respuesta:
{
  "handshake_id": "uuid-handshake",
  "estado": "en_espera_confirmacion",
  "mensaje": "Handshake iniciado. Aguardando confirmación del servidor."
}
```

#### b) Confirmar Handshake
```http
POST /api/encuestas/sync/confirm-handshake
Authorization: Bearer {token}

{
  "handshake_id": "uuid-handshake"
}

Respuesta:
{
  "confirmado": true,
  "encuesta_id": "uuid-encuesta",
  "mensaje": "Handshake confirmado exitosamente"
}
```

#### c) Registrar Error
```http
POST /api/encuestas/sync/registrar-error
Authorization: Bearer {token}

{
  "handshake_id": "uuid-handshake",
  "codigo_respuesta": 500,
  "mensaje_error": "Connection timeout",
  "intento_numero": 1
}

Respuesta:
{
  "registrado": true,
  "mensaje": "Error registrado. Reintento disponible."
}
```

#### d) Obtener Status
```http
GET /api/encuestas/sync/status?encuesta_id=uuid-encuesta
Authorization: Bearer {token}

Respuesta:
{
  "encuesta_id": "uuid",
  "estado": "exito",
  "intento_numero": 1,
  "codigo_respuesta": null,
  "mensaje_error": null,
  "handshake_id": "uuid-handshake",
  "confirmado_servidor": true,
  "fecha_intento": "2026-08-26 12:34:56",
  "fecha_confirmacion": "2026-08-26 12:34:58"
}
```

#### e) Listar Encuestas Pendientes (PFS)
```http
GET /api/encuestas/pfs/pendientes
Authorization: Bearer {token}

Respuesta:
{
  "tienda_id": 123,
  "total_encuestas": 5,
  "encuestas": [
    {
      "id": "uuid",
      "folio": "ENC001",
      "fecha_creacion_local": "2026-08-26 10:00:00",
      "comentario": "Cliente satisfecho",
      "sincronizado": false,
      "estado": "error",
      "intento_numero": 3,
      "mensaje_error": "Connection timeout",
      "fecha_intento": "2026-08-26 10:15:00",
      "fecha_confirmacion": null,
      "total_respuestas": 12
    }
  ]
}
```

### 3. Permisos por Rol

| Endpoint | ATI | Admin | PFS | Otros |
|----------|-----|-------|-----|-------|
| init-handshake | ✓ | ✓ | ✓ | ✗ |
| confirm-handshake | ✓ | ✓ | ✓ | ✗ |
| registrar-error | ✓ | ✓ | ✓ | ✗ |
| sync/status | ✓ | ✓ | ✓ (propia) | ✗ |
| pfs/pendientes | ✗ | ✗ | ✓ | ✗ |

**Nota**: PFS solo ve encuestas de su tienda asignada

---

## 📱 Android

### 1. Archivos Agregados

```
data/local/entities/
  ├── EncuestaSyncLogEntity.kt       # Modelo de datos
  └── DTOs de sincronización

data/local/dao/
  └── EncuestaSyncLogDao.kt          # Acceso a BD local

data/remote/
  ├── ApiService.kt                  # (extender)
  └── ApiServiceSync.kt              # Nuevos endpoints

domain/
  └── EncuestaSyncManager.kt         # Lógica de reintentos y handshaking

ui/pfs/
  ├── PFSModuloViewModel.kt          # ViewModel para PFS
  └── PFSModuloScreen.kt             # UI Compose
```

### 2. Integración en AppDatabase

Agregar al archivo `AppDatabase.kt`:

```kotlin
@Database(
    entities = [
        // ... otras entidades
        EncuestaSyncLogEntity::class
    ],
    version = 2 // Incrementar versión
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun encuestaSyncLogDao(): EncuestaSyncLogDao
    // ... otros DAOs
}
```

### 3. Integración en ApiService

Convertir `ApiService` en `interface` que extienda `ApiServiceSync`:

```kotlin
interface ApiService : ApiServiceSync {
    // endpoints existentes...
}
```

Alternativamente, agregar manualmente los métodos de `ApiServiceSync.kt` a la interfaz existente.

### 4. Uso en Finalizacion de Encuesta

```kotlin
// En tu ViewModel o Repositorio
class EncuestaViewModel(
    private val apiService: ApiService,
    private val db: AppDatabase,
    private val syncManager: EncuestaSyncManager,
    private val token: String
) {
    
    fun finalizarEncuesta(encuestaId: String, detalles: List<...>) {
        viewModelScope.launch {
            // 1. Iniciar handshake
            val handshakeResult = syncManager.iniciarHandshake(
                token = token,
                encuestaId = encuestaId,
                detalles = detalles
            )
            
            if (handshakeResult.isFailure) {
                mostrarError("Error iniciando handshake")
                return@launch
            }
            
            val handshakeId = handshakeResult.getOrNull() ?: return@launch
            
            // 2. Enviar datos con reintentos
            val envioResult = syncManager.enviarEncuestaConReintentos(
                token = token,
                encuestaId = encuestaId,
                handshakeId = handshakeId,
                enviarFuncion = { token ->
                    val request = SubirEncuestasRequest(
                        encuestas = listOf(...)
                    )
                    try {
                        val response = apiService.subirEncuestas(
                            "Bearer $token",
                            request
                        )
                        response.success
                    } catch (e: Exception) {
                        false
                    }
                }
            )
            
            if (envioResult.isSuccess) {
                // 3. Confirmar en servidor
                syncManager.confirmarHandshake(token, handshakeId)
                mostrarExito("Encuesta enviada correctamente")
            } else {
                mostrarError("Error enviando encuesta después de reintentos")
            }
        }
    }
}
```

### 5. Módulo PFS

Integrar `PFSModuloScreen` en tu navegación:

```kotlin
// En tu NavGraph
composable("pfs_modulo") { backStackEntry ->
    val viewModel: PFSModuloViewModel = hiltViewModel()
    PFSModuloScreen(
        viewModel = viewModel,
        modifier = Modifier.fillMaxSize()
    )
}
```

Proporcionar el ViewModel con inyección de dependencias:

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object SyncModule {
    
    @Provides
    @Singleton
    fun provideSyncManager(
        db: AppDatabase,
        apiService: ApiService
    ): EncuestaSyncManager {
        return EncuestaSyncManager(db, apiService)
    }
}
```

---

## 🔄 Flujo Completo de Sincronización

```
Usuario finaliza encuesta
        ↓
Iniciar Handshake (init-handshake)
        ├─→ Genera handshake_id
        └─→ Registra en encuesta_sync_log
        ↓
Enviar datos con reintentos
        ├─→ Intento 1 (delay inicial)
        ├─→ Intento 2 (2x delay)
        ├─→ Intento 3 (4x delay)
        └─→ hasta 5 intentos
        ↓
Confirmar Handshake (confirm-handshake)
        └─→ Actualiza encuesta.sincronizado = 1
        ↓
Éxito ✓
```

## ❌ Manejo de Errores

Todos los errores quedan registrados en `encuesta_sync_log`:

- **Código HTTP**: Se almacena automáticamente (5xx, 4xx, timeout)
- **Mensaje detallado**: Descripción del error exacto
- **Número de intento**: Para rastrear reintentos
- **Timestamp**: Cuándo ocurrió cada intento

**Desde la UI PFS**, el usuario puede:
1. Ver la lista de encuestas con estado visual
2. Tocar encuestas con error para ver detalles exactos
3. Reintentar el envío manualmente (reinicia contador de intentos)

---

## 🧪 Testing

### Backend

```php
// Test: Iniciar handshake
curl -X POST http://localhost/api/encuestas/sync/init-handshake \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"encuesta_id":"550e8400-e29b-41d4-a716-446655440000"}'

// Test: Confirmar
curl -X POST http://localhost/api/encuestas/sync/confirm-handshake \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"handshake_id":"550e8400-e29b-41d4-a716-446655440001"}'

// Test: Ver status
curl -X GET "http://localhost/api/encuestas/sync/status?encuesta_id=550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer {token}"

// Test: PFS pendientes
curl -X GET "http://localhost/api/encuestas/pfs/pendientes" \
  -H "Authorization: Bearer {pfs_token}"
```

### Android

```kotlin
// En tu test
@Test
fun testHandshaking() = runTest {
    val token = "test-token"
    val encuestaId = "test-uuid"
    
    // Mock del API
    coEvery { 
        apiService.iniciarHandshake(any(), any()) 
    } returns SyncInitResponse(
        handshake_id = "test-handshake",
        estado = "en_espera_confirmacion",
        mensaje = "ok"
    )
    
    val result = syncManager.iniciarHandshake(token, encuestaId)
    
    assertTrue(result.isSuccess)
    assertEquals("test-handshake", result.getOrNull())
}
```

---

## 📊 Monitoreo

### Queries útiles en MySQL

```sql
-- Ver encuestas fallidas
SELECT * FROM encuesta_sync_log 
WHERE estado = 'error' 
ORDER BY fecha_intento DESC;

-- Ver encuestas por tienda
SELECT e.tienda_id, COUNT(*) as total
FROM encuesta_sync_log esl
JOIN encuesta e ON e.id = esl.encuesta_id
WHERE esl.estado != 'exito'
GROUP BY e.tienda_id;

-- Ver errores más frecuentes
SELECT mensaje_error, COUNT(*) as count
FROM encuesta_sync_log
WHERE estado = 'error'
GROUP BY mensaje_error
ORDER BY count DESC;

-- Ver intentos promedio por encuesta exitosa
SELECT AVG(intento_numero) as promedio
FROM encuesta_sync_log
WHERE estado = 'exito';
```

---

## 🚀 Despliegue

1. Ejecutar migración en servidor
2. Actualizar archivos PHP
3. Compilar app Android con nuevas clases
4. Probar endpoints manualmente
5. Integrar con UI existente
6. Desplegar versión Android

---

## 📝 Notas Importantes

- El token debe ser enviado en header `Authorization: Bearer {token}`
- Los UUIDs se generan del lado del servidor
- Los reintentos usan backoff exponencial (2s, 4s, 8s, 16s, 32s)
- PFS solo ve datos de su tienda asignada
- Los errores se registran aunque el reintentos falle
- Máximo 5 intentos antes de marcar como definitivamente fallido
