// ============================================================================
// MODULO: Entradas.pde
// DESCRIPCION:
//   Gestor centralizado de eventos de entrada (teclado y raton). Enruta las
//   acciones del usuario segun el contexto activo: cinematica, menu de pausa,
//   pantallas de victoria/derrota, minijuego de terminales, combate 3D o menus.
// ============================================================================
///////////////////////////////////////////////////   ENTRADAS   //////////////////////////////////////////////////////////////////////////////////////////
// Guarda las teclas de movimiento para que draw() las use frame a frame.
// Las acciones puntuales, como atacar o entrar al nivel 2, se ejecutan una vez.
// En el juego (PantallaDeJuego == 1) se usan las teclas de movimiento; en el menu (PantallaDeJuego == 0) las del menu.
void keyPressed() {
  if (cargandoInicio) return;
  if (cargandoNivel) return;

  if (reproduciendoCinematica) {
    if (key == ' ' || keyCode == ENTER || key == RETURN || keyCode == ESC || key == 'e' || key == 'E') {
      saltarCinematica();
    }
    if (keyCode == ESC) key = 0;
    return;
  }

  if (reproduciendoCinematicaNivel3) {
    if (key == ' ' || keyCode == ENTER || key == RETURN || keyCode == ESC) {
      saltarCinematicaNivel3();
    }
    if (keyCode == ESC) key = 0;
    return;
  }

    if (PantallaDeJuego == 1) {

    // ATAJOS DE PRUEBA: P (Derrota) y O (Victoria / Cinematica Nivel 3)
    if (key == 'p' || key == 'P') {
      if (sonidoCorrer != null) try { sonidoCorrer.stop(); } catch (Exception e) {}
      if (sonidoCaminar != null) try { sonidoCaminar.stop(); } catch (Exception e) {}
      vidaJugador = 0;
      juegoTerminado = true;
      nivelCompletado = false;
      pausa = false;
      volumenPausa = false;
      controlesPausa = false;
      tiempoMuerte = millis();
      sonidoDerrotaReproducido = false;
      shardsGenerados = false;
      mostrarMensaje("ATAJO: Pantalla de Derrota", 60);
      return;
    }

    if (key == 'o' || key == 'O') {
      if (sonidoCorrer != null) try { sonidoCorrer.stop(); } catch (Exception e) {}
      if (sonidoCaminar != null) try { sonidoCaminar.stop(); } catch (Exception e) {}
      pausa = false;
      volumenPausa = false;
      controlesPausa = false;
      if (nivelActual == 3) {
        mostrarMensaje("ATAJO: Cinematica 2 y Victoria", 60);
        iniciarCinematicaNivel3();
      } else {
        nivelCompletado = true;
        juegoTerminado = false;
        tiempoVictoria = millis();
        sonidoVictoriaReproducido = false;
        shardsGenerados = false;
        mostrarMensaje("ATAJO: Pantalla de Victoria", 60);
      }
      return;
    }

    // --- LOGICA DE PAUSA ---
    if (key == ESC) {
      if (minijuegoActivo) {
        minijuegoActivo = false;
        EnTerminal = false;
      } else {
        if (pausa == false) {
          pausa = true;
          botonpausa = 0; // Reinicia el botÃ³n seleccionado al abrir pausa
          volumenPausa = false;
          tiempoInicioPausa = millis();
          tiempoAnim = millis();
        } else {
          if (volumenPausa || controlesPausa) {
            volumenPausa = false;
            controlesPausa = false;
          } else {
            pausa = false; // Cierra la pausa si ya estaba abierta
            tiempoInicioPausa = -10000;
          }
        }
      }
      key = 0; // Anula la tecla ESC para que Processing no cierre la ventana sola
    }

    // Si el juego estÃ¡ en pausa, solo funcionan los controles del menÃº de pausa
    if (pausa) {
      if (volumenPausa) {
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          botonvolumen--;
          if (botonvolumen < 0) {
            botonvolumen = 0;
          }
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          botonvolumen++;
          if (botonvolumen > 10) {
            botonvolumen = 10;
          }
          reproducir(navegar);
        }

        volumenjuego = ((float)botonvolumen / 10);
        Sound.volume(volumenjuego);

        if (keyCode == ESC) {
          volumenPausa = false;
        }
        return;
      }

      if (controlesPausa) {
        int ultimaSlide = textoControles.length - 1;
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          if (slidescontrolesPausa > 0) {
            tiempoFlashIzq = millis();
            slidescontrolesPausa--;
            reproducir(navegar);
          }
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          if (slidescontrolesPausa < ultimaSlide) {
            tiempoFlashDer = millis();
            slidescontrolesPausa++;
            reproducir(navegar);
          }
        }
        if (keyCode == ESC) {
          controlesPausa = false;
        }
        return;
      }

      if (keyCode == UP || key == 'W' || key == 'w') {
        botonpausa--;
        if (botonpausa < 0) {
          botonpausa = 3;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }
      if (keyCode == DOWN || key == 'S' || key == 's') {
        botonpausa++;
        if (botonpausa > 3) {
          botonpausa = 0;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }

      if (keyCode == ENTER || key == RETURN) {
        if (botonpausa == 0) {
          reproducir(no);
          pausa = false; // ContinÃºa el juego (REANUDAR)
          tiempoInicioPausa = -10000;
        }
        if (botonpausa == 1) {
          reproducir(seleccionar); // SONIDO -> Abre volumen
          volumenPausa = true;
          tiempoInicioSubOpcion = millis();
        }
        if (botonpausa == 2) {
          reproducir(seleccionar); // CONTROLES
          controlesPausa = true;
          volumenPausa = false;
          slidescontrolesPausa = 0;
          tiempoInicioSubOpcion = millis();
        }
        if (botonpausa == 3) {
          reproducir(salir);
          PantallaDeJuego = 0; // Regresa al menÃº principal
          pantalla = pantallamenu;
          escogernivel = false;
          pausa = false;
          volumenPausa = false;
          botonselleccionmenu = 0;
          if (Audioprueba != null && !Audioprueba.isPlaying()) {
            Audioprueba.loop();
          }
          delay(400);
        }
      }
    } else if (juegoTerminado && (millis() - tiempoMuerte >= 3600)) {
      if (keyCode == LEFT || key == 'A' || key == 'a') {
        botonderrota--;
        if (botonderrota < 0) {
          botonderrota = 1;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }
      if (keyCode == RIGHT || key == 'D' || key == 'd') {
        botonderrota++;
        if (botonderrota > 1) {
          botonderrota = 0;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }

      if (keyCode == ENTER || key == RETURN) {
        if (botonderrota == 0) {
          reproducir(seleccionar);
          debeReproducirCinematica = false;
          iniciarCargaNivel(nivelActual);
        }
        if (botonderrota == 1) {
          reproducir(salir);
          PantallaDeJuego = 0; // Volver al menÃº principal
          pantalla = pantallamenu;
          juegoTerminado = false; // Limpia la derrota
          tiempoMuerte = 0;
          sonidoDerrotaReproducido = false;
          botonselleccionmenu = 0;
          botonderrota = 0;
          pausa = false;
          if (Audioprueba != null && !Audioprueba.isPlaying()) {
            Audioprueba.loop();
          }
          delay(400);
        }
      }
    } else if (nivelCompletado && (millis() - tiempoVictoria >= 3600)) {
      if (keyCode == LEFT || key == 'A' || key == 'a') {
        botonvictoria--;
        if (botonvictoria < 0) {
          botonvictoria = 1;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }
      if (keyCode == RIGHT || key == 'D' || key == 'd') {
        botonvictoria++;
        if (botonvictoria > 1) {
          botonvictoria = 0;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }

      if (keyCode == ENTER || key == RETURN) {
        if (botonvictoria == 0) {
          reproducir(seleccionar);
          if (nivelActual == 1) {
            iniciarCargaNivel(2);
          } else if (nivelActual == 2) {
            iniciarCargaNivel(3);
          } else {
            iniciarCargaNivel(1);
          }
        }
        if (botonvictoria == 1) {
          reproducir(salir);
          PantallaDeJuego = 0; // Volver al menÃº principal
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
          delay(400);
        }
      }
    } else if (minijuegoActivo) {
      for (int i = 0; i < teclas.length; i++) teclas[i] = false;
      for (int i = 0; i < teclasTeclado.length; i++) teclasTeclado[i] = false;
      for (int i = 0; i < lados.length; i++) lados[i] = false;
      for (int i = 0; i < mirarVertical.length; i++) mirarVertical[i] = false;
      if (key == '1') {
        opcionTerminal = 0;
        responderTerminal(true);
      } else if (key == '2') {
        opcionTerminal = 1;
        responderTerminal(false);
      } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
        opcionTerminal = 0;
        reproducir(navegar);
      } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
        opcionTerminal = 1;
        reproducir(navegar);
      } else if (keyCode == ENTER || key == RETURN || key == 'e' || key == 'E') {
        responderTerminal(opcionTerminal == 0);
      } else if (key == 'q' || key == 'Q') {
        minijuegoActivo = false;
        EnTerminal = false;
      }
    } else {
      if (key == 'D' || key == 'd') {
        teclas[3] = true;
        teclasTeclado[3] = true; // MANDO
      }
      if (key == 'A' || key == 'a') {
        teclas[2] = true;
        teclasTeclado[2] = true; // MANDO
      }
      if (key == 'S' || key == 's') {
        teclas[1] = true;
        teclasTeclado[1] = true; // MANDO
      }
      if (key == 'W' || key == 'w') {
        teclas[0] = true;
        teclasTeclado[0] = true; // MANDO
      }
      if (keyCode == SHIFT) {
        corriendo = true;
        velocidad = velocidadCarrera;
        corriendoTeclado = true; // MANDO
      }
      if (keyCode == RIGHT) {
        lados[1] = true;
      }
      if (keyCode == LEFT) {
        lados[0] = true;
      }
      if (keyCode == UP) {
        mirarVertical[0] = true;
      }
      if (keyCode == DOWN) {
        mirarVertical[1] = true;
      }
      // SPACE salta; E usa el ataque por cooldown.
      if (key == ' ') {
        if (!juegoTerminado && !nivelCompletado) saltar();
      }
      if ((key == 'E' || key == 'e') && !juegoTerminado) {
        atacar();
      }
      if ((key == 'R' || key == 'r') && !juegoTerminado) {
        esquivar();
      }
      if ((key == 'F' || key == 'f') && !juegoTerminado) {
        activarParry();
      }
      if ((key == 'G' || key == 'g') && !juegoTerminado) {
        ataqueEspecial();
      }
      // Atajo de demostracion para revisar el nivel 2 durante la feria.
      if ((key == 'N' || key == 'n') && !juegoTerminado) {
        iniciarCargaNivel(2);
      }
      if ((key == '3' || key == 'M' || key == 'm') && !juegoTerminado) {
        iniciarCargaNivel(3);
      }
      if ((key == 'Q' || key == 'q') && !juegoTerminado) {
        if (nivelActual == 3) {
          activarTerminalNivel3();
        } else if (nivelActual == 1 && !minijuegoActivo) {
          int idxT = indiceTerminalCercana();
          if (idxT >= 0) {
            if (terminalCompletada[idxT]) {
              mostrarMensaje("La Terminal " + (idxT + 1) + " ya fue completada", 60);
            } else {
              terminalActual = idxT;
              opcionTerminal = 0;
              rastroActual = 0;
              ultimoRastroVisto = -1;
              tiempoInicioTerminal = millis();
              EnTerminal = true;
              minijuegoActivo = true;
              reproducir(seleccionar);
              mostrarMensaje("Terminal " + (idxT + 1) + " abierta", 65);
              for (int i = 0; i < teclas.length; i++) teclas[i] = false;
            }
          } else {
            mostrarMensaje("No estas cerca de ninguna terminal", 60);
          }
        }
      }
    }
  }

  // Menu Teclas
  if (PantallaDeJuego == 0) {

    if (pantalla==pantallacarga) {
      if (key != CODED && key != ESC) {
        pantalla=pantallainicio;
        return;
      }
    }
    if (pantalla == pantallainicio && !animacion) {
      if (key != CODED && key != ESC) {
        animacion = true;
        tiempo = millis();
        reproducir(iniciar);
      }
    }

    //MENU PRINCIPAL
    if (pantalla == pantallamenu && ventanasalir == false) {
      if (keyCode == LEFT || key == 'a' || key == 'A') {
        botonselleccionmenu--;
        if (botonselleccionmenu < 0) {
          botonselleccionmenu = 2;
        }
        if (ventanasalir==false) {
          tiempoAnim = millis();
        }
        reproducir(navegar);
      }
      if (keyCode == RIGHT || key == 'd' || key == 'D') {
        botonselleccionmenu++;
        if (botonselleccionmenu > 2) {
          botonselleccionmenu = 0;
        }
        if (ventanasalir==false) {
          tiempoAnim = millis();
        }
        reproducir(navegar);
      }

      if (keyCode == ENTER || key == RETURN) {
        if (botonselleccionmenu == 0) {
          reproducir(jugar);
          pantalla = pantallajugar;
          escogernivel = false;
        }
        if (botonselleccionmenu == 1) {
          reproducir(seleccionar);
          pantalla = pantallaopciones;
          tiempoInicioOpciones = millis();
          botonopciones = 0;
          tiempoAnim = millis();
        }
        if (botonselleccionmenu == 2) {
          reproducir(seleccionar);
          ventanasalir = true;
          tiempoInicioVentanaSalir = millis();
          tiempoAnim = millis();
        }
        return;
      }

      if (keyCode == ESC) {
        if (pantalla == pantallamenu && ventanasalir == false) {
          pantalla = pantallainicio;
        }
      }
    }

    // PANTALLA JUGAR (MISIONES)
    if (pantalla == pantallajugar) {

      if (escogernivel == false) {
        if (keyCode == LEFT || key == 'a' || key == 'A') {
          botonniveles--;
          if (botonniveles < 0) {
            botonniveles = 2;
          }
          tiempoDestelloTriangNivelIzq = millis();
          tiempoAnim = millis();
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          botonniveles++;
          if (botonniveles > 2) {
            botonniveles = 0;
          }
          tiempoDestelloTriangNivelDer = millis();
          tiempoAnim = millis();
          reproducir(navegar);
        }

        if (key == ENTER || key == RETURN) {
          escogernivel = true;
          eleccionnivel = 0;
          reproducir(seleccionar);
          return;
        }
      }

      if (escogernivel == true) {
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          eleccionnivel--;
          if (eleccionnivel < 0) {
            eleccionnivel = 1;
          }
          tiempoAnim = millis();
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          eleccionnivel++;
          if (eleccionnivel > 1) {
            eleccionnivel = 0;
          }
          tiempoAnim = millis();
          reproducir(navegar);
        }

        if (key == ENTER || key == RETURN) {
          if (eleccionnivel == 0) {
            reproducir(jugar);
            noStroke();
            debeReproducirCinematica = true;
            iniciarCargaNivel(botonniveles + 1);
          }
          if (eleccionnivel == 1) {
            reproducir(no);
            escogernivel = false;
          }
          return;
        }
      }

      if (keyCode == ESC) {
        if (escogernivel == true) {
          escogernivel = false;
        } else {
          pantalla = pantallamenu;
        }
      }
    }

    if (pantalla == pantallaopciones) {

      if (volumen == false && detrasdelcodigo == false && creditos == false && controles == false) {
        if (keyCode == UP || key == 'w' || key == 'W') {
          botonopciones--;
          if (botonopciones < 0) {
            botonopciones = 4;
          }
          tiempoAnim = millis();
          reproducir(navegar);
        }
        if (keyCode == DOWN || key == 's' || key == 'S') {
          botonopciones++;
          if (botonopciones > 4) {
            botonopciones = 0;
          }
          tiempoAnim = millis();
          reproducir(navegar);
        }

        if (botonopciones == 0 && (key == ENTER || key == RETURN)) {
          detrasdelcodigo=true;
          botondetrasdelcodigo = 0;
          reproducir(seleccionar);
          return;
        }
        if (botonopciones == 1 && (key == ENTER || key == RETURN)) {
          volumen = true;
          reproducir(seleccionar);
          return;
        }

        if (botonopciones == 2 && (key == ENTER || key == RETURN)) {
          controles = true;
          slidescontroles = 0;
          reproducir(seleccionar);
          return;
        }

        if (botonopciones == 3 && (keyCode == ENTER || key == RETURN)) {
          creditos = true;
          reproducir(seleccionar);
          return;
        }

        if (botonopciones == 4 && (keyCode == ENTER || key == RETURN)) {
          pantalla = pantallamenu;
          botonopciones = 0;
          tiempoInicioOpciones = -10000;
          reproducir(seleccionar);
          return;
        }

        if (keyCode == ESC) {
          pantalla = pantallamenu;
          botonopciones = 0;
          tiempoInicioOpciones = -10000;
        }
      }

      if (detrasdelcodigo) {
        if (keyCode == UP || key == 'W' || key == 'w' ) {
          botondetrasdelcodigo--;
          if (botondetrasdelcodigo < 0) {
            botondetrasdelcodigo = 4;
          }
          tiempoAnim = millis();
          slidesdetras = 0;
          reproducir(navegar);
        }
        if (keyCode == DOWN || key == 'S' || key == 's') {
          botondetrasdelcodigo++;
          if (botondetrasdelcodigo > 4) {
            botondetrasdelcodigo = 0;
          }
          tiempoAnim = millis();
          slidesdetras = 0;
          reproducir(navegar);
        }

        //SLIDES DEL CONCEPTO (misma logica que los creditos)
        int ultimaSlideDetras = textoDetrasDelCodigo[botondetrasdelcodigo].length - 1;
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          if (slidesdetras > 0) {
            tiempoFlashIzq = millis();
          }
          slidesdetras--;
          if (slidesdetras < 0) {
            slidesdetras = 0;
          }
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          if (slidesdetras < ultimaSlideDetras) {
            tiempoFlashDer = millis();
          }
          slidesdetras++;
          if (slidesdetras > ultimaSlideDetras) {
            slidesdetras = ultimaSlideDetras;
          }
          reproducir(navegar);
        }

        if (keyCode == ESC) {
          detrasdelcodigo=false;
        }
      }

      if (volumen) {
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          botonvolumen--;
          if (botonvolumen < 1) {
            botonvolumen = 0;
          }
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          botonvolumen++;
          if (botonvolumen > 10) {
            botonvolumen = 10;
          }
          reproducir(navegar);
        }

        volumenjuego = ((float)botonvolumen / 10);
        Sound.volume(volumenjuego);

        if (keyCode == ESC) {
          volumen = false;
        }
      }

      if (controles) {
        int ultimaSlideControles = textoControles.length - 1;
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          if (slidescontroles > 0) {
            tiempoFlashIzq = millis();
          }
          slidescontroles--;
          if (slidescontroles < 0) {
            slidescontroles = 0;
          }
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          if (slidescontroles < ultimaSlideControles) {
            tiempoFlashDer = millis();
          }
          slidescontroles++;
          if (slidescontroles > ultimaSlideControles) {
            slidescontroles = ultimaSlideControles;
          }
          reproducir(navegar);
        }
        if (keyCode == ESC) {
          controles = false;
        }
      }

      if (creditos) {
        if (keyCode == LEFT || key == 'A' || key == 'a') {
          if (slidescreditos > 0) {
            tiempoFlashIzq = millis();
          }
          slidescreditos--;
          if (slidescreditos < 0) {
            slidescreditos = 0;
          }
          reproducir(navegar);
        }
        if (keyCode == RIGHT || key == 'd' || key == 'D') {
          if (slidescreditos < 2) {
            tiempoFlashDer = millis();
          }
          slidescreditos++;
          if (slidescreditos > 2) {
            slidescreditos = 2;
          }
          reproducir(navegar);
        }
        if (keyCode == ESC) {
          creditos = false;
        }
      }
    }

    if (pantalla == pantallamenu && ventanasalir) {
      if (keyCode == LEFT || key == 'A' || key == 'a') {
        botonseleccionsalir--;
        if (botonseleccionsalir < 0) {
          botonseleccionsalir = 1;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }
      if (keyCode == RIGHT || key == 'd' || key == 'D') {
        botonseleccionsalir++;
        if (botonseleccionsalir > 1) {
          botonseleccionsalir = 0;
        }
        tiempoAnim = millis();
        reproducir(navegar);
      }

      if (botonseleccionsalir == 0 && (keyCode == ENTER || key == RETURN)) {
        reproducir(salir);
        delay(400);
        exit();
      }
      if (botonseleccionsalir == 1 && (keyCode == ENTER || key == RETURN)) {
        reproducir(no);
        ventanasalir = false;
        botonselleccionmenu = 2;
      }
      if (keyCode == ESC) {
        ventanasalir = false;
        botonseleccionsalir=0;
      }
    }

    // Anular ESC
    if (key == ESC) {
      key = 0;
    }
  }
}
// Libera las teclas para detener el movimiento o devolver la velocidad base.
void keyReleased() {

  if (key == 'D' || key == 'd') {
    teclas[3] = false;
    teclasTeclado[3] = false; // MANDO
  }
  if (key == 'A' || key == 'a') {
    teclas[2] = false;
    teclasTeclado[2] = false; // MANDO
  }
  if (key == 'S' || key == 's') {
    teclas[1] = false;
    teclasTeclado[1] = false; // MANDO
  }
  if (key == 'W' || key == 'w') {
    teclas[0] = false;
    teclasTeclado[0] = false; // MANDO
  }
  if (keyCode == SHIFT) {
    corriendo = false;
    velocidad = velocidadBase;
    corriendoTeclado = false; // MANDO
  }
  if (keyCode == RIGHT) {
    lados[1] = false;
  }
  if (keyCode == LEFT) {
    lados[0] = false;
  }
  if (keyCode == UP) {
    mirarVertical[0] = false;
  }
  if (keyCode == DOWN) {
    mirarVertical[1] = false;
  }
}

void mousePressed() {
  if (PantallaDeJuego == 1 && minijuegoActivo && !pausa && !juegoTerminado) {
    if (mouseX >= btnPeligrosoX && mouseX <= btnPeligrosoX + btnAncho && mouseY >= btnPeligrosoY && mouseY <= btnPeligrosoY + btnAlto) {
      opcionTerminal = 0;
      responderTerminal(true);
    } else if (mouseX >= btnNeutroX && mouseX <= btnNeutroX + btnAncho && mouseY >= btnNeutroY && mouseY <= btnNeutroY + btnAlto) {
      opcionTerminal = 1;
      responderTerminal(false);
    }
  }
}
