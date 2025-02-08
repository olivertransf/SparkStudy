import SwiftUI
import FirebaseFirestore

// Note Editor View
struct NoteEditorView: View {
    @ObservedObject var viewModel: NotesViewModel
    let note: Note?
    @State private var title: String
    @State private var content: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(viewModel: NotesViewModel, note: Note?) {
        self.viewModel = viewModel
        self.note = note
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .font(.title)
                    .padding()
                
                TextEditor(text: $content)
                    .padding()
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveNote()
                }
                .disabled(isLoading)
            )
            .navigationBarTitle(note == nil ? "New Note" : "Edit Note", displayMode: .inline)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                    }
                }
            )
        }
    }
    
    private func saveNote() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let existingNote = note {
                    try await viewModel.updateNote(existingNote, title: title, content: content)
                } else {
                    try await viewModel.addNote(title: title, content: content)
                }
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// Notes List View
struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingNewNote = false
    @State private var selectedNote: Note?
    
    var body: some View {
        List {
            ForEach(viewModel.notes.sorted(by: { $0.dateModified > $1.dateModified })) { note in
                VStack(alignment: .leading) {
                    Text(note.title)
                        .font(.headline)
                    Text(note.content)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    selectedNote = note
                }
            }
            .onDelete(perform: viewModel.deleteNote)
        }
        .navigationTitle("Notes")
        .refreshable {
            Task {
                try await viewModel.loadCurrentUser()
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                showingNewNote = true
            }) {
                Image(systemName: "square.and.pencil")
            }
        )
        .sheet(isPresented: $showingNewNote) {
            NoteEditorView(viewModel: viewModel, note: nil)
        }
        .sheet(item: $selectedNote) { note in
            NoteEditorView(viewModel: viewModel, note: note)
        }
    }
}
