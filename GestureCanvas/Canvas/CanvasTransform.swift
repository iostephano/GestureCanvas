//
//  CanvasTransform.swift
//  GestureCanvas
//
//  Created by Stephano Portella on 03/09/26.
//

import CoreGraphics

/// La transformación acumulada del lienzo, en coordenadas de la supervista.
///
/// Cada gesto aporta un cambio incremental. La clave está en el orden de
/// composición: todo se concatena *después* del transform actual, así que las
/// traslaciones y los anclajes se interpretan en coordenadas de pantalla y no se
/// deforman con el zoom o la rotación ya aplicados.
struct CanvasTransform: Equatable {

    static let minScale: CGFloat = 0.5
    static let maxScale: CGFloat = 4

    private(set) var affine: CGAffineTransform = .identity

    /// Factor de escala uniforme actual respecto a la identidad. Válido porque
    /// solo se componen traslación, escala uniforme y rotación: nunca hay shear.
    var scale: CGFloat {
        (affine.a * affine.a + affine.b * affine.b).squareRoot()
    }

    /// Desplaza el lienzo en coordenadas de pantalla, sin que lo afecten el zoom
    /// ni la rotación previos.
    mutating func pan(by translation: CGVector) {
        affine = affine.concatenating(
            CGAffineTransform(translationX: translation.dx, y: translation.dy)
        )
    }

    /// Escala alrededor de `anchor` (coordenadas de pantalla), limitando la
    /// escala resultante a `minScale...maxScale`. `anchor` queda como punto fijo.
    mutating func zoom(by factor: CGFloat, around anchor: CGPoint) {
        guard scale > 0, factor > 0 else { return }
        let target = min(max(scale * factor, Self.minScale), Self.maxScale)
        let step = target / scale
        affine = affine.concatenating(
            Self.anchored(anchor, CGAffineTransform(scaleX: step, y: step))
        )
    }

    /// Rota alrededor de `anchor` (coordenadas de pantalla). `anchor` queda como
    /// punto fijo. La rotación no tiene límite.
    mutating func rotate(by radians: CGFloat, around anchor: CGPoint) {
        affine = affine.concatenating(
            Self.anchored(anchor, CGAffineTransform(rotationAngle: radians))
        )
    }

    mutating func reset() {
        affine = .identity
    }

    /// Envuelve `core` para que se aplique alrededor de `p`: llevar `p` al
    /// origen, aplicar `core`, devolver `p` a su sitio.
    private static func anchored(_ p: CGPoint, _ core: CGAffineTransform) -> CGAffineTransform {
        CGAffineTransform(translationX: -p.x, y: -p.y)
            .concatenating(core)
            .concatenating(CGAffineTransform(translationX: p.x, y: p.y))
    }
}
