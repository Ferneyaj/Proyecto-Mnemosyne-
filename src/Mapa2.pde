// ============================================================================
// MODULO: Mapa2.pde
// DESCRIPCION:
//   Diseño topologico, fisica de plataformas moviles/colapsables/trampolines,
//   sistema de checkpoints, recoleccion de fragmentos de datos y renderizado
//   del Nivel 2 (servidores centrales sobre el vacio digital).
// ============================================================================
float ultimoX, ultimoZ;


// Define la topologia del segundo nivel mediante plataformas independientes.
// La plataforma 0 es un hub central. Desde ahi salen tres ramas con mecanicas
// distintas y, despues de reunir los fragmentos, se habilita el puente final.
void configurarPlataformasNivel2() {
  plataformaX[0] = 0;
  plataformaZ[0] = 0;
  plataformaAnchoX[0] = 240;
  plataformaAnchoZ[0] = 240;
  plataformaY[0] = height/2;
  esMeta[0] = false;

  // Rama norte: ocho apoyos con movimiento, caidas y un trampolin.
  plataformaX[1] = 0;
  plataformaZ[1] = -360;
  plataformaAnchoX[1] = 130;
  plataformaAnchoZ[1] = 115;
  plataformaY[1] = height/2 - 40;
  esMeta[1] = false;

  plataformaX[2] = 230;
  plataformaZ[2] = -690;
  plataformaAnchoX[2] = 85;
  plataformaAnchoZ[2] = 80;
  plataformaY[2] = height/2 - 130;
  esMeta[2] = false;

  plataformaX[3] = -190;
  plataformaZ[3] = -1010;
  plataformaAnchoX[3] = 80;
  plataformaAnchoZ[3] = 80;
  plataformaY[3] = height/2 - 230;
  esMeta[3] = false;

  plataformaX[4] = 160;
  plataformaZ[4] = -1300;
  plataformaAnchoX[4] = 75;
  plataformaAnchoZ[4] = 75;
  plataformaY[4] = height/2 - 350;
  esMeta[4] = false;

  plataformaX[5] = -220;
  plataformaZ[5] = -1600;
  plataformaAnchoX[5] = 78;
  plataformaAnchoZ[5] = 78;
  plataformaY[5] = height/2 - 470;
  esMeta[5] = false;

  plataformaX[6] = 120;
  plataformaZ[6] = -1880;
  plataformaAnchoX[6] = 75;
  plataformaAnchoZ[6] = 75;
  plataformaY[6] = height/2 - 600;
  esMeta[6] = false;

  plataformaX[7] = -180;
  plataformaZ[7] = -2170;
  plataformaAnchoX[7] = 80;
  plataformaAnchoZ[7] = 80;
  plataformaY[7] = height/2 - 730;
  esMeta[7] = false;

  plataformaX[8] = 80;
  plataformaZ[8] = -2470;
  plataformaAnchoX[8] = 105;
  plataformaAnchoZ[8] = 100;
  plataformaY[8] = height/2 - 860;
  esMeta[8] = false;

  // Rama este: apoyos que caen y plataformas moviles con poca superficie.
  plataformaX[9] = 380;
  plataformaZ[9] = 0;
  plataformaAnchoX[9] = 120;
  plataformaAnchoZ[9] = 115;
  plataformaY[9] = height/2 - 30;
  esMeta[9] = false;

  plataformaX[10] = 760;
  plataformaZ[10] = 240;
  plataformaAnchoX[10] = 82;
  plataformaAnchoZ[10] = 80;
  plataformaY[10] = height/2 - 120;
  esMeta[10] = false;

  plataformaX[11] = 1080;
  plataformaZ[11] = -120;
  plataformaAnchoX[11] = 78;
  plataformaAnchoZ[11] = 78;
  plataformaY[11] = height/2 - 250;
  esMeta[11] = false;

  plataformaX[12] = 1420;
  plataformaZ[12] = 250;
  plataformaAnchoX[12] = 78;
  plataformaAnchoZ[12] = 78;
  plataformaY[12] = height/2 - 380;
  esMeta[12] = false;

  plataformaX[13] = 1760;
  plataformaZ[13] = -120;
  plataformaAnchoX[13] = 78;
  plataformaAnchoZ[13] = 78;
  plataformaY[13] = height/2 - 510;
  esMeta[13] = false;

  plataformaX[14] = 2110;
  plataformaZ[14] = 230;
  plataformaAnchoX[14] = 76;
  plataformaAnchoZ[14] = 76;
  plataformaY[14] = height/2 - 640;
  esMeta[14] = false;

  plataformaX[15] = 2450;
  plataformaZ[15] = -130;
  plataformaAnchoX[15] = 80;
  plataformaAnchoZ[15] = 78;
  plataformaY[15] = height/2 - 770;
  esMeta[15] = false;

  plataformaX[16] = 2810;
  plataformaZ[16] = 180;
  plataformaAnchoX[16] = 105;
  plataformaAnchoZ[16] = 100;
  plataformaY[16] = height/2 - 900;
  esMeta[16] = false;

  // Rama oeste: ocho apoyos de rebote y cambios de altura.
  plataformaX[17] = -380;
  plataformaZ[17] = 50;
  plataformaAnchoX[17] = 120;
  plataformaAnchoZ[17] = 115;
  plataformaY[17] = height/2 - 30;
  esMeta[17] = false;

  plataformaX[18] = -730;
  plataformaZ[18] = -250;
  plataformaAnchoX[18] = 90;
  plataformaAnchoZ[18] = 85;
  plataformaY[18] = height/2 - 150;
  esMeta[18] = false;

  plataformaX[19] = -1060;
  plataformaZ[19] = 80;
  plataformaAnchoX[19] = 76;
  plataformaAnchoZ[19] = 76;
  plataformaY[19] = height/2 - 280;
  esMeta[19] = false;

  plataformaX[20] = -1400;
  plataformaZ[20] = -260;
  plataformaAnchoX[20] = 76;
  plataformaAnchoZ[20] = 76;
  plataformaY[20] = height/2 - 410;
  esMeta[20] = false;

  plataformaX[21] = -1740;
  plataformaZ[21] = 70;
  plataformaAnchoX[21] = 76;
  plataformaAnchoZ[21] = 76;
  plataformaY[21] = height/2 - 540;
  esMeta[21] = false;

  plataformaX[22] = -2080;
  plataformaZ[22] = -260;
  plataformaAnchoX[22] = 76;
  plataformaAnchoZ[22] = 76;
  plataformaY[22] = height/2 - 670;
  esMeta[22] = false;

  plataformaX[23] = -2420;
  plataformaZ[23] = 80;
  plataformaAnchoX[23] = 76;
  plataformaAnchoZ[23] = 76;
  plataformaY[23] = height/2 - 800;
  esMeta[23] = false;

  plataformaX[24] = -2790;
  plataformaZ[24] = -220;
  plataformaAnchoX[24] = 110;
  plataformaAnchoZ[24] = 105;
  plataformaY[24] = height/2 - 930;
  esMeta[24] = false;

  // Puente final: doce plataformas mas hasta la meta dorada.
  plataformaX[25] = 0;
  plataformaZ[25] = 500;
  plataformaAnchoX[25] = 140;
  plataformaAnchoZ[25] = 135;
  plataformaY[25] = height/2 - 100;
  esMeta[25] = false;

  plataformaX[26] = 330;
  plataformaZ[26] = 900;
  plataformaAnchoX[26] = 90;
  plataformaAnchoZ[26] = 85;
  plataformaY[26] = height/2 - 220;
  esMeta[26] = false;

  plataformaX[27] = -220;
  plataformaZ[27] = 1280;
  plataformaAnchoX[27] = 80;
  plataformaAnchoZ[27] = 80;
  plataformaY[27] = height/2 - 350;
  esMeta[27] = false;

  plataformaX[28] = 300;
  plataformaZ[28] = 1660;
  plataformaAnchoX[28] = 80;
  plataformaAnchoZ[28] = 80;
  plataformaY[28] = height/2 - 480;
  esMeta[28] = false;

  plataformaX[29] = -120;
  plataformaZ[29] = 2040;
  plataformaAnchoX[29] = 100;
  plataformaAnchoZ[29] = 95;
  plataformaY[29] = height/2 - 610;
  esMeta[29] = false;

  // La plataforma 30 es la torre lateral de los tiradores. Se conserva
  // fuera de la ruta principal para que el jugador no tenga que pasar encima.
  plataformaX[30] = -120;
  plataformaZ[30] = 2300;
  plataformaAnchoX[30] = 100;
  plataformaAnchoZ[30] = 95;
  plataformaY[30] = height/2 - 740;
  esMeta[30] = false;

  plataformaX[31] = 300;
  plataformaZ[31] = 2800;
  plataformaAnchoX[31] = 80;
  plataformaAnchoZ[31] = 80;
  plataformaY[31] = height/2 - 870;
  esMeta[31] = false;

  plataformaX[32] = 300;
  plataformaZ[32] = 3180;
  plataformaAnchoX[32] = 80;
  plataformaAnchoZ[32] = 80;
  plataformaY[32] = height/2 - 1000;
  esMeta[32] = false;

  plataformaX[33] = -120;
  plataformaZ[33] = 3560;
  plataformaAnchoX[33] = 95;
  plataformaAnchoZ[33] = 90;
  plataformaY[33] = height/2 - 1130;
  esMeta[33] = false;

  plataformaX[34] = 300;
  plataformaZ[34] = 3940;
  plataformaAnchoX[34] = 82;
  plataformaAnchoZ[34] = 80;
  plataformaY[34] = height/2 - 1260;
  esMeta[34] = false;

  plataformaX[35] = -100;
  plataformaZ[35] = 4320;
  plataformaAnchoX[35] = 80;
  plataformaAnchoZ[35] = 80;
  plataformaY[35] = height/2 - 1390;
  esMeta[35] = false;

  plataformaX[36] = 200;
  plataformaZ[36] = 4700;
  plataformaAnchoX[36] = 220;
  plataformaAnchoZ[36] = 210;
  plataformaY[36] = height/2 - 1510;
  esMeta[36] = true;

  // Ruta principal alternativa: misma altura y profundidad que la torre,
  // pero desplazada a la derecha para continuar sin aterrizar sobre ella.
  plataformaX[37] = 300;
  plataformaZ[37] = 2300;
  plataformaAnchoX[37] = 120;
  plataformaAnchoZ[37] = 95;
  plataformaY[37] = height/2 - 740;
  esMeta[37] = false;

  configurarComportamientoPlataformasNivel2();
}


