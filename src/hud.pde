// ============================================================================
// MODULO: hud.pde
// DESCRIPCION:
//   Interfaz de usuario en partida (HUD): barras de vida y memoria, minimapa
//   circular pre-renderizado, sistema de avisos apilados sin solapamiento,
//   minijuego de analisis de rastros en terminales, pantallas de carga con
//   precalentamiento de VRAM, efecto de cristal roto y cinematicas MP4.
// ============================================================================
PGraphics minimapaBase;
// Dibuja la informacion de vidas, nivel, cooldown, mensajes y pantallas finales.
boolean sonidoDerrotaReproducido = false;
boolean sonidoVictoriaReproducido = false;
int tiempoVictoria = 0;
int tiempoInicioTerminal = 0;
int ultimoRastroVisto = -1;
int mensajeInicio = 0;
int mensajeDuracion = 45;

void dibujarHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  fill(245);
  textAlign(LEFT, BASELINE);
  textSize(24 * escalaY);


  if (juegoTerminado) {
    if (tiempoMuerte == 0) {
      tiempoMuerte = millis();
      shardsGenerados = false;
    }
    int t = millis() - tiempoMuerte;

    noStroke();

    // =========================================================
    // FASE 1: DESVANECIDO A NEGRO DEL JUEGO (0 a 600 ms)
    // =========================================================
    if (t < 60) { shardsGenerados = false; }
    if (t < 600) {
      float alfaNegro = map(t, 0, 600, 0, 255);
      fill(0, alfaNegro);
      rect(0, 0, width, height);

    // =========================================================
    // FASE 2: PAUSA EN NEGRO SILENCIOSA ESTILO DMC3 (600 a 1000 ms)
    // =========================================================
    } else if (t < 1000) {
      fill(0);
      rect(0, 0, width, height);

    // =========================================================
    // FASE 3: RAFAGA DE DISPAROS EN LA PANTALLA NEGRA (1000 a 2400 ms)
    // =========================================================
    } else if (t < 2400) {
      fill(0);
      rect(0, 0, width, height);

      // Reproducir la pista de disparos + quiebre
      if (!sonidoDerrotaReproducido) {
        if (transicionBalas != null) {
          reproducir(transicionBalas);
        } else {
          reproducir(iniciar);
        }
        sonidoDerrotaReproducido = true;
      }

      // Orificios de bala con impacto
      float[][] balas = {
        {768, 380, 0.2, 280, 205},
        {610, 310, -0.35, 260, 190},
        {930, 420, 0.45, 270, 195},
        {830, 280, -0.2, 250, 180},
        {690, 480, 0.3, 260, 190},
        {990, 350, -0.5, 250, 180},
        {580, 430, 0.15, 260, 190},
        {880, 500, -0.3, 270, 195},
        {760, 450, 0.4, 260, 190},
        {720, 320, -0.15, 250, 180}
      };
      int[] tiemposB = {1020, 1250, 1450, 1580, 1680, 1780, 1880, 1980, 2080, 2180};

      boolean destello = false;
      for (int i = 0; i < tiemposB.length; i++) {
        if (t >= tiemposB[i]) {
          if (t - tiemposB[i] < 45) {
            destello = true;
          }
          if (balazo != null && balazo.width > 0) {
            pushMatrix();
            translate(balas[i][0] * escalaX, balas[i][1] * escalaY);
            rotate(balas[i][2]);
            image(balazo, -balas[i][3] * 0.5 * escalaX, -balas[i][4] * 0.5 * escalaY, balas[i][3] * escalaX, balas[i][4] * escalaY);
            popMatrix();
          }
        }
      }

      if (destello) {
        fill(255, 150);
        rect(0, 0, width, height);
      }

    // =========================================================
// =========================================================
    // FASE 4: QUIEBRE Y ESTALLIDO DE CRISTAL (2400 a 3600 ms)
    // =========================================================
    } else if (t < 3600) {
      // 1. Fondo de derrota que se revela detras del cristal que se rompe
      if (t >= 2400 && t < 2450) reproducir(sonidoCristal);
      if (fondoderrota != null && fondoderrota.width > 0) {
        image(fondoderrota, 0, 0, REF_W * escalaX, REF_H * escalaY);
      } else {
        fill(100, 10, 16);
        rect(0, 0, width, height);
      }

      // 2. Grietas de fondo sutiles
      if (grietas != null && grietas.width > 0) {
        image(grietas, 0, 0, REF_W * escalaX, REF_H * escalaY);
      }

      // 3. Personaje derrota comenzando a verse detras de los fragmentos
      if (derrota != null && derrota.width > 0) {
        float altoDerrota = 760;
        float anchoDerrota = altoDerrota * ((float)derrota.width / (float)derrota.height);
        image(derrota, 680 * escalaX, 50 * escalaY, anchoDerrota * escalaX, altoDerrota * escalaY);
      }

      // 4. La pantalla negra partiendose en fragmentos de cristal que caen
      dibujarFragmentosCristal(t - 2400);

      // 5. Destello rapido e impactante del quiebre (primeros 40ms)
      if (t < 2445) {
        float flashShatter = map(t, 2400, 2445, 210, 0);
        fill(255, flashShatter);
        noStroke();
        rect(0, 0, width, height);
      }

    // =========================================================
    // FASE 5: PANTALLA DE DERROTA REVELADA (3600 ms en adelante)
    // =========================================================
    } else {
      int tDerrota = t - 3600;

      // 1. Fondo de derrota
      if (fondoderrota != null && fondoderrota.width > 0) {
        noTint();
        image(fondoderrota, 0, 0, REF_W * escalaX, REF_H * escalaY);
      } else {
        fill(100, 10, 16);
        rect(0, 0, width, height);
      }

      // 2. Grietas en negro en el fondo
      if (grietas != null && grietas.width > 0) {
        noTint();
        image(grietas, 0, 0, REF_W * escalaX, REF_H * escalaY);
      }

      // 3. Imagen del personaje "derrota" en la derecha
      if (derrota != null && derrota.width > 0) {
        float altoDerrota = 760;
        float anchoDerrota = altoDerrota * ((float)derrota.width / (float)derrota.height);
        float pImg = constrain(tDerrota / 350.0, 0.0, 1.0);
        float eImg = 1.0 - pow(1.0 - pImg, 3);
        float xDerrotaBase = 680;
        float xDerrota = (tDerrota >= 350) ? xDerrotaBase : (xDerrotaBase + (1.0 - eImg) * 70.0);
        tint(255, 255 * eImg);
        image(derrota, xDerrota * escalaX, 50 * escalaY, anchoDerrota * escalaX, altoDerrota * escalaY);
        noTint();
      }

      // Fragmentos de cristal terminando de caer
      if (t < 3950) {
        dibujarFragmentosCristal(t - 2400);
      }

      // PALABRA DERROTA EN ESQUINA SUPERIOR IZQUIERDA EN GRANDE
      if (tDerrota >= 100) {
        aplicarFuente(fuente1);
        textAlign(LEFT, BASELINE);
        fill(0);
        crearbotongrueso("DERROTA", 70, 130, 130);
        fill(235, 25, 35);
        textSize(130 * escalaY);
        text("DERROTA", 70 * escalaX, 130 * escalaY);
      }

      // RECTANGULO NEGRO EN LA PARTE DE ABAJO PARA LOS BOTONES
      if (tDerrota >= 200) {
        float yBarraNegra = height - 150 * escalaY;
        fill(0, 245);
        noStroke();
        rect(0, yBarraNegra, width, 150 * escalaY);
        stroke(225, 25, 35);
        strokeWeight(3 * escalaY);
        line(0, yBarraNegra, width, yBarraNegra);
        noStroke();

        // BOTONES EN ESQUINA INFERIOR IZQUIERDA UNO AL LADO DEL OTRO
        textAlign(LEFT, BASELINE);
        aplicarFuente(fuente1);
        float yBtns = (height - 52 * escalaY) / escalaY;
        animacionboton(botonderrota, 0, "REINTENTAR", 70, yBtns, 56, rojo);
        animacionboton(botonderrota, 1, "SALIR AL MENU", 390, yBtns, 56, rojo);
      }
    }
  } else if (nivelCompletado) {
    if (tiempoVictoria == 0) {
      tiempoVictoria = millis();
      shardsGenerados = false;
    }
    int tv = millis() - tiempoVictoria;

    noStroke();

    // =========================================================
    // FASE 1: DESVANECIDO A NEGRO DEL JUEGO (0 a 600 ms)
    // =========================================================
    if (tv < 60) { shardsGenerados = false; }
    if (tv < 600) {
      float alfaNegro = map(tv, 0, 600, 0, 255);
      fill(0, alfaNegro);
      rect(0, 0, width, height);

    // =========================================================
    // FASE 2: PAUSA EN NEGRO SILENCIOSA ESTILO DMC3 (600 a 1000 ms)
    // =========================================================
    } else if (tv < 1000) {
      fill(0);
      rect(0, 0, width, height);

    // =========================================================
    // FASE 3: RAFAGA DE DISPAROS EN LA PANTALLA NEGRA (1000 a 2400 ms)
    // =========================================================
    } else if (tv < 2400) {
      fill(0);
      rect(0, 0, width, height);

      // Reproducir la pista de disparos + quiebre
      if (!sonidoVictoriaReproducido) {
        if (transicionBalas != null) {
          reproducir(transicionBalas);
        } else {
          reproducir(jugar);
        }
        sonidoVictoriaReproducido = true;
      }

      // Orificios de bala
      float[][] balas = {
        {768, 380, 0.2, 280, 205},
        {610, 310, -0.35, 260, 190},
        {930, 420, 0.45, 270, 195},
        {830, 280, -0.2, 250, 180},
        {690, 480, 0.3, 260, 190},
        {990, 350, -0.5, 250, 180},
        {580, 430, 0.15, 260, 190},
        {880, 500, -0.3, 270, 195},
        {760, 450, 0.4, 260, 190},
        {720, 320, -0.15, 250, 180}
      };
      int[] tiemposB = {1020, 1250, 1450, 1580, 1680, 1780, 1880, 1980, 2080, 2180};

      boolean destello = false;
      for (int i = 0; i < tiemposB.length; i++) {
        if (tv >= tiemposB[i]) {
          if (tv - tiemposB[i] < 45) {
            destello = true;
          }
          if (balazo != null && balazo.width > 0) {
            pushMatrix();
            translate(balas[i][0] * escalaX, balas[i][1] * escalaY);
            rotate(balas[i][2]);
            image(balazo, -balas[i][3] * 0.5 * escalaX, -balas[i][4] * 0.5 * escalaY, balas[i][3] * escalaX, balas[i][4] * escalaY);
            popMatrix();
          }
        }
      }

      if (destello) {
        fill(255, 150);
        rect(0, 0, width, height);
      }

    // =========================================================
// =========================================================
    // FASE 4: QUIEBRE Y ESTALLIDO DE CRISTAL (2400 a 3600 ms)
    // =========================================================
    } else if (tv < 3600) {
      // 1. Fondo de victoria que se revela detras del cristal que se rompe
      if (tv >= 2400 && tv < 2450) reproducir(sonidoCristal);
      if (victoriaFondo != null && victoriaFondo.width > 0) {
        image(victoriaFondo, 0, 0, REF_W * escalaX, REF_H * escalaY);
      } else {
        fill(10, 60, 40);
        rect(0, 0, width, height);
      }

      // 2. Grietas de fondo sutiles
      if (grietas != null && grietas.width > 0) {
        image(grietas, 0, 0, REF_W * escalaX, REF_H * escalaY);
      }

      // 3. Personaje victoria comenzando a verse detras de los fragmentos
      if (victoriaImg != null && victoriaImg.width > 0) {
        float altoVic = 760;
        float anchoVic = altoVic * ((float)victoriaImg.width / (float)victoriaImg.height);
        image(victoriaImg, 700 * escalaX, 50 * escalaY, anchoVic * escalaX, altoVic * escalaY);
      }

      // 4. La pantalla negra partiendose en fragmentos de cristal que caen
      dibujarFragmentosCristal(tv - 2400);

      // 5. Destello rapido e impactante del quiebre (primeros 40ms)
      if (tv < 2445) {
        float flashShatter = map(tv, 2400, 2445, 210, 0);
        fill(255, flashShatter);
        noStroke();
        rect(0, 0, width, height);
      }

    // =========================================================
    // FASE 5: PANTALLA DE VICTORIA REVELADA (3600 ms en adelante)
    // =========================================================
    } else {
      int tVic = tv - 3600;

      // 1. Fondo de victoria
      if (victoriaFondo != null && victoriaFondo.width > 0) {
        noTint();
        image(victoriaFondo, 0, 0, REF_W * escalaX, REF_H * escalaY);
      } else {
        fill(10, 60, 40);
        rect(0, 0, width, height);
      }

      // 2. Grietas sutiles en negro
      if (grietas != null && grietas.width > 0) {
        noTint();
        image(grietas, 0, 0, REF_W * escalaX, REF_H * escalaY);
      }

      // 3. Personaje victoria (thumbs up) a la derecha
      if (victoriaImg != null && victoriaImg.width > 0) {
        float altoVic = 760;
        float anchoVic = altoVic * ((float)victoriaImg.width / (float)victoriaImg.height);
        float pImg = constrain(tVic / 350.0, 0.0, 1.0);
        float eImg = 1.0 - pow(1.0 - pImg, 3);
        float xVicBase = 700;
        float xVic = (tVic >= 350) ? xVicBase : (xVicBase + (1.0 - eImg) * 70.0);
        tint(255, 255 * eImg);
        image(victoriaImg, xVic * escalaX, 50 * escalaY, anchoVic * escalaX, altoVic * escalaY);
        noTint();
      }

      // PALABRA VICTORIA EN ESQUINA SUPERIOR IZQUIERDA EN GRANDE
      if (tVic >= 100) {
        aplicarFuente(fuente1);
        textAlign(LEFT, BASELINE);
        fill(0);
        crearbotongrueso("VICTORIA", 70, 130, 130);
        fill(245, 35, 45);
        textSize(130 * escalaY);
        text("VICTORIA", 70 * escalaX, 130 * escalaY);
      }

      // RECTANGULO NEGRO EN LA PARTE DE ABAJO PARA LOS BOTONES
      if (tVic >= 200) {
        float yBarraNegra = height - 150 * escalaY;
        fill(0, 245);
        noStroke();
        rect(0, yBarraNegra, width, 150 * escalaY);
        stroke(225, 25, 35);
        strokeWeight(3 * escalaY);
        line(0, yBarraNegra, width, yBarraNegra);
        noStroke();

        // BOTONES EN ESQUINA INFERIOR IZQUIERDA UNO AL LADO DEL OTRO
        textAlign(LEFT, BASELINE);
        aplicarFuente(fuente1);
        float yBtns = (height - 52 * escalaY) / escalaY;
        String textoBtn0 = (nivelActual == 3) ? "REINTENTAR" : "SIGUIENTE NIVEL";
        float xBtn1 = (nivelActual == 3) ? 390 : 510;
        animacionboton(botonvictoria, 0, textoBtn0, 70, yBtns, 56, rojo);
        animacionboton(botonvictoria, 1, "SALIR AL MENU", xBtn1, yBtns, 56, rojo);
      }
    }
  }

  else if (pausa) {
    fill(0, 0, 0, 175);
    rect(0, 0, width, height);

    // LOGO ESTRATEGICO EN ESQUINA SUPERIOR DERECHA (AMPLIO Y SIN ANIMACION)
    if (logo != null && logo.width > 0) {
      float anchoLogo = 380.0 * escalaX;
      float altoLogo = anchoLogo / 3.0;
      image(logo, width - (anchoLogo + 40 * escalaX), 25 * escalaY, anchoLogo, altoLogo);
    }

    textAlign(LEFT, BASELINE);
    aplicarFuente(fuente1);

    if (tiempoInicioPausa < 0) {
      tiempoInicioPausa = millis();
      tiempoAnim = millis();
    }
    int tiempoPausa = millis() - tiempoInicioPausa;

    if (!volumenPausa && !controlesPausa) {
      tiempoInicioSubOpcion = -10000;
    }

    // Cascada de botones con transicion al mismo estilo que el menu principal
    if (tiempoPausa >= 120) {
      float p = constrain((tiempoPausa - 120) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoPausa >= 280) ? 108 : (108 - (1.0 - e) * 80.0);
      fill(200, 15, 15);
      crearbotongrueso("PAUSA", x, 130, 120);
      fill(255);
      textSize(120*escalaY);
      text("PAUSA", x*escalaX, 130*escalaY);


    }

    if (tiempoPausa >= 180) {
      float p = constrain((tiempoPausa - 180) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoPausa >= 340) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonpausa, 0, "REANUDAR", x, 271, 60, rojo);
    }

    if (tiempoPausa >= 240) {
      float p = constrain((tiempoPausa - 240) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoPausa >= 400) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonpausa, 1, "SONIDO", x, 365, 60, rojo);
    }

    if (volumenPausa) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      float pSub = constrain(tiempoSub / 220.0, 0.0, 1.0);
      float eSub = 1.0 - pow(1.0 - pSub, 3);
      float xTarjeta = 640 + (1.0 - eSub) * 60.0;
      float yTarjeta = 140;
      float wTarjeta = 800;
      float hTarjeta = 620;

      fill(225, 25, 35);
      crearbotongrueso("VOLUMEN", xTarjeta + 230, 195, 80);
      fill(255);
      textSize(80 * escalaY);
      text("VOLUMEN", (xTarjeta + 230) * escalaX, 195 * escalaY);

      fill(18, 6, 8, 245);
      stroke(225, 25, 35);
      strokeWeight(2.5 * escalaY);
      rect(xTarjeta * escalaX, yTarjeta * escalaY, wTarjeta * escalaX, hTarjeta * escalaY, 14);
      noStroke();

      color colVolIzq = (millis() - tiempoFlashIzq < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
      color colVolDer = (millis() - tiempoFlashDer < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);

      float yBarra = 360;
      trianguloBorde(xTarjeta + 130, yBarra + 5, xTarjeta + 100, yBarra + 26, xTarjeta + 130, yBarra + 47, colVolIzq);
      dibujarBarraVolumenEn(botonvolumen, xTarjeta + 155, yBarra + 5, 450, 42);
      trianguloBorde(xTarjeta + 630, yBarra + 5, xTarjeta + 660, yBarra + 26, xTarjeta + 630, yBarra + 47, colVolDer);

      fill(255, 70, 80);
      aplicarFuente(fuente1);
      textSize(24 * escalaY);
      textAlign(CENTER, CENTER);
      text("Usa A / D, flechas o haz click en los triangulos", (xTarjeta + wTarjeta / 2.0) * escalaX, 485 * escalaY);
      fill(180, 40, 45);
      textSize(26 * escalaY);
      text("Presiona ESC para regresar", (xTarjeta + wTarjeta / 2.0) * escalaX, 680 * escalaY);
      textAlign(LEFT, BASELINE);
    }

    if (tiempoPausa >= 300) {
      float p = constrain((tiempoPausa - 300) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoPausa >= 460) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonpausa, 2, "CONTROLES", x, 459, 60, rojo);
    }

    // PANEL DE CONTROLES EN LA PANTALLA DE PAUSA (SIMETRICO Y CENTRADO)
    if (controlesPausa) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      float pSub = constrain(tiempoSub / 220.0, 0.0, 1.0);
      float eSub = 1.0 - pow(1.0 - pSub, 3);
      float xTarjeta = 640 + (1.0 - eSub) * 60.0;
      float yTarjeta = 140;
      float wTarjeta = 800;
      float hTarjeta = 620;

      fill(225, 25, 35);
      crearbotongrueso("CONTROLES", xTarjeta + 190, 195, 80);
      fill(255);
      textSize(80 * escalaY);
      text("CONTROLES", (xTarjeta + 190) * escalaX, 195 * escalaY);

      fill(18, 6, 8, 245);
      stroke(225, 25, 35);
      strokeWeight(2.5 * escalaY);
      rect(xTarjeta * escalaX, yTarjeta * escalaY, wTarjeta * escalaX, hTarjeta * escalaY, 14);
      noStroke();

      fill(255);
      aplicarFuente(fuenteTexto);
      textSize(21 * escalaY);
      textAlign(LEFT, TOP);
      textLeading(28 * escalaY);
      // Ancho delimitado en formato estricto para evitar descuadres
      float anchoPausaTexto = 480 * escalaX;
      float xPausaTexto = (xTarjeta * escalaX) + (wTarjeta * escalaX - anchoPausaTexto) / 2.0;
      text(textoControles[slidescontrolesPausa], xPausaTexto, 225 * escalaY, anchoPausaTexto, 430 * escalaY);
      aplicarFuente(fuente1);
      textAlign(LEFT, BASELINE);

      color colIzq = (millis() - tiempoFlashIzq < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
      color colDer = (millis() - tiempoFlashDer < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
      if (slidescontrolesPausa > 0 || millis() - tiempoFlashIzq < duracionFlashTriangulo) {
        trianguloBorde(xTarjeta - 35, 430, xTarjeta - 65, 452, xTarjeta - 35, 474, colIzq);
      }
      if (slidescontrolesPausa < textoControles.length - 1 || millis() - tiempoFlashDer < duracionFlashTriangulo) {
        trianguloBorde(xTarjeta + wTarjeta + 35, 430, xTarjeta + wTarjeta + 65, 452, xTarjeta + wTarjeta + 35, 474, colDer);
      }

      String contador = (slidescontrolesPausa + 1) + " / " + textoControles.length;
      fill(255, 50, 60);
      textSize(30 * escalaY);
      textAlign(CENTER, CENTER);
      text(contador, (xTarjeta + wTarjeta / 2.0) * escalaX, 680 * escalaY);

      fill(180, 40, 45);
      textSize(24 * escalaY);
      text("Presiona ESC para regresar", (xTarjeta + wTarjeta / 2.0) * escalaX, 720 * escalaY);
      textAlign(LEFT, BASELINE);
    }

    if (tiempoPausa >= 360) {
      float p = constrain((tiempoPausa - 360) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoPausa >= 520) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonpausa, 3, "SALIR AL MENU", x, 553, 60, rojo);
    }
  } else {
    tiempoInicioPausa = -10000;
    volumenPausa = false;
    controlesPausa = false;
    aplicarFuente(fuenteTexto);
    fill(245);
    textAlign(LEFT, BASELINE);
    textSize(24 * escalaY);
    text("Vida: " + vidaJugador, 30 * escalaX, 38 * escalaY);
    text("Nivel " + nivelActual, 30 * escalaX, 70 * escalaY);

    // BANNER PERMANENTE DE OBJETIVO CLARO EN EL HUD SUPERIOR (ROJO)
    fill(18, 6, 8, 220);
    stroke(225, 25, 35);
    strokeWeight(1.8 * escalaY);
    rect(320 * escalaX, 15 * escalaY, 896 * escalaX, 42 * escalaY, 6);
    noStroke();
    fill(255, 50, 60);
    textSize(18 * escalaY);
    textAlign(CENTER, CENTER);
    if (nivelActual == 1) {
      text("[ ! ] OBJETIVO: Neutraliza a los Centinelas Kaze (" + enemigosVivos() + "/" + NUM_ENEMIGOS + ") y cruza el portal", 768 * escalaX, 35 * escalaY);
    } else if (nivelActual == 2) {
      text("[ ! ] OBJETIVO: Atraviesa los servidores y alcanza el enlace dorado (" + fragmentosNivel2 + "/" + FRAGMENTOS_NECESARIOS + ")", 768 * escalaX, 35 * escalaY);
    } else {
      text(jefeNivel3Iniciado ? "[ ! ] OBJETIVO CRITICO: DESTRUYE A ARGOS // Nodo Maestro de Kaze Corp" : "[ ! ] OBJETIVO: Penetra el laberinto de datos y accede al nucleo", 768 * escalaX, 35 * escalaY);
    }
    textAlign(LEFT, BASELINE);

    // COLUMNA IZQUIERDA DEL HUD SIN SUPERPOSICION (UNO DEBAJO DEL OTRO)
    fill(245);
    textSize(22 * escalaY);
    if (nivelActual == 1) {
      text("Enemigos: " + enemigosVivos() + "/" + NUM_ENEMIGOS, 30 * escalaX, 102 * escalaY);
      text("Terminales: " + contarTerminalesCompletadas() + "/3", 30 * escalaX, 130 * escalaY);
      dibujarBarraCooldown();
      dibujarBarraMemoria();
      fill(210);
      textSize(16 * escalaY);
      text("E: atacar   R: esquiva   F: parry   G: especial   Q: terminal", 30 * escalaX, 222 * escalaY);
      dibujarMinimapa();
    } else if (nivelActual == 2) {
      text("WASD: mover   SPACE: saltar", 30 * escalaX, 104 * escalaY);
      text("Fragmentos: " + fragmentosNivel2 + "/" + FRAGMENTOS_NECESARIOS, 30 * escalaX, 136 * escalaY);
      text("Checkpoint: hub central", 30 * escalaX, 168 * escalaY);
      text(fragmentosNivel2 < FRAGMENTOS_NECESARIOS
        ? "Explora las tres ramas"
        : "Puente final desbloqueado", 30 * escalaX, 200 * escalaY);
    } else {
      text("Zona: " + nombreZonaNivel3() + "   |   Checkpoint: " + (checkpointNivel3 + 1), 30 * escalaX, 102 * escalaY);
      text(jefeNivel3Iniciado ? "ARGOS: " + enemigosVida[JEFE_NIVEL3] + " PV | " + nombreModoJefeNivel3()
        : (terminalNivel3Usada ? "Terminal arena: ACTIVA" : "Q: activar terminal cuando este cerca"), 30 * escalaX, 130 * escalaY);
      dibujarBarraCooldown();
      dibujarBarraMemoria();
      fill(210);
      textSize(16 * escalaY);
      text("E: atacar   R: esquiva   F: parry   G: especial", 30 * escalaX, 222 * escalaY);
      if (jefeNivel3Iniciado) dibujarBarraJefeNivel3();
    }

    fill(210);
    textSize(18 * escalaY);
    text("WASD mover | SHIFT correr | Mouse / flechas mirar | SPACE saltar", 30 * escalaX, height - 28 * escalaY);

    dibujarMensajesApiladosHUD();
  }

  if (!pausa && !juegoTerminado) {
    TerminalMiniJuego();
    dibujarAvisoObjetivoNivel();
  }
  textAlign(LEFT, BASELINE);
  aplicarFuente(fuente1);
  hint(ENABLE_DEPTH_TEST);
}

