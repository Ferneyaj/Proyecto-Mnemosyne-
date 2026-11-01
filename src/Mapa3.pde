// ============================================================================
// MODULO: Mapa3.pde
// DESCRIPCION:
//   Estructura de zonas progresivas (Salas 1 y 2, Laberinto, Tramo Vertical de
//   Plataformas y Arena Final) y maquina de estados del jefe final ARGOS
//   (Disparo, Embestida, Convocatoria de refuerzos y Ventana Vulnerable).
// ============================================================================
// Nivel 3: recorrido final con dos salas, laberinto, plataformas y una arena
// amplia donde ARGOS alterna entre disparar, embestir y convocar refuerzos.

final int NIVEL3_SALA_1 = 0;
final int NIVEL3_SALA_2 = 1;
final int NIVEL3_LABERINTO = 2;
final int NIVEL3_PLATAFORMAS = 3;
final int NIVEL3_ARENA = 4;

final int PLATAFORMAS_NIVEL3 = 6;
final int JEFE_NIVEL3 = 8;
final int JEFE_DISPARO = 0;
final int JEFE_EMBESTIDA = 1;
final int JEFE_CONVOCATORIA = 2;
final int JEFE_VULNERABLE = 3;

final int JEFE_DURACION_DISPARO = 360;
final int JEFE_DURACION_PREPARACION = 48;
final int JEFE_DURACION_EMBESTIDA = 65;
final int JEFE_DURACION_VULNERABLE = 120;
// Tiempo que ARGOS queda expuesto cuando falla la embestida (180 frames = 3 s a 60 fps).
final int JEFE_DURACION_VULNERABLE_EMBESTIDA = 180;
final int JEFE_DANO_MAXIMO_POR_VENTANA = 4;

int zonaNivel3 = NIVEL3_SALA_1;
int checkpointNivel3 = 0;
int[][] mapaNivel3;

float[] plataforma3X = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3Z = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3AnchoX = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3AnchoZ = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3Y = new float[PLATAFORMAS_NIVEL3];
int[] plataforma3Tipo = new int[PLATAFORMAS_NIVEL3];
boolean[] plataforma3Activa = new boolean[PLATAFORMAS_NIVEL3];
int[] plataforma3Tiempo = new int[PLATAFORMAS_NIVEL3];
float[] plataforma3VelX = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3MinX = new float[PLATAFORMAS_NIVEL3];
float[] plataforma3MaxX = new float[PLATAFORMAS_NIVEL3];

float[] checkpoint3X = {500, 1500, 1500, 1500};
float[] checkpoint3Z = {300, 850, 1550, 2850};
boolean terminalNivel3Usada = false;
boolean jefeNivel3Iniciado = false;
int jefeModoNivel3 = JEFE_DISPARO;
int jefeTiempoNivel3 = 0;
int jefeProximoDisparoNivel3 = 0;
boolean jefeInvocoNivel3 = false;
boolean jefeEmbestidaGolpeoNivel3 = false;
// true = la ventana de vulnerabilidad actual vino de una embestida fallida;
// al terminar, ARGOS convoca refuerzos en vez de volver a disparar.
boolean jefeConvocarTrasVulnerableNivel3 = false;
int jefeVidaMinimaVentanaNivel3 = 0;

// Construye una matriz pequena para el recorrido final. Las zonas abiertas
// y las paredes internas forman dos salas y un laberinto sencillo.
int[][] crearMapaNivel3() {
  int filas = 60;
  int columnas = 40;
  int[][] nuevo = new int[filas][columnas];

  for (int f = 0; f < filas; f++) {
    for (int c = 0; c < columnas; c++) {
      nuevo[f][c] = 0;
      if (f == 0 || c == 0 || f == filas - 1 || c == columnas - 1) {
        nuevo[f][c] = 1;
      }
    }
  }

  // Separacion entre la primera sala, la segunda sala y el laberinto.
  for (int c = 1; c < columnas - 1; c++) {
    if (c < 14 || c > 17) nuevo[7][c] = 1;
    if (c < 10 || c > 21) nuevo[14][c] = 1;
  }

  // Paredes alternadas del laberinto. Cada tramo deja un hueco lateral.
  for (int f = 15; f <= 25; f++) {
    if (f < 19 || f > 21) nuevo[f][7] = 1;
    if (f < 22 || f > 24) nuevo[f][15] = 1;
    if (f < 17 || f > 19) nuevo[f][24] = 1;
  }
  for (int c = 3; c <= 28; c++) {
    if (c < 12 || c > 15) nuevo[18][c] = 1;
    if (c < 20 || c > 23) nuevo[23][c] = 1;
  }

  // Esta franja queda vacia: aqui aparecen las plataformas del nivel 3.
  for (int f = 27; f <= 35; f++) {
    for (int c = 1; c < columnas - 1; c++) nuevo[f][c] = -1;
  }

  return nuevo;
}

