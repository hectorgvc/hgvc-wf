---
description: >
  Configura autenticación en un proyecto nuevo o existente. Activar cuando
  el usuario diga: "necesito auth", "agrega login", "implementa autenticación",
  "sign in / sign up", "necesito registro de usuarios", "proteger rutas",
  "JWT", "sesiones", o "Clerk". Incluye templates de UI y decisión entre
  Clerk (managed) y solución propia (JWT/sesiones).
depends_on:
  - team-context
---

# Auth Setup

## Paso 1 — Elegir la estrategia

Antes de escribir código, hacer estas preguntas al usuario:

1. ¿El proyecto es público (usuarios externos) o interno (equipo/empresa)?
2. ¿Necesitas OAuth social (Google, GitHub, Facebook)?
3. ¿Necesitas MFA o SSO empresarial (SAML/OIDC)?
4. ¿Cuántos usuarios esperas en los próximos 12 meses?
5. ¿Cuál es el stack? (Next.js, Laravel, Django, vanilla, etc.)

Usar la tabla para recomendar:

| Situación | Recomendación |
|-----------|---------------|
| App pública, Next.js/React, <50k usuarios | Clerk (free tier) |
| App interna / LDAP/AD existente | Solución propia con JWT |
| Laravel / Django / PHP | JWT + middleware propio o Laravel Sanctum / Passport |
| Multi-tenant B2B con SSO | Clerk Pro ($25/mo) |
| Máximo control, sin vendor lock-in | JWT + bcrypt propio |

**Clerk free tier incluye:** 50k monthly retained users, OAuth social,
3 dashboard seats (administradores del panel), email/SMS OTP, custom domain.
Los "dashboard seats" son quiénes administran Clerk — no afectan los usuarios
de la app.

---

## Paso 2a — Implementación con Clerk

### Instalación

**Next.js (App Router):**
```bash
npm install @clerk/nextjs
```

`middleware.ts`:
```typescript
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isPublicRoute = createRouteMatcher(['/sign-in(.*)', '/sign-up(.*)'])

export default clerkMiddleware((auth, request) => {
  if (!isPublicRoute(request)) auth().protect()
})

export const config = {
  matcher: ['/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)', '/(api|trpc)(.*)'],
}
```

`.env.local`:
```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard
```

`app/layout.tsx`:
```typescript
import { ClerkProvider } from '@clerk/nextjs'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider>
      <html lang="es">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  )
}
```

Páginas de auth:
```
app/sign-in/[[...sign-in]]/page.tsx  → <SignIn />
app/sign-up/[[...sign-up]]/page.tsx  → <SignUp />
```

**Laravel (via API, frontend separado):**
```bash
composer require clerkinc/clerk-sdk-php
```

```php
// Middleware de verificación de token Clerk
$token = $request->bearerToken();
$client = new Clerk\Backend\ClerkBackend(bearerAuth: env('CLERK_SECRET_KEY'));
$session = $client->sessions->verify(sessionId: '...', token: $token);
```

---

## Paso 2b — Implementación propia con JWT

Para proyectos donde se prefiere control total o hay LDAP/AD.

### Laravel (Sanctum — recomendado para APIs internas):
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

`config/sanctum.php` → ajustar `stateful` domains.

Ruta de login:
```php
Route::post('/login', function (Request $request) {
    $user = User::where('email', $request->email)->first();
    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Credenciales inválidas'], 401);
    }
    return response()->json([
        'token' => $user->createToken('api')->plainTextToken,
        'user'  => $user,
    ]);
});
```

### Node.js / Express:
```bash
npm install jsonwebtoken bcryptjs
```

```typescript
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'

const JWT_SECRET = process.env.JWT_SECRET!
const JWT_EXPIRES = '7d'

export const generateToken = (userId: string) =>
  jwt.sign({ sub: userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES })

export const verifyToken = (token: string) =>
  jwt.verify(token, JWT_SECRET) as { sub: string }

export const hashPassword = (password: string) => bcrypt.hash(password, 12)
export const comparePassword = (password: string, hash: string) =>
  bcrypt.compare(password, hash)
```

---

## Paso 3 — Template de UI (HTML + CSS standalone)

Copiar este template al proyecto como `login.html` o componente.
Inspirado en diseño split-panel: panel decorativo izquierdo + formulario derecho.
Ajustar colores en las variables CSS al inicio.

