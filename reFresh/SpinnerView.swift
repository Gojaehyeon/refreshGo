//
//  SpinnerView.swift
//  reFresh
//
//  Created by 고재현 on 5/3/25.
//

import SwiftUI
import CoreHaptics

struct SpinnerView: View {
    @State private var rotation: Double = 0
    @State private var spinSpeed: Double = 3600.0 // degrees per second
    @State private var lastUpdate = Date()
    @State private var isTouching = false
    @State private var engine: CHHapticEngine?

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("spinner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)
                .rotationEffect(.degrees(rotation))
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { _ in
                            spinSpeed += 500
                        }
                )
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onChanged { _ in
                    isTouching = true
                }
                .onEnded { _ in
                    isTouching = false
                }
        )
        .onAppear {
            prepareHaptics()
            lastUpdate = Date()
        }
        .onReceive(timer) { _ in
            let now = Date()
            let delta = now.timeIntervalSince(lastUpdate)
            lastUpdate = now

            rotation += spinSpeed * delta

            if rotation >= 360 {
                rotation -= 360
                triggerHaptic()
            }

            // 감속 처리 (터치 중일 땐 감속하지 않음)
            if isTouching {
                // 유지 (감속 없음)
            } else {
                spinSpeed *= 0.97
                if spinSpeed < 10 {
                    spinSpeed = 0
                }
            }
        }
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error.localizedDescription)")
        }
    }

    func triggerHaptic() {
        guard let engine = engine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic trigger error: \(error.localizedDescription)")
        }
    }
}