void configurarPlataformasNivel3() {
  float base = yBasePared();

  plataforma3X[0] = 1500;
  plataforma3Z[0] = 2850;
  plataforma3AnchoX[0] = 180;
  plataforma3AnchoZ[0] = 150;
  plataforma3Y[0] = base - 20;

  plataforma3X[1] = 1280;
  plataforma3Z[1] = 3200;
  plataforma3AnchoX[1] = 105;
  plataforma3AnchoZ[1] = 95;
  plataforma3Y[1] = base - 130;

  plataforma3X[2] = 1600;
  plataforma3Z[2] = 3500;
  plataforma3AnchoX[2] = 90;
  plataforma3AnchoZ[2] = 85;
  plataforma3Y[2] = base - 250;

  plataforma3X[3] = 1250;
  plataforma3Z[3] = 3800;
  plataforma3AnchoX[3] = 88;
  plataforma3AnchoZ[3] = 82;
  plataforma3Y[3] = base - 360;

  plataforma3X[4] = 1650;
  plataforma3Z[4] = 4100;
  plataforma3AnchoX[4] = 105;
  plataforma3AnchoZ[4] = 95;
  plataforma3Y[4] = base - 470;

  plataforma3X[5] = 1900;
  plataforma3Z[5] = 4320;
  plataforma3AnchoX[5] = 170;
  plataforma3AnchoZ[5] = 135;
  plataforma3Y[5] = base - 520;

  for (int i = 0; i < PLATAFORMAS_NIVEL3; i++) {
    plataforma3Tipo[i] = PLATAFORMA_NORMAL;
    plataforma3Activa[i] = true;
    plataforma3Tiempo[i] = -1;
    plataforma3VelX[i] = 0;
    plataforma3MinX[i] = plataforma3X[i];
    plataforma3MaxX[i] = plataforma3X[i];
  }

  plataforma3Tipo[2] = PLATAFORMA_MOVIL;
  plataforma3VelX[2] = 2.4;
  plataforma3MinX[2] = 1420;
  plataforma3MaxX[2] = 1780;
  plataforma3Tipo[3] = PLATAFORMA_CAE;
  plataforma3Tipo[4] = PLATAFORMA_TRAMPOLIN;
}

void iniciarNivel3() {
  mapaNivel3 = crearMapaNivel3();
  mapa = mapaNivel3;
  configurarPlataformasNivel3();
  zonaNivel3 = NIVEL3_SALA_1;
  checkpointNivel3 = 0;
  terminalNivel3Usada = false;
  jefeNivel3Iniciado = false;
  jefeInvocoNivel3 = false;
  jefeEmbestidaGolpeoNivel3 = false;
  jefeConvocarTrasVulnerableNivel3 = false;
  jefeVidaMinimaVentanaNivel3 = 0;
  nivelCompletado = false;
  vidaJugador = VIDAS_NIVEL3;
  juegoTerminado = false;
  tiempoMuerte = 0;
  tiempoVictoria = 0;
  pausa = false;
  ultimoGolpeRecibido = -1000;
  invulnerableHasta = 0;
  parryHasta = 0;
  dashActivo = false;
  hitStopHasta = 0;

  for (int i = 0; i < NUM_PROYECTILES; i++) proyectilesActivo[i] = false;
  configurarEnemigosNivel3Zona(NIVEL3_SALA_1);
  JugadorX = checkpoint3X[0];
  JugadorZ = checkpoint3Z[0];
  JugadorY = alturaDePisoNivel3(JugadorX, JugadorZ) - 75;
  velocidadY = 0;
  enElSuelo = true;
  mostrarMensaje("Nivel 3: nucleo de ARGOS", 120);
}

