//
//  CanvasView.swift
//  GestureCanvas
//
//  Created by Stephano Portella on 05/04/25.
//

import UIKit

/// Fondo del lienzo: una cuadrícula fija dibujada con Core Graphics. Los gestos
/// se aplican como `transform` de esta vista; la cuadrícula no se vuelve a
/// dibujar en cada gesto.
final class CanvasView: UIView {

    private let gridSpacing: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.lightGray.cgColor)

        var x: CGFloat = 0
        while x <= rect.width {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += gridSpacing
        }

        var y: CGFloat = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += gridSpacing
        }

        context.strokePath()
    }
}