```html
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login</title>
<style>
  :root {
    --brand: #E8566A;
    --brand-dark: #C43050;
    --brand-light: #F28090;
    --panel-bg: #E8566A;
  }
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body { min-height: 100vh; display: flex; align-items: center;
         justify-content: center; background: #f4f4f4; font-family: system-ui, sans-serif; }
  .card { display: flex; border-radius: 16px; overflow: hidden;
          box-shadow: 0 8px 32px rgba(0,0,0,0.12); width: 100%; max-width: 820px; min-height: 480px; }
  .panel { width: 38%; background: var(--panel-bg); position: relative;
           overflow: hidden; display: flex; flex-direction: column;
           justify-content: flex-end; padding: 32px 28px; }
  .shape { position: absolute; border-radius: 20px; }
  .s1 { width: 220px; height: 220px; background: var(--brand-light);
        top: -60px; left: -60px; transform: rotate(20deg); }
  .s2 { width: 180px; height: 180px; background: var(--brand-dark);
        top: 60px; left: 30px; transform: rotate(35deg); }
  .s3 { width: 200px; height: 200px; background: var(--brand-light);
        top: 140px; left: -40px; transform: rotate(50deg); }
  .s4 { width: 160px; height: 160px; background: var(--brand-dark);
        top: 240px; left: 60px; transform: rotate(10deg); }
  .panel-label { position: relative; z-index: 2; }
  .panel-label span { color: rgba(255,255,255,.7); font-size: 11px;
                      letter-spacing: .12em; text-transform: uppercase; display: block; margin-bottom: 4px; }
  .panel-label h2 { color: #fff; font-size: 28px; font-weight: 500; }
  .form-side { flex: 1; padding: 48px 40px; display: flex;
               flex-direction: column; justify-content: center; background: #fff; }
  .logo { width: 52px; height: 52px; margin: 0 auto 14px; display: block; }
  .form-title { text-align: center; font-size: 22px; font-weight: 600;
                color: var(--brand); margin-bottom: 28px; }
  .field { margin-bottom: 16px; position: relative; }
  .field svg { position: absolute; left: 0; top: 50%; transform: translateY(-50%);
               width: 18px; height: 18px; color: #aaa; }
  .field input { width: 100%; border: none; border-bottom: 1.5px solid #e0e0e0;
                 background: transparent; padding: 10px 10px 10px 28px;
                 font-size: 14px; color: #333; outline: none; transition: border-color .15s; }
  .field input:focus { border-bottom-color: var(--brand); }
  .field input::placeholder { color: #bbb; }
  .meta { display: flex; justify-content: space-between; align-items: center;
          margin: 8px 0 22px; }
  .forgot { font-size: 13px; color: var(--brand); cursor: pointer; text-decoration: none; }
  .btn { width: 100%; padding: 12px; border-radius: 50px; background: var(--brand);
         color: #fff; font-size: 14px; font-weight: 600; border: none;
         cursor: pointer; letter-spacing: .08em; transition: opacity .15s; }
  .btn:hover { opacity: .88; }
  .divider { display: flex; align-items: center; gap: 12px; margin: 20px 0;
             color: #bbb; font-size: 12px; }
  .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #eee; }
  .oauth { display: flex; gap: 12px; }
  .oauth-btn { flex: 1; display: flex; align-items: center; justify-content: center;
               gap: 8px; padding: 9px; border: 1px solid #e0e0e0; border-radius: 8px;
               background: #fff; font-size: 13px; color: #555; cursor: pointer;
               transition: background .15s; }
  .oauth-btn:hover { background: #f8f8f8; }
  @media (max-width: 600px) { .panel { display: none; } .card { border-radius: 0; } }
</style>
</head>
<body>
<div class="card">
  <div class="panel">
    <div class="shape s1"></div><div class="shape s2"></div>
    <div class="shape s3"></div><div class="shape s4"></div>
    <div class="panel-label">
      <span>bienvenido</span>
      <h2>Sign in</h2>
    </div>
  </div>
  <div class="form-side">
    <svg class="logo" viewBox="0 0 52 52" fill="none">
      <rect x="8" y="8" width="16" height="16" rx="3" stroke="#E8566A" stroke-width="2"/>
      <rect x="28" y="8" width="16" height="16" rx="3" stroke="#E8566A" stroke-width="2"/>
      <rect x="8" y="28" width="16" height="16" rx="3" stroke="#E8566A" stroke-width="2"/>
      <rect x="28" y="28" width="16" height="16" rx="3" stroke="#E8566A" stroke-width="2" fill="#E8566A" fill-opacity="0.12"/>
    </svg>
    <div class="form-title">Login</div>
    <form>
      <div class="field">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
        <input type="email" placeholder="Email" autocomplete="email" required>
      </div>
      <div class="field">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        <input type="password" placeholder="Password" autocomplete="current-password" required>
      </div>
      <div class="meta">
        <a href="/forgot-password" class="forgot">Forgot password?</a>
      </div>
      <button type="submit" class="btn">LOGIN</button>
    </form>
    <div class="divider">Or login with</div>
    <div class="oauth">
      <button class="oauth-btn" type="button">
        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
        Google
      </button>
      <button class="oauth-btn" type="button">
        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="#1877F2" d="M24 12.073C24 5.405 18.627 0 12 0S0 5.405 0 12.073C0 18.1 4.388 23.094 10.125 24v-8.437H7.078v-3.49h3.047V9.41c0-3.025 1.792-4.697 4.533-4.697 1.312 0 2.686.236 2.686.236v2.97h-1.514c-1.491 0-1.956.93-1.956 1.886v2.267h3.328l-.532 3.49h-2.796V24C19.612 23.094 24 18.1 24 12.073z"/></svg>
        Facebook
      </button>
    </div>
  </div>
</div>
</body>
</html>
```

---

## Paso 4 — Checklist de seguridad

Antes de hacer deploy de cualquier implementación de auth, verificar:

- [ ] Contraseñas hasheadas con bcrypt (cost ≥ 12) — NUNCA MD5 o SHA1
- [ ] Tokens JWT con expiración corta (≤ 7 días access, 30 días refresh)
- [ ] Secrets en variables de entorno, no en código
- [ ] Rate limiting en rutas de login (máx 5 intentos / 15 min)
- [ ] HTTPS obligatorio en producción
- [ ] Cookies con `HttpOnly`, `Secure`, `SameSite=Strict` si aplica
- [ ] CORS configurado correctamente (no `*` en producción)
- [ ] Logs de intentos fallidos sin exponer datos del usuario

## Archivos que crea / modifica esta skill

- Crea: `login.html` o componente de auth según el stack
- Modifica: middleware/guards de rutas existentes
- Crea: `.env.example` con las variables necesarias (sin valores reales)
- Documenta en: `01-Arquitectura.md` del proyecto en el vault
