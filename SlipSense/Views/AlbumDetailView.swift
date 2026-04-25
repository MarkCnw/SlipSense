import SwiftUI
import Photos
import SwiftData

struct AlbumDetailView: View {
    let album: AlbumInfo
    var photoService: PhotoService
    
    @Environment(\.modelContext) private var context
    @State private var viewModel: AlbumDetailViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    init(album: AlbumInfo, photoService: PhotoService) {
        self.album = album
        self.photoService = photoService
        _viewModel = State(initialValue: AlbumDetailViewModel(photoService: photoService))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                        NavigationLink(destination: SlipDetailView(asset: asset)) {
                            ThumbnailView(asset: asset)
                                .frame(height: 120)
                                .clipped()
                        }
                    }
                }
            }
            
            if viewModel.isBatchScanning {
                VStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ProgressView(viewModel.progressText)
                            .tint(.white)
                            .foregroundStyle(.white)
                        
                        ProgressView(
                            value: Double(viewModel.scannedCount),
                            total: Double(max(viewModel.assets.count, 1))
                        )
                        .progressViewStyle(.linear)
                        .tint(.orange)
                        
                        Text(viewModel.summaryText)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .padding()
                }
            }
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("สแกนทั้งหมด") {
                    viewModel.startBatchScan(context: context)
                }
                .bold()
                .disabled(viewModel.isBatchScanning || viewModel.assets.isEmpty)
            }
        }
        .onAppear {
            viewModel.loadAssets(in: album.collection)
        }
    }
}
// MARK: - Thumbnail
struct ThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            
            manager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                DispatchQueue.main.async {
                    self.image = result
                }
            }
        }
    }
}
