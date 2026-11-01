// ============================================================================
// MODULO: Jugador.pde
// DESCRIPCION:
//   Controla la locomocion 3D del Detective Walt (movimiento relativo a camara,
//   colisiones separadas por ejes, gravedad, coyote time y jump buffer), las
//   habilidades de combate (Ataque normal, Pulso de Memoria, Esquiva/Dash con
//   invulnerabilidad y Parry) y el renderizado 2.5D con indicador de alcance.
// ============================================================================
// Calcula el vector de movimiento usando la orientacion actual de la camara.
// El resultado se comparte entre los dos niveles para mantener los mismos controles.
float[] calcularVectorMovimiento() {
  float dirX = -sin(anguloCamara);
  float dirZ = -cos(anguloCamara);
  float rightX = cos(anguloCamara);
  float rightZ = -sin(anguloCamara);

  float moveX = 0;
  float moveZ = 0;

  if (teclas[0]) {
    moveX += dirX;
    moveZ += dirZ;
  }
  if (teclas[1]) {
    moveX -= dirX;
    moveZ -= dirZ;
  }
  if (teclas[3]) {
    moveX += rightX;
    moveZ += rightZ;
  }
  if (teclas[2]) {
    moveX -= rightX;
    moveZ -= rightZ;
  }

  // Normalizar evita que moverse en diagonal sea mas rapido que moverse recto.
  float magnitud = sqrt(moveX*moveX + moveZ*moveZ);
  if (magnitud > 0) {
    moveX = moveX / magnitud * velocidad;
    moveZ = moveZ / magnitud * velocidad;
  }

  return new float[]{moveX, moveZ};
}

// Mueve al jugador por cada eje y valida cada posicion propuesta con AABB.
void moverJugador() {
  float[] mover = calcularVectorMovimiento();
  float moveX = mover[0];
  float moveZ = mover[1];

  if (dashActivo && frameCount < dashHasta) {
    moverConColision(dashDireccionX * velocidadDash, dashDireccionZ * velocidadDash);
    return;
  }
  dashActivo = false;

  if (abs(moveX) > 0.01 || abs(moveZ) > 0.01) {
    float magnitud = sqrt(moveX*moveX + moveZ*moveZ);
    direccionJugadorX = moveX / magnitud;
    direccionJugadorZ = moveZ / magnitud;
  }

  moverConColision(moveX, moveZ);
}

// Separa el movimiento por ejes para que el jugador pueda deslizarse junto a una pared.
void moverConColision(float moveX, float moveZ) {
  // Primero se mueve en X y se revisa el choque contra paredes y bordes.
  if (moveX != 0) {
    xPropuesta = JugadorX + moveX;

    if (puedeMoverse(xPropuesta, JugadorY, JugadorZ)) {
      JugadorX = xPropuesta;
    }
  }

  // Luego se mueve en Z usando la posicion X ya validada.
  if (moveZ != 0) {
    zPropuesta = JugadorZ + moveZ;

    if (puedeMoverse(JugadorX, JugadorY, zPropuesta)) {
      JugadorZ = zPropuesta;
    }
  }
}

// Aplica gravedad en el nivel 1 y aterriza sobre el piso de la celda actual.
void aplicarGravedad() {
  boolean estabaEnElSuelo = enElSuelo;
  velocidadY += gravedad;
  float nuevaY = JugadorY + velocidadY;
  float piso = alturaDePiso(JugadorX, JugadorZ) - 75;

  if (velocidadY >= 0 && JugadorY <= piso && nuevaY >= piso) {
    JugadorY = piso;
    velocidadY = 0;
    enElSuelo = true;
    coyoteHasta = frameCount + DURACION_COYOTE;
    if (saltoSolicitadoHasta >= frameCount) ejecutarSalto();
  } else {
    JugadorY = nuevaY;
    if (estabaEnElSuelo) coyoteHasta = frameCount + DURACION_COYOTE;
    enElSuelo = false;
  }
}