// Define que plataformas se mueven, cuales se desprenden y donde se guarda
// el progreso. Los limites evitan que una plataforma movil salga del camino.
void configurarComportamientoPlataformasNivel2() {
  for (int i = 0; i < NUM_PLATAFORMAS; i++) {
    plataformaTipo[i] = PLATAFORMA_NORMAL;
    plataformaActiva[i] = true;
    plataformaCheckpoint[i] = false;
    plataformaTiempo[i] = -1;
    plataformaVelX[i] = 0;
    plataformaVelZ[i] = 0;
    plataformaMinX[i] = plataformaX[i];
    plataformaMaxX[i] = plataformaX[i];
    plataformaMinZ[i] = plataformaZ[i];
    plataformaMaxZ[i] = plataformaZ[i];
    plataformaFragmento[i] = false;
    fragmentoRecogido[i] = false;
  }

  // El hub es el checkpoint comun a las tres ramas.
  plataformaCheckpoint[0] = true;

  // Cada rama termina en un fragmento y devuelve al jugador al hub.
  plataformaFragmento[8] = true;
  plataformaFragmento[16] = true;
  plataformaFragmento[24] = true;

  // Rama norte: alterna movimiento horizontal, caidas y plataformas estrechas.
  plataformaTipo[2] = PLATAFORMA_MOVIL;
  plataformaVelX[2] = 2.4;
  plataformaMinX[2] = 120;
  plataformaMaxX[2] = 340;
  plataformaTipo[3] = PLATAFORMA_CAE;
  plataformaTipo[4] = PLATAFORMA_MOVIL;
  plataformaVelZ[4] = 2.7;
  plataformaMinZ[4] = -1420;
  plataformaMaxZ[4] = -1170;
  plataformaTipo[5] = PLATAFORMA_CAE;
  plataformaTipo[6] = PLATAFORMA_MOVIL;
  plataformaVelX[6] = -2.6;
  plataformaMinX[6] = 40;
  plataformaMaxX[6] = 240;
  plataformaTipo[7] = PLATAFORMA_CAE;
  plataformaTipo[8] = PLATAFORMA_TRAMPOLIN;

  // Rama este: alterna apoyos que caen y movimientos en ambos ejes.
  plataformaTipo[10] = PLATAFORMA_CAE;
  plataformaTipo[11] = PLATAFORMA_MOVIL;
  plataformaVelZ[11] = 3.0;
  plataformaMinZ[11] = 50;
  plataformaMaxZ[11] = 330;
  plataformaTipo[12] = PLATAFORMA_CAE;
  plataformaTipo[13] = PLATAFORMA_MOVIL;
  plataformaVelX[13] = -2.8;
  plataformaMinX[13] = 1640;
  plataformaMaxX[13] = 1900;
  plataformaTipo[14] = PLATAFORMA_CAE;
  plataformaTipo[15] = PLATAFORMA_MOVIL;
  plataformaVelZ[15] = 2.8;
  plataformaMinZ[15] = -300;
  plataformaMaxZ[15] = 50;
  plataformaTipo[16] = PLATAFORMA_TRAMPOLIN;

  // Rama oeste: el camino exige calcular varios rebotes consecutivos.
  plataformaTipo[18] = PLATAFORMA_TRAMPOLIN;
  plataformaTipo[19] = PLATAFORMA_CAE;
  plataformaTipo[20] = PLATAFORMA_TRAMPOLIN;
  plataformaTipo[21] = PLATAFORMA_CAE;
  plataformaTipo[22] = PLATAFORMA_TRAMPOLIN;
  plataformaTipo[23] = PLATAFORMA_CAE;
  plataformaTipo[24] = PLATAFORMA_TRAMPOLIN;

  // El puente final alterna movilidad, caidas y trampolines.
  plataformaTipo[26] = PLATAFORMA_MOVIL;
  plataformaVelX[26] = -2.8;
  plataformaMinX[26] = 220;
  plataformaMaxX[26] = 440;
  plataformaTipo[27] = PLATAFORMA_CAE;
  plataformaTipo[28] = PLATAFORMA_MOVIL;
  plataformaVelZ[28] = 3.0;
  plataformaMinZ[28] = 1480;
  plataformaMaxZ[28] = 1840;
  // La plataforma 29 ocupa la posicion anterior de los tiradores.
  // La 30 conserva el trampolin y permanece fija como torre de tiradores.
  plataformaTipo[30] = PLATAFORMA_TRAMPOLIN;
  plataformaTipo[31] = PLATAFORMA_MOVIL;
  plataformaVelX[31] = 2.8;
  plataformaMinX[31] = 220;
  plataformaMaxX[31] = 440;
  plataformaTipo[32] = PLATAFORMA_CAE;
  plataformaTipo[33] = PLATAFORMA_TRAMPOLIN;
  plataformaTipo[34] = PLATAFORMA_MOVIL;
  plataformaVelZ[34] = 3.0;
  plataformaMinZ[34] = 3770;
  plataformaMaxZ[34] = 4120;
  plataformaTipo[35] = PLATAFORMA_CAE;
}


