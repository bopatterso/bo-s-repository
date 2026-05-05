import SwiftUI

struct JournalView: View {
    @State private var dreams: [String] = UserDefaults.standard.stringArray(forKey: "dreams") ?? []
    @State private var newDream = ""

    var body: some View {
        VStack {
            Text("Record your dreams to improve lucidity")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top)

            TextField("Describe your dream...", text: $newDream)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.vertical, 10)

            Button(action: {
                if !newDream.isEmpty {
                    dreams.append(newDream)
                    UserDefaults.standard.set(dreams, forKey: "dreams")
                    newDream = ""
                }
            }) {
                Text("Add Dream Entry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            List(dreams.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text("Dream \(index + 1)")
                        .font(.headline)
                    Text(dreams[index])
                        .font(.body)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Dream Journal")
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}