//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Rishav Gupta on 25/06/23.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    // View Model = have properties and methods here - easier for tests
    // Manipulation of views is a great candicate for ViewModel
    
    @MainActor class ViewModel: ObservableObject {
        // @MainActor is responsible for running all user interface updates and adding that attribute to our class means whatever we run in this class to run on the MainActor - responsible for making UI updates
        // As before, when using ObservableObject, when we made objects, ObjservedObjects or StateObject, Swift silently inferred the MainActor without us asking for it.
        // But that is not 100% safe. If called StateObject from SwiftUI view it may use MainActor but what if we call it from somewhere else.
        
        // Every time you have a class conform to ObservableObject, add a MainActor wrapper
        
        
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        @Published private(set) var locations: [Location] // read all you want, but you can't set from outside
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        @Published var isErrorAlertShown = false
        @Published var errorShown = ""
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaced")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
//                        Task { // this makes the task run in background thread
//                            await MainActor.run { // this will make it run in main thread
//                                self.isUnlocked = true
//                            }
//                        }
                        Task { @MainActor in // this will make the task run in main thread directly
                            self.isUnlocked = true
                        }
                    } else {
                        // problem
                        Task { @MainActor in
                            self.isErrorAlertShown = true
                            self.errorShown = authenticationError?.localizedDescription ?? "Unknown Error"
                        }
                    }
                }
            } else {
                // no biometrics
                Task { @MainActor in
                    self.isErrorAlertShown = true
                    self.errorShown = error?.localizedDescription ?? "Unknown Error"
                }
            }
        }
    }
}