// Actualiza plataformas especiales antes del movimiento y la gravedad.
void actualizarPlataformasNivel2() {
  int plataformaJugador = enElSuelo ? plataformaBajo(JugadorX, JugadorZ) : -1;

  for (int i = 0; i < NUM_PLATAFORMAS; i++) {
    if (!plataformaActiva[i]) continue;

    if (plataformaTipo[i] == PLATAFORMA_MOVIL) {
      float anteriorX = plataformaX[i];
      float anteriorZ = plataformaZ[i];

      plataformaX[i] += plataformaVelX[i];
      plataformaZ[i] += plataformaVelZ[i];

      if (plataformaX[i] < plataformaMinX[i] || plataformaX[i] > plataformaMaxX[i]) {
        plataformaX[i] = constrain(plataformaX[i], plataformaMinX[i], plataformaMaxX[i]);
        plataformaVelX[i] *= -1;
      }
      if (plataformaZ[i] < plataformaMinZ[i] || plataformaZ[i] > plataformaMaxZ[i]) {
        plataformaZ[i] = constrain(plataformaZ[i], plataformaMinZ[i], plataformaMaxZ[i]);
        plataformaVelZ[i] *= -1;
      }

      // El jugador conserva el apoyo cuando la plataforma se desplaza.
      if (plataformaJugador == i) {
        JugadorX += plataformaX[i] - anteriorX;
        JugadorZ += plataformaZ[i] - anteriorZ;
      }
    }

    if (plataformaTipo[i] == PLATAFORMA_CAE && plataformaJugador == i && enElSuelo) {
      if (plataformaTiempo[i] < 0) {
        plataformaTiempo[i] = 75;
        mostrarMensaje("Plataforma inestable", 50);
      } else {
        plataformaTiempo[i]--;
      }

      if (plataformaTiempo[i] <= 0) {
        plataformaActiva[i] = false;
        mostrarMensaje("La plataforma cayo", 55);
      }
    }
  }
}