// Representa visualmente el tiempo restante antes de poder volver a atacar.
void dibujarBarraCooldown() {
  aplicarFuente(fuenteTexto);
  float progreso = constrain((frameCount - ultimoAtaqueJugador) / float(cooldownAtaque), 0, 1);
  float ancho = 220 * escalaX;
  noStroke();
  fill(45, 50, 60);
  rect(30 * escalaX, 148 * escalaY, ancho, 16 * escalaY, 4 * escalaY);
  fill(40, 210, 180);
  rect(30 * escalaX, 148 * escalaY, ancho * progreso, 16 * escalaY, 4 * escalaY);

  if (progreso >= 1) {
    float pulsoListo = map(sin(millis() * 0.012), -1, 1, 0, 1);
    fill(lerpColor(color(40, 240, 190), color(255), pulsoListo));
    textSize((16 + 2 * pulsoListo) * escalaY);
    text("Listo!", 260 * escalaX, 161 * escalaY);
  } else {
    fill(180);
    textSize(16 * escalaY);
    text("Recargando", 260 * escalaX, 161 * escalaY);
  }
}

// La barra de Memoria se llena al golpear, esquivar o hacer parry.
// Al llegar al maximo permite usar el pulso especial con G o Y.
void dibujarBarraMemoria() {
  aplicarFuente(fuenteTexto);
  float progreso = memoriaActual / float(MEMORIA_MAX);
  float ancho = 220 * escalaX;
  noStroke();
  fill(35, 50, 60);
  rect(30 * escalaX, 176 * escalaY, ancho, 16 * escalaY, 4 * escalaY);
  fill(70, 235, 210);
  rect(30 * escalaX, 176 * escalaY, ancho * progreso, 16 * escalaY, 4 * escalaY);
  fill(220);
  textSize(16 * escalaY);
  text("Memoria " + memoriaActual + "/" + MEMORIA_MAX, 260 * escalaX, 189 * escalaY);
}