void configurarEnemigosNivel3Zona(int zona) {
  for (int i = 0; i < NUM_ENEMIGOS; i++) enemigosActivo[i] = false;
  for (int i = 0; i < NUM_PROYECTILES; i++) proyectilesActivo[i] = false;

  if (zona == NIVEL3_SALA_1) {
    configurarEnemigoMundo(0, 700, 500, 2, 7.0, color(220, 45, 55), TIPO_PERSEGUIDOR);
    configurarEnemigoMundo(1, 2200, 500, 2, 7.5, color(245, 145, 45), TIPO_EMBESTIDOR);
  } else if (zona == NIVEL3_SALA_2) {
    configurarEnemigoMundo(3, 700, 1050, 2, 6.5, color(235, 65, 150), TIPO_PERSEGUIDOR);
    configurarEnemigoMundo(4, 2200, 1150, 3, 6.5, color(180, 70, 220), TIPO_TANQUE);
  } else if (zona == NIVEL3_LABERINTO) {
    // El laberinto queda libre: despues de las dos salas no aparecen enemigos.
  } else if (zona == NIVEL3_ARENA) {
    configurarJefeNivel3();
  }
}

void actualizarNivel3() {
  if (zonaNivel3 == NIVEL3_SALA_1 && JugadorZ > 700) {
    if (enemigosVivos() > 0) {
      JugadorZ = 690;
      mostrarMensaje("Derrota a la sala 1", 35);
    } else {
      avanzarZonaNivel3(NIVEL3_SALA_2, 1, "Sala 2 desbloqueada");
    }
  } else if (zonaNivel3 == NIVEL3_SALA_2 && JugadorZ > 1400) {
    if (enemigosVivos() > 0) {
      JugadorZ = 1390;
      mostrarMensaje("Derrota a la sala 2", 35);
    } else {
      avanzarZonaNivel3(NIVEL3_LABERINTO, 2, "El laberinto esta abierto");
    }
  } else if (zonaNivel3 == NIVEL3_LABERINTO && JugadorZ > 2600) {
    if (enemigosVivos() > 0) {
      JugadorZ = 2590;
      mostrarMensaje("Limpia el laberinto", 35);
    } else {
      avanzarZonaNivel3(NIVEL3_PLATAFORMAS, 3, "Checkpoint: tramo vertical");
    }
  } else if (zonaNivel3 == NIVEL3_PLATAFORMAS) {
    if (dist(JugadorX, JugadorZ, 1900, 4320) < 340 && !terminalNivel3Usada) {
      mostrarMensaje("Q: activar terminal de la arena", 30);
    }
    if (!terminalNivel3Usada && JugadorZ > 4450) {
      JugadorZ = 4440;
      mostrarMensaje("Activa la terminal antes de entrar", 45);
    } else if (terminalNivel3Usada && JugadorZ > 4450) {
      avanzarZonaNivel3(NIVEL3_ARENA, 3, "Arena de ARGOS");
    }
  } else if (jefeNivel3Iniciado
    && (!enemigosActivo[JEFE_NIVEL3] || enemigosVida[JEFE_NIVEL3] <= 0)) {
    enemigosActivo[JEFE_NIVEL3] = false;
    if (!reproduciendoCinematicaNivel3 && !nivelCompletado) {
      iniciarCinematicaNivel3();
    }
  }
}

void avanzarZonaNivel3(int nuevaZona, int nuevoCheckpoint, String aviso) {
  zonaNivel3 = nuevaZona;
  checkpointNivel3 = nuevoCheckpoint;
  if (nuevaZona == NIVEL3_PLATAFORMAS) {
    // El primer apoyo funciona como entrada segura al tramo vertical.
    JugadorX = checkpoint3X[3];
    JugadorZ = checkpoint3Z[3];
    JugadorY = plataforma3Y[0] - 75;
    velocidadY = 0;
    enElSuelo = true;
  }
  if (nuevaZona != NIVEL3_ARENA) configurarEnemigosNivel3Zona(nuevaZona);
  else configurarEnemigosNivel3Zona(NIVEL3_ARENA);
  mostrarMensaje(aviso, 90);
}

boolean cercaTerminalNivel3() {
  return zonaNivel3 == NIVEL3_PLATAFORMAS
    && dist(JugadorX, JugadorZ, 1900, 4320) < 340;
}

void activarTerminalNivel3() {
  if (zonaNivel3 != NIVEL3_PLATAFORMAS) return;
  if (!cercaTerminalNivel3()) {
    mostrarMensaje("Acercate a la terminal de la ultima plataforma", 60);
    return;
  }
  if (terminalNivel3Usada) {
    mostrarMensaje("La terminal de la arena ya esta activa", 60);
    return;
  }
  terminalNivel3Usada = true;
  reproducir(seleccionar);
  mostrarMensaje("Terminal aceptada: arena desbloqueada", 100);
}

