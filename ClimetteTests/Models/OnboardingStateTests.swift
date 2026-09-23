import Testing
import Foundation
import SwiftData
@testable import Climette

@MainActor
struct OnboardingStateTests {
    
    @Test("Valores por defecto iniciales")
    func defaultValues() {
        let state = OnboardingState()
        #expect(state.currentTab == 0)
        #expect(state.selectedSensitivity == .normal)
        #expect(state.selectedLocationMode == .gps)
        #expect(state.isCurrentStepValid == true)
    }

    @Test("Navegación respeta los límites")
    func navigationBounds() {
        let state = OnboardingState()
        
        state.goBack(reduceMotion: true)
        #expect(state.currentTab == 0) // No baja de 0

        state.advance(reduceMotion: true)
        #expect(state.currentTab == 1)

        state.advance(reduceMotion: true)
        #expect(state.currentTab == 2)

        state.advance(reduceMotion: true)
        #expect(state.currentTab == 2) // No supera totalTabs - 1
    }

    @Test("Validación de ingreso manual de ubicación")
    func manualLocationValidation() {
        let state = OnboardingState()
        state.currentTab = 1
        
        state.selectedLocationMode = .gps
        #expect(state.isCurrentStepValid == true)
        
        state.selectedLocationMode = .manual
        state.manualCityName = ""
        #expect(state.isCurrentStepValid == false)
        
        state.manualCityName = "   "
        #expect(state.isCurrentStepValid == false)
        
        state.manualCityName = "Madrid"
        #expect(state.isCurrentStepValid == true)
    }

    @Test("Persistencia de datos en ModelContext")
    func saveAndComplete() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserProfileEntity.self, LocationStateEntity.self, configurations: config)
        let context = container.mainContext
        
        let state = OnboardingState()
        state.manualCityName = "Valencia"
        state.selectedLocationMode = .manual
        
        state.saveAndComplete(context: context)
        
        let userProfiles = try context.fetch(FetchDescriptor<UserProfileEntity>())
        let locations = try context.fetch(FetchDescriptor<LocationStateEntity>())
        
        #expect(userProfiles.count == 1)
        #expect(locations.count == 1)
        #expect(locations.first?.cityName == "Valencia")
        #expect(locations.first?.modeRaw == "manualCity")
    }
}
