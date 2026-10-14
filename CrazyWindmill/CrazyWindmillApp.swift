import SwiftUI
import Darwin

@main
struct CrazyWindmillApp: App {
    var body: some Scene {
        WindowGroup {
            WindmillView()
                .statusBarHidden()
                .preferredColorScheme(.light)
        }
    }
}

private struct WindmillView: View {
    private let approachDuration = 30.0
    private let alignDuration = 0.25
    private let stillDuration = 1.0
    private let rushDuration = 0.30
    private let spinRate = 2.8

    @State private var startTime: Date?
    @State private var didTerminate = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(startTime ?? timeline.date))
            let phase = phase(at: elapsed)

            GeometryReader { geometry in
                ZStack {
                    (phase.isTransformed ? Color.black : Color.white)
                        .ignoresSafeArea()

                    windmill(
                        transformed: phase.isTransformed,
                        radius: min(geometry.size.width, geometry.size.height) * 0.205,
                        scale: phase.scale,
                        rotation: phase.rotation
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            .onChange(of: elapsed) { value in
                guard !didTerminate, value >= approachDuration + alignDuration + stillDuration + rushDuration else { return }
                didTerminate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    exit(EXIT_SUCCESS)
                }
            }
        }
        .onAppear {
            startTime = Date()
        }
    }

    private func windmill(transformed: Bool, radius: CGFloat, scale: CGFloat, rotation: Double) -> some View {
        let hand = transformed ? "👉" : "☝️"
        let glyphSize: CGFloat = transformed ? 66 : 62
        let face = transformed ? "😳" : "😁"

        return ZStack {
            Text(face)
                .font(.system(size: 78))

            ZStack {
                Text(hand)
                    .font(.system(size: glyphSize))
                    .rotationEffect(.degrees(transformed ? 90 : 180))
                    .offset(y: -radius)
                Text(hand)
                    .font(.system(size: glyphSize))
                    .rotationEffect(.degrees(transformed ? 180 : -90))
                    .offset(x: radius)
                Text(hand)
                    .font(.system(size: glyphSize))
                    .rotationEffect(.degrees(transformed ? -90 : 0))
                    .offset(y: radius)
                Text(hand)
                    .font(.system(size: glyphSize))
                    .rotationEffect(.degrees(transformed ? 0 : 90))
                    .offset(x: -radius)
            }
            .rotationEffect(.radians(rotation))
        }
        .scaleEffect(scale)
        .frame(width: radius * 2 + glyphSize, height: radius * 2 + glyphSize)
        .accessibilityLabel(transformed ? "😳 surrounded by outward-pointing hands" : "😁 surrounded by inward-pointing fingers")
    }

    private func phase(at elapsed: TimeInterval) -> (scale: CGFloat, rotation: Double, isTransformed: Bool) {
        if elapsed < approachDuration {
            let progress = elapsed / approachDuration
            let scale = 0.34 + 1.16 * progress
            return (CGFloat(scale), elapsed * spinRate, false)
        }

        let phaseElapsed = elapsed - approachDuration
        let startAngle = approachDuration * spinRate
        let quarterTurn = Double.pi / 2
        let targetAngle = (startAngle / quarterTurn).rounded() * quarterTurn
        if phaseElapsed < alignDuration {
            let progress = max(0, phaseElapsed / alignDuration)
            let eased = progress * progress * (3 - 2 * progress)
            let angle = startAngle + (targetAngle - startAngle) * eased
            return (1.5, angle, true)
        }
        if phaseElapsed < alignDuration + stillDuration {
            return (1.5, targetAngle, true)
        }

        let rushProgress = min(1, (phaseElapsed - alignDuration - stillDuration) / rushDuration)
        let scale = 1.5 + 30 * pow(rushProgress, 2.2)
        return (CGFloat(scale), targetAngle, true)
    }
}