// Convierte la matriz completa en una vista circular estilo radar, un poco mas grande
void dibujarMinimapa() {
  float diametro = 350;
  float centroX = width - (diametro / 2) - 35;
  float centroY = height - (diametro / 2) - 35;

  float miniAncho = 200;
  float miniAlto = miniAncho * (mapa[0].length / float(mapa.length));

  float miniX = centroX - (miniAncho / 2);
  float miniY = centroY - (miniAlto / 2) - 15;

  float celdaH = miniAncho / mapa.length;
  float celdaV = miniAlto / mapa[0].length;

  if (minimapaBase == null) CrearMiniMapaBase();
  noStroke();
  noTint();
  imageMode(CORNER);
  if (minimapaBase != null) {
    image(minimapaBase, centroX - minimapaBase.width / 2.0, centroY - minimapaBase.height / 2.0);
  }

  float colJugador = constrain(celdaDe(JugadorX), 0, mapa[0].length - 1);
  float filaJugador = constrain(celdaDe(JugadorZ), 0, mapa.length - 1);
  float jugPixelX = miniX + (filaJugador + 0.5) * celdaH;
  float jugPixelY = miniY + (mapa[0].length - 1 - colJugador + 0.5) * celdaV;

  fill(255);
  ellipse(jugPixelX, jugPixelY, 14, 14);
  fill(0, 190, 255);
  ellipse(jugPixelX, jugPixelY, 8, 8);

  for (int i = 0; i < NUM_ENEMIGOS; i++) {
    if (!enemigosActivo[i]) continue;
    float colE = constrain(celdaDe(enemigosX[i]), 0, mapa[0].length - 1);
    float filaE = constrain(celdaDe(enemigosZ[i]), 0, mapa.length - 1);
    float ePixelX = miniX + (filaE + 0.5) * celdaH;
    float ePixelY = miniY + (mapa[0].length - 1 - colE + 0.5) * celdaV;

    fill(255, 40, 50);
    ellipse(ePixelX, ePixelY, 10, 10);
  }

  noFill();
  stroke(235, 30, 45, 230);
  strokeWeight(4);
  ellipse(centroX, centroY, diametro, diametro);

  stroke(130, 20, 30, 150);
  strokeWeight(2);
  ellipse(centroX, centroY, diametro + 14, diametro + 14);
  noStroke();
}

