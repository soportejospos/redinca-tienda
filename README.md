# REDINCA 2025 — Guía de instalación

## Archivos del proyecto

```
redinca/
├── index.html       → Portal del cliente (catálogo + carrito)
├── admin.html       → Panel de administración
├── css/style.css    → Estilos compartidos
├── js/config.js     → Configuración y utilidades
├── setup.sql        → Script de base de datos
└── README.md        → Esta guía
```

---

## PASO 1 — Configurar Supabase (base de datos)

1. Ir a https://supabase.com → **Start for free**
2. Crear un nuevo proyecto (nombre: `redinca2025`, elige región `South America`)
3. Esperar ~2 minutos a que se inicialice
4. Ir a **SQL Editor** → pegar el contenido de `setup.sql` → clic en **Run**
5. Ir a **Settings → API** y copiar:
   - `Project URL` → es tu `SUPABASE_URL`
   - `anon / public key` → es tu `SUPABASE_ANON_KEY`

### Crear cuenta de administrador
1. Ir a **Authentication → Users → Add user**
2. Ingresar tu email y una contraseña segura
3. Esa cuenta es la que usarás en `admin.html`

---

## PASO 2 — Configurar EmailJS (emails de pedidos)

1. Ir a https://www.emailjs.com → crear cuenta gratis
2. **Email Services** → Add New Service → elegí Gmail o tu proveedor → conectar tu correo
3. **Email Templates** → Create New Template

Pegar este template en el editor:

```
Asunto: 🔧 Nuevo pedido REDINCA — {{cliente_nombre}}

Orden: #{{orden_id}}
Fecha: {{fecha}}

CLIENTE
-------
Nombre:    {{cliente_nombre}}
Teléfono:  {{cliente_telefono}}
Nota:      {{cliente_nota}}

PRODUCTOS
---------
{{productos}}

TOTAL: {{total}}
```

4. En **Account → General** copiar tu **Public Key**
5. Anotar el **Service ID** y el **Template ID**

---

## PASO 3 — Editar js/config.js

Abrir el archivo `js/config.js` y reemplazar los valores:

```javascript
const SUPABASE_URL      = 'https://XXXXXXXX.supabase.co';   // del Paso 1
const SUPABASE_ANON_KEY = 'eyJhbGc...';                      // del Paso 1

const EMAILJS_SERVICE_ID  = 'service_XXXXXX';  // del Paso 2
const EMAILJS_TEMPLATE_ID = 'template_XXXXXX'; // del Paso 2
const EMAILJS_PUBLIC_KEY  = 'XXXXXXXXXX';      // del Paso 2

const WHATSAPP_NUMBER = '584121234567'; // tu número CON código de país, sin + ni espacios
```

---

## PASO 4 — Publicar en GitHub Pages

1. Ir a https://github.com → crear cuenta gratis si no tenés
2. Crear un repositorio nuevo → nombre: `redinca-tienda` → **Public**
3. Subir todos los archivos del proyecto (arrastrar al repositorio o usar GitHub Desktop)
4. Ir a **Settings → Pages**
5. En "Source" elegir: **main branch, / (root)**
6. Clic en **Save**
7. En ~2 minutos tu tienda estará en:
   - `https://TUUSUARIO.github.io/redinca-tienda/` → portal cliente
   - `https://TUUSUARIO.github.io/redinca-tienda/admin.html` → panel admin

### Dominio propio (opcional)
Si querés un dominio como `www.redinca2025.com`:
1. Comprar dominio en Namecheap (~$10/año)
2. En GitHub Pages → Custom domain → ingresar tu dominio
3. En Namecheap → DNS → agregar los registros que te indica GitHub

---

## RESUMEN DE FUNCIONALIDADES

### Portal del cliente (index.html)
- ✅ Catálogo con fotos, nombre, categoría, precio
- ✅ Filtro por categoría y búsqueda por nombre
- ✅ Ordenamiento por precio y nombre
- ✅ Vista detallada del producto con galería de fotos
- ✅ Carrito persistente (se mantiene si cierra el navegador)
- ✅ Formulario de pedido con nombre, teléfono y nota
- ✅ Envío por **email + WhatsApp** simultáneamente

### Panel de administración (admin.html)
- ✅ Login seguro con email y contraseña (Supabase Auth)
- ✅ Dashboard con estadísticas en tiempo real
- ✅ Crear, editar y eliminar productos
- ✅ Subida de hasta 4 fotos por producto
- ✅ Activar/desactivar productos sin borrarlos
- ✅ Gestión de órdenes con estados: pendiente → confirmado → entregado
- ✅ Botón de WhatsApp directo al cliente desde cada orden
- ✅ Filtro de órdenes por estado

---

## COSTOS

| Servicio     | Plan gratis incluye              |
|--------------|----------------------------------|
| GitHub Pages | Hosting ilimitado                |
| Supabase     | 500MB DB · 1GB storage · 50k rows |
| EmailJS      | 200 emails/mes                   |
| WhatsApp     | Sin límites (link directo)       |
| **TOTAL**    | **$0/mes**                       |

---

## SOPORTE

Si necesitás ayuda con algún paso, consultá la documentación de cada servicio:
- Supabase: https://supabase.com/docs
- EmailJS: https://www.emailjs.com/docs
- GitHub Pages: https://docs.github.com/pages
