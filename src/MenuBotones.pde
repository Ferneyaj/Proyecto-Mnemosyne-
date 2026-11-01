// ============================================================================
// MODULO: MenuBotones.pde
// DESCRIPCION:
//   Componentes visuales reutilizables de la interfaz: botones con borde
//   contorneado, animaciones de seleccion con desplazamiento lateral, destello
//   de confirmacion, indicadores triangulares y reproductor seguro de audio.
// ============================================================================
int tiempoAnim = 0;
int duracionAgrandado = 150;

void reproducir(SoundFile s) {
  if (s != null) {
    try {
      s.play();
    } catch (Exception e) {}
  }
}

void crearboton(String textoboton, float posX, float posY, float tamano) {
  textSize(tamano*escalaY);
  for (j=0; j<12; j++) {
    text(textoboton, (posX+grueso1X[j])*escalaX, (posY+grueso1Y[j])*escalaY);
  }
}

void crearbotongrueso(String textoboton, float posX, float posY, float tamano) {
  textSize(tamano*escalaY);
  for (j=0; j<20; j++) {
    text(textoboton, (posX+grueso2X[j])*escalaX, (posY+grueso2Y[j])*escalaY);
  }
}

void iluminacionboton(int seleccionActual, int numeroboton) {
  if (seleccionActual == numeroboton) {
    float pulso = map(sin(millis() * 0.007), -1, 1, 0, 1);
    color cActivo = lerpColor(color(255), color(185, 190, 200), pulso);
    fill(cActivo);
  } else {
    fill(96, 96, 98);
  }
}

void animacionboton(int seleccionActual, int numeroboton, String textoboton, float posX, float posY, int tamano, color colorborde) {
  int duracionAgrandado = 150;
  boolean activo = (seleccionActual == numeroboton) || (ventanasalir && textoboton.equals("SALIR"));
  if (activo) {
    float agrandado = (ventanasalir && textoboton.equals("SALIR")) ? 1.0 : constrain((millis() - tiempoAnim) / (float)duracionAgrandado, 0, 1);
    agrandado = agrandado * agrandado * (3 - 2 * agrandado);
    textSize((tamano + (agrandado * 12))*escalaY);
  } else {
    textSize(tamano*escalaY);
  }
  fill(colorborde);
  for (j=0; j<12; j++) {
    text(textoboton, (posX+grueso1X[j])*escalaX, (posY+grueso1Y[j])*escalaY);
  }

  if (activo) {
    float pulso = map(sin(millis() * 0.007), -1, 1, 0, 1);
    color cActivo = lerpColor(color(255), color(195, 205, 215), pulso);
    fill(cActivo);
    text(textoboton, posX * escalaX, posY * escalaY);

    // Indicador tecnologico animado (cursor neon a la izquierda)
    float hCursor = tamano * 0.65 * escalaY;
    float wCursor = 5 * escalaX;
    fill(210, 25, 25);
    rect((posX - 20) * escalaX, (posY - hCursor * 0.85) * escalaY, wCursor, hCursor, 2);
  } else {
    fill(96, 96, 98);
    text(textoboton, posX * escalaX, posY * escalaY);
  }
}

void dibujarBarraVolumen(int nivelActual) {
  dibujarBarraVolumenEn(nivelActual, 780, 345, 440, 42);
}

void dibujarBarraVolumenEn(int nivelActual, float xBase, float yBase, float anchoTotal, float altoBloque) {
  volumenVisual = lerp(volumenVisual, (float)nivelActual, 0.22);

  // Marco de fondo estilo terminal cyber en ROJO
  fill(16, 6, 8, 230);
  stroke(225, 25, 35);
  strokeWeight(2.5 * escalaY);
  rect(xBase * escalaX, yBase * escalaY, anchoTotal * escalaX, altoBloque * escalaY, 8);
  noStroke();

  int bloques = 10;
  float sep = 6;
  float wBloque = (anchoTotal - (bloques + 1) * sep) / (float)bloques;

  for (int k = 1; k <= bloques; k++) {
    float bx = xBase + sep + (k - 1) * (wBloque + sep);
    float by = yBase + 5;
    float bh = altoBloque - 10;

    if (volumenVisual >= k - 0.15) {
      float pulso = map(sin(millis() * 0.008 + k * 0.45), -1, 1, 0, 1);
      color colNeon = lerpColor(color(235, 25, 35), color(255, 125, 135), pulso);
      fill(colNeon);
      rect(bx * escalaX, by * escalaY, wBloque * escalaX, bh * escalaY, 4);
    } else if (volumenVisual > k - 1) {
      float frac = volumenVisual - (k - 1);
      fill(225, 25, 35, frac * 230);
      rect(bx * escalaX, by * escalaY, wBloque * frac * escalaX, bh * escalaY, 4);
    } else {
      fill(42, 14, 18);
      rect(bx * escalaX, by * escalaY, wBloque * escalaX, bh * escalaY, 4);
    }
  }

  // Porcentaje numerico centrado en ROJO vivo
  fill(255, 50, 60);
  textAlign(CENTER, CENTER);
  aplicarFuente(fuenteTexto);
  textSize(24 * escalaY);
  int pct = int(constrain(volumenVisual * 10, 0, 100));
  text("[ " + pct + "% ]", (xBase + anchoTotal / 2.0) * escalaX, (yBase + altoBloque + 26) * escalaY);
  aplicarFuente(fuente1);
  textAlign(LEFT, BASELINE);
}

void trianguloBorde(float x1, float y1, float x2, float y2, float x3, float y3, color colorInterior) {
  fill(0);
  for (j=0; j<12; j++) {
    triangle((x1+grueso1X[j])*escalaX, (y1+grueso1Y[j])*escalaY, (x2+grueso1X[j])*escalaX, (y2+grueso1Y[j])*escalaY, (x3+grueso1X[j])*escalaX, (y3+grueso1Y[j])*escalaY);
  }
  fill(colorInterior);
  triangle(x1*escalaX, y1*escalaY, x2*escalaX, y2*escalaY, x3*escalaX, y3*escalaY);
}