void configurarJefeNivel3() {
  configurarEnemigoMundo(JEFE_NIVEL3, 1800, 5050, 24, 4.8,
    color(235, 45, 65), TIPO_JEFE);
  jefeNivel3Iniciado = true;
  jefeModoNivel3 = JEFE_DISPARO;
  jefeTiempoNivel3 = JEFE_DURACION_DISPARO;
  jefeProximoDisparoNivel3 = frameCount + 45;
  jefeInvocoNivel3 = false;
  jefeEmbestidaGolpeoNivel3 = false;
  jefeConvocarTrasVulnerableNivel3 = false;
  jefeVidaMinimaVentanaNivel3 = 0;
}

void actualizarJefeNivel3() {
  if (!jefeNivel3Iniciado || !enemigosActivo[JEFE_NIVEL3]) return;

  if (jefeModoNivel3 == JEFE_DISPARO) {
    enemigosEstado[JEFE_NIVEL3] = ENEMIGO_PERSEGUIR;
    jefeTiempoNivel3--;

    float objetivoX = 1800 + sin(frameCount * 0.010) * 1050;
    float objetivoZ = 5050 + cos(frameCount * 0.010) * 430;
    moverJefeHacia(objetivoX, objetivoZ, 0.45);

    if (frameCount >= jefeProximoDisparoNivel3) {
      dispararProyectil(JEFE_NIVEL3);
      jefeProximoDisparoNivel3 = frameCount + 72;
    }
    if (jefeTiempoNivel3 <= 0) {
      jefeModoNivel3 = JEFE_EMBESTIDA;
      jefeTiempoNivel3 = JEFE_DURACION_PREPARACION;
      cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_PREPARAR, JEFE_DURACION_PREPARACION);
      actualizarDireccionEnemigo(JEFE_NIVEL3);
      mostrarMensaje("ARGOS prepara una embestida", 50);
    }
  } else if (jefeModoNivel3 == JEFE_EMBESTIDA) {
    if (enemigosEstado[JEFE_NIVEL3] == ENEMIGO_PREPARAR) {
      jefeTiempoNivel3--;
      if (jefeTiempoNivel3 <= 0) {
        cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_ATACAR, JEFE_DURACION_EMBESTIDA);
        jefeTiempoNivel3 = JEFE_DURACION_EMBESTIDA;
        jefeEmbestidaGolpeoNivel3 = false;
        actualizarDireccionEnemigo(JEFE_NIVEL3);
      }
    } else {
      boolean pudoAvanzar = avanzarEnemigo(JEFE_NIVEL3,
        enemigosDireccionX[JEFE_NIVEL3] * enemigosVelocidad[JEFE_NIVEL3] * 3.4,
        enemigosDireccionZ[JEFE_NIVEL3] * enemigosVelocidad[JEFE_NIVEL3] * 3.4);
      jefeTiempoNivel3--;

      if (enemigosAtaqueAplicado[JEFE_NIVEL3]
        || !pudoAvanzar || jefeTiempoNivel3 <= 0) {
        jefeEmbestidaGolpeoNivel3 = enemigosAtaqueAplicado[JEFE_NIVEL3];
        if (jefeEmbestidaGolpeoNivel3) {
          jefeModoNivel3 = JEFE_DISPARO;
          jefeTiempoNivel3 = JEFE_DURACION_DISPARO;
          jefeProximoDisparoNivel3 = frameCount + 45;
          cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_PERSEGUIR, 0);
          mostrarMensaje("ARGOS retoma el fuego", 55);
        } else {
          entrarVulnerableTrasEmbestidaNivel3();
        }
      }
    }
  } else if (jefeModoNivel3 == JEFE_CONVOCATORIA) {
    // Durante la convocatoria ARGOS no se mueve, no dispara y no recibe dano.
    enemigosEstado[JEFE_NIVEL3] = ENEMIGO_ATURDIDO;
    if (!enemigosInvocadosVivosNivel3()) {
      jefeModoNivel3 = JEFE_VULNERABLE;
      jefeTiempoNivel3 = JEFE_DURACION_VULNERABLE;
      jefeVidaMinimaVentanaNivel3 = max(0,
        enemigosVida[JEFE_NIVEL3] - JEFE_DANO_MAXIMO_POR_VENTANA);
      cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_RECUPERAR,
        JEFE_DURACION_VULNERABLE);
      mostrarMensaje("ARGOS quedo expuesto", 65);
    }
  } else if (jefeModoNivel3 == JEFE_VULNERABLE) {
    jefeTiempoNivel3--;
    if (enemigosEstado[JEFE_NIVEL3] != ENEMIGO_ATURDIDO) {
      cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_RECUPERAR, jefeTiempoNivel3);
    }
    if (jefeTiempoNivel3 <= 0) {
      if (jefeConvocarTrasVulnerableNivel3) {
        // Embestida fallida: tras la ventana de dano, ARGOS convoca refuerzos.
        jefeConvocarTrasVulnerableNivel3 = false;
        entrarConvocatoriaNivel3();
      } else {
        jefeModoNivel3 = JEFE_DISPARO;
        jefeTiempoNivel3 = JEFE_DURACION_DISPARO;
        jefeProximoDisparoNivel3 = frameCount + 45;
        jefeInvocoNivel3 = false;
        cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_PERSEGUIR, 0);
      }
    }
  }
}

