// ============================================================================
// MODULO: Enemigos.pde
// DESCRIPCION:
//   Inteligencia artificial, navegacion, disparo de proyectiles, deteccion de
//   dano/parry y renderizado 2.5D (billboarding) de las unidades de Kaze Corp:
//   Perseguidor (NORMAL.png), Tirador (NORMAL.png con tinte cian), Embestidor
//   (EMBESTIDA.png), Tanque con escudo (ESCUDO.png) y Jefe ARGOS (BOSS.png).
// ============================================================================
// Cada enemigo conserva su comportamiento en los arreglos paralelos.
// El estado define si persigue, prepara el ataque, ataca, se recupera o esta aturdido.
void moverEnemigos() {
  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]) continue;
    if (enemigosTipo[i] == TIPO_JEFE) continue;

    aplicarRetrocesoEnemigo(i);
    if (enemigosTimer[i] > 0) enemigosTimer[i]--;

    if (enemigosEstado[i] == ENEMIGO_PERSEGUIR) {
      float distancia = distanciaAlJugador(i);
      perseguirJugador(i);
      float distanciaParaAtacar;
      if (enemigosTipo[i] == TIPO_TIRADOR) {
        distanciaParaAtacar = RANGO_ATAQUE_TIRADOR;
      } else if (enemigosTipo[i] == TIPO_EMBESTIDOR) {
        distanciaParaAtacar = RANGO_DETECCION_EMBESTIDOR;
      } else {
        distanciaParaAtacar = rangoContactoEnemigo;
      }
      if (distancia < distanciaParaAtacar) {
        int duracionPreparacion = enemigosTipo[i] == TIPO_TIRADOR
          ? DURACION_PREPARACION_TIRADOR : DURACION_PREPARACION_MELEE;
        cambiarEstadoEnemigo(i, ENEMIGO_PREPARAR, duracionPreparacion);
      }
    } else if (enemigosEstado[i] == ENEMIGO_PREPARAR) {
      actualizarDireccionEnemigo(i);
      if (enemigosTimer[i] <= 0) {
        int duracionAtaque;
        if (enemigosTipo[i] == TIPO_EMBESTIDOR) {
          duracionAtaque = DURACION_ATAQUE_EMBESTIDOR;
        } else if (enemigosTipo[i] == TIPO_TIRADOR) {
          duracionAtaque = DURACION_ATAQUE_TIRADOR;
        } else {
          duracionAtaque = DURACION_ATAQUE_MELEE;
        }
        cambiarEstadoEnemigo(i, ENEMIGO_ATACAR, duracionAtaque);
        actualizarDireccionEnemigo(i);
      }
    } else if (enemigosEstado[i] == ENEMIGO_ATACAR) {
      if (enemigosTipo[i] == TIPO_EMBESTIDOR) {
        float multiplicadorEmbestida = nivelActual == 3
          ? MULTIPLICADOR_EMBESTIDA_NIVEL3 : MULTIPLICADOR_EMBESTIDA;
        boolean pudoCargar = avanzarEnemigo(i,
          enemigosDireccionX[i] * enemigosVelocidad[i] * multiplicadorEmbestida,
          enemigosDireccionZ[i] * enemigosVelocidad[i] * multiplicadorEmbestida);
        if (!pudoCargar) {
          cambiarEstadoEnemigo(i, ENEMIGO_ATURDIDO, 55);
          mostrarMensaje("Embestida bloqueada", 40);
          sacudirCamara(5, 3);
        }
      } else if (enemigosTipo[i] == TIPO_TIRADOR && !enemigosAtaqueAplicado[i]) {
        dispararProyectil(i);
        enemigosAtaqueAplicado[i] = true;
      } else if (enemigosTipo[i] != TIPO_TIRADOR) {
        // Los enemigos cuerpo a cuerpo avanzan durante ATACAR para que la
        // ventana de preparacion no se convierta en un ataque a distancia.
        actualizarDireccionEnemigo(i);
        float multiplicadorAtaque = nivelActual == 3
          ? MULTIPLICADOR_ATAQUE_NIVEL3 : MULTIPLICADOR_ATAQUE;
        avanzarEnemigo(i,
          enemigosDireccionX[i] * enemigosVelocidad[i] * multiplicadorAtaque,
          enemigosDireccionZ[i] * enemigosVelocidad[i] * multiplicadorAtaque);
      }

      if (enemigosTimer[i] <= 0) {
        int duracionRecuperacion = enemigosTipo[i] == TIPO_TIRADOR
          ? DURACION_RECUPERACION_TIRADOR : DURACION_RECUPERACION_MELEE;
        cambiarEstadoEnemigo(i, ENEMIGO_RECUPERAR, duracionRecuperacion);
      }
    } else if (enemigosEstado[i] == ENEMIGO_RECUPERAR) {
      if (enemigosTimer[i] <= 0) {
        cambiarEstadoEnemigo(i, ENEMIGO_PERSEGUIR, 0);
      }
    } else if (enemigosEstado[i] == ENEMIGO_ATURDIDO) {
      if (enemigosTimer[i] <= 0) {
        cambiarEstadoEnemigo(i, ENEMIGO_RECUPERAR, 24);
      }
    }
  }
}

