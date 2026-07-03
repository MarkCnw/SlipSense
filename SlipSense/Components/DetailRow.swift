import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    var isHighlight: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(isHighlight ? .bold : .medium)
                .font(isHighlight ? .title3 : .body)
        }
    }
}
