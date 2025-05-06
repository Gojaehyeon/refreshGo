//
//  CatRunView.swift
//  reFresh
//
//  Created by 고재현 on 5/3/25.
//

import SwiftUI
import CoreHaptics

struct CatRunView: View {
    @State private var cats: [UUID] = [UUID()]
    @State private var positions: [UUID: CGPoint] = [:]
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var timers: [UUID: Timer] = [:]
    @State private var catImages: [UUID: String] = [:]
    @State private var catSizes: [UUID: CGFloat] = [:]
    @State private var longPressTimers: [UUID: Timer] = [:]

    var body: some View {
//        HStack {
//            Spacer()
//            Button(action: {
//                self.cats.removeAll()
//            }) {
//                Text("Reset")
//                    .foregroundColor(.black)
//                    .padding()
//            }
//        }
        GeometryReader { geometry in
            ZStack {
                TimelineView(.animation) { _ in
                    ZStack {
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .onTapGesture {
                                let newId = UUID()
                                let initialPosition = randomPosition(in: geometry.size)
                                let imageName = Bool.random() ? "cat" : "cat2"
                                let size = CGFloat.random(in: 30...120)
                                cats.append(newId)
                                positions[newId] = initialPosition
                                catImages[newId] = imageName
                                catSizes[newId] = size

                                withAnimation(.easeInOut(duration: 3.0)) {
                                    positions[newId] = randomPosition(in: geometry.size)
                                }

                                let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                                    withAnimation(.easeInOut(duration: 3.0)) {
                                        positions[newId] = randomPosition(in: geometry.size)
                                    }
                                }
                                timers[newId] = timer

                                for i in 0..<3 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                        feedbackGenerator.impactOccurred()
                                    }
                                }
                            }
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    for i in 0..<5 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            feedbackGenerator.impactOccurred()
                                        }
                                    }

                                    // Reset state
                                    timers.values.forEach { $0.invalidate() }
                                    timers.removeAll()
                                    cats = [UUID()]
                                    positions.removeAll()
                                    catImages.removeAll()
                                    catSizes.removeAll()
                                }) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 50)
                            }
                            Spacer()
                        }

                        ForEach(cats, id: \.self) { id in
                            let position = positions[id] ?? randomPosition(in: geometry.size)
                            Image(catImages[id] ?? "cat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: catSizes[id] ?? 80)
                                .position(position)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            positions[id] = value.location
                                            feedbackGenerator.impactOccurred()
                                        }
                                        .onEnded { _ in
                                            timers[id]?.invalidate()
                                            timers.removeValue(forKey: id)
                                            cats.removeAll { $0 == id }
                                            positions.removeValue(forKey: id)
                                            catImages.removeValue(forKey: id)
                                            catSizes.removeValue(forKey: id)
                                        }
                                )
                                .onTapGesture {
                                    let newId = UUID()
                                    let imageName = Bool.random() ? "cat" : "cat2"
                                    let size = CGFloat.random(in: 30...120)
                                    cats.append(newId)
                                    catImages[newId] = imageName
                                    catSizes[newId] = size
                                    positions[newId] = randomPosition(in: geometry.size)

                                    withAnimation(.easeInOut(duration: 3.0)) {
                                        positions[newId] = randomPosition(in: geometry.size)
                                    }

                                    let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                                        withAnimation(.easeInOut(duration: 3.0)) {
                                            positions[newId] = randomPosition(in: geometry.size)
                                        }
                                    }
                                    timers[newId] = timer

                                    for i in 0..<3 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                            feedbackGenerator.impactOccurred()
                                        }
                                    }
                                }
                                .onAppear {
                                    if positions[id] == nil {
                                        positions[id] = randomPosition(in: geometry.size)
                                    }
                                    if timers[id] == nil {
                                        withAnimation(.easeInOut(duration: 3.0)) {
                                            positions[id] = randomPosition(in: geometry.size)
                                        }

                                        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                                            withAnimation(.easeInOut(duration: 3.0)) {
                                                positions[id] = randomPosition(in: geometry.size)
                                            }
                                        }
                                        timers[id] = timer
                                    }
                                    if catImages[id] == nil {
                                        catImages[id] = Bool.random() ? "cat" : "cat2"
                                    }
                                    if catSizes[id] == nil {
                                        catSizes[id] = CGFloat.random(in: 30...120)
                                    }
                                }
                        }
                    }
                }

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            for i in 0..<5 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                                    feedbackGenerator.impactOccurred()
                                }
                            }

                            // Reset state
                            timers.values.forEach { $0.invalidate() }
                            timers.removeAll()
                            cats = [UUID()]
                            positions.removeAll()
                            catImages.removeAll()
                            catSizes.removeAll()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    Spacer()
                }
            }
        }
    }

    func randomPosition(in size: CGSize) -> CGPoint {
        let x = CGFloat.random(in: 40...(size.width - 40))
        let y = CGFloat.random(in: 100...(size.height - 100))
        return CGPoint(x: x, y: y)
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

final class ShakeWindow: UIWindow {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

#Preview {
    CatRunView()
}