void CrearMiniMapaBase() {
  if (mapa == null || mapa.length == 0) return;
  int tam = 370;
  float diametro = 350;
  float centroX = tam / 2.0;
  float centroY = tam / 2.0;
  float miniAncho = 200;
  float miniAlto = miniAncho * (mapa[0].length / float(mapa.length));

  float miniX = centroX - (miniAncho / 2);
  float miniY = centroY - (miniAlto / 2) - 15;

  float celdaH = miniAncho / mapa.length;
  float celdaV = miniAlto / mapa[0].length;

  minimapaBase = createGraphics(tam, tam);
  minimapaBase.beginDraw();
  minimapaBase.noStroke();
  minimapaBase.fill(10, 15, 24, 235);
  minimapaBase.ellipse(centroX, centroY, diametro, diametro);

  for (int f = 0; f < mapa.length; f++) {
    for (int c = 0; c < mapa[f].length; c++) {
      int valor = mapa[f][c];
      if (valor == 4 || valor == -1) continue;

      float celdaX = miniX + f * celdaH;
      float celdaY = miniY + (mapa[0].length - 1 - c) * celdaV;

      if (dist(celdaX, celdaY, centroX, centroY) > diametro / 2 - 4) continue;

      if (esPared(valor)) {
        minimapaBase.fill(45, 60, 85);
        minimapaBase.rect(celdaX, celdaY, celdaH + 0.8, celdaV + 0.8);
      } else if (esPiso(valor)) {
        minimapaBase.fill(210, 235, 255);
        minimapaBase.rect(celdaX, celdaY, celdaH + 0.8, celdaV + 0.8);
      }
    }
  }

  minimapaBase.fill(0, 255, 200);
  minimapaBase.rect(miniX + SALIDA_FILA * celdaH, miniY + (mapa[0].length - 1 - SALIDA_COL) * celdaV, celdaH * 2.5, celdaV * 2.5);

  if (posicionesTerminales != null) {
    for (int j = 0; j < posicionesTerminales.length; j++) {
      float tx = miniX + (posicionesTerminales[j].z + 0.5) * celdaH;
      float ty = miniY + (mapa[0].length - 1 - posicionesTerminales[j].x + 0.5) * celdaV;
      if (dist(tx, ty, centroX, centroY) > diametro / 2 - 4) continue;
      if (terminalCompletada != null && j < terminalCompletada.length && terminalCompletada[j]) minimapaBase.fill(0, 255, 140);
      else minimapaBase.fill(255, 220, 6);
      minimapaBase.rect(tx - 5, ty - 5, 10, 10);
    }
  }

  minimapaBase.endDraw();
}



// ====================================================================
// SISTEMA DE AVISOS DEL HUD APILADOS (UNO DEBAJO DEL OTRO SIN SOBREESCRIBIRSE)
// ====================================================================
final int MAX_MENSAJES_HUD = 4;
String[] colaMensajesTexto = new String[MAX_MENSAJES_HUD];
int[] colaMensajesInicio = new int[MAX_MENSAJES_HUD];
int[] colaMensajesDuracion = new int[MAX_MENSAJES_HUD];
int[] colaMensajesHasta = new int[MAX_MENSAJES_HUD];
int numMensajesActivos = 0;

