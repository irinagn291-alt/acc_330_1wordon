import SwiftUI

struct ContentView: View {
    var body: some View {
        ReviewScreenRouter()
    }
}

#Preview {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cordon-preview.json")
    ContentView()
        .environment(
            CordonStore(
                fileURL: url,
                defaultsSuite: "cordon.preview",
                allowsDemoSeed: false
            )
        )
}
