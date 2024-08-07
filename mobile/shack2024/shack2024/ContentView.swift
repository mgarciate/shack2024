//
//  ContentView.swift
//  shack2024
//
//  Created by mgarciate on 5/8/24.
//

import SwiftUI
import eas_sdk_swift

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(EAS().name)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
