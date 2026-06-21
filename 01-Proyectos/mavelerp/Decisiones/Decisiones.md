# Decisiones arquitectónicas — mavelerp

> Formato ADR. Las entradas se **agregan** al final, nunca se borran.
> Si una decisión cambia, crear nueva entrada con `Status: Superseded by ADR-XXXX`.

---

### ADR-0001: Framework MVC propio (sin third-party)

- **Fecha**: 2026-06-18 (retroactiva)
- **Estado**: Aceptada
- **Contexto**: ERP para mercado RD con requisitos fiscales muy específicos
  (e-CF DGII). Los frameworks generales (Laravel, Symfony) añadían complejidad
  innecesaria y dependencias que complican el mantenimiento en Hostinger.
- **Decisión**: Implementar MVC propio con autoloader PSR-4 custom, routing
  simple, middleware chain y sistema de módulos.
- **Alternativas consideradas**:
  - Laravel: overhead de ORM, broadcasting, jobs; licencia no bloqueante pero
    curva alta para el equipo.
  - Slim/Lumen: viable, pero aún agrega una capa que no controlamos.
- **Consecuencias**: Control total del stack; deuda de no tener ORM maduro
  (queries manuales en `Database`); sin ecosystem de paquetes listos.

---

### ADR-0002: Firma digital e-CF con XMLDSig (RSA-SHA256)

- **Fecha**: 2026-06-18 (retroactiva)
- **Estado**: Aceptada
- **Contexto**: DGII requiere firma digital XMLDSig con certificado `.p12`
  (VIAFIRMA) en cada e-CF. PHP no tiene soporte nativo completo.
- **Decisión**: Usar `robrichards/xmlseclibs` vía Composer para la firma.
  Certificado `.p12` almacenado en `storage/certificates/` encriptado AES-256
  via `CertificateManager`.
- **Alternativas consideradas**:
  - OpenSSL directo: más bajo nivel, más frágil ante cambios de formato DGII.
- **Consecuencias**: Dependencia crítica en `xmlseclibs`; `PreserveWhitespace=false`
  es obligatorio para que la firma valide en DGII.

---

### ADR-0003: Sistema de módulos con licencias por BD

- **Fecha**: 2026-06-18 (retroactiva)
- **Estado**: Aceptada
- **Contexto**: ERP debe poder habilitarse parcialmente por cliente (solo
  Facturación, o + Inventario, etc.) y soportar módulos premium.
- **Decisión**: `ModuleLoader` escanea `modules/*/module.json` y consulta
  `module_license` (`is_enabled`, `expires_at`) en BD. Solo carga `routes.php`
  de módulos activos.
- **Alternativas consideradas**:
  - Flags en `config/modules.php`: sencillo pero no permite control por BD ni
    expiración automática.
- **Consecuencias**: `config/modules.php` queda solo como lista estática para
  la UI admin; la lógica real vive en BD. Agregar un módulo nuevo requiere
  insertar fila en `module_license`.

---

### ADR-0007: e-NCF y asiento contable se asignan al ENVIAR, no al convertir

- **Fecha**: 2026-06-19
- **Estado**: Aceptada (reemplaza ADR-0004)
- **Contexto**: Al convertir cotización→factura se asignaba el e-NCF de
  inmediato (`nextEcfFromRange`), quemando la secuencia autorizada si la
  factura se anulaba antes de enviarse. Además el asiento contable se
  creaba al convertir, dejando asientos de facturas nunca emitidas.
- **Decisión**: En modo ELECTRONIC, la factura DRAFT se crea **sin** e-NCF
  (solo `tipo_ecf`). El e-NCF se asigna en `approveInvoice()` ("Validar y
  Enviar") justo antes de firmar/enviar. El asiento contable se crea al
  envío exitoso (idempotente). El 607 excluye borradores sin e-NCF.
- **Alternativas consideradas**:
  - Liberar/reciclar el e-NCF al anular: DGII no permite reutilizar
    números de forma confiable; más frágil.
  - Mantener asiento al convertir + reverso al anular: ensucia el libro.
- **Consecuencias**: Anular un borrador no consume secuencia ni deja
  asiento. Un envío que falla mantiene su e-NCF para reintentar (correcto).
  LEGACY conserva el comportamiento anterior (NCF físico al convertir).

---

### ADR-0006: Lookup de RNC vía API MegaPlus (no endpoint oficial DGII)

- **Fecha**: 2026-06-19
- **Estado**: Aceptada
- **Contexto**: Se quería autocompletar datos del cliente consultando el
  RNC/cédula contra la DGII. Los endpoints "oficiales" gratuitos están
  caídos: `api.digital.gob.do` (404, retirado) y el web service
  `dgii.gov.do/wsMovilDGII` (301, roto desde ene-2025). El dataset ZIP
  oficial (20MB) funciona pero exige importación + cron + refresco.
- **Decisión**: Usar la API pública de **MegaPlus**
  (`rnc.megaplus.com.do/api/consulta?rnc={rnc}`), que devuelve el dato del
  padrón DGII en JSON sin API key. Verificada en vivo desde local y desde
  el servidor de producción.
- **Alternativas consideradas**:
  - Dataset ZIP oficial DGII → más robusto (sin dependencia runtime) pero
    más trabajo; queda como **plan B** si MegaPlus se cae.
  - APIs de pago (dgiiapicloud, dominicantechnology) → costo + signup;
    una estaba caída (520) al probar.
- **Consecuencias**: Dependemos de un tercero gratuito sin SLA → si falla,
  el alta de cliente sigue funcionando manual (degradación elegante). La
  API **no** trae dirección ni teléfono (el padrón DGII no los expone),
  así que esos campos siguen siendo manuales. Mitigación futura: cachear
  respuestas en una tabla local.

---

### ADR-0005: customer_type como fuente de verdad del tipo e-CF

- **Fecha**: 2026-06-19
- **Estado**: Aceptada
- **Contexto**: La heurística anterior (9 dígitos → E31, resto → E32)
  no cubría tipos especiales (E44, E45, E46). Un cliente del gobierno
  con RNC de 9 dígitos generaba E31 en lugar del correcto E45.
- **Decisión**: Agregar `customer_type` ENUM a la tabla `customers`.
  La lógica en `convertToInvoice()` usa prioridad: (1) override manual
  `tipo_ecf_forzado`, (2) mapa `customer_type→tipo_ecf`, (3) heurística
  RNC como fallback para registros legacy.
- **Alternativas consideradas**:
  - Selección manual siempre: impone carga al usuario en cada factura.
  - Campo libre de tipo e-CF en el cliente: más flexible pero requiere
    validar contra los tipos DGII válidos.
- **Consecuencias**: El override manual sigue disponible — el tipo del
  cliente es el default, no una restricción. Los clientes existentes
  heredan `empresa` y el comportamiento anterior no cambia.

---

### ADR-0004: eNCF se asigna al convertir cot→factura (deuda conocida)

- **Fecha**: 2026-06-18 (retroactiva)
- **Estado**: Aceptada (pendiente de cambio — ver [[../Tareas-Pendientes.md]])
- **Contexto**: Al pasar una cotización a factura se asigna el `eNCF`
  inmediatamente, lo que "quema" secuencia aunque la factura se cancele
  antes del envío a DGII.
- **Decisión**: Por simplicidad de implementación inicial, se acepta este
  comportamiento.
- **Consecuencias**: Deuda técnica registrada. La solución correcta es
  asignar el `eNCF` solo al pulsar "Enviar y validar" (ver tarea
  "Esquema cot → factura sin quemar secuencia").