void limpiarMensajesExpirados() {
  int w = 0;
  for (int i = 0; i < numMensajesActivos; i++) {
    if (frameCount < colaMensajesHasta[i] && colaMensajesTexto[i] != null) {
      colaMensajesTexto[w] = colaMensajesTexto[i];
      colaMensajesInicio[w] = colaMensajesInicio[i];
      colaMensajesDuracion[w] = colaMensajesDuracion[i];
      colaMensajesHasta[w] = colaMensajesHasta[i];
      w++;
    }
  }
  numMensajesActivos = w;
}

void mostrarMensaje(String mensaje, int duracion) {
  if (mensaje == null || mensaje.length() == 0) return;
  mensajeActual = mensaje;
  mensajeHasta = frameCount + duracion;
  mensajeInicio = frameCount;
  mensajeDuracion = duracion;

  limpiarMensajesExpirados();

  // Si el mismo aviso ya esta en pantalla, actualiza su duracion para no duplicarlo
  for (int i = 0; i < numMensajesActivos; i++) {
    if (colaMensajesTexto[i].equals(mensaje)) {
      colaMensajesHasta[i] = frameCount + duracion;
      colaMensajesDuracion[i] = max(colaMensajesDuracion[i], duracion);
      return;
    }
  }

  // Si la cola esta llena, desplaza hacia arriba el mas antiguo
  if (numMensajesActivos >= MAX_MENSAJES_HUD) {
    for (int i = 0; i < MAX_MENSAJES_HUD - 1; i++) {
      colaMensajesTexto[i] = colaMensajesTexto[i + 1];
      colaMensajesInicio[i] = colaMensajesInicio[i + 1];
      colaMensajesDuracion[i] = colaMensajesDuracion[i + 1];
      colaMensajesHasta[i] = colaMensajesHasta[i + 1];
    }
    numMensajesActivos = MAX_MENSAJES_HUD - 1;
  }

  colaMensajesTexto[numMensajesActivos] = mensaje;
  colaMensajesInicio[numMensajesActivos] = frameCount;
  colaMensajesDuracion[numMensajesActivos] = max(1, duracion);
  colaMensajesHasta[numMensajesActivos] = frameCount + duracion;
  numMensajesActivos++;
}

void dibujarMensajesApiladosHUD() {
  limpiarMensajesExpirados();
  if (numMensajesActivos <= 0) return;

  aplicarFuente(fuenteTexto);
  textAlign(CENTER, CENTER);
  float baseY = height - 175 * escalaY;
  float separacionY = 38 * escalaY;

  for (int i = 0; i < numMensajesActivos; i++) {
    String msg = colaMensajesTexto[i];
    float progMsg = constrain((frameCount - colaMensajesInicio[i]) / float(max(1, colaMensajesDuracion[i])), 0, 1);
    float alfaMsg = progMsg > 0.75 ? map(progMsg, 0.75, 1.0, 255, 0) : 255;

    float temblor = 0;
    color colTexto;
    if (msg.indexOf("vida") >= 0 || msg.indexOf("Impacto") >= 0 || msg.indexOf("incorrecta") >= 0) {
      if (frameCount - colaMensajesInicio[i] < 8) temblor = random(-3, 3);
      colTexto = color(255, 85, 85, alfaMsg);
    } else if (msg.indexOf("derrotado") >= 0 || msg.indexOf("Nivel") >= 0 || msg.indexOf("completada") >= 0 || msg.indexOf("aceptada") >= 0 || msg.indexOf("desbloqueada") >= 0) {
      colTexto = color(60, 255, 200, alfaMsg);
    } else {
      colTexto = color(255, 230, 120, alfaMsg);
    }

    float yFila = baseY + i * separacionY;
    textSize(22 * escalaY);
    float wCaja = (textWidth(msg) + 36 * escalaX);
    noStroke();
    fill(8, 10, 16, alfaMsg * 0.72);
    rect((768 + temblor) * escalaX - wCaja / 2.0, yFila - 15 * escalaY, wCaja, 30 * escalaY, 6 * escalaY);

    fill(colTexto);
    text(msg, (768 + temblor) * escalaX, yFila);
  }
  textAlign(LEFT, BASELINE);
}

int contarTerminalesCompletadas() {
  if (terminalCompletada == null) return 0;
  int c = 0;
  for (int i = 0; i < terminalCompletada.length; i++) {
    if (terminalCompletada[i]) c++;
  }
  return c;
}

void responderTerminal(boolean eligioPeligroso) {
  if (!minijuegoActivo) return;
  int tIdx = constrain(terminalActual, 0, rastrosEsPeligroso.length - 1);
  int rIdx = constrain(rastroActual, 0, rastrosEsPeligroso[tIdx].length - 1);
  boolean esCorrecto = (eligioPeligroso == rastrosEsPeligroso[tIdx][rIdx]);

  if (esCorrecto) {
    reproducir(seleccionar);
    if (rastroActual == 0) {
      rastroActual = 1;
      ultimoRastroVisto = -1;
      tiempoInicioTerminal = millis();
      mostrarMensaje("Rastro 1 verificado correctamente", 65);
    } else {
      terminalCompletada[tIdx] = true;
      minijuegoActivo = false;
      EnTerminal = false;
      memoriaActual = min(MEMORIA_MAX, memoriaActual + 25);
      CrearMiniMapaBase();
      mostrarMensaje("Terminal " + (tIdx + 1) + " completada (" + contarTerminalesCompletadas() + "/3)", 95);
    }
  } else {
    reproducir(no);
    mostrarMensaje("Clasificacion incorrecta: analiza el rastro otra vez", 65);
  }
}

void MostrarTerminal() {
  int idx = indiceTerminalCercana();
  if (idx >= 0 && !minijuegoActivo) {
    if (terminalCompletada != null && terminalCompletada[idx]) {
      mostrarMensaje("Terminal " + (idx + 1) + " ya analizada (" + contarTerminalesCompletadas() + "/3)", 25);
    } else {
      mostrarMensaje("Presione Q para abrir la Terminal " + (idx + 1), 25);
    }
  }
}

void TerminalMiniJuego() {
  if (minijuegoActivo) {
    aplicarFuente(fuenteTexto);

    float panelAncho = 720 * escalaX;
    float panelAlto = 460 * escalaY;
    float panelX = width/2 - panelAncho/2;
    float panelY = height/2 - panelAlto/2;

    stroke(0, 255, 150);
    strokeWeight(3 * escalaY);
    fill(5, 25, 15, 240);
    rect(panelX, panelY, panelAncho, panelAlto, 15 * escalaY);

    fill(0, 255, 150);
    textAlign(CENTER, CENTER);
    textSize(25 * escalaY);
    text("ANALIZADOR DE RASTROS - TERMINAL " + (terminalActual + 1), width/2, panelY + 45 * escalaY);

    textSize(18 * escalaY);
    fill(180, 220, 200);
    text("Rastro " + (rastroActual + 1) + " / 2", width/2, panelY + 80 * escalaY);
    strokeWeight(1 * escalaY);
    line(panelX + 40 * escalaX, panelY + 100 * escalaY, panelX + panelAncho - 40 * escalaX, panelY + 100 * escalaY);

    int tIdx = constrain(terminalActual, 0, rastrosTexto.length - 1);
    if (tiempoInicioTerminal == 0 || ultimoRastroVisto != rastroActual) {
      tiempoInicioTerminal = millis();
      ultimoRastroVisto = rastroActual;
    }
    String textoCompleto = rastrosTexto[tIdx][rastroActual];
    int charsAMostrar = min(textoCompleto.length(), max(0, (millis() - tiempoInicioTerminal) / 22));
    String textoAnimado = textoCompleto.substring(0, charsAMostrar);
    if (charsAMostrar < textoCompleto.length() || (millis() / 250) % 2 == 0) {
      textoAnimado += "_";
    }
    fill(255);
    textSize(22 * escalaY);
    text(textoAnimado, panelX + 50 * escalaX, panelY + 130 * escalaY, panelAncho - 100 * escalaX, 130 * escalaY);

    btnAncho = 200 * escalaX;
    btnAlto = 54 * escalaY;
    btnPeligrosoX = width/2 - 220 * escalaX;
    btnNeutroX = width/2 + 20 * escalaX;
    btnPeligrosoY = panelY + 315 * escalaY;
    btnNeutroY = panelY + 315 * escalaY;

    boolean mouseSobrePeligroso = mouseX >= btnPeligrosoX && mouseX <= btnPeligrosoX + btnAncho && mouseY >= btnPeligrosoY && mouseY <= btnPeligrosoY + btnAlto;
    boolean mouseSobreNeutro = mouseX >= btnNeutroX && mouseX <= btnNeutroX + btnAncho && mouseY >= btnNeutroY && mouseY <= btnNeutroY + btnAlto;
    if (mouseSobrePeligroso) opcionTerminal = 0;
    else if (mouseSobreNeutro) opcionTerminal = 1;

    boolean activoPeligroso = (opcionTerminal == 0) || mouseSobrePeligroso;
    fill(activoPeligroso ? color(235, 45, 55) : color(135, 18, 28));
    stroke(activoPeligroso ? color(255, 220, 220) : color(255, 80, 80));
    strokeWeight(activoPeligroso ? 3.2 * escalaY : 1.5 * escalaY);
    rect(btnPeligrosoX, btnPeligrosoY, btnAncho, btnAlto, 8 * escalaY);
    fill(255);
    textSize(20 * escalaY);
    text("[1] PELIGROSO", btnPeligrosoX + btnAncho/2, btnPeligrosoY + btnAlto/2);

    boolean activoNeutro = (opcionTerminal == 1) || mouseSobreNeutro;
    fill(activoNeutro ? color(40, 165, 235) : color(18, 80, 135));
    stroke(activoNeutro ? color(220, 245, 255) : color(100, 200, 255));
    strokeWeight(activoNeutro ? 3.2 * escalaY : 1.5 * escalaY);
    rect(btnNeutroX, btnNeutroY, btnAncho, btnAlto, 8 * escalaY);
    fill(255);
    textSize(20 * escalaY);
    text("[2] NEUTRO", btnNeutroX + btnAncho/2, btnNeutroY + btnAlto/2);

    fill(185, 210, 195);
    textSize(15 * escalaY);
    text("A/D o Click: Seleccionar   |   ENTER: Confirmar   |   ESC: Cerrar", width/2, panelY + panelAlto - 28 * escalaY);
    noStroke();
  }
}

