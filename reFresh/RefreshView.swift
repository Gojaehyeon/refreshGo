//
//  RefreshView.swift
//  reFresh
//
//  Created by 고재현 on 5/3/25.
//

import SwiftUI
import CoreHaptics

struct RefreshView: View {
    @State private var mainCount = 0
    @State private var subCount = 0
    @State private var isCounting = false
    @State private var countingTimer: Timer?
    @State private var colorIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var engine: CHHapticEngine?
    @State private var dragHapticTimer: Timer?
    @State private var dragColorTimer: Timer?
    
    let colors: [Color] = [
        .black,
        Color(red: 200/255, green: 0, blue: 0),     // 진한 빨강
        Color(red: 0, green: 0, blue: 200/255),     // 파랑
        Color(red: 255/255, green: 100/255, blue: 0), // 오렌지
        Color(red: 0, green: 150/255, blue: 0),     // 녹색
        Color(red: 100/255, green: 0, blue: 150/255), // 보라
        Color(red: 60/255, green: 60/255, blue: 60/255) // 어두운 회색
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Main background color
                colors[colorIndex]
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.2), value: colorIndex)

                // Pull-down area showing next color
                colors[(colorIndex + 1) % colors.count]
                    .frame(height: dragOffset)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .offset(y: -geometry.safeAreaInsets.top)

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.white)
                            .font(.title)
                        Text("Pull to refresh")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(mainCount)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)

                        Text(String(format: "%03d", subCount))
                            .font(.title2)
                            .baselineOffset(12)
                            .foregroundColor(.white)
                    }
                    .animation(.easeInOut, value: mainCount)

                    Spacer()
                }
                .padding(.top, 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isRefreshing {
                                dragOffset = max(value.translation.height, 0)
                                if dragHapticTimer == nil {
                                    dragHapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                        triggerTapHaptic()
                                    }
                                }
                                if dragColorTimer == nil {
                                    dragColorTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            colorIndex = (colorIndex + 1) % colors.count
                                        }
                                    }
                                }
                                if !isCounting {
                                    isCounting = true
                                    countingTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                                        subCount += 1
                                        if subCount >= 1000 {
                                            mainCount += 1
                                            subCount = 0
                                        }
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            dragHapticTimer?.invalidate()
                            dragHapticTimer = nil
                            dragColorTimer?.invalidate()
                            dragColorTimer = nil
                            countingTimer?.invalidate()
                            countingTimer = nil
                            isCounting = false // 다시 시작될 수 있도록 false로 초기화
                            if dragOffset > 20 {
                                triggerRefresh()
                            }
                            dragOffset = 0
                        }
                )
            }
        }
        .onAppear {
            prepareHaptics()
        }
    }

    func triggerRefresh() {
        isRefreshing = true
        mainCount += 1

        withAnimation(.easeOut(duration: 0.4)) {
            dragOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // 색상 인덱스를 더 이상 변경하지 않음. 드래그 중 멈춘 색상 유지.
            // Repeat transient haptic multiple times during refresh
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    triggerTapHaptic()
                }
            }
            isRefreshing = false
        }
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }

    func triggerHaptic() {
        guard let engine = engine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [intensity, sharpness],
                                  relativeTime: 0,
                                  duration: 0.3)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic Playback Error: \(error.localizedDescription)")
        }
    }
    
    func triggerTapHaptic() {
        guard let engine = engine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensity, sharpness],
                                  relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Tap Haptic Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RefreshView()
}
