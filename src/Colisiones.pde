// ============================================================================
// MODULO: Colisiones.pde
// DESCRIPCION:
//   Motor de deteccion de colisiones AABB (Axis-Aligned Bounding Box) en 3D y
//   consulta de alturas de superficie para la matriz del Nivel 1, las plataformas
//   suspendidas del Nivel 2 y la infraestructura hibrida del Nivel 3.
// ============================================================================
// Convierte una posicion en pixeles (X o Z) al indice de celda.
// Las celdas estan centradas en indice*TAM_CELDA, por eso se usa round().
int celdaDe(float posicion) {
  return round(posicion / TAM_CELDA);
}

// Calcula los seis limites de una caja: minimo y maximo en X, Z y Y.
// Se usa para comparar al jugador, enemigos y paredes con AABB.
float[] calcularBordes(float centroX, float centroY, float centroZ, float anchoX, float altoY, float anchoZ) {

  float[] bordes = new float[6];
  bordes[0] = centroX - (anchoX/2);
  bordes[1] = centroX + (anchoX/2);
  bordes[2] = centroZ - (anchoZ/2);
  bordes[3] = centroZ + (anchoZ/2);
  bordes[4] = centroY - (altoY/2);
  bordes[5] = centroY + (altoY/2);

  return bordes;
}

// Atajo de colision para el jugador, cuyo tamano es 50 x 150 x 50.
boolean puedeMoverse (float JugX, float JugY, float JugZ) {
  if (nivelActual == 3) {
    return puedeMoverseNivel3ConTamano(JugX, JugY, JugZ, 50, 150, 50);
  }
  return puedeMoverseConTamano(JugX, JugY, JugZ, 50, 150, 50);
}

// Los enemigos usan la misma prueba AABB, pero con sus propias dimensiones.
boolean puedeMoverseEnemigo(float enemigoX, float enemigoY, float enemigoZ) {
  if (nivelActual == 3) {
    return puedeMoverseNivel3ConTamano(enemigoX, enemigoY, enemigoZ,
      ENEMIGO_ANCHO, ENEMIGO_ALTO, ENEMIGO_ANCHO);
  }
  return puedeMoverseConTamano(enemigoX, enemigoY, enemigoZ,
    ENEMIGO_ANCHO, ENEMIGO_ALTO, ENEMIGO_ANCHO);
}

// Revisa que el actor este sobre una celda de piso y que no se cruce con paredes.
// La ventana local mejora el rendimiento porque no recorre la matriz completa.
boolean puedeMoverseConTamano(float centroX, float centroY, float centroZ,
  float anchoX, float altoY, float anchoZ) {

  float [] actorBordes = calcularBordes(centroX, centroY, centroZ,
    anchoX, altoY, anchoZ);

  int filaCentro = celdaDe(centroZ);
  int colCentro = celdaDe(centroX);

  for (int j = 0; j < posicionesTerminales.length; j++) {
    float[] terminalBordes = calcularBordes(posicionesTerminales[j].x* TAM_CELDA, posicionesTerminales[j].y * TAM_CELDA, posicionesTerminales[j].z * TAM_CELDA, 75, 2000, 75);


    if ((actorBordes[0] < terminalBordes[1] && actorBordes[1] > terminalBordes[0])
      && (actorBordes[2] < terminalBordes[3] && actorBordes[3] > terminalBordes[2])
      && (actorBordes[4] < terminalBordes[5] && actorBordes[5] > terminalBordes[4])) {

      return false;
    }
  }

  // El valor 4 representa espacio fuera del escenario, no una celda transitable.
  if (filaCentro < 0 || filaCentro >= mapa.length
    || colCentro < 0 || colCentro >= mapa[0].length
    || !(esPiso(mapa[filaCentro][colCentro]) || esVacio(mapa[filaCentro][colCentro]))) {
    return false;
  }
  // Ventana local de celdas: el mapa completo no se revisa en cada frame.
  int filaIni = constrain(filaCentro - RADIO_COLISION, 0, mapa.length - 1);
  int filaFin = constrain(filaCentro + RADIO_COLISION, 0, mapa.length - 1);
  int colIni = constrain(colCentro - RADIO_COLISION, 0, mapa[0].length - 1);
  int colFin = constrain(colCentro + RADIO_COLISION, 0, mapa[0].length - 1);

  for (int f = filaIni; f <= filaFin; f++) {
    for (int c = colIni; c <= colFin; c++) {
      if (esPared(mapa[f][c])) {

        float[] paredBordes = calcularBordes(c * TAM_CELDA, centroYpared(), f * TAM_CELDA, TAM_CELDA, AltoPared, TAM_CELDA);

        if ((actorBordes[0] < paredBordes[1] && actorBordes[1] > paredBordes[0])
          && (actorBordes[2] < paredBordes[3] && actorBordes[3] > paredBordes[2])
          && (actorBordes[4] < paredBordes[5] && actorBordes[5] > paredBordes[4])) {
          return false;
        }
      }
    }
  }

  return true;
}

// Devuelve la altura de la superficie de la celda bajo los pies del actor.
float alturaDePiso(float JugX, float JugZ) {

  if (nivelActual == 2) return alturaPlataformas(JugX, JugZ);
  if (nivelActual == 3) return alturaDePisoNivel3(JugX, JugZ);

  // acceso directo a la celda bajo los pies, sin recorrer el mapa
  int f = celdaDe(JugZ);
  int c = celdaDe(JugX);

  // fuera del mapa: no hay piso
  if (f < 0 || f >= mapa.length || c < 0 || c >= mapa[0].length) {
    return SIN_PISO;
  }

  if (esPiso(mapa[f][c])) {
    float[] pisoBordes = calcularBordes(c * TAM_CELDA, height/2, f * TAM_CELDA, TAM_CELDA, AltoPiso, TAM_CELDA);
    return pisoBordes[4];
  }

  return SIN_PISO;
}
