import SwiftUI

struct JournalView: View {
    @State private var dreams: [String] = UserDefaults.standard.stringArray(forKey: "dreams") ?? []
    @State private var newDream = ""
    @State private var showingAddSheet = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.2), Color.blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Dream Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50)

                Text("Record your dreams to improve lucidity")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)

                if dreams.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No dreams recorded yet")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.title2)
                        Text("Tap + to add your first dream")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(dreams.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("Dream \(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Text(dreams[index])
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.top, 5)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDreamView(newDream: $newDream, dreams: $dreams, showingSheet: $showingAddSheet)
        }
        .navigationBarHidden(true)
    }
}

struct AddDreamView: View {
    @Binding var newDream: String
    @Binding var dreams: [String]
    @Binding var showingSheet: Bool

    var body: some View {
        NavigationView {
            VStack {
                Text("Add New Dream")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                TextEditor(text: $newDream)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(height: 200)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    newDream = ""
                    showingSheet = false
                },
                trailing: Button("Save") {
                    if !newDream.isEmpty {
                        dreams.append(newDream)
                        UserDefaults.standard.set(dreams, forKey: "dreams")
                        newDream = ""
                        showingSheet = false
                    }
                }
                .disabled(newDream.isEmpty)
            )
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}