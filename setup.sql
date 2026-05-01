-- ============================================================
-- REDINCA 2025 — Script de configuración Supabase
-- Ejecutar en: https://app.supabase.com → SQL Editor
-- ============================================================

-- ---- TABLA: productos ----
CREATE TABLE IF NOT EXISTS productos (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre      TEXT NOT NULL,
  categoria   TEXT NOT NULL,
  descripcion TEXT,
  precio      NUMERIC(12,2) NOT NULL DEFAULT 0,
  imagenes    TEXT[] DEFAULT '{}',
  activo      BOOLEAN DEFAULT true,
  destacado   BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ---- TABLA: ordenes ----
CREATE TABLE IF NOT EXISTS ordenes (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cliente_nombre   TEXT NOT NULL,
  cliente_telefono TEXT NOT NULL,
  cliente_nota     TEXT,
  productos        JSONB NOT NULL DEFAULT '[]',
  total            NUMERIC(12,2) DEFAULT 0,
  estado           TEXT DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente','confirmado','entregado','cancelado')),
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ---- AUTO updated_at ----
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS productos_updated_at ON productos;
CREATE TRIGGER productos_updated_at
  BEFORE UPDATE ON productos
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS ordenes_updated_at ON ordenes;
CREATE TRIGGER ordenes_updated_at
  BEFORE UPDATE ON ordenes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---- ÍNDICES ----
CREATE INDEX IF NOT EXISTS idx_productos_activo    ON productos(activo);
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);
CREATE INDEX IF NOT EXISTS idx_ordenes_estado      ON ordenes(estado);
CREATE INDEX IF NOT EXISTS idx_ordenes_created     ON ordenes(created_at DESC);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes   ENABLE ROW LEVEL SECURITY;

-- Productos: lectura pública para productos activos
DROP POLICY IF EXISTS "productos_public_read" ON productos;
CREATE POLICY "productos_public_read" ON productos
  FOR SELECT USING (activo = true);

-- Productos: escritura solo para usuarios autenticados (admin)
DROP POLICY IF EXISTS "productos_auth_all" ON productos;
CREATE POLICY "productos_auth_all" ON productos
  FOR ALL USING (auth.role() = 'authenticated');

-- Órdenes: inserción pública (cualquier cliente puede crear)
DROP POLICY IF EXISTS "ordenes_public_insert" ON ordenes;
CREATE POLICY "ordenes_public_insert" ON ordenes
  FOR INSERT WITH CHECK (true);

-- Órdenes: lectura y actualización solo admin
DROP POLICY IF EXISTS "ordenes_auth_select" ON ordenes;
CREATE POLICY "ordenes_auth_select" ON ordenes
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "ordenes_auth_update" ON ordenes;
CREATE POLICY "ordenes_auth_update" ON ordenes
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Admin puede leer TODOS los productos (activos e inactivos)
DROP POLICY IF EXISTS "productos_auth_select_all" ON productos;
CREATE POLICY "productos_auth_select_all" ON productos
  FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================================
-- STORAGE BUCKET para imágenes
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('productos', 'productos', true)
ON CONFLICT (id) DO NOTHING;

-- Política de storage: subida solo autenticados
DROP POLICY IF EXISTS "storage_auth_upload" ON storage.objects;
CREATE POLICY "storage_auth_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'productos' AND auth.role() = 'authenticated'
  );

-- Política de storage: lectura pública
DROP POLICY IF EXISTS "storage_public_read" ON storage.objects;
CREATE POLICY "storage_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'productos');

-- ============================================================
-- DATOS DE EJEMPLO (opcional — borrar en producción)
-- ============================================================
INSERT INTO productos (nombre, categoria, descripcion, precio, activo) VALUES
  ('Filtro de aceite Cummins ISX', 'Filtros', 'Compatible con motores Cummins ISX, ISM, ISL. Referencia LF9009. Capacidad de filtrado: 20 micras.', 85.00, true),
  ('Inyector bomba Bosch VP44', 'Inyección', 'Inyector bomba de alta presión para motores diesel de transporte pesado. Garantía 6 meses.', 480.00, true),
  ('Kit de juntas motor Detroit Series 60', 'Juntas y Sellos', 'Kit completo de juntas para overhaul. Incluye junta de culata, tapas y sellos de cigüeñal.', 320.00, true),
  ('Turbocompresor Holset HX35', 'Turbo', 'Turbocompresor reconstruido para Cummins 6BT 5.9L. Incluye accesorios de montaje.', 950.00, true),
  ('Filtro de combustible CAT', 'Filtros', 'Filtro de combustible primario para motores Caterpillar C7, C9, C15. Ref. 1R-0751.', 65.00, true),
  ('Bomba de agua Mack E7', 'Refrigeración', 'Bomba de agua para motor Mack E7 11L. Caudal 200 L/min. Con empaque incluido.', 290.00, true)
ON CONFLICT DO NOTHING;

-- ============================================================
-- FIN DEL SCRIPT
-- Siguiente paso: ir a Authentication → Users → Add user
-- y crear tu cuenta de administrador
-- ============================================================
