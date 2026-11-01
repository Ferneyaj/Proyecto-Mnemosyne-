// ============================================================================
// MODULO: Mapa.pde
// DESCRIPCION:
//   Construccion, renderizado espacial con frustum/distance culling y logica
//   de terminales interactivas para el Nivel 1 (infiltracion inicial en la red
//   de Kaze Corp) y el portal de salida hacia el Nivel 2.
// ============================================================================

// --- dimensiones y clasificacion de las celdas del mapa ---
int AltoBanda = 70;
int AltoCuerpo = 400;
int AltoPared = 2 * AltoBanda + AltoCuerpo;
int AltoPiso = 5;
// 1 - 9 son paredes; 0 y 10 - 19 son pisos con distintas texturas.
PImage[] texturaDe = new PImage[20];
PImage texBanda;
boolean esPared(int n){ return n >=1 && n <=9;}
boolean esPiso(int n){ return n >=10 && n <=19 || n == 0;}
boolean esVacio(int n) { return n == -1; }
// Estas funciones centralizan las alturas usadas por dibujo y colisiones.
float yBasePared() {return (height/2) - (AltoPiso/2); }
float yTopePared() {return yBasePared() - AltoPared;}
float centroYpared() {return yBasePared() - AltoPared/2;}




//Terminales
int [] TerminalId = {
1,
2,
3,
5,
6
};
PVector[] posicionesTerminales = {
  new PVector(48, 4.65 + (150/TAM_CELDA) , 13),
  new PVector(86.4, 4.65 + (150/TAM_CELDA) , 1),
  new PVector(126, 4.65 + (150/TAM_CELDA) , 18.9),
};
float[] orientacionX = {
PI,
PI,  
PI,


};
float[] orientacionY = {
HALF_PI,
HALF_PI,  
HALF_PI,

};


boolean EnTerminal;



// Terminal
PShape terminal;
PImage BaseColor;



// Dibuja solo las celdas cercanas al jugador para mantener fluido el nivel grande.
// Primero aplica las texturas de piso y cuerpo; despues agrega las bandas rojas.
void dibujarMapa(){
  
  int filaJug = celdaDe(JugadorZ);
  int colJug = celdaDe(JugadorX);
  int filaIni = constrain(filaJug - RADIO_DIBUJO, 0, mapa.length - 1);
  int filaFin = constrain(filaJug + RADIO_DIBUJO, 0, mapa.length - 1);
  int colIni = constrain(colJug - RADIO_DIBUJO, 0, mapa[0].length - 1);
  int colFin = constrain(colJug + RADIO_DIBUJO, 0, mapa[0].length - 1);
  
  
  // Se agrupan las celdas por numero de textura para reutilizar texturaDe[].
  for (int n = 0; n < texturaDe.length; n++){
  if (texturaDe[n] == null) continue;
  for (int f = filaIni; f <= filaFin; f++) {
    for (int c = colIni; c <= colFin; c++) {
      if (mapa[f][c] != n) continue;
      pushMatrix();
      if (esPiso(n)) {
       translate(c * TAM_CELDA, height/2, f * TAM_CELDA);
       cajaTexturada(TAM_CELDA, AltoPiso, TAM_CELDA, texturaDe[n]);
      } else{        
         translate(c * TAM_CELDA, yTopePared() + AltoBanda + AltoCuerpo/2, f * TAM_CELDA);
         cajaTexturada(TAM_CELDA, AltoCuerpo, TAM_CELDA, texturaDe[n]);
      }
      popMatrix();
      }
    }
  }   
  
  
  // Las bandas reciben un tinte rojo para conservar la identidad visual del mapa.


 tint(255,60,60);
  emissive(150,0,0);

  for (int f = filaIni; f <= filaFin; f++) {
    for (int c = colIni; c <= colFin; c++) {
  if (!esPared(mapa[f][c])) continue;
  
  pushMatrix();
      translate(c * TAM_CELDA, yTopePared() + AltoBanda/2, f * TAM_CELDA);
      cajaTexturada(TAM_CELDA, AltoBanda, TAM_CELDA, texBanda);
      popMatrix();

      pushMatrix();
      translate(c * TAM_CELDA, yBasePared() - AltoBanda/2, f * TAM_CELDA);
      cajaTexturada(TAM_CELDA, AltoBanda, TAM_CELDA, texBanda);
      popMatrix();
  
      
      
      
      
    }  
    }
     noTint();
    emissive(0);
  
  }
  


// La salida se representa con un arco turquesa para que sea visible en el mapa.
void dibujarSalidaNivel1() {
  float salidaX = SALIDA_COL * TAM_CELDA;
  float salidaZ = SALIDA_FILA * TAM_CELDA;
  float superficie = yBasePared();

  pushMatrix();
  translate(salidaX, superficie - 80, salidaZ);
  emissive(0, 120, 100);
  fill(0, 240, 190);
  box(20, 160, 20);
  translate(120, 0, 0);
  box(20, 160, 20);
  translate(-60, -80, 0);
  box(140, 20, 20);
  emissive(0);
  popMatrix();
}

 int MAX_LUCES_ROJAS = 6;   // lights() ya usa 2 de las 8
int RADIO_LUCES = 4;       // hasta cuantas celdas alrededor se buscan paredes

void luzDeBandas() {

  // cuanto se apaga la luz con la distancia (el tercer numero es el que mas pesa)
  lightFalloff(1.0, 0.0, 0.00002);

  int filaJug = celdaDe(JugadorZ);
  int colJug = celdaDe(JugadorX);
  int puestas = 0;

  // se busca por anillos, del mas cercano al mas lejano
  for (int r = 0; r <= RADIO_LUCES; r++) {
    for (int df = -r; df <= r; df++) {
      for (int dc = -r; dc <= r; dc++) {

        if (max(abs(df), abs(dc)) != r) continue;   // solo el borde del anillo r

        int f = filaJug + df;
        int c = colJug + dc;

        if (f < 0 || f >= mapa.length || c < 0 || c >= mapa[0].length) continue;
        if (!esPared(mapa[f][c])) continue;

        pointLight(255, 0, 0, c * TAM_CELDA, yBasePared() - AltoBanda/2, f * TAM_CELDA);
        puestas++;
        if (puestas >= MAX_LUCES_ROJAS) return;
      }
    }
  }
}



void terminales(){

  

for (int j = 0; j < 3; j++){

pushMatrix();
translate(posicionesTerminales[j].x * TAM_CELDA, posicionesTerminales[j].y*TAM_CELDA, posicionesTerminales[j].z*TAM_CELDA);
rotateX(orientacionX[j]);
rotateY(orientacionY[j]);
scale(100);
shape(terminal);
popMatrix();


}







}

int indiceTerminalCercana() {
  for (int j = 0; j < 3; j++) {
    float termX = posicionesTerminales[j].x * TAM_CELDA;
    float termZ = posicionesTerminales[j].z * TAM_CELDA;
    if (dist(JugadorX, JugadorZ, termX, termZ) < 320) {
      return j;
    }
  }
  return -1;
}

boolean CercaTerminal() {
  return indiceTerminalCercana() >= 0;
}
