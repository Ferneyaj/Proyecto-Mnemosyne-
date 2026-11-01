// ============================================================================
// MODULO: GamepadControl.pde
// DESCRIPCION:
//   Integracion con Game Control Plus para soporte de mandos (gamepads).
//   Sincroniza sticks analogicos, cruceta (D-Pad) y botones de accion con los
//   arreglos de entrada del teclado sin generar conflictos de estado.
// ============================================================================
// ====================================================================================
// GamepadControl.pde - Sistema de Mando Sencillo y Personalizable
// ====================================================================================

// ====================================================================================
// 1. NOMBRES DE LOS BOTONES (Xbox / PlayStation)
// ====================================================================================
// CÃ¡mbialos o Ãºsalos por su nombre directamente:
final int BTN_A_X           = 0;  // BotÃ³n 'A' (Xbox)  /  'X' (PlayStation)
final int BTN_B_CIRCULO     = 1;  // BotÃ³n 'B' (Xbox)  /  'CÃ­rculo' (PlayStation)
final int BTN_X_CUADRADO    = 2;  // BotÃ³n 'X' (Xbox)  /  'Cuadrado' (PlayStation)
final int BTN_Y_TRIANGULO   = 3;  // BotÃ³n 'Y' (Xbox)  /  'TriÃ¡ngulo' (PlayStation)
final int BTN_LB_L1         = 4;  // BotÃ³n superior izquierdo 'LB' / 'L1'
final int BTN_RB_R1         = 5;  // BotÃ³n superior derecho   'RB' / 'R1'
final int BTN_SELECT        = 6;  // 'Select' / 'Back' / 'Share'
final int BTN_START         = 7;  // 'Start'  / 'Options' / 'Menu'

// ====================================================================================
// 2. EJES DE LAS PALANCAS Y GATILLOS
// ====================================================================================
final int EJE_CAMINAR_Y     = 0;  // Palanca Izquierda: Arriba / Abajo
final int EJE_CAMINAR_X     = 1;  // Palanca Izquierda: Izquierda / Derecha
final int EJE_CAMARA_X      = 3;  // Palanca Derecha: Girar CÃ¡mara
final int EJE_GATILLO_RT    = 4;  // Gatillo RT (Xbox) / R2 (PlayStation)

// --- Variables internas ---
ControlIO controlIO;
ControlDevice mando;
boolean mandoConectado = false;

// Estado del teclado (para no interferir entre teclado y mando)
boolean[] teclasTeclado = new boolean[4]; // 0=W, 1=S, 2=A, 3=D
boolean corriendoTeclado = false;

// Memoria para detectar cuando se presiona un botÃ³n una sola vez
boolean[] botonPrev = new boolean[32];
boolean stickPrevArr, stickPrevAbj, stickPrevIzq, stickPrevDer;