void iniciarCargaNivel(int nivel) {
  cargandoNivel = true;
  nivelACargar = nivel;
  tiempoInicioCarga = millis();
  cargaProcesada = false;
  pausa = false;
  nivelCompletado = false;
  juegoTerminado = false;
  tiempoMuerte = 0;
  sonidoDerrotaReproducido = false;
  tiempoVictoria = 0;
  sonidoVictoriaReproducido = false;
  botonvictoria = 0;
  tiempoInicioTerminal = 0;
  ultimoRastroVisto = -1;
}

// Pre-carga y sube las texturas a la VRAM de la GPU para que no haya micro-tirones (lag) al entrar al nivel
void precalentarTexturas() {
  pushMatrix();
  translate(0, 0, -20000);
  noStroke();
  fill(0, 0);

  for (int n = 0; n < texturaDe.length; n++) {
    if (texturaDe[n] != null) {
      beginShape(QUADS);
      texture(texturaDe[n]);
      vertex(0, 0, 0, 0);
      vertex(1, 0, 1, 0);
      vertex(1, 1, 1, 1);
      vertex(0, 1, 0, 1);
      endShape();
    }
  }

  if (texBanda != null) {
    beginShape(QUADS);
    texture(texBanda);
    vertex(0, 0, 0, 0);
    vertex(1, 0, 1, 0);
    vertex(1, 1, 1, 1);
    vertex(0, 1, 0, 1);
    endShape();
  }

  if (texturaNivel2 != null) {
    beginShape(QUADS);
    texture(texturaNivel2);
    vertex(0, 0, 0, 0);
    vertex(1, 0, 1, 0);
    vertex(1, 1, 1, 1);
    vertex(0, 1, 0, 1);
    endShape();
  }

  popMatrix();
}

// Dibuja un reloj de arena minimalista que rota suavemente (borde rojo, adentro blanco)
void dibujarRelojDeArena(float x, float y, float tamano, float rot) {
  pushMatrix();
  translate(x, y);
  rotate(rot);

  float w = tamano * 0.64;
  float h = tamano;

  // 1. Arena interior (ADENTRO BLANCO)
  noStroke();
  fill(255); // Blanco puro

  // Arena acumulada en el bulbo inferior
  triangle(-w * 0.36, h/2 - 4, w * 0.36, h/2 - 4, 0, h * 0.16);

  // Arena en el bulbo superior cayendo
  triangle(-w * 0.30, -h/2 + 6, w * 0.30, -h/2 + 6, 0, -h * 0.1);

  // Hilo de arena cayendo por el cuello central (blanco)
  stroke(255);
  strokeWeight(3);
  line(0, -h * 0.1, 0, h * 0.28);

  // 2. Borde y tapas del reloj (BORDE ROJO MAS GRUESO)
  stroke(235, 30, 45); // Rojo vivo cyberpunk
  strokeWeight(4.5);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  noFill();

  // Tapa superior e inferior
  line(-w/2, -h/2, w/2, -h/2);
  line(-w/2, h/2, w/2, h/2);

  // Cristal en forma de X (los dos bulbos unidos)
  line(-w/2, -h/2, 0, 0);
  line( w/2, -h/2, 0, 0);
  line( 0, 0, -w/2, h/2);
  line( 0, 0, w/2, h/2);

  popMatrix();
  noStroke();
}

// Dibuja la pantalla negra con el texto grande y el reloj de arena en la esquina inferior derecha
void dibujarPantallaDeCarga() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  background(0); // Pantalla completamente negra

  float tiempoTranscurrido = millis() - tiempoInicioCarga;

  // Coordenadas en la esquina inferior derecha (mÃ¡s espaciadas y grandes)
  float margenDer = 75 * escalaX;
  float margenAbj = 70 * escalaY;
  float relojX = width - margenDer;
  float relojY = height - margenAbj;

  // 1. Reloj de arena mÃ¡s grande (tamaÃ±o 70 px) con rotaciÃ³n continua
  float rotacion = tiempoTranscurrido * 0.0035;
  dibujarRelojDeArena(relojX, relojY, 70 * escalaY, rotacion);

  // 2. Palabra "CARGANDO..." mÃ¡s grande (tamaÃ±o 54 px, fuente Black Mustang, color blanco)
  fill(255);
  textAlign(RIGHT, CENTER);
  aplicarFuente(fuente1); // Black Mustang
  textSize(54 * escalaY);
  text("CARGANDO...", relojX - 55 * escalaX, relojY - 4 * escalaY);

  // 3. Proceso interno de carga de recursos y texturas (despuÃ©s de mostrar el primer frame)
  if (tiempoTranscurrido > 80 && !cargaProcesada) {
    precalentarTexturas();
    if (nivelACargar == 1) {
      nivelActual = 1;
      reiniciarJuego();
      if (cinematicaNivel1 == null) {
        try {
          try { cinematicaNivel1 = new Movie(this, "cinematica1.mp4"); } catch (Exception _e) { cinematicaNivel1 = new Movie(this, "CINEMATICA 1.mp4"); }
        } catch (Exception e) {
          println("Error al instanciar CINEMATICA 1.mp4: " + e);
        }
      }
    } else if (nivelACargar == 2) {
      nivelActual = 2;
      iniciarNivel2();
    } else if (nivelACargar == 3) {
      nivelActual = 3;
      iniciarNivel3();
      if (cinematicaNivel3 == null) {
        try {
          cinematicaNivel3 = new Movie(this, "CINEMATICA2.mp4");
        } catch (Exception _e) {
          try { cinematicaNivel3 = new Movie(this, "cinematica2.mp4"); } catch (Exception _e2) {}
        }
      }
    }
    cargaProcesada = true;
  }

  // 4. Terminar la pantalla de carga tras un tiempo suave para ver la transición
  if (tiempoTranscurrido >= 1400 && cargaProcesada) {
    cargandoNivel = false;
    tiempoInicioMisionActiva = millis();
    avisoObjetivoDescartado = false;
    if (Audioprueba != null && Audioprueba.isPlaying()) {
      Audioprueba.stop();
    }
    if (menu != null && menu.isPlaying()) {
      menu.stop();
    }

    if (nivelACargar == 1 && debeReproducirCinematica) {
      iniciarCinematicaNivel1();
    } else {
      PantallaDeJuego = 1;
      noStroke();
    }
  }

  hint(ENABLE_DEPTH_TEST);
}

// =========================================================
// SISTEMA DE CRISTAL ROTO DMC3 (LA PANTALLA NEGRA SE PARTE)
// =========================================================
int NUM_SHARDS = 60;
float[] shardCX = new float[NUM_SHARDS];
float[] shardCY = new float[NUM_SHARDS];
float[] shardX0 = new float[NUM_SHARDS];
float[] shardY0 = new float[NUM_SHARDS];
float[] shardX1 = new float[NUM_SHARDS];
float[] shardY1 = new float[NUM_SHARDS];
float[] shardX2 = new float[NUM_SHARDS];
float[] shardY2 = new float[NUM_SHARDS];
float[] shardVX = new float[NUM_SHARDS];
float[] shardVY = new float[NUM_SHARDS];
float[] shardRot = new float[NUM_SHARDS];

