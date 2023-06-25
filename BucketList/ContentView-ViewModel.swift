//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Rishav Gupta on 25/06/23.
//

import Foundation
import MapKit

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        // @MainActor is responsible for running all user interface updates and adding that attribute to our class means whatever we run in this class to run on the MainActor - responsible for making UI updates
        // As before, when using ObservableObject, when we made objects, ObjservedObjects or StateObject, Swift silently inferred the MainActor without us asking for it.
        // But that is not 100% safe. If called StateObject from SwiftUI view it may use MainActor but what if we call it from somewhere else.
        
        // Every time you have a class conform to ObservableObject, add a MainActor wrapper
        
        
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        
        @Published var locations = [Location]()
        
        @Published var selectedPlace: Location?
    }
}