void moverJefeHacia(float objetivoX, float objetivoZ, float factor) {
  float dx = objetivoX - enemigosX[JEFE_NIVEL3];
  float dz = objetivoZ - enemigosZ[JEFE_NIVEL3];
  float distancia = max(0.01, sqrt(dx*dx + dz*dz));
  enemigosDireccionX[JEFE_NIVEL3] = dx / distancia;
  enemigosDireccionZ[JEFE_NIVEL3] = dz / distancia;
  moverEnemigoPorEjes(JEFE_NIVEL3,
    enemigosDireccionX[JEFE_NIVEL3] * enemigosVelocidad[JEFE_NIVEL3] * factor,
    enemigosDireccionZ[JEFE_NIVEL3] * enemigosVelocidad[JEFE_NIVEL3] * factor);
}

void invocarEnemigosNivel3() {
  if (jefeInvocoNivel3) return;
  jefeInvocoNivel3 = true;
  configurarEnemigoMundo(0, 950, 4800, 3, 7.0, color(220, 45, 55), TIPO_PERSEGUIDOR);
  configurarEnemigoMundo(1, 2650, 5050, 2, 7.5, color(245, 145, 45), TIPO_EMBESTIDOR);
  configurarEnemigoMundo(2, 1800, 5550, 2, 6.5, color(180, 70, 220), TIPO_TANQUE);
}

void entrarVulnerableTrasEmbestidaNivel3() {
  jefeModoNivel3 = JEFE_VULNERABLE;
  jefeTiempoNivel3 = JEFE_DURACION_VULNERABLE_EMBESTIDA;
  jefeConvocarTrasVulnerableNivel3 = true;
  jefeVidaMinimaVentanaNivel3 = max(0,
    enemigosVida[JEFE_NIVEL3] - JEFE_DANO_MAXIMO_POR_VENTANA);
  cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_RECUPERAR,
    JEFE_DURACION_VULNERABLE_EMBESTIDA);
  mostrarMensaje("ARGOS fallo la embestida: golpealo", 65);
}

void entrarConvocatoriaNivel3() {
  jefeModoNivel3 = JEFE_CONVOCATORIA;
  jefeTiempoNivel3 = 0;
  jefeEmbestidaGolpeoNivel3 = false;
  jefeInvocoNivel3 = false;
  for (int i = 0; i < NUM_PROYECTILES; i++) proyectilesActivo[i] = false;
  cambiarEstadoEnemigo(JEFE_NIVEL3, ENEMIGO_ATURDIDO, 0);
  invocarEnemigosNivel3();
  mostrarMensaje("ARGOS convoca refuerzos", 70);
}

boolean enemigosInvocadosVivosNivel3() {
  for (int i = 0; i < JEFE_NIVEL3; i++) {
    if (enemigosActivo[i]) return true;
  }
  return false;
}

boolean jefePuedeRecibirDanoNivel3(int indice) {
  if (nivelActual != 3 || indice != JEFE_NIVEL3) return true;
  return jefeModoNivel3 == JEFE_VULNERABLE
    && enemigosVida[indice] > jefeVidaMinimaVentanaNivel3;
}