// Permite saltar durante unos frames despues de abandonar el borde y
// recuerda un salto pulsado justo antes de aterrizar.
void saltar() {
  if (enElSuelo || frameCount <= coyoteHasta) ejecutarSalto();
  else saltoSolicitadoHasta = frameCount + DURACION_BUFFER_SALTO;
}

// Centraliza el impulso para que el salto normal, el coyote time y el buffer
// usen exactamente la misma fuerza.
void ejecutarSalto() {
  reproducir(sonidoSalto);
  velocidadY = fuerzaSalto;
  enElSuelo = false;
  coyoteHasta = 0;
  saltoSolicitadoHasta = 0;
}

// Activa una esquiva corta que tambien protege al jugador del dano de contacto.
void esquivar() {
  if (juegoTerminado || (nivelActual != 1 && nivelActual != 3)) return;
  if (frameCount - ultimoDash < cooldownDash) {
    if (frameCount - ultimoDash < cooldownDash) mostrarMensaje("Esquiva recargando", 35);
    return;
  }

  float[] mover = calcularVectorMovimiento();
  float magnitud = sqrt(mover[0]*mover[0] + mover[1]*mover[1]);

  if (magnitud > 0.01) {
    dashDireccionX = mover[0] / magnitud;
    dashDireccionZ = mover[1] / magnitud;
  } else {
    dashDireccionX = direccionJugadorX;
    dashDireccionZ = direccionJugadorZ;
  }

  ultimoDash = frameCount;
  dashHasta = frameCount + duracionDash;
  invulnerableHasta = frameCount + duracionDash + 2;
  dashActivo = true;
  iniciarAnimacionDashProta();
  reproducir(sonidoDash);
  memoriaActual = min(MEMORIA_MAX, memoriaActual + 5);
  sacudirCamara(4, 2.5);
  mostrarMensaje("Esquiva", 25);
}

// Abre una ventana corta para bloquear el ataque de un enemigo y dejarlo aturdido.
void activarParry() {
  if (juegoTerminado || (nivelActual != 1 && nivelActual != 3)) return;
  if (frameCount - ultimoParry < cooldownParry) {
    if (frameCount - ultimoParry < cooldownParry) mostrarMensaje("Parry recargando", 35);
    return;
  }

  ultimoParry = frameCount;
  parryHasta = frameCount + duracionParry;
  reproducir(sonidoParry);
  mostrarMensaje("Parry listo", 25);
}

// Dibuja al jugador con sus sprites animados 2.5D y muestra temporalmente el rango del ataque.
float Alto_Sprite_Prota = 170;
void dibujarJugador() {
  if (!pausa && !minijuegoActivo && !juegoTerminado && frameCount >= hitStopHasta) actualizarAnimacionProta();

  pushMatrix();
  translate(JugadorX, JugadorY, JugadorZ);
  rotateY(anguloCamara);

  // --- sprite ---
  PImage s = spriteActualProta();
  if (s != null) {
    float alto = Alto_Sprite_Prota = 170;
    float ancho = alto * s.width / (float) s.height;

    pushMatrix();
    translate(0, 75, 0);          // el origen pasa a los pies
    rotateX(-pitchCamara);        // se inclina para encarar la camara
    noLights();
    noStroke();
    if (frameCount < invulnerableHasta) tint(255, 245, 150);
    else noTint();
    beginShape(QUADS);
    texture(s);
    vertex(-ancho/2, -alto, 0, 0, 0);
    vertex( ancho/2, -alto, 0, 1, 0);
    vertex( ancho/2,  0,    0, 1, 1);
    vertex(-ancho/2,  0,    0, 0, 1);
    endShape();
    noTint();
    popMatrix();
  } else {
    if (frameCount < invulnerableHasta) {
      fill(255, 245, 150);
    } else {
      fill(65, 205, 255);
    }
    box(50, 150, 50);
  }

  if ((nivelActual == 1 || nivelActual == 3) && frameCount < ataqueVisibleHasta) {
    pushMatrix();
    // Se dibuja desde el frente del jugador hasta el alcance real (-rangoAtaque)
    translate(0, 20, -rangoAtaque * 0.50);
    fill(255, 215, 70, 48);
    stroke(255, 220, 75, 235);
    strokeWeight(4);
    box(rangoAtaque * 1.10, 16, rangoAtaque);
    popMatrix();
    noStroke();
  }

  if ((nivelActual == 1 || nivelActual == 3) && frameCount < ataqueEspecialVisibleHasta) {
    pushMatrix();
    translate(0, 20, -rangoAtaqueEspecial * 0.45);
    fill(80, 255, 220, 45);
    stroke(80, 255, 220, 240);
    strokeWeight(6);
    box(rangoAtaqueEspecial * 1.50, 22, rangoAtaqueEspecial * 1.15);
    popMatrix();
    noStroke();
  }
  popMatrix();
}

