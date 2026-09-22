import SwiftUI

struct OnboardingBottomBar: View {
    @Binding var currentTab: Int
    let totalTabs: Int
    let isValid: Bool
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
                        withAnimation(.easeInOut) {
                            currentTab += 1
                        }
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
                        .clipShape(.capsule)
                }
                .disabled(!isValid)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
    }
}

// Representación nativa del indicador de páginas HIG
private struct PageControlIndicator: View {
    let currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.snappy, value: currentPage)
            }
        }
    }
}