float distanciaAlJugador(int indice) {
  return dist(enemigosX[indice], enemigosZ[indice], JugadorX, JugadorZ);
}

void perseguirJugador(int indice) {
  float dx = JugadorX - enemigosX[indice];
  float dz = JugadorZ - enemigosZ[indice];
  float distancia = sqrt(dx*dx + dz*dz);
  if (distancia <= 0.01) return;

  actualizarDireccionEnemigo(indice);

  float factorVelocidad = 1.0;
  if (enemigosTipo[indice] == TIPO_TANQUE) factorVelocidad = 0.90;

  // El tirador intenta conservar distancia y se mueve hacia atras si el
  // jugador se acerca demasiado, en lugar de entrar siempre al cuerpo a cuerpo.
  if (enemigosTipo[indice] == TIPO_TIRADOR) {
    factorVelocidad = 0.70;
    if (distancia < 300) {
      moverEnemigoPorEjes(indice,
        -enemigosDireccionX[indice] * enemigosVelocidad[indice] * factorVelocidad,
        -enemigosDireccionZ[indice] * enemigosVelocidad[indice] * factorVelocidad);
      return;
    }
    if (distancia < 480) return;
  }

  moverEnemigoPorEjes(indice,
    enemigosDireccionX[indice] * enemigosVelocidad[indice] * factorVelocidad,
    enemigosDireccionZ[indice] * enemigosVelocidad[indice] * factorVelocidad);
}

// Crea un proyectil rapido que apunta a la posicion actual del jugador.
void dispararProyectil(int indiceEnemigo) {
  for (int i = 0; i < NUM_PROYECTILES; i++) {
    if (proyectilesActivo[i]) continue;

    float dx = JugadorX - enemigosX[indiceEnemigo];
    float dz = JugadorZ - enemigosZ[indiceEnemigo];
    float pisoProyectil = yBasePared();
    if (nivelActual == 2) {
      pisoProyectil = alturaPlataformas(enemigosX[indiceEnemigo], enemigosZ[indiceEnemigo]);
    } else if (nivelActual == 3) {
      pisoProyectil = alturaDePisoNivel3(enemigosX[indiceEnemigo], enemigosZ[indiceEnemigo]);
    }
    float origenY = pisoProyectil == SIN_PISO
      ? yBasePared() - 75
      : pisoProyectil - ((nivelActual == 2 || nivelActual == 3) ? ENEMIGO_ALTO/2 : 75);
    float dy = (nivelActual == 2 || nivelActual == 3) ? JugadorY - origenY : 0;
    float distancia = max(0.01, sqrt(dx*dx + dy*dy + dz*dz));

    proyectilesX[i] = enemigosX[indiceEnemigo];
    proyectilesZ[i] = enemigosZ[indiceEnemigo];
    proyectilesY[i] = origenY;
    proyectilesDireccionX[i] = dx / distancia;
    proyectilesDireccionZ[i] = dz / distancia;
    proyectilesDireccionY[i] = dy / distancia;
    proyectilesHasta[i] = frameCount + 180;
    proyectilesActivo[i] = true;
    reproducir(sonidoDisparo);
    break;
  }
}

// Mueve los proyectiles y los elimina al tocar una pared o salir del mapa.
void moverProyectiles() {
  for (int i = 0; i < NUM_PROYECTILES; i++) {
    if (!proyectilesActivo[i]) continue;

    proyectilesX[i] += proyectilesDireccionX[i] * VELOCIDAD_PROYECTIL;
    proyectilesZ[i] += proyectilesDireccionZ[i] * VELOCIDAD_PROYECTIL;
    proyectilesY[i] += proyectilesDireccionY[i] * VELOCIDAD_PROYECTIL;

    boolean fueraDelNivel = false;
    if (nivelActual == 1) {
      int fila = celdaDe(proyectilesZ[i]);
      int col = celdaDe(proyectilesX[i]);
      fueraDelNivel = fila < 0 || fila >= mapa.length
        || col < 0 || col >= mapa[0].length
        || esPared(mapa[fila][col]);
    } else {
      fueraDelNivel = abs(proyectilesX[i]) > 3500
        || abs(proyectilesZ[i]) > 5300;
    }

    if (frameCount >= proyectilesHasta[i] || fueraDelNivel) {
      proyectilesActivo[i] = false;
    }
  }
}

