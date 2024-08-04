//
//  ContentView.swift
//  shack2024watch Watch App
//
//  Created by mgarciate on 5/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
    
    init() {
        let healthDataService = HealthDataService()

        healthDataService.requestHealthKitPermissions { success, error in
            if success {
                healthDataService.fetchHealthData { healthData, error in
                    if let error = error {
                        print("Error fetching health data: \(error.localizedDescription)")
                    } else {
                        print("Health Data: \(healthData)")
                    }
                }
            } else {
                print("HealthKit permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

#Preview {
    ContentView()
}
