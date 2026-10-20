import SwiftUI

struct RemoteImage: View {
    let url: URL?

    var body: some View {
        DesignSystem.Colors.imagePlaceholder
            .overlay {
                if let url, url.isFileURL, let image = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo")
                                .font(DesignSystem.Fonts.title)
                                .foregroundStyle(DesignSystem.Colors.secondaryText)
                        }
                    }
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

#Preview("Image") {
    RemoteImage(url: URL(string: "https://picsum.photos/seed/tixmarkt/400/400"))
        .frame(width: 200, height: 200)
}

#Preview("Placeholder") {
    RemoteImage(url: nil)
        .frame(width: 200, height: 200)
}
