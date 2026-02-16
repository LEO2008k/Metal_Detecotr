import SwiftUI

struct RulerView: View {
    @State private var sliderPosition: CGFloat = 0
    @State private var sliderValueCm: Double = 0
    @State private var sliderValueIn: Double = 0
    
    // Standard calibration for generic iPhones (approximate)
    // On most modern iPhones, 1 point is remarkably consistent physically,
    // but slight variations exist.
    // 1 inch = 25.4 mm
    // A standard credit card width is 85.60 mm (3.370 inches).
    // Using a safe default: ~160-163 points per inch logically in SwiftUI coordinate space.
    private let pointsPerInch: CGFloat = 160.0 
    private let pointsPerCm: CGFloat = 160.0 / 2.54
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // Background ruler lines
                HStack(spacing: 0) {
                    // Centimeters (Left Side)
                    ZStack(alignment: .topLeading) {
                        // Background strip
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.05), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 80)
                        
                        // Ticks
                        ForEach(0..<Int(geo.size.height / (pointsPerCm / 10)) + 1, id: \.self) { i in
                            let y = CGFloat(i) * (pointsPerCm / 10)
                            let isCm = i % 10 == 0
                            let isHalf = i % 5 == 0 && !isCm
                            
                            Rectangle()
                                .fill(.white.opacity(isCm ? 0.8 : (isHalf ? 0.5 : 0.2)))
                                .frame(width: isCm ? 30 : (isHalf ? 20 : 10), height: 1)
                                .offset(y: y)
                            
                            if isCm {
                                Text("\(i / 10)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .offset(x: 35, y: y - 5)
                                    .rotationEffect(.degrees(-90))
                            }
                        }
                    }
                    .frame(width: geo.size.width / 2, alignment: .leading)
                    
                    // Inches (Right Side)
                    ZStack(alignment: .topTrailing) {
                        // Background strip
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.05), .clear],
                                startPoint: .trailing,
                                endPoint: .leading
                            ))
                            .frame(width: 80)
                        
                        // Ticks
                        ForEach(0..<Int(geo.size.height / (pointsPerInch / 16)) + 1, id: \.self) { i in
                            let y = CGFloat(i) * (pointsPerInch / 16)
                            let isInch = i % 16 == 0
                            let isHalf = i % 8 == 0 && !isInch
                            let isQuarter = i % 4 == 0 && !isHalf && !isInch
                            
                            Rectangle()
                                .fill(.white.opacity(isInch ? 0.8 : (isHalf ? 0.6 : (isQuarter ? 0.4 : 0.2))))
                                .frame(width: isInch ? 30 : (isHalf ? 20 : (isQuarter ? 15 : 8)), height: 1)
                                .offset(y: y)
                            
                            if isInch {
                                Text("\(i / 16)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .offset(x: -35, y: y - 5)
                                    .rotationEffect(.degrees(-90))
                            }
                        }
                    }
                    .frame(width: geo.size.width / 2, alignment: .trailing)
                }
                
                // Measurement Slider
                Rectangle()
                    .fill(Color.cyan)
                    .frame(height: 2)
                    .offset(y: sliderPosition)
                    .overlay(
                        HStack {
                            // Left handle (CM value)
                            Text(String(format: "%.1f %@", sliderValueCm, L10n.centimeters))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cyan, in: RoundedRectangle(cornerRadius: 6))
                                .offset(x: 20, y: -30)
                            
                            Spacer()
                            
                            // Right handle (Inch value)
                            Text(String(format: "%.2f %@", sliderValueIn, L10n.inches))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cyan, in: RoundedRectangle(cornerRadius: 6))
                                .offset(x: -20, y: -30)
                        }
                        .offset(y: sliderPosition)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let y = max(0, min(value.location.y, geo.size.height))
                                sliderPosition = y
                                updateValues(y: y)
                            }
                    )
                
                // Instructions Overlay (fades out)
                VStack {
                    Text(L10n.ruler)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.1))
                    Text(L10n.rulerSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.1))
                }
                .padding(.top, 100)
                .allowsHitTesting(false)
            }
        }
        .background(Color.black.opacity(0.9))
        .onAppear {
            // Initial position (e.g. at 5cm mark)
            let startY = 5.0 * pointsPerCm
            sliderPosition = startY
            updateValues(y: startY)
        }
    }
    
    private func updateValues(y: CGFloat) {
        sliderValueCm = Double(y / pointsPerCm)
        sliderValueIn = Double(y / pointsPerInch)
    }
}

#Preview {
    RulerView()
        .preferredColorScheme(.dark)
}
