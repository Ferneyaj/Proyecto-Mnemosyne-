// ============================================================================
// MODULO: MenuTextos.pde
// DESCRIPCION:
//   Banco de textos narrativos y documentales del proyecto REMANENTE:
//   sinopsis, creditos del equipo, guia de controles (teclado y mando) y
//   documentacion tecnica de "Detras del Codigo".
// ============================================================================
// TEXTOS DE LOS MARCOS: creditos, detras del codigo y controles
// TEXTOS DE LOS MARCOS (CREDITOS, DETRAS DEL CODIGO Y CONTROLES)
// CREDITOS: un texto por slide (1, 2 y 3).
String[] textoCreditos = {
  "Remanente\n\nCREADO POR: \nBreaking Bugs\n\nProyecto de programacion desarrollado en Processing\n",
  "Equipo de Desarrollo\n\nLIDER DEL PROYECTO : Ferney Jimenez\nDISENADOR : Luis Padilla\nPROGRAMADOR : Santiago Monsalvo\nDOCUMENTADOR : Cesar Lugo",
  "Recursos y Licencias\n\nFuentes: Black Mustang (Linecreative) y Blacky (Trotoart).\n\nBanda Sonora y Efectos:\nDevil May Cry - Let's Rock Baby por Maru Tseru\nDevil May Cry 3 - Menu/Inventory SFX por SolidSoundStimulation"
};