// Revisa el impacto sin quitarle al jugador las opciones de esquiva o parry.
void revisarDanioPorProyectiles() {
  for (int i = 0; i < NUM_PROYECTILES; i++) {
    if (!proyectilesActivo[i]) continue;

    float distancia = dist(proyectilesX[i], proyectilesY[i], proyectilesZ[i],
      JugadorX, JugadorY, JugadorZ);
    if (distancia > 60) continue;

    proyectilesActivo[i] = false;
    if (frameCount < invulnerableHasta) continue;

    if ((nivelActual == 1 || nivelActual == 3) && frameCount <= parryHasta) {
      memoriaActual = min(MEMORIA_MAX, memoriaActual + 14);
      parryHasta = 0;
      hitStopHasta = max(hitStopHasta, frameCount + 4);
      mostrarMensaje("Parry de proyectil", 50);
      reproducir(sonidoParry);
      continue;
    }

    if (frameCount - ultimoGolpeRecibido > cooldownDanioJugador) {
      vidaJugador--;
      ultimoGolpeRecibido = frameCount;
      mostrarMensaje("Impacto a distancia", 75);
      sacudirCamara(7, 4);
    }
  }
}

// Dibuja las amenazas a distancia como esferas rojas pequenas y visibles.
void dibujarProyectiles() {
  for (int i = 0; i < NUM_PROYECTILES; i++) {
    if (!proyectilesActivo[i]) continue;

    pushMatrix();
    translate(proyectilesX[i], proyectilesY[i], proyectilesZ[i]);
    fill(255, 70, 80);
    sphere(RADIO_PROYECTIL);
    popMatrix();
  }
}

// En el nivel 2 los tiradores permanecen en una plataforma elevada y
// obligan a leer la trayectoria para moverse entre los apoyos.
void actualizarTiradoresNivel2() {
  if (!tiradoresNivel2Activos) return;

  for (int i = 0; i < 2; i++) {
    if (!enemigosActivo[i]) continue;
    if (frameCount >= tiradorNivel2ProximoDisparo[i]) {
      dispararProyectil(i);
      tiradorNivel2ProximoDisparo[i] = frameCount + CADENCIA_TIRADORES_NIVEL2;
    }
  }
}

void actualizarDireccionEnemigo(int indice) {
  float dx = JugadorX - enemigosX[indice];
  float dz = JugadorZ - enemigosZ[indice];
  float distancia = sqrt(dx*dx + dz*dz);
  if (distancia <= 0.01) return;
  float direccionObjetivo = atan2(dx, dz);
  float direccionActual = atan2(enemigosDireccionX[indice], enemigosDireccionZ[indice]);

  if (enemigosTipo[indice] == TIPO_TANQUE) {
    float diferencia = atan2(sin(direccionObjetivo - direccionActual),
      cos(direccionObjetivo - direccionActual));
    direccionActual += constrain(diferencia,
      -VELOCIDAD_GIRO_TANQUE, VELOCIDAD_GIRO_TANQUE);
  } else {
    direccionActual = direccionObjetivo;
  }

  enemigosDireccionX[indice] = sin(direccionActual);
  enemigosDireccionZ[indice] = cos(direccionActual);
}

// El movimiento normal puede deslizarse por una pared; la embestida detecta el choque.
boolean moverEnemigoPorEjes(int indice, float pasoX, float pasoZ) {
  boolean pudoMoverse = true;
  float enemigoY = alturaBaseEnemigo(indice) - ENEMIGO_ALTO/2;

  if (abs(pasoX) > 0.01) {
    if (puedeMoverseEnemigo(enemigosX[indice] + pasoX, enemigoY, enemigosZ[indice])) {
      enemigosX[indice] += pasoX;
    } else {
      pudoMoverse = false;
    }
  }

  if (abs(pasoZ) > 0.01) {
    if (puedeMoverseEnemigo(enemigosX[indice], enemigoY, enemigosZ[indice] + pasoZ)) {
      enemigosZ[indice] += pasoZ;
    } else {
      pudoMoverse = false;
    }
  }

  return pudoMoverse;
}

