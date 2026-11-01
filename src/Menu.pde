// ============================================================================
// MODULO: Menu.pde
// DESCRIPCION:
//   Sistema de interfaz grafica del menu principal, secuencia de introduccion
//   con logos, selector de misiones con vista previa narrativa, ajustes de
//   volumen, visor de controles, detras del codigo y creditos interactivos.
// ============================================================================
// MENU: variables y pantallas (Menu() dibuja todas)
SoundFile Audioprueba;

SoundFile jugar;
SoundFile navegar;
SoundFile seleccionar;
SoundFile no;
SoundFile salir;
SoundFile iniciar;
SoundFile transicionBalas;
SoundFile sonidoCaminar;
SoundFile sonidoCorrer;
SoundFile sonidoDash;
SoundFile sonidoParry;
SoundFile sonidoSalto;
SoundFile sonidoHit;
SoundFile sonidoUlti;
SoundFile sonidoDisparo;
SoundFile sonidoCristal;


//animacion inicio
float brillo;
boolean animacion =false;
int tiempo = 0, tiempoTranscurrido;
//pantallas y ventanas
int pantallacarga = -1, pantallainicio = 0, pantallamenu = 1, pantallaopciones = 2, pantallajugar = 3, pantalla = pantallacarga;
boolean ventanasalir = false, volumen = false, escogernivel=false, detrasdelcodigo = false, creditos=false, controles=false;
int botonselleccionmenu=0, botonseleccionsalir=0, botonopciones=0, botonvolumen = 5, botonniveles = 0, eleccionnivel=0, botondetrasdelcodigo=0, slidescreditos=0, slidesdetras=0, slidescontroles=0, botonpausa=0, botonderrota=0, botonvictoria=0;//botones IMPORTANTE: BOTONVOLUMEN ES INICIALIZADO EN 1PARA PODER SUBIR Y BAJAR VOLUMEN A GUSTO

//variables para el destello de los triangulos de creditos al presionar
int tiempoFlashIzq = -10000;
int tiempoFlashDer = -10000;
int duracionFlashTriangulo = 150; //milisegundos que dura el destello blanco antes de volver a gris

// Variables para transiciones y animaciones
int tiempoInicioMenuPrincipal = -10000;
int tiempoInicioOpciones = -10000;
int tiempoInicioSubOpcion = -10000;
int ultimoBotonNiveles = -1;
int tiempoInicioMisionTexto = 0;
boolean volumenPausa = false;
boolean controlesPausa = false;
int slidescontrolesPausa = 0;
int tiempoInicioPausa = -10000;
int tiempoInicioVentanaSalir = -10000;
float volumenVisual = 5.0;
int tiempoDestelloTriangNivelIzq = -10000;
int tiempoDestelloTriangNivelDer = -10000;
int tiempoInicioMisionActiva = -10000;
boolean avisoObjetivoDescartado = false;

//ESTETICA LETRAS
int i, j;
int grueso1X[] = {-4, 4, 0, 0, -2, 2, -2, 2, -3, 3, -3, 3};
int grueso1Y[] = {0, 0, -4, 4, -2, -2, 2, 2, -3, -3, 3, 3};
int grueso2X[] = {-7, 7, 0, 0, -5, 5, -5, 5, -4, 4, 0, 0, -2, 2, -2, 2, -3, 3, -3, 3};
int grueso2Y[] = {0, 0, -7, 7, -5, -5, 5, 5, 0, 0, -4, 4, -2, -2, 2, 2, -3, -3, 3, 3};
//FUENTE
PFont fuente;
PFont fuente1;
//FUENTE DE LOS TEXTOS LARGOS (Blacky.otf): marcos de CREDITOS, DETRAS DEL CODIGO y CONTROLES, y explicacion de los niveles
PFont fuenteTexto;
//VARIABLES RESOLUCION
float REF_W = 1536;
float REF_H = 864;
float escalaX;
float escalaY;

//VOLUMEN
float volumenInicio=0.5;
float volumenjuego=0.5;
//IMAGENES
PImage logo;
PImage breakingbugs;
PImage iconomando;