// ====================================================================================
// 3. AQUI ANADES Y EDITAS TUS CONTROLES FACILMENTE
// ====================================================================================
void leerControlesMando() {
  if (!mandoConectado || mando == null) return;
  if (cargandoInicio || cargandoNivel) return;

  try {
    if (reproduciendoCinematica) {
      if (boton(BTN_A_X) || boton(BTN_START) || boton(BTN_X_CUADRADO)) {
        saltarCinematica();
      }
      return;
    }
    // ------------------------------------------------------------
    // ACCIONES DENTRO DEL JUEGO (Niveles)
    // ------------------------------------------------------------
    if (PantallaDeJuego == 1) {

      // 1. BotÃ³n A / X -> Saltar
      if (boton(BTN_A_X)) {
        saltar();
      }

      // 2. BotÃ³n X / Cuadrado -> Atacar
      if (boton(BTN_X_CUADRADO)) {
        atacar();
      }

      // LB / L1 -> Esquiva con invulnerabilidad breve.
      if (boton(BTN_LB_L1)) {
        esquivar();
      }

      // RB / R1 -> Ventana de parry.
      if (boton(BTN_RB_R1)) {
        activarParry();
      }

      // Y / Triangulo -> Ataque especial de Memoria.
      if (boton(BTN_Y_TRIANGULO)) {
        ataqueEspecial();
      }

      // 3. BotÃ³n Start -> Pausar / Reanudar el juego
      if (boton(BTN_START)) {
        pausa = !pausa;
        botonpausa = 0;
        volumenPausa = false;
        if (pausa) {
          tiempoInicioPausa = millis();
          tiempoAnim = millis();
        } else {
          tiempoInicioPausa = -10000;
        }
      }

      // Si el juego estÃ¡ en pausa, el mando controla el menÃº de pausa
      if (pausa) {
        if (volumenPausa) {
          float moveX = palanca(EJE_CAMINAR_X);
          if (moveX < -0.5 && !stickPrevIzq) {
            botonvolumen--;
            if (botonvolumen < 0) botonvolumen = 0;
            volumenjuego = ((float)botonvolumen / 10);
            Sound.volume(volumenjuego);
            reproducir(navegar);
            stickPrevIzq = true;
          } else if (moveX >= -0.3) {
            stickPrevIzq = false;
          }

          if (moveX > 0.5 && !stickPrevDer) {
            botonvolumen++;
            if (botonvolumen > 10) botonvolumen = 10;
            volumenjuego = ((float)botonvolumen / 10);
            Sound.volume(volumenjuego);
            reproducir(navegar);
            stickPrevDer = true;
          } else if (moveX <= 0.3) {
            stickPrevDer = false;
          }

          if (boton(BTN_B_CIRCULO)) {
            volumenPausa = false;
          }
          return;
        }

        float moveY = palanca(EJE_CAMINAR_Y);
        if (moveY < -0.5 && !stickPrevArr) {
          botonpausa--;
          if (botonpausa < 0) botonpausa = 3;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevArr = true;
        } else if (moveY >= -0.3) {
          stickPrevArr = false;
        }

        if (moveY > 0.5 && !stickPrevAbj) {
          botonpausa++;
          if (botonpausa > 3) botonpausa = 0;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevAbj = true;
        } else if (moveY <= 0.3) {
          stickPrevAbj = false;
        }

        if (boton(BTN_A_X)) {
          if (botonpausa == 0) {
            reproducir(no);
            pausa = false; // Reanudar
            tiempoInicioPausa = -10000;
          }
          if (botonpausa == 1) {
            reproducir(seleccionar); // Sonido
            volumenPausa = true;
            tiempoInicioSubOpcion = millis();
          }
          if (botonpausa == 2) {
            reproducir(seleccionar); // Controles
          }
          if (botonpausa == 3) {
            reproducir(salir);
            PantallaDeJuego = 0; // Regresa al menÃº principal
            pantalla = pantallamenu;
            escogernivel = false;
            pausa = false;
            volumenPausa = false;
            tiempoInicioPausa = -10000;
            botonselleccionmenu = 0;
            if (Audioprueba != null && !Audioprueba.isPlaying()) {
              Audioprueba.loop();
            }
          }
        }
        if (boton(BTN_B_CIRCULO)) {
          pausa = false;
          tiempoInicioPausa = -10000;
        }
        return; // Detiene el procesamiento para que el jugador no camine mientras estÃ¡ en pausa
      }

      // Si el jugador perdio, el mando controla los botones de derrota
      if (juegoTerminado && (millis() - tiempoMuerte >= 3600)) {
        float moveX = palanca(EJE_CAMINAR_X);
        if (moveX < -0.5 && !stickPrevIzq) {
          botonderrota--;
          if (botonderrota < 0) botonderrota = 1;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevIzq = true;
        } else if (moveX >= -0.3) {
          stickPrevIzq = false;
        }

        if (moveX > 0.5 && !stickPrevDer) {
          botonderrota++;
          if (botonderrota > 1) botonderrota = 0;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevDer = true;
        } else if (moveX <= 0.3) {
          stickPrevDer = false;
        }

        if (boton(BTN_A_X)) {
          if (botonderrota == 0) {
            reproducir(seleccionar);
            iniciarCargaNivel(nivelActual);
          }
          if (botonderrota == 1) {
            reproducir(salir);
            PantallaDeJuego = 0;
            pantalla = pantallamenu;
            juegoTerminado = false;
            tiempoMuerte = 0;
            sonidoDerrotaReproducido = false;
            botonselleccionmenu = 0;
            botonderrota = 0;
            pausa = false;
            if (Audioprueba != null && !Audioprueba.isPlaying()) {
              Audioprueba.loop();
            }
          }
        }
        return;
      }

      // Si el jugador ganÃ³, el mando controla los botones de victoria
      if (nivelCompletado && (millis() - tiempoVictoria >= 3600)) {
        float moveX = palanca(EJE_CAMINAR_X);
        if (moveX < -0.5 && !stickPrevIzq) {
          botonvictoria--;
          if (botonvictoria < 0) botonvictoria = 1;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevIzq = true;
        } else if (moveX >= -0.3) {
          stickPrevIzq = false;
        }

        if (moveX > 0.5 && !stickPrevDer) {
          botonvictoria++;
          if (botonvictoria > 1) botonvictoria = 0;
          tiempoAnim = millis();
          reproducir(navegar);
          stickPrevDer = true;
        } else if (moveX <= 0.3) {
          stickPrevDer = false;
        }

        if (boton(BTN_A_X)) {
          if (botonvictoria == 0) {
            reproducir(seleccionar);
            if (nivelActual == 1) {
              iniciarCargaNivel(2);
            } else {
              iniciarCargaNivel(1);
            }
          }
          if (botonvictoria == 1) {
            reproducir(salir);
            PantallaDeJuego = 0;
            pantalla = pantallamenu;
            nivelCompletado = false;
            tiempoVictoria = 0;
            sonidoVictoriaReproducido = false;
            botonselleccionmenu = 0;
            botonvictoria = 0;
            pausa = false;
            if (Audioprueba != null && !Audioprueba.isPlaying()) {
              Audioprueba.loop();
            }
          }
        }
        return;
      }

      // 4. Gatillo RT / R2 -> Correr
      if (gatillo(EJE_GATILLO_RT)) {
        corriendo = true;
        velocidad = velocidadCarrera;
      } else if (!corriendoTeclado) {
        corriendo = false;
        velocidad = velocidadBase;
      }

      // 5. Palanca Derecha -> Girar la CÃ¡mara
      anguloCamara -= palanca(EJE_CAMARA_X) * 0.04;

      // 6. Palanca Izquierda -> Caminar
      float moveY = palanca(EJE_CAMINAR_Y);
      float moveX = palanca(EJE_CAMINAR_X);

      // Si mueves la palanca, controla el personaje
      if (abs(moveY) > 0.1 || abs(moveX) > 0.1) {
        teclas[0] = moveY < -0.3; // W (Adelante)
        teclas[1] = moveY >  0.3; // S (AtrÃ¡s)
        teclas[2] = moveX < -0.3; // A (Izquierda)
        teclas[3] = moveX >  0.3; // D (Derecha)
      } else {
        // Si no tocas la palanca, manda el teclado
        teclas[0] = teclasTeclado[0];
        teclas[1] = teclasTeclado[1];
        teclas[2] = teclasTeclado[2];
        teclas[3] = teclasTeclado[3];
      }
    }

    // ------------------------------------------------------------
    // ACCIONES EN LOS MENÃšS
    // ------------------------------------------------------------
    if (PantallaDeJuego == 0) {
      float menuY = palanca(EJE_CAMINAR_Y);
      float menuX = palanca(EJE_CAMINAR_X);

      // Moverse en los menÃºs con la palanca izquierda
      if (stickPulsadoArriba(menuY))    simularTeclaMenu(UP, CODED);
      if (stickPulsadoAbajo(menuY))     simularTeclaMenu(DOWN, CODED);
      if (stickPulsadoIzquierda(menuX)) simularTeclaMenu(LEFT, CODED);
      if (stickPulsadoDerecha(menuX))   simularTeclaMenu(RIGHT, CODED);

      // BotÃ³n A / X -> Aceptar (Enter)
      if (boton(BTN_A_X)) simularTeclaMenu(ENTER, ENTER);

      // BotÃ³n B / CÃ­rculo -> Volver AtrÃ¡s (ESC)
      if (boton(BTN_B_CIRCULO)) simularTeclaMenu(ESC, ESC);
    }

    // Guardar estado actual de botones para detectar el siguiente toque
    int totalBotones = min(32, mando.getNumberOfButtons());
    for (int i = 0; i < totalBotones; i++) {
      try {
        botonPrev[i] = mando.getButton(i).pressed();
      }
      catch (Exception e) {
      }
    }
  }
  catch (Exception e) {
    mandoConectado = false;
    println("[Mando] Error o desconexiÃ³n del mando.");
  }
}