boolean avanzarEnemigo(int indice, float pasoX, float pasoZ) {
  return moverEnemigoPorEjes(indice, pasoX, pasoZ);
}

void aplicarRetrocesoEnemigo(int indice) {
  if (abs(enemigosRetrocesoX[indice]) < 0.1
    && abs(enemigosRetrocesoZ[indice]) < 0.1) return;

  moverEnemigoPorEjes(indice, enemigosRetrocesoX[indice], enemigosRetrocesoZ[indice]);
  enemigosRetrocesoX[indice] *= 0.72;
  enemigosRetrocesoZ[indice] *= 0.72;
}

void cambiarEstadoEnemigo(int indice, int nuevoEstado, int duracion) {
  enemigosEstado[indice] = nuevoEstado;
  enemigosTimer[indice] = duracion;
  enemigosAtaqueAplicado[indice] = false;
}

// Renderiza cada unidad enemiga en 2.5D (billboard orientado a la camara) usando
// su sprite correspondiente (NORMAL, EMBESTIDA, ESCUDO, BOSS) y conserva las
// senales visuales de combate (destello de impacto, aviso de ataque y aturdimiento).
void dibujarEnemigos() {
  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]) continue;

    pushMatrix();
    translate(enemigosX[i], alturaBaseEnemigo(i) - ENEMIGO_ALTO/2, enemigosZ[i]);

    PImage sprite = spriteDeEnemigo(enemigosTipo[i]);
    if (sprite != null && sprite.width > 0) {
      float altoSprite = 185;
      if (enemigosTipo[i] == TIPO_JEFE) {
        altoSprite = 310;
      } else if (enemigosTipo[i] == TIPO_EMBESTIDOR || enemigosTipo[i] == TIPO_TANQUE) {
        altoSprite = 205;
      }
      if (enemigosEstado[i] == ENEMIGO_PREPARAR) {
        altoSprite *= 1.12;
      }
      float anchoSprite = altoSprite * (sprite.width / (float) sprite.height);

      pushMatrix();
      // Orienta el plano del sprite hacia la camara del jugador (billboarding 2.5D)
      rotateY(anguloCamara);
      translate(0, ENEMIGO_ALTO/2, 0); // Ancla la base del sprite al nivel del suelo
      rotateX(-pitchCamara);
      noLights();
      noStroke();

      // Retroalimentacion cromatica segun el estado de combate del enemigo
      if (frameCount < enemigosParpadeoHasta[i]) {
        tint(255, 130, 130); // Destello rojizo-blanco al recibir dano
      } else if (enemigosEstado[i] == ENEMIGO_PREPARAR) {
        tint(255, 255, 255); // Aviso brillante antes de atacar (ventana de parry/castigo)
      } else if (enemigosEstado[i] == ENEMIGO_ATURDIDO
        || (enemigosTipo[i] == TIPO_JEFE && nivelActual == 3 && jefeModoNivel3 == JEFE_VULNERABLE)) {
        tint(255, 225, 85);  // Tinte dorado: enemigo aturdido o ARGOS expuesto
      } else if (enemigosTipo[i] == TIPO_TIRADOR) {
        tint(175, 235, 255); // Tinte cian para distinguir a los tiradores a distancia
      } else {
        noTint();
      }

      beginShape(QUADS);
      texture(sprite);
      vertex(-anchoSprite/2, -altoSprite, 0, 0, 0);
      vertex( anchoSprite/2, -altoSprite, 0, 1, 0);
      vertex( anchoSprite/2,  0,          0, 1, 1);
      vertex(-anchoSprite/2,  0,          0, 0, 1);
      endShape();
      noTint();
      popMatrix();
    } else {
      // Respaldo geometrico en caso de que no exista la imagen
      if (frameCount < enemigosParpadeoHasta[i]) {
        fill(255);
      } else if (enemigosEstado[i] == ENEMIGO_PREPARAR) {
        fill(255, 255, 255);
        scale(1.12);
      } else if (enemigosEstado[i] == ENEMIGO_ATURDIDO) {
        fill(255, 220, 70);
      } else {
        fill(enemigosColor[i]);
      }
      box(ENEMIGO_ANCHO, ENEMIGO_ALTO, ENEMIGO_ANCHO);
    }

    // Franja amarilla 3D en la espalda del tanque: indica el flanco vulnerable sin escudo
    if (enemigosTipo[i] == TIPO_TANQUE) {
      pushMatrix();
      rotateY(atan2(-enemigosDireccionX[i], -enemigosDireccionZ[i]));
      translate(0, 0, ENEMIGO_ANCHO/2 + 8);
      fill(255, 235, 80, 210);
      box(ENEMIGO_ANCHO * 0.55, ENEMIGO_ALTO * 0.35, 8);
      popMatrix();
    }
    popMatrix();
  }
}