// Aplica el comportamiento especial al tocar una plataforma despues de caer.
void aterrizarNivel2(int indice) {
  if (plataformaCheckpoint[indice] && indice > checkpointNivel2) {
    checkpointNivel2 = indice;
    mostrarMensaje("Checkpoint guardado", 75);
  }

  if (plataformaFragmento[indice] && !fragmentoRecogido[indice]) {
    fragmentoRecogido[indice] = true;
    fragmentosNivel2++;
    mostrarMensaje("Fragmento " + fragmentosNivel2 + "/" + FRAGMENTOS_NECESARIOS, 90);

    if (fragmentosNivel2 >= FRAGMENTOS_NECESARIOS) {
      esMeta[36] = true;
      mostrarMensaje("La meta dorada esta activa", 100);
    }

    volverAlHubNivel2();
    return;
  }

  if (plataformaTipo[indice] == PLATAFORMA_TRAMPOLIN) {
    velocidadY = fuerzaSalto * 1.35;
    enElSuelo = false;
    mostrarMensaje("Trampolin", 45);
  }
}


// Devuelve al jugador al checkpoint central al completar una rama.
void volverAlHubNivel2() {
  JugadorX = plataformaX[0];
  JugadorZ = plataformaZ[0];
  JugadorY = plataformaY[0] - 75;
  velocidadY = 0;
  enElSuelo = true;
  coyoteHasta = 0;
  saltoSolicitadoHasta = 0;
  mostrarMensaje("Regreso al hub central", 70);
}