String nombreModoJefeNivel3() {
  if (jefeModoNivel3 == JEFE_DISPARO) return "DISPARO";
  if (jefeModoNivel3 == JEFE_EMBESTIDA) return "EMBESTIDA";
  if (jefeModoNivel3 == JEFE_CONVOCATORIA) return "CONVOCATORIA";
  return "VULNERABLE";
}

void actualizarPlataformasNivel3() {
  int bajo = enElSuelo ? plataformaBajoNivel3(JugadorX, JugadorZ) : -1;
  for (int i = 0; i < PLATAFORMAS_NIVEL3; i++) {
    if (!plataforma3Activa[i]) continue;
    if (plataforma3Tipo[i] == PLATAFORMA_MOVIL) {
      float anterior = plataforma3X[i];
      plataforma3X[i] += plataforma3VelX[i];
      if (plataforma3X[i] < plataforma3MinX[i] || plataforma3X[i] > plataforma3MaxX[i]) {
        plataforma3X[i] = constrain(plataforma3X[i], plataforma3MinX[i], plataforma3MaxX[i]);
        plataforma3VelX[i] *= -1;
      }
      if (bajo == i) JugadorX += plataforma3X[i] - anterior;
    }
    if (plataforma3Tipo[i] == PLATAFORMA_CAE && bajo == i && enElSuelo) {
      if (plataforma3Tiempo[i] < 0) plataforma3Tiempo[i] = 75;
      else plataforma3Tiempo[i]--;
      if (plataforma3Tiempo[i] <= 0) plataforma3Activa[i] = false;
    }
  }
}

int plataformaBajoNivel3(float x, float z) {
  for (int i = 0; i < PLATAFORMAS_NIVEL3; i++) {
    if (!plataforma3Activa[i]) continue;
    if (x > plataforma3X[i] - plataforma3AnchoX[i]
      && x < plataforma3X[i] + plataforma3AnchoX[i]
      && z > plataforma3Z[i] - plataforma3AnchoZ[i]
      && z < plataforma3Z[i] + plataforma3AnchoZ[i]) return i;
  }
  return -1;
}

float alturaDePisoNivel3(float x, float z) {
  if (zonaNivel3 == NIVEL3_PLATAFORMAS) {
    int i = plataformaBajoNivel3(x, z);
    return i >= 0 ? plataforma3Y[i] : SIN_PISO;
  }
  if (zonaNivel3 == NIVEL3_ARENA) return yBasePared();

  int f = celdaDe(z);
  int c = celdaDe(x);
  if (f < 0 || f >= mapaNivel3.length || c < 0 || c >= mapaNivel3[0].length) return SIN_PISO;
  if (esPiso(mapaNivel3[f][c])) return height/2 - AltoPiso/2;
  return SIN_PISO;
}

boolean puedeMoverseNivel3ConTamano(float x, float y, float z,
  float anchoX, float altoY, float anchoZ) {
  if (zonaNivel3 == NIVEL3_PLATAFORMAS) {
    return x > 250 && x < 2800 && z > 2600 && z < 4550;
  }
  if (zonaNivel3 == NIVEL3_ARENA) {
    return x > 200 && x < 3450 && z > 4450 && z < 5700;
  }

  float[] actor = calcularBordes(x, y, z, anchoX, altoY, anchoZ);
  int fila = celdaDe(z);
  int col = celdaDe(x);
  if (fila < 0 || fila >= mapaNivel3.length || col < 0 || col >= mapaNivel3[0].length) return false;
  if (!esPiso(mapaNivel3[fila][col]) && !esVacio(mapaNivel3[fila][col])) return false;

  int filaIni = constrain(fila - 1, 0, mapaNivel3.length - 1);
  int filaFin = constrain(fila + 1, 0, mapaNivel3.length - 1);
  int colIni = constrain(col - 1, 0, mapaNivel3[0].length - 1);
  int colFin = constrain(col + 1, 0, mapaNivel3[0].length - 1);
  for (int f = filaIni; f <= filaFin; f++) {
    for (int c = colIni; c <= colFin; c++) {
      if (!esPared(mapaNivel3[f][c])) continue;
      float[] pared = calcularBordes(c * TAM_CELDA, centroYpared(), f * TAM_CELDA,
        TAM_CELDA, AltoPared, TAM_CELDA);
      if (actor[0] < pared[1] && actor[1] > pared[0]
        && actor[2] < pared[3] && actor[3] > pared[2]
        && actor[4] < pared[5] && actor[5] > pared[4]) return false;
    }
  }
  return true;
}