// DETRAS DEL CODIGO: un grupo de slides por boton (VECTORES, MATRICES, CADENAS, FUNCIONES, SUBRUTINAS)
String[][] textoDetrasDelCodigo = {
  { // VECTORES
    "Vectores\n\nUn vector es una lista de datos del mismo tipo guardada bajo un solo nombre y se recorre con un indice\n\nEn Remanente se usan para estructurar variables de forma limpia y eficiente",
    "Las teclas\n\nteclas es un vector de cuatro boolean que guarda si cada tecla esta oprimida\n\n[W] primera posicion\n[S] segunda posicion\n[A] tercera posicion\n[D] cuarta posicion",
    "Donde se usan las teclas\n\nkeyPressed pone la posicion en verdadero y keyReleased en falso\n\ncalcularVectorMovimiento lee teclas en cada cuadro para mover al jugador\n\nlados gira con las flechas izquierda y derecha y mirarVertical permite mirar arriba y abajo",
    "Los enemigos\n\nenemigosX enemigosZ enemigosVida enemigosVelocidad enemigosActivo y enemigosColor son vectores paralelos\n\nLa misma posicion en todos describe a un mismo enemigo",
    "Enemigos en accion\n\nmoverEnemigos recorre los vectores para perseguir al jugador\n\nlos enemigos cuerpo a cuerpo avanzan durante ATACAR\n\nel tirador crea proyectiles que avanzan por el mapa\n\natacar resta vida en enemigosVida\n\ndibujarEnemigos y dibujarMinimapa pintan solo a los que tienen enemigosActivo en verdadero",
    "Las plataformas\n\nEl nivel dos guarda cada plataforma en vectores paralelos\n\nplataformaX plataformaZ plataformaAnchoX plataformaAnchoZ plataformaY y esMeta\n\nesMeta marca la plataforma dorada que termina el nivel",
    "Otros vectores\n\ntexturaDe guarda las imagenes del mapa y cada numero de la matriz elige una\n\ncalcularBordes devuelve un vector con los seis limites de una caja\n\ncalcularVectorMovimiento devuelve el movimiento en X y en Z",
    "En este menu\n\nLos vectores grueso uno y grueso dos guardan desplazamientos para dibujar el contorno negro de las letras\n\ntextoCreditos y textoDetrasDelCodigo son vectores de cadenas y cada elemento es una diapositiva como esta"
  },
  { // MATRICES
    "Matrices\n\nUna matriz es una tabla con filas y columnas y se recorre con dos indices\n\nEl mapa del nivel uno es la matriz mapa de enteros y cada casilla describe un trozo del escenario",
    "Del archivo a la matriz\n\nEl archivo mapa guarda una fila por linea con numeros separados por comas\n\ncargarMapa convierte cada linea en una fila de la matriz al iniciar el juego",
    "Que significa cada numero\n\nDe uno a nueve pared con su textura\nCero y de diez a diecinueve piso\nMenos uno casilla vacia\nCuatro fuera del escenario\n\nesPared esPiso y esVacio leen estos valores",
    "Colisiones\n\npuedeMoverse no revisa toda la matriz sino solo las casillas vecinas al jugador\n\nSi una pared se cruza con la caja del jugador el paso se cancela\n\nAsi el juego se mantiene fluido aunque el mapa tenga cien filas",
    "Dibujo del mapa\n\ndibujarMapa recorre solo las casillas cercanas al jugador\n\nLa casilla decide que textura se usa y si se dibuja un piso o una pared\n\nluzDeBandas busca paredes cercanas anillo por anillo para colocar luces rojas",
    "Piso y salida\n\nalturaDePiso consulta directamente la casilla que esta bajo los pies del jugador\n\nSi es piso devuelve su altura y si no el jugador cae\n\nLa salida del nivel uno es una fila y una columna fijas de la matriz",
    "El minimapa\n\ndibujarMinimapa recorre la matriz completa y pinta un cuadrito por casilla\n\nLa pared va en gris azulado el piso en claro y lo que esta fuera del escenario en oscuro\n\nLuego marca la salida al jugador y a los enemigos",
    "Matrices de transformacion\n\npushMatrix translate y popMatrix ubican cada caja del mapa cada enemigo y al jugador en el espacio\n\nGuardan y restauran el sistema de coordenadas para que un objeto no afecte a los demas"
  },
  { // CADENAS
    "Cadenas\n\nUna cadena String es texto guardado en una variable\n\nSe usa para mensajes avisos nombres de archivo y todos los textos que ves en pantalla",
    "Leer el mapa\n\nloadStrings lee el archivo del mapa y entrega un vector con una cadena por linea\n\nsplit corta cada linea en las comas e int convierte cada pedazo en numero\n\nAsi nace la matriz del nivel",
    "Mensajes del juego\n\nmensajeActual guarda el aviso que muestra el HUD\n\nImpacto Golpeaste el aire Enemigo derrotado Pierdes una vida y Ataque recargando\n\nmostrarMensaje lo guarda junto con el cuadro en que debe desaparecer",
    "Texto en el HUD\n\nSe unen cadenas con numeros para formar frases como Vida con la cantidad de vidas o Enemigos con los que quedan\n\nEl nombre del nivel actual y los controles tambien son cadenas",
    "Nombres de archivo\n\nloadImage createFont y SoundFile reciben el nombre como cadena\n\nAsi se cargan las texturas del mapa las imagenes del menu las fuentes y los sonidos",
    "Cadenas del menu\n\ntitulosniveles e informacionniveles cambian segun la mision elegida\n\ninfosalir e infoopciones muestran la ayuda de cada pantalla\n\ncargarnivel guarda la pregunta para confirmar la mision",
    "Texto con saltos\n\ntextoCreditos y textoDetrasDelCodigo guardan estas diapositivas\n\ntext acomoda cada cadena dentro del marco y corta las lineas por palabras\n\nimage dibuja el marco vertical detras del texto"
  },
  { // FUNCIONES
    "Funciones\n\nUna funcion calcula algo y lo devuelve con return para usarlo en una condicion o en una cuenta\n\nAqui hay funciones que devuelven int float boolean y vectores",
    "De pixeles a casillas\n\nceldaDe convierte una posicion en pixeles en el indice de una casilla de la matriz\n\nSe usa en las colisiones el minimapa las luces y la salida del nivel",
    "Altura del suelo\n\nalturaDePiso devuelve la altura de la superficie que hay bajo los pies\n\nplataformaBajo devuelve que plataforma esta debajo o menos uno si no hay ninguna\n\nalturaPlataformas usa ese resultado en el nivel dos",
    "Colisiones\n\ncalcularBordes devuelve un vector con los limites minimo y maximo de una caja\n\npuedeMoverse y puedeMoverseEnemigo responden verdadero o falso comparando cajas alineadas con los ejes",
    "Clasificar casillas\n\nesPared esPiso y esVacio devuelven boolean segun el numero de la casilla\n\nenemigosVivos devuelve cuantos enemigos siguen activos\n\nyBasePared yTopePared y centroYpared devuelven alturas del escenario",
    "Movimiento\n\ncalcularVectorMovimiento devuelve el desplazamiento en X y en Z segun las teclas y el angulo de la camara\n\nNormaliza el resultado para que ir en diagonal no sea mas rapido"
  },
  { // SUBRUTINAS
    "Subrutinas\n\nUna subrutina void ejecuta una tarea y no devuelve ningun valor\n\nDividen el programa en partes pequenas con un solo trabajo cada una",
    "El bucle principal\n\ndraw se repite sin parar\n\nSi PantallaDeJuego vale cero llama a Menu y si vale uno ejecuta el nivel\n\nsetup prepara ventana sonidos imagenes y mapa una sola vez",
    "El jugador\n\nmoverJugador aplicarGravedad y saltar controlan su cuerpo\n\natacar revisa que enemigos estan dentro del rango\n\ndibujarJugador pinta la caja celeste y el rango del ataque",
    "Enemigos y vida\n\nmoverEnemigos los acerca al jugador y los tiradores disparan a distancia\n\nrevisarDanioAjugador resta una vida al contacto con una pausa entre golpes\n\nconfigurarEnemigo prepara a cada enemigo y reiniciarJuego devuelve todo al inicio",
    "Los niveles\n\ndibujarMapa y luzDeBandas construyen el nivel uno\n\nrevisarTransicionDeNivel pasa al nivel dos cuando se derrota a todos\n\nrevisarCaida quita una vida si el jugador cae al vacio",
    "Pantalla y HUD\n\ndibujarHUD muestra vidas nivel y controles\n\ndibujarBarraCooldown muestra la recarga del ataque\n\ndibujarMinimapa dibuja el mapa pequeno\nmostrarMensaje programa los avisos",
    "Eventos\n\nkeyPressed y keyReleased se ejecutan solos al oprimir o soltar una tecla\n\nmousePressed atiende el boton Reiniciar cuando pierdes\n\nEn el menu keyPressed mueve la seleccion y confirma con Enter",
    "Subrutinas del menu\n\nMenu dibuja todas las pantallas del menu\n\nreproducir lanza los sonidos\n\ncrearboton y crearbotongrueso dibujan el contorno negro de los textos",
    "Dibujo de marcos\n\ntrianguloBorde dibuja las flechas de las diapositivas\n\nimage dibuja el marco vertical\n\ntext escribe dentro de el"
  }
};

