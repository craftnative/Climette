import SwiftUI

struct OnboardingBottomBar: View {
    let currentTab: Int
    let totalTabs: Int
    let isValid: Bool
    let onNext: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.5)
            
            HStack {
                PageControlIndicator(currentPage: currentTab, numberOfPages: totalTabs)
                
                Spacer()
                
                Button {
                    if currentTab < totalTabs - 1 {
                        onNext()
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentTab == totalTabs - 1 ? "Comenzar" : "Siguiente")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(isValid ? Color.accentColor : Color.secondary)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
                .disabled(!isValid)
                .accessibilityLabel(currentTab == totalTabs - 1 ? "Comenzar la aplicación" : "Ir al siguiente paso")
                .accessibilityHint(isValid ? "" : "Debes completar la información requerida para continuar.")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
    }
}

private struct PageControlIndicator: View {
    let currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Paso \(currentPage + 1) de \(numberOfPages)")
        .accessibilityAddTraits(.isStaticText)
    }
}
