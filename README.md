# GestureCanvas — Lienzo manipulable con gestos simultáneos

GestureCanvas es una app de iOS con un lienzo de cuadrícula que se puede acercar,
rotar y desplazar con los dedos, con los tres gestos funcionando a la vez. Un doble
toque devuelve el lienzo a su posición inicial con una animación. Toda la
manipulación se resuelve como un único `CGAffineTransform` sobre la vista del lienzo.
Existe como proyecto de portafolio para mostrar cómo se combinan varios
`UIGestureRecognizer` sin que se estorben y cómo se componen transformaciones
ancladas a un punto, con esa lógica separada en un tipo de valor y cubierta por
pruebas.

---

## Tecnologías usadas

- Swift 6 (con verificación estricta de concurrencia activada)
- UIKit, construido por código (sin Storyboards)
- `UIGestureRecognizer` (pinch, rotación, pan, tap) con un delegate para
  reconocimiento simultáneo
- Core Graphics para la cuadrícula y `CGAffineTransform` para la manipulación
- Swift Testing para las pruebas
- Integración continua con GitHub Actions (compila y corre los tests en cada push/PR)
- Cero dependencias externas

---

## Cómo está organizado el proyecto

```
GestureCanvas/
├── AppDelegate.swift / SceneDelegate.swift   # Arranque; SceneDelegate crea el ViewController
├── Controllers/
│   └── ViewController.swift                  # Configura los gestos y traduce cada uno a CanvasTransform
├── Views/
│   └── CanvasView.swift                      # UIView que dibuja la cuadrícula con Core Graphics
└── Canvas/
    └── CanvasTransform.swift                 # Composición pura del CGAffineTransform (pan, zoom, rotación, reset)
```

`CanvasTransform` no importa UIKit: son operaciones puras sobre `CGAffineTransform`.
El `ViewController` solo traduce cada gesto a una llamada (`pan`, `zoom`, `rotate`,
`reset`) y asigna el resultado a `canvas.transform`.

---

## Cómo funciona / flujo principal

1. `SceneDelegate` crea el `ViewController`, que añade una `CanvasView` a pantalla
   completa.
2. El `ViewController` registra en la `CanvasView` un `UIPinchGestureRecognizer`, un
   `UIRotationGestureRecognizer`, un `UIPanGestureRecognizer` de dos dedos y un
   `UITapGestureRecognizer` de doble toque. Los tres primeros comparten un delegate
   que devuelve `true` en `shouldRecognizeSimultaneouslyWith`, así que UIKit los deja
   actuar juntos.
3. En cada callback de gesto, el `ViewController` lee el incremento (escala, ángulo o
   traslación desde el último callback), lo aplica a `CanvasTransform` y resetea ese
   incremento en el recognizer.
4. `CanvasTransform` concatena cada cambio *después* del transform acumulado:
   - **pan**: suma la traslación en coordenadas de pantalla, sin que la deformen el
     zoom o la rotación previos;
   - **zoom** y **rotación**: se anclan al punto que indica el gesto (el punto medio
     entre los dedos), llevándolo al origen, aplicando la operación y devolviéndolo a
     su sitio, de modo que ese punto queda fijo bajo el dedo;
   - el zoom limita la escala resultante al rango `0.5x ... 4x`.
5. El doble toque llama a `reset()` dentro de un bloque `UIView.animate`, así que el
   lienzo vuelve a la identidad con una transición.

---

## Funcionalidades / qué demuestra

- Pinch, rotación y pan de dos dedos reconocidos de forma simultánea con un solo
  `UIGestureRecognizerDelegate`.
- Composición de `CGAffineTransform` en el orden correcto: traslación en espacio de
  pantalla, y zoom/rotación anclados a un punto arbitrario.
- Clamping de la escala a un rango, calculado a partir de la escala actual del
  transform.
- Reset animado al estado inicial.
- La lógica de transformación aislada de UIKit y cubierta por pruebas (punto fijo del
  anclaje, límites de zoom, independencia del pan respecto al zoom/rotación).

---

## Pruebas

`GestureCanvasTests` (Swift Testing) cubre `CanvasTransform`:

- **Estado inicial**: un transform nuevo es la identidad, con escala 1.
- **Pan**: suma la traslación a `tx`/`ty` en espacio de pantalla; tras aplicar zoom y
  rotación, un pan sigue sumando exactamente esa traslación y no toca el resto de la
  matriz.
- **Zoom**: multiplica la escala actual; el punto de anclaje queda fijo bajo el
  transform; la escala se limita al máximo y al mínimo, incluso acumulando varios
  gestos; un factor de zoom menor o igual a 0 se ignora.
- **Rotación**: no cambia la escala; el punto de anclaje queda fijo; zoom y rotación
  sobre el mismo punto lo mantienen fijo entre ambos.
- **Reset**: vuelve a la identidad.

Correr los tests:

```bash
xcodebuild test \
  -project GestureCanvas.xcodeproj \
  -scheme GestureCanvas \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Cómo correr el proyecto

1. Clona el repo:
   ```bash
   git clone https://github.com/iostephano/GestureCanvas.git
   ```
2. Abre `GestureCanvas.xcodeproj` con **Xcode 26** (ver `.xcode-version`).
3. El objetivo mínimo es **iOS 26**. Elige un simulador de iPhone o un dispositivo y
   ejecuta (Cmd-R).
4. Usa dos dedos para hacer pinch, rotar y arrastrar el lienzo (se pueden combinar).
   Doble toque para resetear.

---

## Cosas pendientes o limitadas (a propósito)

- **La cuadrícula no se redibuja al transformar.** Se dibuja una vez a resolución
  base y luego se escala como bitmap, así que con mucho zoom las líneas se ven
  pixeladas. Redibujarla en cada frame según el transform inverso queda fuera del
  alcance del demo.
- **No hay dibujo.** El lienzo solo se manipula; no se pintan trazos ni figuras.
- **El pan necesita dos dedos**, para no competir con un gesto de un dedo si más
  adelante se añadiera dibujo.
- **Sin inercia ni rebote**: al soltar, el lienzo se queda donde está; no hay
  desaceleración ni límites de desplazamiento (solo se limita el zoom).
- **Sin indicadores en pantalla** de la escala o el ángulo actuales.

---

## Autor

Stephano Portella