// El enemigo solo hace dano durante su estado ATACAR.
// Esquiva e invulnerabilidad se revisan antes del contacto.
void revisarDanioAJugador() {
  if (frameCount < invulnerableHasta) return;

  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]
      || enemigosEstado[i] != ENEMIGO_ATACAR
      || enemigosAtaqueAplicado[i]) continue;

    float distancia = distanciaAlJugador(i);
    if (distancia > rangoContactoEnemigo) continue;

    // Un ataque cuerpo a cuerpo solo alcanza si el jugador esta apoyado y
    // comparte la altura del enemigo; saltar deja de ser dano inevitable.
    if (!enElSuelo) continue;
    float centroYEnemigo = alturaBaseEnemigo(i) - ENEMIGO_ALTO/2;
    if (abs(JugadorY - centroYEnemigo) > 125) continue;

    if (frameCount <= parryHasta && distancia <= rangoParry) {
      enemigosAtaqueAplicado[i] = true;
      recibirGolpeEnemigo(i, 1, 75);
      memoriaActual = min(MEMORIA_MAX, memoriaActual + 18);
      parryHasta = 0;
      hitStopHasta = max(hitStopHasta, frameCount + 6);
      sacudirCamara(9, 5);
      mostrarMensaje("Parry perfecto", 55);
      reproducir(sonidoParry);
      continue;
    }

    if (frameCount - ultimoGolpeRecibido > cooldownDanioJugador) {
      vidaJugador--;
      ultimoGolpeRecibido = frameCount;
      enemigosAtaqueAplicado[i] = true;
      mostrarMensaje("Pierdes una vida", 90);
      sacudirCamara(8, 5);
    }
  }
}


// Cuenta enemigos activos para mostrar progreso y validar la salida del nivel 1.
int enemigosVivos() {
  int vivos = 0;
  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (enemigosActivo[i]) vivos++;
  }
  return vivos;
}

// Inicializa una posicion de los arreglos paralelos de enemigos.
// col y fila son coordenadas de la matriz, por eso se convierten a pixeles.
void configurarEnemigo(int indice, int col, int fila, int vida, float rapidez, color colorEnemigo) {
  configurarEnemigo(indice, col, fila, vida, rapidez, colorEnemigo, TIPO_PERSEGUIDOR);
}

void configurarEnemigo(int indice, int col, int fila, int vida, float rapidez,
  color colorEnemigo, int tipo) {
  configurarEnemigoMundo(indice, col * TAM_CELDA, fila * TAM_CELDA,
    vida, rapidez, colorEnemigo, tipo);
}

// Variante para ubicar amenazas directamente sobre las plataformas del nivel 2.
void configurarEnemigoMundo(int indice, float posicionX, float posicionZ,
  int vida, float rapidez, color colorEnemigo, int tipo) {
  enemigosX[indice] = posicionX;
  enemigosZ[indice] = posicionZ;
  enemigosVidaMax[indice] = vida;
  enemigosVida[indice] = vida;
  enemigosVelocidad[indice] = rapidez;
  enemigosColor[indice] = colorEnemigo;
  enemigosTipo[indice] = tipo;
  enemigosDireccionX[indice] = 0;
  enemigosDireccionZ[indice] = -1;
  enemigosRetrocesoX[indice] = 0;
  enemigosRetrocesoZ[indice] = 0;
  enemigosParpadeoHasta[indice] = 0;
  enemigosActivo[indice] = true;
  cambiarEstadoEnemigo(indice, ENEMIGO_PERSEGUIR, 0);
}

float alturaBaseEnemigo(int indice) {
  if (nivelActual == 2) {
    float piso = alturaPlataformas(enemigosX[indice], enemigosZ[indice]);
    if (piso != SIN_PISO) return piso;
  }
  if (nivelActual == 3) {
    float piso = alturaDePisoNivel3(enemigosX[indice], enemigosZ[indice]);
    if (piso != SIN_PISO) return piso;
  }
  return yBasePared();
}