// Ataca solamente a los enemigos que estan delante del jugador y respeta el cooldown.
void atacar() {
  if (juegoTerminado || (nivelActual != 1 && nivelActual != 3)) return;

  int golpeados = 0;

  if (frameCount - ultimoAtaqueJugador < cooldownAtaque) {
    mostrarMensaje("Ataque recargando", 45);
    return;
  }

  ultimoAtaqueJugador = frameCount;
  ataqueVisibleHasta = frameCount + 8;
  iniciarAnimacionAtaqueProta();
  reproducir(sonidoHit);

  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]) continue;

    float dx = enemigosX[i] - JugadorX;
    float dz = enemigosZ[i] - JugadorZ;
    float distancia = sqrt(dx*dx + dz*dz);

    if (distancia < rangoAtaque && enemigoEstaEnFrente(i, 0.62)) {
      if (enemigosTipo[i] == TIPO_JEFE && !jefePuedeRecibirDanoNivel3(i)) {
        mostrarMensaje("ARGOS no esta expuesto", 35);
        continue;
      }
      if (!enemigoEstaEnVentanaGolpe(i)) {
        mostrarMensaje("Espera la recuperacion", 35);
        continue;
      }
      if (enemigoTieneEscudoFrontal(i)) {
        mostrarMensaje("Escudo frontal", 35);
        continue;
      }
      golpeados++;
      recibirGolpeEnemigo(i, 1, 45);
    }
  }

  if (golpeados == 0) {
    mostrarMensaje("Golpeaste el aire", 45);
  } else {
    mostrarMensaje("Impacto", 30);
  }
}



// Permite castigar solo el inicio del aviso enemigo. Despues de esos frames
// el golpe vuelve a estar bloqueado hasta la recuperacion o el aturdimiento.
boolean enemigoEstaEnVentanaGolpe(int indice) {
  if (enemigosEstado[indice] == ENEMIGO_RECUPERAR
    || enemigosEstado[indice] == ENEMIGO_ATURDIDO) return true;
  if (enemigosEstado[indice] != ENEMIGO_PREPARAR) return false;

  int duracionPreparacion;
  int tiempoRestante;
  if (enemigosTipo[indice] == TIPO_JEFE) {
    duracionPreparacion = JEFE_DURACION_PREPARACION;
    tiempoRestante = jefeTiempoNivel3;
  } else {
    duracionPreparacion = enemigosTipo[indice] == TIPO_TIRADOR
      ? DURACION_PREPARACION_TIRADOR : DURACION_PREPARACION_MELEE;
    tiempoRestante = enemigosTimer[indice];
  }

  int tiempoTranscurrido = duracionPreparacion - tiempoRestante;
  return tiempoTranscurrido >= 0
    && tiempoTranscurrido < VENTANA_GOLPE_PREPARACION;
}

