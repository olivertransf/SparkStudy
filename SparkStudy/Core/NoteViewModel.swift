//
//  NoteViewModel.swift
//  SparkStudy
//
//  Created by Oliver Tran on 2/7/25.
//

import Foundation
import FirebaseFirestore

// Note Model
struct Note: Identifiable, Codable {
    var id: String
    var title: String
    var content: String
    var dateModified: Date
    
    // Add Firestore dictionary conversion
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "content": content,
            "dateModified": dateModified
        ]
    }
}

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published private(set) var user: DBUser? = nil
    private var collection: CollectionReference? = nil
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        Task {
            try? await loadCurrentUser()
            setupNotesListener()
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Load User
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        collection = Firestore.firestore().collection("users").document(authDataResult.uid).collection("notes")
    }
    
    private func setupNotesListener() {
        guard let collection else { return }
        
        listenerRegistration = collection
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.notes = documents.compactMap { document -> Note? in
                    try? document.data(as: Note.self)
                }
            }
    }
    
    func addNote(title: String, content: String) async throws {
        guard let collection else { return }
        
        let documentRef = collection.document()
        let note = Note(
            id: documentRef.documentID,
            title: title,
            content: content,
            dateModified: Date()
        )
        
        try await documentRef.setData(note.toDictionary())
    }
    
    func deleteNote(at offsets: IndexSet) {
        guard let collection else { return }
        
        for index in offsets {
            let note = notes[index]
            Task {
                try? await collection.document(note.id).delete()
            }
        }
    }
    
    func updateNote(_ note: Note, title: String, content: String) async throws {
        guard let collection else { return }
        
        let updatedNote = Note(
            id: note.id,
            title: title,
            content: content,
            dateModified: Date()
        )
        
        try await collection.document(note.id).setData(updatedNote.toDictionary())
    }
}
