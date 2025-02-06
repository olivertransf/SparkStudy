//
//  ContentView.swift
//  SparkStudy
//
//  Created by Oliver Tran on 2/5/25.
//

import SwiftUI

struct ContentView: View {

    @State private var showSignInview: Bool = false
    
    var body: some View {
            ZStack {
                if !showSignInview {
                    NavigationStack {
                        Text("Hello")
                    }
                }
            }
            .onAppear {
                let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignInview = authuser == nil
            }
        
            .fullScreenCover(isPresented: $showSignInview) {
                NavigationView {
                    AuthenticationView(showSignInView: $showSignInview)
            }
        }
    }
}

#Preview {
    ContentView()
}
