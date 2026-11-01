// ============================================================================
// MODULO: Cajas.pde
// DESCRIPCION:
//   Funciones de renderizado geometrico en 3D (prismas rectangulares texturizados)
//   utilizadas para construir los muros, pisos, bandas de neon y plataformas
//   de los tres niveles del juego mediante coordenadas UV normalizadas.
// ============================================================================
// Reemplaza box() cuando una cara necesita una imagen como textura.
// La caja queda centrada en el origen y conserva las medidas recibidas.
void cajaTexturada(float ancho, float alto, float fondo, PImage tex) {
  float x = ancho / 2;
  float y = alto / 2;
  float z = fondo / 2;

  beginShape(QUADS);
  texture(tex);

  // Cada grupo de cuatro vertices construye una cara del cubo.
  // frente
  vertex(-x, -y, z, 0, 0);
  vertex( x, -y, z, 1, 0);
  vertex( x, y, z, 1, 1);
  vertex(-x, y, z, 0, 1);

  // atrás
  vertex( x, -y, -z, 0, 0);
  vertex(-x, -y, -z, 1, 0);
  vertex(-x, y, -z, 1, 1);
  vertex( x, y, -z, 0, 1);

  // derecha
  vertex( x, -y, z, 0, 0);
  vertex( x, -y, -z, 1, 0);
  vertex( x, y, -z, 1, 1);
  vertex( x, y, z, 0, 1);

  // izquierda
  vertex(-x, -y, -z, 0, 0);
  vertex(-x, -y, z, 1, 0);
  vertex(-x, y, z, 1, 1);
  vertex(-x, y, -z, 0, 1);

  // arriba
  vertex(-x, -y, -z, 0, 0);
  vertex( x, -y, -z, 1, 0);
  vertex( x, -y, z, 1, 1);
  vertex(-x, -y, z, 0, 1);

  // abajo
  vertex(-x, y, -z, 0, 0);
  vertex( x, y, -z, 1, 0);
  vertex( x, y, z, 1, 1);
  vertex(-x, y, z, 0, 1);

  endShape();
}