// Devuelve al ultimo checkpoint disponible en lugar de reiniciar todo el nivel.
void reaparecerNivel2() {
  // Las plataformas que cayeron vuelven a su estado original al reaparecer.
  // Asi una muerte no deja una ruta imposible para el siguiente intento.
  for (int i = 0; i < NUM_PLATAFORMAS; i++) {
    if (plataformaTipo[i] == PLATAFORMA_CAE) {
      plataformaActiva[i] = true;
      plataformaTiempo[i] = -1;
    }
  }

  int indice = constrain(checkpointNivel2, 0, NUM_PLATAFORMAS - 1);

  if (!plataformaActiva[indice]) {
    for (int i = NUM_PLATAFORMAS - 1; i >= 0; i--) {
      if (i <= checkpointNivel2 && plataformaCheckpoint[i] && plataformaActiva[i]) {
        indice = i;
        break;
      }
    }
  }

  JugadorX = plataformaX[indice];
  JugadorZ = plataformaZ[indice];
  JugadorY = plataformaY[indice] - 75;
  velocidadY = 0;
  enElSuelo = true;
  coyoteHasta = 0;
  saltoSolicitadoHasta = 0;
}


// Dibuja las plataformas; la meta dorada permanece bloqueada hasta reunir
// los tres fragmentos de memoria.
void dibujarNivel2() {
  for (int i = 0; i < NUM_PLATAFORMAS; i++) {
    if (!plataformaActiva[i]) continue;

    pushMatrix();
    translate(plataformaX[i], plataformaY[i] + 10, plataformaZ[i]);

    if (esMeta[i] && fragmentosNivel2 < FRAGMENTOS_NECESARIOS) {
      fill(245, 190, 35, 85);
      box(plataformaAnchoX[i]*2, 20, plataformaAnchoZ[i]*2);
    } else if (esMeta[i]) {
      fill(245, 190, 35);
      box(plataformaAnchoX[i]*2, 20, plataformaAnchoZ[i]*2);
    } else if (texturaNivel2 != null) {
      // Evita que el color de la marca anterior tine la textura de la plataforma.
      noTint();
      fill(255);
      cajaTexturada(plataformaAnchoX[i]*2, 20, plataformaAnchoZ[i]*2, texturaNivel2);
    } else {
      fill(0, 150, 130);
      box(plataformaAnchoX[i]*2, 20, plataformaAnchoZ[i]*2);
    }
    popMatrix();

    // Marcas sencillas para leer el comportamiento antes de pisar la plataforma.
    pushMatrix();
    translate(plataformaX[i], plataformaY[i] - 4, plataformaZ[i]);
    if (plataformaTipo[i] == PLATAFORMA_MOVIL) {
      fill(80, 200, 255);
      box(18, 5, 18);
    } else if (plataformaTipo[i] == PLATAFORMA_CAE) {
      fill(255, 105, 70);
      box(plataformaAnchoX[i] * 1.2, 5, 9);
    } else if (plataformaTipo[i] == PLATAFORMA_TRAMPOLIN) {
      fill(80, 240, 150);
      box(plataformaAnchoX[i] * 1.2, 5, 9);
    }
    popMatrix();

    if (plataformaFragmento[i] && !fragmentoRecogido[i]) {
      pushMatrix();
      translate(plataformaX[i], plataformaY[i] - 62
        + sin(frameCount * 0.08) * 8, plataformaZ[i]);
      rotateY(frameCount * 0.04);
      fill(80, 255, 230);
      box(34, 34, 34);
      popMatrix();
    }
  }

  dibujarSombraNivel2();
}


