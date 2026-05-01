// ============================================================
// REDINCA 2025 — CONFIGURACIÓN GLOBAL
// ============================================================
// ⚠️  ANTES DE PUBLICAR: reemplaza estos valores con los tuyos
//     de https://app.supabase.com → Settings → API
// ============================================================

const SUPABASE_URL = 'https://ysecnphhuessiznsdfof.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzZWNucGhodWVzc2l6bnNkZm9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MTgyOTgsImV4cCI6MjA5MzE5NDI5OH0.nFeRiqEoyALMF0XEiyrxbIN1CgzfXzjfzWNMnSp14Dw';

// EmailJS — https://www.emailjs.com → Account → API Keys
const EMAILJS_SERVICE_ID  = 'service_xq6elgo';
const EMAILJS_TEMPLATE_ID = 'template_sxweb93';
const EMAILJS_PUBLIC_KEY  = 'aasfUi1Av5-qT3E8O';

// WhatsApp — número de la empresa con código de país, sin + ni espacios
const WHATSAPP_NUMBER = '56990500542';

// ============================================================
// SUPABASE CLIENT (carga dinámica sin npm)
// ============================================================
let supabase;

async function initSupabase() {
  if (supabase) return supabase;
  const { createClient } = await import('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm');
  supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return supabase;
}

// ============================================================
// TOAST
// ============================================================
function toast(msg, type = 'info') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }
  const t = document.createElement('div');
  t.className = `toast ${type}`;
  t.textContent = msg;
  container.appendChild(t);
  setTimeout(() => { t.style.opacity = '0'; t.style.transition = 'opacity 0.3s'; setTimeout(() => t.remove(), 300); }, 3500);
}

// ============================================================
// CARRITO (localStorage)
// ============================================================
const Cart = {
  get() {
    try { return JSON.parse(localStorage.getItem('redinca_cart') || '[]'); }
    catch { return []; }
  },
  save(items) { localStorage.setItem('redinca_cart', JSON.stringify(items)); },
  add(product, qty = 1) {
    const items = this.get();
    const existing = items.find(i => i.id === product.id);
    if (existing) { existing.qty += qty; }
    else { items.push({ id: product.id, nombre: product.nombre, precio: product.precio, imagen: product.imagenes?.[0] || '', qty }); }
    this.save(items);
    this.updateBadge();
  },
  remove(id) {
    this.save(this.get().filter(i => i.id !== id));
    this.updateBadge();
  },
  updateQty(id, qty) {
    const items = this.get();
    const item = items.find(i => i.id === id);
    if (item) { item.qty = Math.max(1, qty); this.save(items); }
    this.updateBadge();
  },
  clear() { localStorage.removeItem('redinca_cart'); this.updateBadge(); },
  count() { return this.get().reduce((s, i) => s + i.qty, 0); },
  total() { return this.get().reduce((s, i) => s + (i.precio * i.qty), 0); },
  updateBadge() {
    const badge = document.getElementById('cart-badge');
    if (badge) {
      const c = this.count();
      badge.textContent = c;
      badge.style.display = c > 0 ? 'flex' : 'none';
    }
  }
};

// ============================================================
// FORMAT
// ============================================================
function fmtPrice(n) {
  return new Intl.NumberFormat('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(n);
}
function fmtDate(str) {
  return new Date(str).toLocaleDateString('es-VE', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

// ============================================================
// WHATSAPP ORDER
// ============================================================
function buildWhatsAppMessage(cliente, items, total) {
  const lineas = items.map(i => `  • ${i.nombre} x${i.qty} — Bs. ${fmtPrice(i.precio * i.qty)}`).join('\n');
  const msg = `🔧 *REDINCA 2025 — Nuevo Pedido*\n\n*Cliente:* ${cliente.nombre}\n*Teléfono:* ${cliente.telefono}\n${cliente.nota ? `*Nota:* ${cliente.nota}\n` : ''}\n*Productos:*\n${lineas}\n\n*TOTAL: Bs. ${fmtPrice(total)}*\n\n_Pedido generado desde el portal web_`;
  return encodeURIComponent(msg);
}

function sendWhatsApp(cliente, items, total) {
  const msg = buildWhatsAppMessage(cliente, items, total);
  window.open(`https://wa.me/${WHATSAPP_NUMBER}?text=${msg}`, '_blank');
}

// ============================================================
// EMAILJS ORDER
// ============================================================
async function sendOrderEmail(cliente, items, total, ordenId) {
  if (!window.emailjs) return;
  const lineas = items.map(i => `${i.nombre} x${i.qty} — Bs. ${fmtPrice(i.precio * i.qty)}`).join('\n');
  try {
    await emailjs.send(EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, {
      orden_id:      ordenId,
      cliente_nombre: cliente.nombre,
      cliente_telefono: cliente.telefono,
      cliente_nota:  cliente.nota || '—',
      productos:     lineas,
      total:         `Bs. ${fmtPrice(total)}`,
      fecha:         new Date().toLocaleString('es-VE'),
    });
  } catch(e) { console.warn('EmailJS error:', e); }
}

// ============================================================
// IMAGE UPLOAD (Supabase Storage)
// ============================================================
async function uploadImage(file, bucket = 'productos') {
  const sb = await initSupabase();
  const ext  = file.name.split('.').pop();
  const path = `${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`;
  const { error } = await sb.storage.from(bucket).upload(path, file, { cacheControl: '3600', upsert: false });
  if (error) throw error;
  const { data } = sb.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
}
