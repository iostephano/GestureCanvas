//
//  CanvasTransformTests.swift
//  GestureCanvasTests
//
//  Created by Stephano Portella on 03/09/26.
//

import Testing
import CoreGraphics
@testable import GestureCanvas

struct CanvasTransformTests {

    private let anchor = CGPoint(x: 120, y: 260)
    private let epsilon: CGFloat = 0.0001

    private func isClose(_ a: CGPoint, _ b: CGPoint) -> Bool {
        abs(a.x - b.x) < epsilon && abs(a.y - b.y) < epsilon
    }

    // MARK: - Estado inicial

    @Test("A fresh transform is the identity with scale 1")
    func startsAtIdentity() {
        let transform = CanvasTransform()
        #expect(transform.affine == .identity)
        #expect(abs(transform.scale - 1) < epsilon)
    }

    // MARK: - Pan

    @Test("Pan adds the translation in screen space")
    func panTranslatesInScreenSpace() {
        var transform = CanvasTransform()
        transform.pan(by: CGVector(dx: 30, dy: -12))
        #expect(abs(transform.affine.tx - 30) < epsilon)
        #expect(abs(transform.affine.ty - (-12)) < epsilon)
    }

    @Test("Pan is unaffected by an existing zoom or rotation")
    func panIgnoresZoomAndRotation() {
        var transform = CanvasTransform()
        transform.zoom(by: 3, around: anchor)
        transform.rotate(by: .pi / 3, around: anchor)
        let before = transform.affine

        transform.pan(by: CGVector(dx: 40, dy: 25))

        // La traslación de pantalla se suma tal cual a tx/ty; el resto de la
        // matriz no cambia.
        #expect(abs(transform.affine.tx - (before.tx + 40)) < epsilon)
        #expect(abs(transform.affine.ty - (before.ty + 25)) < epsilon)
        #expect(abs(transform.affine.a - before.a) < epsilon)
        #expect(abs(transform.affine.b - before.b) < epsilon)
        #expect(abs(transform.affine.c - before.c) < epsilon)
        #expect(abs(transform.affine.d - before.d) < epsilon)
    }

    // MARK: - Zoom

    @Test("Zoom multiplies the current scale")
    func zoomMultipliesScale() {
        var transform = CanvasTransform()
        transform.zoom(by: 2, around: anchor)
        #expect(abs(transform.scale - 2) < epsilon)
        transform.zoom(by: 1.5, around: anchor)
        #expect(abs(transform.scale - 3) < epsilon)
    }

    @Test("The zoom anchor stays fixed under the transform")
    func zoomKeepsAnchorFixed() {
        var transform = CanvasTransform()
        transform.zoom(by: 2.5, around: anchor)
        #expect(isClose(anchor.applying(transform.affine), anchor))
    }

    @Test("Zoom clamps the scale to the maximum")
    func zoomClampsToMax() {
        var transform = CanvasTransform()
        transform.zoom(by: 100, around: anchor)
        #expect(abs(transform.scale - CanvasTransform.maxScale) < epsilon)
    }

    @Test("Zoom clamps the scale to the minimum")
    func zoomClampsToMin() {
        var transform = CanvasTransform()
        transform.zoom(by: 0.001, around: anchor)
        #expect(abs(transform.scale - CanvasTransform.minScale) < epsilon)
    }

    @Test("Zooming past the limit in steps still clamps")
    func zoomClampsAcrossSteps() {
        var transform = CanvasTransform()
        transform.zoom(by: 3, around: anchor)
        transform.zoom(by: 3, around: anchor)
        #expect(abs(transform.scale - CanvasTransform.maxScale) < epsilon)
    }

    @Test("A non-positive zoom factor is ignored")
    func zoomIgnoresNonPositiveFactor() {
        var transform = CanvasTransform()
        transform.zoom(by: 0, around: anchor)
        transform.zoom(by: -2, around: anchor)
        #expect(transform.affine == .identity)
    }

    // MARK: - Rotación

    @Test("Rotation does not change the scale")
    func rotationKeepsScale() {
        var transform = CanvasTransform()
        transform.zoom(by: 2, around: anchor)
        transform.rotate(by: .pi / 2, around: anchor)
        #expect(abs(transform.scale - 2) < epsilon)
    }

    @Test("The rotation anchor stays fixed under the transform")
    func rotationKeepsAnchorFixed() {
        var transform = CanvasTransform()
        transform.rotate(by: .pi / 4, around: anchor)
        #expect(isClose(anchor.applying(transform.affine), anchor))
    }

    @Test("Zoom and rotation about the same anchor both keep it fixed")
    func combinedKeepsAnchorFixed() {
        var transform = CanvasTransform()
        transform.zoom(by: 1.8, around: anchor)
        transform.rotate(by: .pi / 5, around: anchor)
        transform.zoom(by: 1.4, around: anchor)
        #expect(isClose(anchor.applying(transform.affine), anchor))
    }

    // MARK: - Reset

    @Test("Reset returns to the identity")
    func resetClearsEverything() {
        var transform = CanvasTransform()
        transform.zoom(by: 2, around: anchor)
        transform.rotate(by: 1, around: anchor)
        transform.pan(by: CGVector(dx: 50, dy: 50))
        transform.reset()
        #expect(transform.affine == .identity)
        #expect(abs(transform.scale - 1) < epsilon)
    }
}