// ====================================================================================
// 4. FUNCIONES AUXILIARES (Simples para usar en tus 'if')
// ====================================================================================

// Devuelve TRUE solo en el instante en que presionas el botÃ³n (1 toque)
boolean boton(int id) {
  if (mando == null || id < 0 || id >= mando.getNumberOfButtons()) return false;
  try {
    boolean presionado = mando.getButton(id).pressed();
    return presionado && !botonPrev[id];
  }
  catch (Exception e) {
    return false;
  }
}

// Devuelve TRUE mientras dejes el botÃ³n hundido
boolean botonMantener(int id) {
  if (mando == null || id < 0 || id >= mando.getNumberOfButtons()) return false;
  try {
    return mando.getButton(id).pressed();
  }
  catch (Exception e) {
    return false;
  }
}

// Lee una palanca con zona muerta para que no tiemble
float palanca(int eje) {
  if (mando == null || eje < 0 || eje >= mando.getNumberOfSliders()) return 0;
  try {
    float val = mando.getSlider(eje).getValue();
    if (abs(val) < 0.2) return 0;
    return val;
  }
  catch (Exception e) {
    return 0;
  }
}

// Detecta si el gatillo estÃ¡ presionado
boolean gatillo(int eje) {
  return abs(palanca(eje)) > 0.3;
}

