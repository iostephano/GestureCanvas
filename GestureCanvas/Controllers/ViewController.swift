//
//  ViewController.swift
//  GestureCanvas
//
//  Created by Stephano Portella on 05/04/25.
//

import UIKit

final class ViewController: UIViewController {

    private let canvas = CanvasView()

    private var canvasTransform = CanvasTransform() {
        didSet { canvas.transform = canvasTransform.affine }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        canvas.frame = view.bounds
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(canvas)

        addGestures()
    }

    private func addGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2

        // Un delegate compartido que permite que pinch, rotación y pan se
        // reconozcan a la vez; sin esto UIKit solo deja actuar a uno.
        for recognizer in [pinch, rotation, pan] as [UIGestureRecognizer] {
            recognizer.delegate = self
            canvas.addGestureRecognizer(recognizer)
        }

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        canvas.addGestureRecognizer(doubleTap)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .began || gesture.state == .changed else { return }
        canvasTransform.zoom(by: gesture.scale, around: gesture.location(in: view))
        gesture.scale = 1
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .began || gesture.state == .changed else { return }
        canvasTransform.rotate(by: gesture.rotation, around: gesture.location(in: view))
        gesture.rotation = 0
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began || gesture.state == .changed else { return }
        let translation = gesture.translation(in: view)
        canvasTransform.pan(by: CGVector(dx: translation.x, dy: translation.y))
        gesture.setTranslation(.zero, in: view)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        UIView.animate(withDuration: 0.3) {
            self.canvasTransform.reset()
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
