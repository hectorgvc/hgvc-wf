---
tipo: arquitectura
creado: 2026-06-19
proyecto: mavelerp
tags: [despliegue, hostinger, ssh, opcache, operaciones]
---

# Despliegue en Hostinger — Notas operativas

> Lecciones aprendidas desplegando (2026-06-19). Leer antes de subir
> cambios para no repetir errores que costaron tiempo.

## Acceso

- **SSH/SCP** (no solo FTP): `ssh -p 65002 u690045374@195.179.239.166`
  - Requiere `sshpass` para automatizar (la contraseña va inline).
  - ⚠️ Las credenciales se compartieron en chat → conviene rotarlas.

## Rutas — ⚠️ EL ERROR MÁS COSTOSO

El sitio de **producción sirve desde**:
```
/home/u690045374/domains/mavelerp.e-tecsystem.com/public_html/
```

**NO** desde `/public_html/dev/` — esa es una carpeta de **backup/copia**.
Subir ahí no afecta el sitio en vivo y parece que "el cambio no aparece".

> Regla: siempre desplegar a `public_html/` (raíz), nunca a `public_html/dev/`.

## OPcache — ⚠️ EL SEGUNDO ERROR

`php -r 'opcache_reset()'` por **SSH (CLI)** corre en un proceso PHP
distinto al de la web → **no limpia** el OPcache de PHP-FPM que sirve el
sitio. El cambio queda cacheado y "no se ve".

**Forma correcta:** llamar el script vía HTTP (corre bajo PHP-FPM):
```bash
curl -s "https://mavelerp.e-tecsystem.com/opcache_clear.php"
```
(devuelve `OK`). También existe `clear_cache.php` en la raíz.

## ⚠️ PHP CLI 7.4 vs Web 8.3 — no confiar en el `php` de SSH

- `php` por SSH (CLI) = **PHP 7.4.33**.
- La web (PHP-FPM) = **PHP 8.3.30**.

→ Testear código 8.x con `php archivo.php` por SSH puede dar **parse
errors falsos** (ej. `catch (\Throwable)` sin variable es 8.0+; 7.4 lo
rechaza). Para verificar comportamiento real, ejecutar bajo el PHP de la
web: subir un script temporal a `public_html/`, llamarlo por `curl` y
borrarlo. `php -l` local (8.x) sí sirve para sintaxis.

## Gotcha de namespaces (helpers globales)

`core/Helpers/QrHelper.php` **no declara namespace** (vive en global).
Desde un controller (namespace `App\Controllers`) hay que llamarlo con
backslash: `\QrHelper::metodo()`. Sin `\`, PHP busca
`App\Controllers\QrHelper` → Fatal. Desde **vistas** (namespace global)
funciona sin `\`. Fue la causa de BUG-001 (2FA). Ver
[[../Bitacora/Sesiones/2026-06-19-fix-2fa]].

## Receta de despliegue (probada)

```bash
PASS="<password>" REMOTE="u690045374@195.179.239.166" PORT="65002"
DEST="/home/u690045374/domains/mavelerp.e-tecsystem.com/public_html"
LOCAL="/home/hector/Documents/mavelerp-dev"

# 1. Subir archivo(s) — ¡a public_html, no a dev!
sshpass -p "$PASS" scp -P $PORT -o StrictHostKeyChecking=no \
  "$LOCAL/ruta/al/archivo.php" "$REMOTE:$DEST/ruta/al/archivo.php"

# 2. Limpiar OPcache vía HTTP (no por CLI)
curl -s "https://mavelerp.e-tecsystem.com/opcache_clear.php"

# 3. (opcional) verificar checksum local vs remoto
md5sum "$LOCAL/ruta/al/archivo.php"
sshpass -p "$PASS" ssh -p $PORT "$REMOTE" "md5sum '$DEST/ruta/al/archivo.php'"
```

## Base de datos

- Migraciones SQL se aplican por **phpMyAdmin** (panel Hostinger →
  Bases de datos → SQL) o por SSH con `mysql` CLI.
- El `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` devuelve "0 rows" = OK.

## Gotcha de las vistas (no es de Hostinger pero relacionado)

Un `<script>` dentro de una vista de módulo **debe ir dentro** de
`View::startSection('content') ... endSection()`. Si va después de
`endSection()`, `View::module()` lo **descarta** (el layout solo
renderiza `section('content')`). Ver
[[Bitacora/Sesiones/2026-06-19-rnc-lookup]].