// CONTROLES: slides con formato delimitado y disciplina tipografica
String[] textoControles = {
  "CONTROLES // TECLADO Y RATON\n\n[W][A][S][D] Mover a Walt\n[Shift]      Correr rapido\n[Espacio]    Saltar\n[E]          Atacar de frente\n[R]          Esquiva (Dash)\n[F]          Parry en impacto\n[G]          Pulso de Memoria\n[Raton]      Girar camara\n[ESC]        Menu de Pausa",
  "CONTROLES // MANDO Y GAMEPAD\n\n[Palanca L]  Mover a Walt\n[Palanca R]  Girar camara\n[Gatillo RT] Correr / Esprintar\n[Boton A]    Saltar\n[Boton X]    Atacar de frente\n[Boton LB]   Esquiva con impulso\n[Boton RB]   Parry defensivo\n[Boton Y]    Pulso de Memoria\n[Start]      Menu de Pausa\n[Boton B]    Volver / Cancelar",
  "MISIONES // LORE REMANENTE\n\nKaze Corp suplanta a la gente\ncon clones digitales al 85%.\nWalt y Dante deben detenerlos\nantes de la sincronizacion 100%:\n\n* ACTO I: Infiltrate en la red,\nelimina Centinelas y cruza el\nportal de codigo rojo.\n\n* ACTO II: Salta plataformas\nsobre el vacio digital y llega\nal nodo de enlace dorado.\n\n* ACTO III: Penetra el laberinto\nde datos y destruye a ARGOS.",
  "COMBATE // ANALISIS TACTICO\n\n* Atacar [E]: Golpea de frente\nrespetando el aviso enemigo.\n\n* Esquiva [R]: Invulnerabilidad\nbreve para evitar golpes letales.\n\n* Parry [F]: Bloquea golpes o\nproyectiles en el milisegundo\nexacto para aturdir al rival.\n\n* Pulso [G]: Descarga expansiva\nletal al llenar la barra memoria."
};