// Sombra circular sobre la plataforma actual para calcular mejor los saltos.
void dibujarSombraNivel2() {
  int indice = plataformaBajo(JugadorX, JugadorZ);
  if (indice < 0) return;

  float altura = abs((JugadorY + 75) - plataformaY[indice]);
  float tamano = constrain(82 - altura * 0.08, 26, 82);

  pushMatrix();
  translate(JugadorX, plataformaY[indice] - 3, JugadorZ);
  rotateX(HALF_PI);
  noStroke();
  fill(0, 95);
  ellipse(0, 0, tamano, tamano);
  popMatrix();
}


// En el nivel 2 el movimiento horizontal es libre y la gravedad decide si cae.
void moverJugadorNivel2() {
  float[] mover = calcularVectorMovimiento();
  JugadorX += mover[0];
  JugadorZ += mover[1];
}

// Una caida descuenta una vida y devuelve al jugador al ultimo checkpoint.
void revisarCaida() {
  if (enElSuelo) { ultimoX = JugadorX; ultimoZ = JugadorZ; }

  if (JugadorY > height/2 + 1400) {
    vidaJugador--;
    reproducir(sonidoHit);
    if (vidaJugador > 0) {
      if (nivelActual == 1) {
        JugadorX = ultimoX;
        JugadorZ = ultimoZ;
        JugadorY = alturaDePiso(JugadorX, JugadorZ) - 75;
        velocidadY = 0;
      } else if (nivelActual == 2) {
        reaparecerNivel2();
      } else {
        reaparecerNivel3();
      }
      mostrarMensaje("Caida: pierdes una vida", 120);
    }
  }
}