int NUM_DEBRIS = 40;
float[] debX = new float[NUM_DEBRIS];
float[] debY = new float[NUM_DEBRIS];
float[] debVX = new float[NUM_DEBRIS];
float[] debVY = new float[NUM_DEBRIS];
float[] debSize = new float[NUM_DEBRIS];

boolean shardsGenerados = false;

void generarFragmentosCristal() {
  int cols = 5;
  int rows = 3;
  float W = REF_W;
  float H = REF_H;

  float[][] pts = new float[(rows + 1) * (cols + 1)][2];
  for (int r = 0; r <= rows; r++) {
    for (int c = 0; c <= cols; c++) {
      float x = (c / (float)cols) * W;
      float y = (r / (float)rows) * H;
      // Jitter interior vertices only to keep outer screen boundaries clean
      if (c > 0 && c < cols) x += random(-40, 40);
      if (r > 0 && r < rows) y += random(-30, 30);
      int idx = r * (cols + 1) + c;
      pts[idx][0] = x;
      pts[idx][1] = y;
    }
  }

  int sIdx = 0;
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      int idxTL = r * (cols + 1) + c;
      int idxTR = r * (cols + 1) + (c + 1);
      int idxBR = (r + 1) * (cols + 1) + (c + 1);
      int idxBL = (r + 1) * (cols + 1) + c;

      float pTLx = pts[idxTL][0], pTLy = pts[idxTL][1];
      float pTRx = pts[idxTR][0], pTRy = pts[idxTR][1];
      float pBRx = pts[idxBR][0], pBRy = pts[idxBR][1];
      float pBLx = pts[idxBL][0], pBLy = pts[idxBL][1];

      float centX = (pTLx + pTRx + pBRx + pBLx) * 0.25 + random(-25, 25);
      float centY = (pTLy + pTRy + pBRy + pBLy) * 0.25 + random(-20, 20);

      float[][][] tris = {
        {{pTLx, pTLy}, {pTRx, pTRy}, {centX, centY}},
        {{pTRx, pTRy}, {pBRx, pBRy}, {centX, centY}},
        {{pBRx, pBRy}, {pBLx, pBLy}, {centX, centY}},
        {{pBLx, pBLy}, {pTLx, pTLy}, {centX, centY}}
      };

      for (int t = 0; t < 4 && sIdx < NUM_SHARDS; t++) {
        float tcx = (tris[t][0][0] + tris[t][1][0] + tris[t][2][0]) / 3.0;
        float tcy = (tris[t][0][1] + tris[t][1][1] + tris[t][2][1]) / 3.0;

        shardCX[sIdx] = tcx;
        shardCY[sIdx] = tcy;

        shardX0[sIdx] = tris[t][0][0] - tcx;
        shardY0[sIdx] = tris[t][0][1] - tcy;
        shardX1[sIdx] = tris[t][1][0] - tcx;
        shardY1[sIdx] = tris[t][1][1] - tcy;
        shardX2[sIdx] = tris[t][2][0] - tcx;
        shardY2[sIdx] = tris[t][2][1] - tcy;

        float dx = tcx - (W * 0.5);
        float dy = tcy - (H * 0.5);
        float dist = max(1.0, sqrt(dx * dx + dy * dy));
        float speed = random(280, 560) + (dist / (W * 0.5)) * 220;

        shardVX[sIdx] = (dx / dist) * speed + random(-40, 40);
        shardVY[sIdx] = (dy / dist) * speed + random(-130, 25);
        shardRot[sIdx] = random(-2.2, 2.2);

        sIdx++;
      }
    }
  }

  // Esquirlas menores de vidrio
  for (int i = 0; i < NUM_DEBRIS; i++) {
    float ang = random(0, TWO_PI);
    float sp = random(260, 600);
    debX[i] = (W * 0.5) + random(-220, 220);
    debY[i] = (H * 0.5) + random(-150, 150);
    debVX[i] = cos(ang) * sp;
    debVY[i] = sin(ang) * sp - random(80, 200);
    debSize[i] = random(7, 16);
  }

  shardsGenerados = true;
}

void dibujarFragmentosCristal(float tQuiebreMs) {
  if (tQuiebreMs < 0 || tQuiebreMs > 1600) return;
  if (!shardsGenerados) {
    generarFragmentosCristal();
  }
  float dt = constrain(tQuiebreMs / 1000.0, 0.0, 1.6);
  float alfaShatter = map(tQuiebreMs, 0, 1400, 255, 0);
  if (alfaShatter <= 5) return;

  float grav = 1350.0;

  // 1. Shards de cristal negro con bordes afilados blancos brillantes
  for (int i = 0; i < NUM_SHARDS; i++) {
    float px = (shardCX[i] + shardVX[i] * dt) * escalaX;
    float py = (shardCY[i] + shardVY[i] * dt + 0.5 * grav * dt * dt) * escalaY;
    float ang = shardRot[i] * dt;

    pushMatrix();
    translate(px, py);
    rotate(ang);

    // Cuerpo negro del cristal (es la pantalla negra partida)
    fill(5, 5, 8, alfaShatter);
    // Borde filoso de fractura blanco brillante
    stroke(255, 255, 255, alfaShatter);
    strokeWeight(3.0 * escalaY);

    triangle(shardX0[i] * escalaX, shardY0[i] * escalaY,
             shardX1[i] * escalaX, shardY1[i] * escalaY,
             shardX2[i] * escalaX, shardY2[i] * escalaY);
    popMatrix();
  }

  // 2. Esquirlas de diamante brillantes
  for (int i = 0; i < NUM_DEBRIS; i++) {
    float dx = (debX[i] + debVX[i] * dt) * escalaX;
    float dy = (debY[i] + debVY[i] * dt + 0.5 * grav * dt * dt) * escalaY;
    float sz = debSize[i] * escalaY;
    fill(255, 255, 255, alfaShatter);
    stroke(200, 240, 255, alfaShatter);
    strokeWeight(1.5 * escalaY);
    rect(dx - sz * 0.5, dy - sz * 0.5, sz, sz);
  }

  noStroke();
}


// =========================================================
// PANTALLA DE CARGA INICIAL (ARRANQUE DEL JUEGO)
// =========================================================
void dibujarPantallaDeCargaInicio() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  background(0);

  float tiempoTranscurrido = millis() - tiempoInicioCargaInicio;

  float margenDer = 75 * escalaX;
  float margenAbj = 70 * escalaY;
  float relojX = width - margenDer;
  float relojY = height - margenAbj;

  float rotacion = tiempoTranscurrido * 0.0035;
  dibujarRelojDeArena(relojX, relojY, 70 * escalaY, rotacion);

  fill(255);
  textAlign(RIGHT, CENTER);
  aplicarFuente(fuente1);
  textSize(54 * escalaY);
  text("CARGANDO...", relojX - 55 * escalaX, relojY - 4 * escalaY);

  if (tiempoTranscurrido > 60 && !cargaInicioProcesada) {
    ejecutarCargaInicio();
  }

  if (cargaInicioProcesada && tiempoTranscurrido >= 1200) {
    cargandoInicio = false;
    PantallaDeJuego = 0;
    pantalla = pantallacarga;
    tiempo = millis();
    if (menu != null) {
      menu.loop();
    }
    if (Audioprueba != null) {
      Audioprueba.amp(1);
      Audioprueba.loop();
    }
    noStroke();
  }

  hint(ENABLE_DEPTH_TEST);
}

// =========================================================
// CINEMATICA NIVEL 1 CON DEGRADADO (TINT) AL NIVEL
// =========================================================
void iniciarCinematicaNivel1() {
  reproduciendoCinematica = true;
  tiempoInicioCinematica = millis();
  tiempoInicioFadeCinematica = -1;
  if (cinematicaNivel1 != null) {
    cinematicaNivel1.jump(0);
    cinematicaNivel1.play();
  }
}

void saltarCinematica() {
  if (reproduciendoCinematica && (millis() - tiempoInicioCinematica > 350)) {
    if (tiempoInicioFadeCinematica == -1) {
      tiempoInicioFadeCinematica = millis();
    } else {
      tiempoInicioFadeCinematica = millis() - FADE_CINEMATICA_DURACION - 100;
    }
  }
}

