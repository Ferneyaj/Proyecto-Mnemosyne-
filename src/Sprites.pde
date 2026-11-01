// ============================================================================
// MODULO: Sprites.pde
// DESCRIPCION:
//   Gestiona la carga, almacenamiento y maquina de estados de animacion 2.5D
//   (billboarding en espacio P3D) tanto para el protagonista (Detective Walt)
//   como para todas las variantes de enemigos y el jefe final (ARGOS).
//
// ARQUITECTURA DE ANIMACIONES DEL PROTAGONISTA:
//   - ANIM_IDLE    (0): Reposo ("protaSprites/0000.png" .. "0015.png")
//   - ANIM_CAMINAR (1): Desplazamiento base ("protaSprites/0100.png" .. "0115.png")
//   - ANIM_CORRER  (2): Carrera con Shift ("protaSprites/0200.png" .. "0215.png")
//   - ANIM_DASH    (3): Esquiva rapida ("DASH/final_rojo/0300.png" .. "0315.png")
//   - ANIM_ATAQUE  (4): Golpe cuerpo a cuerpo ("HIT/HIT/0400.png" .. "0415.png")
//
// ASIGNACION DE SPRITES DE ENEMIGOS (KAZE CORP):
//   - NORMAL.png    -> Centinela Perseguidor (TIPO_PERSEGUIDOR) y Tirador (TIPO_TIRADOR)
//   - EMBESTIDA.png -> Unidad Pesada de Asalto / Embestidor (TIPO_EMBESTIDOR)
//   - ESCUDO.png    -> Unidad Acorazada con Escudo Frontal (TIPO_TANQUE)
//   - BOSS.png      -> Nucleo Maestro ARGOS (TIPO_JEFE)
// ============================================================================

final int ANIM_IDLE = 0;
final int ANIM_CAMINAR = 1;
final int ANIM_CORRER = 2;
final int ANIM_DASH = 3;
final int ANIM_ATAQUE = 4;

String[] nombresAnim = {"00", "01", "02", "03", "04"};
int[] framesAnim = {16, 16, 16, 16, 16};
PImage[][] spritesProta = new PImage[5][];

// Estado actual del reproductor de animaciones del protagonista
int animActual = ANIM_IDLE;
float frameAnim = 0;
float[] velocidadAnim = {0.20, 0.35, 0.50, 0.95, 0.95}; // Frames avanzados por ciclo de draw()
int animDashHasta = 0;
int animAtaqueHasta = 0;

// Sprites 2.5D de las unidades enemigas de Kaze Corp
PImage spriteEnemigoNormal;
PImage spriteEnemigoEmbestida;
PImage spriteEnemigoEscudo;
PImage spriteEnemigoBoss;

// Carga las secuencias de 16 fotogramas para cada uno de los 5 estados del protagonista.
// Incluye rutas alternativas automaticas para garantizar compatibilidad entre carpetas.
void cargarSpritesProta() {
  for (int a = 0; a < nombresAnim.length; a++) {
    spritesProta[a] = new PImage[framesAnim[a]];
    for (int f = 0; f < framesAnim[a]; f++) {
      String codigoFrame = nombresAnim[a] + nf(f, 2) + ".png";
      PImage img = null;
      if (a == ANIM_DASH) {
        img = loadImage("DASH/final_rojo/" + codigoFrame);
        if (img == null) img = loadImage("protaSprites/" + codigoFrame);
      } else if (a == ANIM_ATAQUE) {
        img = loadImage("HIT/HIT/" + codigoFrame);
        if (img == null) img = loadImage("protaSprites/" + codigoFrame);
      } else {
        img = loadImage("protaSprites/" + codigoFrame);
      }
      spritesProta[a][f] = img;
    }
  }
}

// Carga en memoria las texturas RGBA de los enemigos y del jefe final ARGOS.
void cargarSpritesEnemigos() {
  spriteEnemigoNormal = loadImage("NORMAL.png");
  spriteEnemigoEmbestida = loadImage("EMBESTIDA.png");
  spriteEnemigoEscudo = loadImage("ESCUDO.png");
  spriteEnemigoBoss = loadImage("BOSS.png");
}

// Dispara la animacion completa de esquiva (Dash) desde el fotograma 0.
void iniciarAnimacionDashProta() {
  animActual = ANIM_DASH;
  frameAnim = 0;
  animDashHasta = frameCount + 16;
}

// Dispara la animacion completa de golpe (Hit / Ataque) desde el fotograma 0.
void iniciarAnimacionAtaqueProta() {
  animActual = ANIM_ATAQUE;
  frameAnim = 0;
  animAtaqueHasta = frameCount + 16;
}

// Actualiza la maquina de estados de animacion del jugador dando prioridad a
// las acciones activas (Ataque > Dash > Correr/Caminar > Idle).
void actualizarAnimacionProta() {
  int nueva = ANIM_IDLE;

  if (frameCount < animAtaqueHasta) {
    nueva = ANIM_ATAQUE;
  } else if (dashActivo || frameCount < animDashHasta) {
    nueva = ANIM_DASH;
  } else if (teclas[0] || teclas[1] || teclas[2] || teclas[3]) {
    nueva = corriendo ? ANIM_CORRER : ANIM_CAMINAR;
  }

  if (nueva != animActual) {
    animActual = nueva;
    frameAnim = 0;
  }

  frameAnim = (frameAnim + velocidadAnim[animActual]) % framesAnim[animActual];
}

// Devuelve el fotograma actual que debe renderizarse en el quad 2.5D del jugador.
PImage spriteActualProta() {
  int idx = constrain(int(frameAnim), 0, framesAnim[animActual] - 1);
  if (spritesProta[animActual] != null && spritesProta[animActual][idx] != null) {
    return spritesProta[animActual][idx];
  }
  // Respaldo seguro al primer fotograma de reposo si faltara algun archivo
  if (spritesProta[ANIM_IDLE] != null && spritesProta[ANIM_IDLE][0] != null) {
    return spritesProta[ANIM_IDLE][0];
  }
  return null;
}

// Selecciona el sprite correspondiente segun la clasificacion tactica del enemigo.
PImage spriteDeEnemigo(int tipo) {
  if (tipo == TIPO_JEFE) return spriteEnemigoBoss;
  if (tipo == TIPO_EMBESTIDOR) return spriteEnemigoEmbestida;
  if (tipo == TIPO_TANQUE) return spriteEnemigoEscudo;
  return spriteEnemigoNormal; // TIPO_PERSEGUIDOR y TIPO_TIRADOR
}