// Reinicia las plataformas y reubica al jugador al comenzar el nivel 2.
void iniciarNivel2() {
  configurarPlataformasNivel2();
  checkpointNivel2 = 0;
  fragmentosNivel2 = 0;
  vidaJugador = VIDAS_INICIALES;
  juegoTerminado = false;
  tiempoMuerte = 0;
  sonidoDerrotaReproducido = false;
  nivelCompletado = false;
  pausa = false;
  ultimoGolpeRecibido = -1000;
  invulnerableHasta = 0;
  parryHasta = 0;
  dashActivo = false;
  hitStopHasta = 0;
  tiradoresNivel2Activos = false;
  for (int i = 0; i < NUM_PROYECTILES; i++) proyectilesActivo[i] = false;
  for (int i = 0; i < NUM_ENEMIGOS; i++) enemigosActivo[i] = false;
  configurarEnemigoMundo(0, -165, 2300, 3, 12.5, color(80, 210, 255), TIPO_TIRADOR);
  configurarEnemigoMundo(1, -75, 2300, 3, 12.5, color(80, 210, 255), TIPO_TIRADOR);
  tiradorNivel2ProximoDisparo[0] = 2147483000;
  tiradorNivel2ProximoDisparo[1] = 2147483000;
  reaparecerNivel2();
}

// Los tiradores permanecen dormidos hasta que el jugador inicia el puente.
void revisarActivacionTiradoresNivel2(int indice) {
  if (tiradoresNivel2Activos) return;
  if (fragmentosNivel2 < FRAGMENTOS_NECESARIOS) return;
  if (indice != 25) return;

  tiradoresNivel2Activos = true;
  tiradorNivel2ProximoDisparo[0] = frameCount + 28;
  tiradorNivel2ProximoDisparo[1] = frameCount + 52;
  mostrarMensaje("Los tiradores detectaron movimiento", 90);
}

int plataformaBajo(float x, float z) {
  for (int i = 0; i < NUM_PLATAFORMAS; i++) {
    if (!plataformaActiva[i]) continue;
    if (esMeta[i] && fragmentosNivel2 < FRAGMENTOS_NECESARIOS) continue;
    boolean dentroX = x > plataformaX[i] - plataformaAnchoX[i] && x < plataformaX[i] + plataformaAnchoX[i];
    boolean dentroZ = z > plataformaZ[i] - plataformaAnchoZ[i] && z < plataformaZ[i] + plataformaAnchoZ[i];
    if (dentroX && dentroZ) return i;
  }
  return -1;
}

float alturaPlataformas(float x, float z) {
  int i = plataformaBajo(x, z);
  if (i == -1) return SIN_PISO;
  return plataformaY[i];
}
