//
//  ContentView.swift
//  SparkStudy
//
//  Created by Oliver Tran on 2/5/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSignInView: Bool = false
    @State private var selectedView: SelectedView? = .note
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationSplitView {
                    List(selection: $selectedView) {
                        Section(header: Text("Main")) {
                            NavigationLink(value: SelectedView.note) {
                                Label("Notes", systemImage: "note.text")
                            }
                            NavigationLink(value: SelectedView.profile) {
                                Label("Profile", systemImage: "person")
                            }
                        }
                    }
                    .navigationTitle("Menu")
                } detail: {
                    switch selectedView {
                    case .note:
                        NotesListView()
                    case .profile:
                        ProfileView(showSignInView: $showSignInView)
                    case .none:
                        Text("Select a view")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

// Enum to manage selected views
enum SelectedView: Hashable {
    case note
    case profile
}

#Preview {
    ContentView()
}