void dibujarCinematica() {
  if (cinematicaNivel1 == null) {
    reproduciendoCinematica = false;
    PantallaDeJuego = 1;
    return;
  }

  float dur = cinematicaNivel1.duration();
  float pos = cinematicaNivel1.time();
  int tDesdeInicio = millis() - tiempoInicioCinematica;

  if (dur > 0 && pos >= dur - 1.6 && tiempoInicioFadeCinematica == -1) {
    tiempoInicioFadeCinematica = millis();
  }

  if (tiempoInicioFadeCinematica == -1) {
    camera();
    hint(DISABLE_DEPTH_TEST);
    noLights();
    background(0);

    float alfaIn = constrain(map(tDesdeInicio, 0, 900, 0, 255), 0, 255);
    tint(255, alfaIn);
    if (cinematicaNivel1.width > 0) {
      image(cinematicaNivel1, 0, 0, width, height);
    }
    noTint();

    fill(255, 140);
    textAlign(RIGHT, BOTTOM);
    aplicarFuente(fuenteTexto);
    textSize(22 * escalaY);
    text("[ESPACIO / ENTER] Saltar", width - 35 * escalaX, height - 25 * escalaY);

    hint(ENABLE_DEPTH_TEST);
  } else {
    float tFade = millis() - tiempoInicioFadeCinematica;
    float progreso = tFade / (float)FADE_CINEMATICA_DURACION;

    if (progreso >= 1.0) {
      cinematicaNivel1.stop();
      reproduciendoCinematica = false;
      PantallaDeJuego = 1;
      noStroke();
      return;
    }

    PantallaDeJuego = 1;
    actualizarCamara();
    background(5, 9, 16);
    ambientLight(150, 150, 150);
    luzDeBandas();
    dibujarMapa();
    dibujarSalidaNivel1();
    dibujarEnemigos();
    dibujarProyectiles();
    terminales();
    dibujarJugador();

    camera();
    hint(DISABLE_DEPTH_TEST);
    noLights();

    float alfaVideo = constrain(map(progreso, 0, 1.0, 255, 0), 0, 255);
    tint(255, alfaVideo);
    if (cinematicaNivel1.width > 0) {
      image(cinematicaNivel1, 0, 0, width, height);
    }
    noTint();

    hint(ENABLE_DEPTH_TEST);
  }
}

void dibujarAvisoObjetivoNivel() {
  if (avisoObjetivoDescartado) return;
  int t = millis() - tiempoInicioMisionActiva;
  if (t < 0 || t > 7500) return;

  float alfa = (t > 6800) ? map(t, 6800, 7500, 255, 0) : 255;
  float pSlide = constrain(t / 250.0, 0.0, 1.0);
  float eSlide = 1.0 - pow(1.0 - pSlide, 3);
  float yDestino = (nivelActual == 3 && jefeNivel3Iniciado) ? 112 : 68;
  float yBase = -160 + eSlide * (160 + yDestino);

  pushMatrix();
  translate(width / 2.0, yBase * escalaY);

  float anchoCaja = 940 * escalaX;
  float altoCaja = 135 * escalaY;

  // Fondo Cyberpunk Noir con acento ROJO de Remanente
  fill(18, 6, 8, constrain(alfa * 0.95, 0, 245));
  stroke(225, 25, 35, alfa);
  strokeWeight(2.5 * escalaY);
  rect(-anchoCaja / 2.0, 0, anchoCaja, altoCaja, 8);
  noStroke();

  fill(225, 25, 35, alfa);
  rect(-anchoCaja / 2.0, 0, anchoCaja, 5 * escalaY, 4, 4, 0, 0);

  fill(255, 50, 60, alfa);
  aplicarFuente(fuente1);
  textSize(20 * escalaY);
  textAlign(LEFT, TOP);
  text("[ TRANSMISION CIFRADA // DANTE - OFICINA CLANDESTINA ]", (-anchoCaja / 2.0 + 20 * escalaX), 12 * escalaY);

  aplicarFuente(fuenteTexto);
  fill(255, 255, 255, alfa);
  textSize(18 * escalaY);
  textLeading(23 * escalaY);

  if (nivelActual == 1) {
    text("«Walt, el clon ya va por el 85% de sincronizacion. Si llega al 100%, tu cliente esta acabado.»\nOBJETIVO: Neutraliza a todos los Centinelas de Kaze Corp y cruza el portal de codigo rojo.",
      (-anchoCaja / 2.0 + 20 * escalaX), 38 * escalaY, anchoCaja - 40 * escalaX, altoCaja - 45 * escalaY);
  } else if (nivelActual == 2) {
    text("«Tu senal se fragmenta. Estas dentro de los servidores centrales de Kaze Corp.»\nOBJETIVO: Sortea las torretas sobre el vacio digital y alcanza el nodo de enlace superior.",
      (-anchoCaja / 2.0 + 20 * escalaX), 38 * escalaY, anchoCaja - 40 * escalaX, altoCaja - 45 * escalaY);
  } else {
    text("«Ya encontramos el rastro del clon en el nucleo. Cierra el nodo desde adentro.»\nOBJETIVO: Penetra el laberinto de datos y destruye a ARGOS para colapsar la conexion.",
      (-anchoCaja / 2.0 + 20 * escalaX), 38 * escalaY, anchoCaja - 40 * escalaX, altoCaja - 45 * escalaY);
  }

  fill(160, 175, 190, alfa * 0.85);
  aplicarFuente(fuente1);
  textSize(14 * escalaY);
  textAlign(RIGHT, BOTTOM);
  text("[ESPACIO / ENTER / CLICK PARA DESCARTAR]", (anchoCaja / 2.0 - 18 * escalaX), altoCaja - 8 * escalaY);

  popMatrix();
  textAlign(LEFT, BASELINE);
  aplicarFuente(fuente1);
}

// =========================================================
// CINEMATICA NIVEL 3 (FINAL) CON TRANSICION A VICTORIA
// =========================================================
void iniciarCinematicaNivel3() {
  if (reproduciendoCinematicaNivel3) return;
  if (sonidoCorrer != null) try { sonidoCorrer.stop(); } catch (Exception e) {}
  if (sonidoCaminar != null) try { sonidoCaminar.stop(); } catch (Exception e) {}
  pausa = false;
  volumenPausa = false;
  controlesPausa = false;

  if (cinematicaNivel3 == null) {
    try {
      cinematicaNivel3 = new Movie(this, "CINEMATICA2.mp4");
    } catch (Exception e) {
      try {
        cinematicaNivel3 = new Movie(this, "cinematica2.mp4");
      } catch (Exception ex) {
        println("Error cargando CINEMATICA2.mp4: " + ex);
      }
    }
  }

  if (cinematicaNivel3 != null) {
    reproduciendoCinematicaNivel3 = true;
    tiempoInicioCinematicaNivel3 = millis();
    try {
      cinematicaNivel3.jump(0);
      cinematicaNivel3.play();
    } catch (Exception e) {
      println("Error al reproducir cinematica 2: " + e);
      terminarCinematicaNivel3YMostrarVictoria();
    }
  } else {
    terminarCinematicaNivel3YMostrarVictoria();
  }
}

void saltarCinematicaNivel3() {
  if (reproduciendoCinematicaNivel3 && (millis() - tiempoInicioCinematicaNivel3 > 1200)) {
    terminarCinematicaNivel3YMostrarVictoria();
  }
}

void terminarCinematicaNivel3YMostrarVictoria() {
  if (cinematicaNivel3 != null) {
    try { cinematicaNivel3.stop(); } catch (Exception e) {}
  }
  reproduciendoCinematicaNivel3 = false;
  nivelCompletado = true;
  tiempoVictoria = millis();
  sonidoVictoriaReproducido = false;
  shardsGenerados = false;
}

void dibujarCinematicaNivel3() {
  if (cinematicaNivel3 == null) {
    terminarCinematicaNivel3YMostrarVictoria();
    return;
  }

  float dur = cinematicaNivel3.duration();
  float pos = cinematicaNivel3.time();
  int t = millis() - tiempoInicioCinematicaNivel3;

  if ((t > 1000 && dur > 0 && pos >= dur - 0.25) || (dur > 0 && t > (dur * 1000 + 800))) {
    terminarCinematicaNivel3YMostrarVictoria();
    return;
  }

  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  background(0);

  if (cinematicaNivel3.width > 0) {
    image(cinematicaNivel3, 0, 0, width, height);
  }

  fill(255, 160);
  textAlign(RIGHT, BOTTOM);
  aplicarFuente(fuente1);
  textSize(22 * escalaY);
  text("[ESPACIO / ENTER / CLICK] Continuar", width - 35 * escalaX, height - 25 * escalaY);

  hint(ENABLE_DEPTH_TEST);
}