// DetecciÃ³n de toques con la palanca en menÃºs (para que no salte de 2 en 2)
boolean stickPulsadoArriba(float y) {
  boolean a = y < -0.6;
  boolean r = a && !stickPrevArr;
  stickPrevArr = a;
  return r;
}
boolean stickPulsadoAbajo(float y) {
  boolean a = y >  0.6;
  boolean r = a && !stickPrevAbj;
  stickPrevAbj = a;
  return r;
}
boolean stickPulsadoIzquierda(float x) {
  boolean a = x < -0.6;
  boolean r = a && !stickPrevIzq;
  stickPrevIzq = a;
  return r;
}
boolean stickPulsadoDerecha(float x) {
  boolean a = x >  0.6;
  boolean r = a && !stickPrevDer;
  stickPrevDer = a;
  return r;
}

void simularTeclaMenu(int codigo, int valor) {
  key = (char) valor;
  keyCode = codigo;
  keyPressed();
}

// ====================================================================================
// 5. INICIALIZACIÃN
// ====================================================================================
void iniciarMando() {
  try {
    controlIO = ControlIO.getInstance(this);
    int n = controlIO.getNumberOfDevices();
    ControlDevice mejorMando = null;
    int maxEjes = -1;

    for (int i = 0; i < n; i++) {
      try {
        ControlDevice d = controlIO.getDevice(i);
        String nom = d.getName().toLowerCase();
        int ejes = d.getNumberOfSliders();

        // Ignorar teclado y mouse
        if (nom.contains("keyboard") || nom.contains("mouse") || nom.contains("teclado") || nom.contains("raton")) {
          continue;
        }

        // Seleccionar el dispositivo que tenga palancas/ejes
        if (ejes > maxEjes && ejes >= 2) {
          mejorMando = d;
          maxEjes = ejes;
        }
      }
      catch (Exception e) {
      }
    }

    if (mejorMando != null) {
      mando = mejorMando;
      mandoConectado = true;
      println("[Mando] >>> Conectado con Ã©xito: " + mando.getName());
    }
  }
  catch (Exception e) {
    println("[Mando] Error al iniciar librerÃ­a: " + e.getMessage());
  }

  if (!mandoConectado) {
    println("[Mando] No se detectÃ³ mando. Se jugarÃ¡ con teclado.");
  }
}

// Funciones llamadas desde draw()
void pollMando() {
  leerControlesMando();
}

void fusionarEntradas() {
  // Integrado automÃ¡ticamente dentro de leerControlesMando()
}