void aterrizarNivel3(int indice) {
  if (plataforma3Tipo[indice] == PLATAFORMA_TRAMPOLIN) {
    velocidadY = fuerzaSalto * 1.35;
    enElSuelo = false;
    mostrarMensaje("Trampolin", 45);
  }
}

void reaparecerNivel3() {
  for (int i = 0; i < PLATAFORMAS_NIVEL3; i++) {
    if (plataforma3Tipo[i] == PLATAFORMA_CAE) {
      plataforma3Activa[i] = true;
      plataforma3Tiempo[i] = -1;
    }
  }
  JugadorX = checkpoint3X[checkpointNivel3];
  JugadorZ = checkpoint3Z[checkpointNivel3];
  JugadorY = alturaDePisoNivel3(JugadorX, JugadorZ) - 75;
  velocidadY = 0;
  enElSuelo = true;
  configurarEnemigosNivel3Zona(zonaNivel3);
}

void dibujarNivel3() {
  for (int i = 0; i < PLATAFORMAS_NIVEL3; i++) {
    if (!plataforma3Activa[i]) continue;
    pushMatrix();
    translate(plataforma3X[i], plataforma3Y[i] + 10, plataforma3Z[i]);
    if (texturaNivel2 != null) {
      noTint();
      fill(255);
      cajaTexturada(plataforma3AnchoX[i] * 2, 20, plataforma3AnchoZ[i] * 2, texturaNivel2);
    } else {
      fill(0, 150, 130);
      box(plataforma3AnchoX[i] * 2, 20, plataforma3AnchoZ[i] * 2);
    }
    popMatrix();

    pushMatrix();
    translate(plataforma3X[i], plataforma3Y[i] - 4, plataforma3Z[i]);
    if (plataforma3Tipo[i] == PLATAFORMA_MOVIL) fill(80, 200, 255);
    else if (plataforma3Tipo[i] == PLATAFORMA_CAE) fill(255, 105, 70);
    else if (plataforma3Tipo[i] == PLATAFORMA_TRAMPOLIN) fill(80, 240, 150);
    else fill(0, 0, 0, 0);
    box(plataforma3AnchoX[i] * 1.2, 5, 9);
    popMatrix();
  }

  // Terminal visible antes de la arena.
  pushMatrix();
  translate(1900, plataforma3Y[5] - 120, 4320);
  fill(60, 255, 210);
  box(55, 180, 55);
  fill(255, 230, 90);
  box(25, 70, 8);
  popMatrix();

  // Marca simple de la arena para distinguir la zona final.
  if (zonaNivel3 == NIVEL3_ARENA) {
    pushMatrix();
    translate(1800, yBasePared() - 4, 5050);
    noFill();
    stroke(255, 60, 80);
    strokeWeight(8);
    ellipse(0, 0, 2600, 1250);
    noStroke();
    popMatrix();
  }
}

String nombreZonaNivel3() {
  if (zonaNivel3 == NIVEL3_SALA_1) return "Sala 1";
  if (zonaNivel3 == NIVEL3_SALA_2) return "Sala 2";
  if (zonaNivel3 == NIVEL3_LABERINTO) return "Laberinto";
  if (zonaNivel3 == NIVEL3_PLATAFORMAS) return "Plataformas";
  return "Arena";
}

void dibujarBarraJefeNivel3() {
  float progreso = constrain(enemigosVida[JEFE_NIVEL3]
    / float(max(1, enemigosVidaMax[JEFE_NIVEL3])), 0, 1);
  float ancho = 420 * escalaX;
  float yBarraJefe = 82 * escalaY;
  noStroke();
  fill(35, 15, 25, 230);
  rect(width/2 - ancho/2, yBarraJefe, ancho, 18 * escalaY, 4 * escalaY);
  fill(235, 45, 65);
  rect(width/2 - ancho/2, yBarraJefe, ancho * progreso, 18 * escalaY, 4 * escalaY);
  fill(255);
  aplicarFuente(fuenteTexto);
  textAlign(CENTER, BASELINE);
  textSize(16 * escalaY);
  text("ARGOS [" + enemigosVida[JEFE_NIVEL3] + "/" + enemigosVidaMax[JEFE_NIVEL3] + "] - " + nombreModoJefeNivel3(), width/2, yBarraJefe - 6 * escalaY);
  textAlign(LEFT, BASELINE);
}
