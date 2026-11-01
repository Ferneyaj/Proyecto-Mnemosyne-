// ============================================================================
// MODULO: Camara.pde
// DESCRIPCION:
//   Sistema de camara en tercera persona con rotacion orbital 3D (yaw y pitch),
//   control hibrido por raton (con re-centrado invisible mediante java.awt.Robot),
//   teclado y mando, ademas de efectos de sacudida cinematografica (screen shake).
// ============================================================================
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;

// Actualiza la camara tercera persona tomando al jugador como punto de enfoque.
// El mouse, las flechas y el mando cambian anguloCamara sin alterar la posicion del jugador.
float pitchCamara = 0;
Robot robotCamara = null;
boolean robotInicializado = false;
boolean ignorarSaltoRecenter = false;

void actualizarCamara() {
  if (!robotInicializado) {
    robotInicializado = true;
    try {
      robotCamara = new Robot();
    } catch (Exception e) {
      robotCamara = null;
    }
  }

  // Movimiento de camara con el mouse cuando no se esta en el minijuego de terminal
  if (!minijuegoActivo && !pausa && !juegoTerminado && !nivelCompletado) {
    if (ignorarSaltoRecenter) {
      ignorarSaltoRecenter = false;
    } else {
      float deltaMouseX = constrain(mouseX - pmouseX, -50, 50);
      float deltaMouseY = constrain(mouseY - pmouseY, -40, 40);
      anguloCamara = anguloCamara - deltaMouseX * 0.005;
      inclinacionCamara = inclinacionCamara + deltaMouseY * 0.004;
    }

    // Si el mouse llega al borde de la pantalla en modo sin cursor, lo re-centra suavemente
    if (robotCamara != null && focused && (mouseX < 60 || mouseX > width - 60 || mouseY < 60 || mouseY > height - 60)) {
      try {
        robotCamara.mouseMove(width / 2, height / 2);
        ignorarSaltoRecenter = true;
      } catch (Exception e) {}
    }
  }

  if (!minijuegoActivo && !pausa && !juegoTerminado && !nivelCompletado) {
    if (lados[0]) anguloCamara += 0.04;
    if (lados[1]) anguloCamara -= 0.04;
    if (mirarVertical[0]) inclinacionCamara -= 0.025;
    if (mirarVertical[1]) inclinacionCamara += 0.025;
  }
  inclinacionCamara = constrain(inclinacionCamara, -0.40, 0.40);

  CamaraPosX = JugadorX + 270 * sin(anguloCamara);
  // La posicion y el punto de enfoque cambian juntos para que la inclinacion
  // sea visible tambien cuando el nivel sube en vertical.
  CamaraPosY = JugadorY - 100 + sin(inclinacionCamara) * 180;
  pitchCamara = atan2(CamaraPosY - JugadorY, 270);
  CamaraPosZ = JugadorZ + 270 * cos(anguloCamara);
  CamaraVisX = JugadorX;
  CamaraVisY = JugadorY - sin(inclinacionCamara) * 270;

  float sacudidaX = 0;
  float sacudidaY = 0;
  float sacudidaZ = 0;
  if (frameCount < temblorCamaraHasta) {
    sacudidaX = random(-intensidadTemblorCamara, intensidadTemblorCamara);
    sacudidaY = random(-intensidadTemblorCamara, intensidadTemblorCamara);
    sacudidaZ = random(-intensidadTemblorCamara, intensidadTemblorCamara);
  } else {
    intensidadTemblorCamara = 0;
  }

  camera(CamaraPosX + sacudidaX, CamaraPosY + sacudidaY, CamaraPosZ + sacudidaZ,
    CamaraVisX + sacudidaX * 0.35, CamaraVisY + sacudidaY * 0.35,
    JugadorZ + sacudidaZ * 0.35, 0, 1, 0);
}

// Programa una sacudida breve sin detener el resto de la camara.
void sacudirCamara(int duracion, float intensidad) {
  temblorCamaraHasta = max(temblorCamaraHasta, frameCount + duracion);
  intensidadTemblorCamara = max(intensidadTemblorCamara, intensidad);
}