PImage imagenmenu;
PImage imagenjugar;
PImage mision1Preview;
PImage mision2Preview;
PImage mision3Preview;
PImage opciones, creditosdetras;
PImage ventanasalirimagen;
PImage grietas;
PImage grietasBlancas;
PImage caja;
PImage derrota;
PImage fondoderrota;
PImage balazo;
PImage victoriaImg;
PImage victoriaFondo;

//CADENAS
String titulosniveles="", informacionniveles="", cargarnivel="CARGAR MISION", infosalir="", infoopciones="";

int tiempoAnimSalir = 0;

color rojo = color(200, 15, 15);
color negro = color (0);

// Dibuja todas las pantallas del menu (antes era el draw() del menu)
void Menu() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  textAlign(LEFT, BASELINE);
  rectMode(CORNER);
  imageMode(CORNER);
  aplicarFuente(fuente1);
  noStroke();

  if (tiempo == 0) tiempo = millis();

  //VARIABLES PARA LA RESLUCION
  escalaX = width / REF_W;
  escalaY = height / REF_H;

  // Asegura que el video del menu se mantenga en loop continuo
  if (menu != null && menu.duration() > 0) {
    if (menu.duration() - menu.time() < 0.15 || !menu.isPlaying()) {
      menu.jump(0);
      menu.play();
    }
  }

  // Reseteo automatico de timers de animacion cuando no se esta en esa pantalla
  if (pantalla != pantallamenu) {
    tiempoInicioMenuPrincipal = -10000;
  }
  if (pantalla != pantallaopciones) {
    tiempoInicioOpciones = -10000;
    tiempoInicioSubOpcion = -10000;
  }

  if (pantalla==pantallacarga) {

    background(0);
    tiempoTranscurrido = millis() - tiempo;
    int t = tiempoTranscurrido;
    fill(219, 252, 8);
    //IMPORTANTE:CINEMATICA DEL INICIO CON LOS LOGOS
    if (t < 1000) {
      tint(255, map(t, 0, 1000, 0, 255));
      image(breakingbugs, 0, 0, REF_W * escalaX, REF_H * escalaY);
    } else {
      if (t < 2000) {
        tint(255);
        image(breakingbugs, 0, 0, REF_W * escalaX, REF_H * escalaY);
      } else {
        if (t < 3000) {
          tint(255, map(t, 2000, 3000, 255, 0));
          image(breakingbugs, 0, 0, REF_W * escalaX, REF_H * escalaY);
        } else {

          //SEGUNDA IMAGEN
          if (t < 4000) {
            tint(255, map(t, 3000, 4000, 0, 255));
            image(iconomando, 0, 0, REF_W * escalaX, REF_H * escalaY);
          } else {
            if (t < 5000) {
              tint(255);
              image(iconomando, 0, 0, REF_W * escalaX, REF_H * escalaY);
            } else {
              if (t < 6000) {
                tint(255, map(t, 5000, 6000, 255, 0));
                image(iconomando, 0, 0, REF_W * escalaX, REF_H * escalaY);
              } else {
                pantalla = pantallainicio;
              }
            }
          }
        }
      }
    }
    noTint();
    

    if (t>3000) {
      textAlign(CENTER);
      fill(96, 96, 98);
      textSize(35*escalaY);
      aplicarFuente(fuenteTexto);
      text("PRESIONA CUALQUIER TECLA PARA OMITIR", (REF_W / 2.0) * escalaX, 824*escalaY);
      aplicarFuente(fuente1); //
      textAlign(LEFT);
    }
  }

  if (pantalla==pantallainicio) {
    background(200, 15, 15);
    if (menu != null && menu.width > 0) {
      image(menu, 0, 0, REF_W * escalaX, REF_H * escalaY);
    } else {
      image(imagenmenu, 0, 0, REF_W * escalaX, REF_H * escalaY);
    }

    float posXTextoInicio = 140;

    if (animacion) {
      tiempoTranscurrido = millis() - tiempo;
      int tAnim = tiempoTranscurrido;

      // 1. Parpadeo de confirmacion
      if ((tAnim / 40) % 2 == 0) {
        fill(255);
      } else {
        fill(185, 190, 200);
      }

      // 2. Transicion hacia la derecha saliendo de pantalla
      if (tAnim >= 250) {
        float progreso = constrain((tAnim - 250.0) / 450.0, 0.0, 1.0);
        float factorCurva = (1.35 + 1.0) * pow(progreso, 3) - 1.35 * pow(progreso, 2);

        posXTextoInicio = 140 + factorCurva * 1600.0;
      }

      // 3. Pasar al menu principal al completar
      if (tAnim >= 700) {
        pantalla = pantallamenu;
        tiempoInicioMenuPrincipal = millis();
        botonselleccionmenu = 0;
        tiempoAnim = millis();
        animacion = false;
      }
    } else {
      brillo = map(sin(millis() * 0.005), -1, 1, 100, 255);
      fill(brillo);
    }

    // Imagen del logo estatica (sin desplazamiento) en posicion estrategica
    if (logo != null && logo.width > 0) {
      float anchoLogo = 220.0 * logo.width / logo.height;
      image(logo, 780 * escalaX, 70 * escalaY, anchoLogo * escalaX, 220 * escalaY);
    }
    

    // BORDE Y TEXTO PULSE BOTON
    fill(0);
    crearboton("PRESIONA CUALQUIER BOTON PARA EMPEZAR", posXTextoInicio, 750, 90);

    if (animacion) {
      int tAnim = millis() - tiempo;
      if ((tAnim / 40) % 2 == 0) {
        fill(255);
      } else {
        fill(185, 190, 200);
      }
    } else {
      fill(brillo);
    }
    textSize(90*escalaY);
    text("PRESIONA CUALQUIER BOTON PARA EMPEZAR", posXTextoInicio*escalaX, 750*escalaY);
  }

  //MENU LOGICA
  if (pantalla == pantallamenu) {
    textAlign(LEFT, BASELINE);
    aplicarFuente(fuente1);
    background(200, 15, 15);
    if (menu != null && menu.width > 0) {
      image(menu, 0, 0, REF_W * escalaX, REF_H * escalaY);
    } else {
      image(imagenmenu, 0, 0, REF_W * escalaX, REF_H * escalaY);
    }
    

    // Logo en el menu principal (en posicion estrategica para observar el tren y fondo)
    if (logo != null && logo.width > 0) {
      float anchoLogo = 220.0 * logo.width / logo.height;
      image(logo, 780 * escalaX, 70 * escalaY, anchoLogo * escalaX, 220 * escalaY);
    }

    if (tiempoInicioMenuPrincipal < 0) {
      tiempoInicioMenuPrincipal = millis();
    }
    int tiempoMenu = millis() - tiempoInicioMenuPrincipal;

    // 1. Despliegue de la franja negra
    noStroke();
    fill(0);
    float anchoFranja = REF_W * escalaX;
    if (tiempoMenu < 200) {
      float progresoFranja = constrain(tiempoMenu / 200.0, 0.0, 1.0);
      float curvaFranja = 1.0 - pow(1.0 - progresoFranja, 3);
      anchoFranja = REF_W * escalaX * curvaFranja;
      image(caja,0,342*escalaY,anchoFranja,660*escalaY);

    } else {
      image(caja,0,342*escalaY,anchoFranja,660*escalaY);
    }

    // 2. Cascada de botones con transicion (JUGAR, OPCIONES, SALIR)
    if (tiempoMenu >= 180) {
      float p = constrain((tiempoMenu - 180) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoMenu >= 340) ? 690 : (690 - (1.0 - e) * 70.0);
      animacionboton(botonselleccionmenu, 0, "JUGAR", x, 704, 68, rojo);
    }

    if (tiempoMenu >= 240) {
      float p = constrain((tiempoMenu - 240) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoMenu >= 400) ? 970 : (970 - (1.0 - e) * 70.0);
      animacionboton(botonselleccionmenu, 1, "OPCIONES", x, 704, 68, rojo);
    }

    if (tiempoMenu >= 300) {
      float p = constrain((tiempoMenu - 300) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoMenu >= 460) ? 1307 : (1307 - (1.0 - e) * 70.0);
      animacionboton(botonselleccionmenu, 2, "SALIR", x, 704, 68, rojo);
    }
  }




  if (pantalla==pantallajugar) {
    background(200, 15, 15);
    image(imagenjugar, 0, 0, REF_W * escalaX, REF_H * escalaY);

    // LOGO ESTRATEGICO EN ESQUINA SUPERIOR DERECHA (AMPLIO Y SIN ANIMACION)
    if (logo != null && logo.width > 0) {
      float anchoLogo = 380.0 * escalaX;
      float altoLogo = anchoLogo / 3.0;
      image(logo, width - (anchoLogo + 40 * escalaX), 25 * escalaY, anchoLogo, altoLogo);
    }

    

    fill(0);
    crearboton("MISIONES", 90, 200, 120);
    fill(255);
    textSize(120*escalaY);
    text("MISIONES", 90*escalaX, 200*escalaY);

    if (botonniveles == 0 && mision1Preview != null && mision1Preview.width > 0) {
      image(mision1Preview, 726*escalaX, 240*escalaY, 749*escalaX, 549*escalaY);
    } else if (botonniveles == 1 && mision2Preview != null && mision2Preview.width > 0) {
      image(mision2Preview, 726*escalaX, 240*escalaY, 749*escalaX, 549*escalaY);
    } else if (botonniveles == 2 && mision3Preview != null && mision3Preview.width > 0) {
      image(mision3Preview, 726*escalaX, 240*escalaY, 749*escalaX, 549*escalaY);
    } else {
      fill(219, 252, 8);
      rect(726*escalaX, 240*escalaY, 749*escalaX, 549*escalaY);
    }

    stroke(255);
    strokeWeight(4 * escalaY);
    line(87*escalaX, 214*escalaY, 1475*escalaX, 214*escalaY);
    noStroke();


    // TRIANGULOS FUNCIONALES DE ELECCION DE NIVELES
    color colTriangNivelIzq = (millis() - tiempoDestelloTriangNivelIzq < 150) ? color(255, 40, 50) : color(150, 30, 35);
    color colTriangNivelDer = (millis() - tiempoDestelloTriangNivelDer < 150) ? color(255, 40, 50) : color(150, 30, 35);
    trianguloBorde(845, 123, 815, 148, 845, 173, colTriangNivelIzq);
    trianguloBorde(1355, 123, 1385, 148, 1355, 173, colTriangNivelDer);

    animacionboton(botonniveles, 0, "1", 913, 200, 120, negro);
    animacionboton(botonniveles, 1, "2", 1100, 200, 120, negro);
    animacionboton(botonniveles, 2, "3", 1278, 200, 120, negro);

    // INFORMACION DE LOS NIVELES SEGUN EL LORE DE REMANENTE
    if (botonniveles == 0) {
      titulosniveles = "ACTO I: LA SINCRONIZACION";
      informacionniveles = "Metropolis Noir. El clon digital del cliente alcanza el 85%. Infiltrate en la red de Kaze Corp, neutraliza a los Centinelas de Datos y cruza el portal de codigo rojo antes de que sea tarde.";
    }
    if (botonniveles == 1) {
      titulosniveles = "ACTO II: INFILTRACION EN LA RED";
      informacionniveles = "Servidores Centrales de Kaze Corp. La senal de Walt se fragmenta. Sortea las torretas defensivas sobre el vacio digital, recolecta los fragmentos y alcanza el nodo de enlace dorado.";
    }
    if (botonniveles == 2) {
      titulosniveles = "ACTO III: EL NODO MAESTRO";
      informacionniveles = "Nucleo profundo de datos. Walt debe cerrar el nodo desde adentro. Supera el laberinto de cortafuegos y destruye a ARGOS, el guardian central de Kaze Corp, para erradicar el clon.";
    }

    // Efecto maquina de escribir al cambiar de mision
    if (ultimoBotonNiveles != botonniveles) {
      ultimoBotonNiveles = botonniveles;
      tiempoInicioMisionTexto = millis();
    }
    int caracteresAMostrar = min(informacionniveles.length(), max(0, (millis() - tiempoInicioMisionTexto) / 20));
    String textoMisionAnimado = informacionniveles.substring(0, caracteresAMostrar);
    if (caracteresAMostrar < informacionniveles.length() || (millis() / 300) % 2 == 0) {
      textoMisionAnimado += "_";
    }

    fill(0);
    crearboton(titulosniveles, 90, 310, 70);
    fill(255);
    textSize(70*escalaY);
    text(titulosniveles, 90*escalaX, 310*escalaY);

    fill(255);
    aplicarFuente(fuenteTexto);
    textSize(35*escalaY);
    text(textoMisionAnimado, 90*escalaX, 350*escalaY, 561* escalaX, 412 * escalaY);
    aplicarFuente(fuente1);

    infosalir="PRESIONE ESC PARA SALIR AL MENU PRINCIPAL";

    if (escogernivel == true) {
      infosalir= "PRESIONE ESC PARA CAMBIAR ELECCION";
      fill(0);
      crearboton(cargarnivel, 90, 788, 60);
      fill(255);
      textSize(60*escalaY);
      text(cargarnivel, 90*escalaX, 788*escalaY);

      animacionboton(eleccionnivel, 0, "SI", 471, 788, 60, negro);
      animacionboton(eleccionnivel, 1, "NO", 600, 788, 60, negro);
    }
    color color1 = color(255);
    color color2 = color(96, 96, 98);
    float mezcla = map(sin(millis() * 0.005), -1, 1, 0, 1);

    color colorFinal = lerpColor(color2, color1, mezcla);

    fill(colorFinal);
    textSize(30*escalaY);
    text(infosalir, 1020*escalaX, 821*escalaY);
  }

  //OPCIONES

  if (pantalla==pantallaopciones) {
    if (tiempoInicioOpciones < 0) {
      tiempoInicioOpciones = millis();
      tiempoAnim = millis();
    }
    int tiempoOpciones = millis() - tiempoInicioOpciones;

    if (!detrasdelcodigo && !volumen && !controles && !creditos) {
      tiempoInicioSubOpcion = -10000;
    }

    background(rojo);
    
    image(opciones,0,0,width,height);

    // LOGO ESTRATEGICO EN OPCIONES (ESQUINA SUPERIOR DERECHA, AMPLIO Y SIN ANIMACION)
    if (logo != null && logo.width > 0) {
      float anchoLogo = 380.0 * escalaX;
      float altoLogo = anchoLogo / 3.0;
      image(logo, width - (anchoLogo + 40 * escalaX), 25 * escalaY, anchoLogo, altoLogo);
    }

    

    // Cascada de botones con transicion al mismo estilo que el menu principal
    if (tiempoOpciones >= 120) {
      float p = constrain((tiempoOpciones - 120) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 280) ? 108 : (108 - (1.0 - e) * 80.0);
      fill(200, 15, 15);
      crearbotongrueso("OPCIONES", x, 130, 120);
      fill(255);
      textSize(120*escalaY);
      text("OPCIONES", x*escalaX, 130*escalaY);

      if (volumen) {
        fill(200, 15, 15);
        crearbotongrueso("VOLUMEN", 620, 130, 120);
        fill(255);
        textSize(120*escalaY);
        text("VOLUMEN", 620*escalaX, 130*escalaY);
      }
    }

    if (tiempoOpciones >= 180) {
      float p = constrain((tiempoOpciones - 180) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 340) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonopciones, 0, "DETRAS DEL CODIGO", x, 271, 60, rojo);
    }

    if (detrasdelcodigo==true) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      boolean mostrarImpl = tiempoSub >= 0;
      boolean mostrarVectores = tiempoSub >= 50;
      boolean mostrarMatrices = tiempoSub >= 90;
      boolean mostrarCadenas = tiempoSub >= 130;
      boolean mostrarFunciones = tiempoSub >= 170;
      boolean mostrarSubrutinas = tiempoSub >= 210;
      boolean mostrarTarjetaDetras = tiempoSub >= 120;
      boolean mostrarContenidoDetras = tiempoSub >= 240;

      if (mostrarImpl) {
        fill(0);
        crearbotongrueso("IMPLEMENTACIONES", 688, 130, 120);
        fill(255);
        textSize(120*escalaY);
        text("IMPLEMENTACIONES", 688*escalaX, 130*escalaY);
      }

      if (mostrarVectores) {
        float p = constrain((tiempoSub - 50) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 190) ? 688 : (688 - (1.0 - e) * 50.0);
        animacionboton(botondetrasdelcodigo, 0, "VECTORES", x, 271, 60, negro);
      }

      if (mostrarMatrices) {
        float p = constrain((tiempoSub - 90) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 230) ? 688 : (688 - (1.0 - e) * 50.0);
        animacionboton(botondetrasdelcodigo, 1, "MATRICES", x, 365, 60, negro);
      }

      if (mostrarCadenas) {
        float p = constrain((tiempoSub - 130) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 270) ? 688 : (688 - (1.0 - e) * 50.0);
        animacionboton(botondetrasdelcodigo, 2, "CADENAS", x, 459, 60, negro);
      }

      if (mostrarFunciones) {
        float p = constrain((tiempoSub - 170) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 310) ? 688 : (688 - (1.0 - e) * 50.0);
        animacionboton(botondetrasdelcodigo, 3, "FUNCIONES", x, 553, 60, negro);
      }

      if (mostrarSubrutinas) {
        float p = constrain((tiempoSub - 210) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 350) ? 688 : (688 - (1.0 - e) * 50.0);
        animacionboton(botondetrasdelcodigo, 4, "SUBRUTINAS", x, 647, 60, negro);
      }

      // MARCO DEL TEXTO
      if (mostrarTarjetaDetras) {
        image(creditosdetras, 985*escalaX, 140*escalaY, 535*escalaX, 610*escalaY);
      }

      if (mostrarContenidoDetras) {
        fill(255);
        aplicarFuente(fuenteTexto);
        textSize(21*escalaY);
        textAlign(LEFT, TOP);
        textLeading(28*escalaY);
        text(textoDetrasDelCodigo[botondetrasdelcodigo][slidesdetras], 1060*escalaX, 205*escalaY, 385*escalaX, 490*escalaY);
        textAlign(LEFT, BASELINE);
        aplicarFuente(fuente1);

        // TRIANGULOS DE AVANCE
        color colorTrianguloIzq = color(96, 96, 98);
        if (millis() - tiempoFlashIzq < duracionFlashTriangulo) {
          colorTrianguloIzq = color(255);
        }
        color colorTrianguloDer = color(96, 96, 98);
        if (millis() - tiempoFlashDer < duracionFlashTriangulo) {
          colorTrianguloDer = color(255);
        }
        if (slidesdetras > 0 || millis() - tiempoFlashIzq < duracionFlashTriangulo) {
          trianguloBorde(1012, 752, 985, 774, 1012, 796, colorTrianguloIzq);
        }
        if (slidesdetras < textoDetrasDelCodigo[botondetrasdelcodigo].length - 1 || millis() - tiempoFlashDer < duracionFlashTriangulo) {
          trianguloBorde(1493, 752, 1520, 774, 1493, 796, colorTrianguloDer);
        }

        // CONTADOR DE SLIDES
        String contador = (slidesdetras + 1) + " / " + textoDetrasDelCodigo[botondetrasdelcodigo].length;
        textSize(40*escalaY);
        float anchoContador = textWidth(contador) / escalaX;
        fill(0);
        crearboton(contador, 1252 - anchoContador/2, 788, 40);
        fill(255);
        textSize(40*escalaY);
        text(contador, (1252 - anchoContador/2)*escalaX, 788*escalaY);

        // AYUDA DE CONTROLES
        fill(96, 96, 98);
        textSize(28*escalaY);
        text("W / S: CAMBIAR TEMA", 688*escalaX, 715*escalaY);
        text("A / D: CAMBIAR SLIDE", 688*escalaX, 752*escalaY);

        fill(96, 96, 98);
        infoopciones = "Presiona ESC para regresar";
        textSize(30*escalaY);
        text(infoopciones, 890*escalaX, 820*escalaY);
      }
    }

    if (tiempoOpciones >= 240) {
      float p = constrain((tiempoOpciones - 240) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 400) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonopciones, 1, "VOLUMEN", x, 365, 60, rojo);
    }

    if (volumen) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      boolean mostrarBotonMenos = tiempoSub >= 40;
      boolean mostrarBarraVolumen = tiempoSub >= 80;
      boolean mostrarBotonMas = tiempoSub >= 240;

      color colVolIzq = (millis() - tiempoFlashIzq < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
      color colVolDer = (millis() - tiempoFlashDer < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);

      if (mostrarBotonMenos) {
        trianguloBorde(745, 345, 715, 366, 745, 387, colVolIzq);
      }

      if (mostrarBarraVolumen) {
        dibujarBarraVolumenEn(botonvolumen, 765, 345, 450, 42);
      }

      if (mostrarBotonMas) {
        trianguloBorde(1235, 345, 1265, 366, 1235, 387, colVolDer);
      }

      if (tiempoSub >= 260) {
        fill(255, 70, 80);
        textSize(24 * escalaY);
        textAlign(CENTER, CENTER);
        text("Navega con [A] / [D], flechas o haz click en los triangulos", 990 * escalaX, 450 * escalaY);
        fill(180, 40, 45);
        infoopciones = "Presiona ESC para regresar";
        textSize(30 * escalaY);
        text(infoopciones, 990 * escalaX, 820 * escalaY);
        textAlign(LEFT, BASELINE);
      }
    }

    if (tiempoOpciones >= 300) {
      float p = constrain((tiempoOpciones - 300) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 460) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonopciones, 2, "CONTROLES", x, 459, 60, rojo);
    }

    if (controles) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      boolean mostrarTituloControles = tiempoSub >= 0;
      boolean mostrarTarjetaControles = tiempoSub >= 80;
      boolean mostrarContenidoControles = tiempoSub >= 220;

      if (mostrarTituloControles) {
        fill(0);
        crearbotongrueso("CONTROLES", 688, 130, 120);
        fill(255);
        textSize(120*escalaY);
        text("CONTROLES", 688*escalaX, 130*escalaY);
      }

      if (mostrarTarjetaControles) {
        image(creditosdetras, 730*escalaX, 140*escalaY, 720*escalaX, 620*escalaY);
      }

      if (mostrarContenidoControles) {
        fill(255);
        aplicarFuente(fuenteTexto);
        textSize(21*escalaY);
        textAlign(LEFT, TOP);
        textLeading(28*escalaY);
        // Ancho delimitado en formato estricto para evitar descuadres
        float anchoFormato = 480 * escalaX;
        float xFormato = (730 * escalaX) + (720 * escalaX - anchoFormato) / 2.0;
        text(textoControles[slidescontroles], xFormato, 220*escalaY, anchoFormato, 450*escalaY);
        aplicarFuente(fuente1);
        textAlign(LEFT, BASELINE);

        color colorTrianguloIzq = (millis() - tiempoFlashIzq < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
        color colorTrianguloDer = (millis() - tiempoFlashDer < duracionFlashTriangulo) ? color(255, 40, 50) : color(150, 30, 35);
        if (slidescontroles > 0 || millis() - tiempoFlashIzq < duracionFlashTriangulo) {
          trianguloBorde(705, 425, 675, 450, 705, 475, colorTrianguloIzq);
        }
        if (slidescontroles < textoControles.length - 1 || millis() - tiempoFlashDer < duracionFlashTriangulo) {
          trianguloBorde(1475, 425, 1505, 450, 1475, 475, colorTrianguloDer);
        }

        String contador = (slidescontroles + 1) + " / " + textoControles.length;
        textSize(36*escalaY);
        float anchoContador = textWidth(contador) / escalaX;
        fill(0);
        crearboton(contador, 1090 - anchoContador/2, 792, 36);
        fill(255, 50, 60);
        textSize(36*escalaY);
        text(contador, (1090 - anchoContador/2)*escalaX, 792*escalaY);

        fill(180, 40, 45);
        infoopciones = "Presiona ESC para regresar";
        textSize(30*escalaY);
        textAlign(CENTER, CENTER);
        text(infoopciones, 1090*escalaX, 825*escalaY);
        textAlign(LEFT, BASELINE);
      }
    }

    if (tiempoOpciones >= 360) {
      float p = constrain((tiempoOpciones - 360) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 520) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonopciones, 3, "CREDITOS", x, 553, 60, rojo);
    }

    if (creditos) {
      if (tiempoInicioSubOpcion < 0) {
        tiempoInicioSubOpcion = millis();
      }
      int tiempoSub = millis() - tiempoInicioSubOpcion;

      boolean mostrarNum1 = tiempoSub >= 40;
      boolean mostrarNum2 = tiempoSub >= 90;
      boolean mostrarNum3 = tiempoSub >= 140;
      boolean mostrarTarjetaCreditos = tiempoSub >= 100;
      boolean mostrarContenidoCreditos = tiempoSub >= 220;

      if (mostrarTarjetaCreditos) {
        image(creditosdetras, 683*escalaX, 140*escalaY, 760*escalaX, 715*escalaY);
      }

      if (mostrarContenidoCreditos) {
        fill(255);
        aplicarFuente(fuenteTexto);
        textSize(28*escalaY);
        text(textoCreditos[slidescreditos], 771*escalaX, 209*escalaY, 569*escalaX, 584*escalaY);
        aplicarFuente(fuente1);

        color colorTrianguloIzq = color(96, 96, 98);
        if (millis() - tiempoFlashIzq < duracionFlashTriangulo) {
          colorTrianguloIzq = color(255);
        }
        color colorTrianguloDer = color(96, 96, 98);
        if (millis() - tiempoFlashDer < duracionFlashTriangulo) {
          colorTrianguloDer = color(255);
        }
        if (slidescreditos > 0 || millis() - tiempoFlashIzq < duracionFlashTriangulo) {
          trianguloBorde(656, 476, 629, 498, 656, 520, colorTrianguloIzq);
        }
        if (slidescreditos < textoCreditos.length - 1 || millis() - tiempoFlashDer < duracionFlashTriangulo) {
          trianguloBorde(1470, 476, 1497, 498, 1470, 520, colorTrianguloDer);
        }
      }

      if (mostrarNum1) {
        float p = constrain((tiempoSub - 40) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 180) ? 876 : (876 - (1.0 - e) * 30.0);
        animacionboton(slidescreditos, 0, "1", x, 130, 80, rojo);
      }

      if (mostrarNum2) {
        float p = constrain((tiempoSub - 90) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 230) ? 1063 : (1063 - (1.0 - e) * 30.0);
        animacionboton(slidescreditos, 1, "2", x, 130, 80, rojo);
      }

      if (mostrarNum3) {
        float p = constrain((tiempoSub - 140) / 140.0, 0.0, 1.0);
        float e = 1.0 - pow(1.0 - p, 3);
        float x = (tiempoSub >= 280) ? 1250 : (1250 - (1.0 - e) * 30.0);
        animacionboton(slidescreditos, 2, "3", x, 130, 80, rojo);
      }

      fill(96, 96, 98);
      infoopciones = "Presiona ESC para regresar";
      textSize(30*escalaY);
      text(infoopciones, 890*escalaX, 820*escalaY);
    }

    // SALIR / REGRESAR
    if (tiempoOpciones >= 420) {
      float p = constrain((tiempoOpciones - 420) / 160.0, 0.0, 1.0);
      float e = 1.0 - pow(1.0 - p, 3);
      float x = (tiempoOpciones >= 580) ? 108 : (108 - (1.0 - e) * 80.0);
      animacionboton(botonopciones, 4, "REGRESAR", x, 647, 60, rojo);
    }
    //NOTA: EL INCREMENTO EN Y ES 94
  }

  //OPCIONES PARA SALIR

  if (ventanasalir) {
    float progresoVentana = constrain((millis() - tiempoInicioVentanaSalir) / 120.0, 0.0, 1.0);
    float escalaPop = 1.0 - pow(1.0 - progresoVentana, 3);

    pushMatrix();
    translate(768 * escalaX, 432 * escalaY);
    scale(escalaPop);
    translate(-768 * escalaX, -432 * escalaY);

    image(ventanasalirimagen, 368 * escalaX, 192 * escalaY, 800 * escalaX, 480 * escalaY);

    //BORDE
    fill(200, 15, 15);
    crearboton("SALIR A WINDOWS", 570, 400, 65);
    fill(220);
    textSize(65 * escalaY);
    text("SALIR A WINDOWS", 570*escalaX, 400*escalaY);

    animacionboton(botonseleccionsalir, 0, "SI", 611, 564, 65, rojo);
    animacionboton(botonseleccionsalir, 1, "NO", 870, 564, 65, rojo);

    popMatrix();
  }
}