// Consume la barra de Memoria en un ataque mas amplio y poderoso.
void ataqueEspecial() {
  if (juegoTerminado || (nivelActual != 1 && nivelActual != 3)) return;

  if (memoriaActual < MEMORIA_MAX) {
    mostrarMensaje("Memoria insuficiente", 35);
    return;
  }
  if (frameCount - ultimoAtaqueEspecial < cooldownAtaqueEspecial) {
    mostrarMensaje("Especial recargando", 35);
    return;
  }

  memoriaActual = 0;
  ultimoAtaqueEspecial = frameCount;
  iniciarAnimacionAtaqueProta();
  reproducir(sonidoUlti);
  ataqueEspecialVisibleHasta = frameCount + 12;
  int golpeados = 0;

  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]) continue;

    float dx = enemigosX[i] - JugadorX;
    float dz = enemigosZ[i] - JugadorZ;
    float distancia = sqrt(dx*dx + dz*dz);

    if (distancia < rangoAtaqueEspecial && enemigoEstaEnFrente(i, 0.20)
      && !enemigoTieneEscudoFrontal(i)) {
      golpeados++;
      recibirGolpeEnemigo(i, 2, 65);
    }
  }

  hitStopHasta = max(hitStopHasta, frameCount + 5);
  sacudirCamara(10, 6);
  mostrarMensaje(golpeados > 0 ? "Pulso de Memoria" : "Pulso fallido", 45);
}

// El producto punto indica si el enemigo esta dentro del cono frontal.
boolean enemigoEstaEnFrente(int indice, float limiteProducto) {
  float dx = enemigosX[indice] - JugadorX;
  float dz = enemigosZ[indice] - JugadorZ;
  float distancia = sqrt(dx*dx + dz*dz);
  if (distancia <= 0.01) return true;

  float objetivoX = dx / distancia;
  float objetivoZ = dz / distancia;
  float frenteX = -sin(anguloCamara);
  float frenteZ = -cos(anguloCamara);
  float productoPunto = frenteX * objetivoX + frenteZ * objetivoZ;
  return productoPunto >= limiteProducto;
}

boolean enemigoTieneEscudoFrontal(int indice) {
  if (enemigosTipo[indice] != TIPO_TANQUE) return false;

  float dx = JugadorX - enemigosX[indice];
  float dz = JugadorZ - enemigosZ[indice];
  float distancia = sqrt(dx*dx + dz*dz);
  if (distancia <= 0.01) return false;

  float atacanteX = dx / distancia;
  float atacanteZ = dz / distancia;
  float productoPunto = enemigosDireccionX[indice] * atacanteX
    + enemigosDireccionZ[indice] * atacanteZ;
  // El escudo cubre el frente, pero deja expuestos los laterales para que
  // el tanque no sea imposible de golpear si queda cerca de una pared.
  return productoPunto > 0.45;
}

// Aplica dano, retroceso, aturdimiento y feedback a un enemigo golpeado.
void recibirGolpeEnemigo(int indice, int dano, int duracionAturdido) {
  if (!jefePuedeRecibirDanoNivel3(indice)) {
    mostrarMensaje("ARGOS no esta expuesto", 35);
    return;
  }

  int danoAplicado = dano;
  if (nivelActual == 3 && indice == JEFE_NIVEL3) {
    danoAplicado = min(dano,
      enemigosVida[indice] - jefeVidaMinimaVentanaNivel3);
    if (danoAplicado <= 0) return;
  }
  enemigosVida[indice] -= danoAplicado;
  enemigosParpadeoHasta[indice] = frameCount + 8;

  float dx = enemigosX[indice] - JugadorX;
  float dz = enemigosZ[indice] - JugadorZ;
  float distancia = max(0.01, sqrt(dx*dx + dz*dz));
  enemigosRetrocesoX[indice] = dx / distancia * 20;
  enemigosRetrocesoZ[indice] = dz / distancia * 20;
  cambiarEstadoEnemigo(indice, ENEMIGO_ATURDIDO, duracionAturdido);

  memoriaActual = min(MEMORIA_MAX, memoriaActual + 12);
  hitStopHasta = max(hitStopHasta, frameCount + 4);
  sacudirCamara(7, 4);

  if (enemigosVida[indice] <= 0) {
    enemigosActivo[indice] = false;
    mostrarMensaje("Enemigo derrotado", 60);
    if (nivelActual == 3 && (indice == JEFE_NIVEL3 || enemigosTipo[indice] == TIPO_JEFE)) {
      if (!reproduciendoCinematicaNivel3 && !nivelCompletado) {
        iniciarCinematicaNivel3();
      }
    }
  } else {
    mostrarMensaje("Impacto", 30);
  }
}
