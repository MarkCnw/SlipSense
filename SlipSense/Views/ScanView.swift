import SwiftUI

struct ScanView: View {
    @State private var viewModel = ScanViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasPermission {
                    List {
                        // 💡 AlbumInfo เป็น Identifiable อยู่แล้ว เลยใช้แค่นี้ได้เลยครับ
                        ForEach(viewModel.albums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album, photoService: viewModel.getService())) {
                                HStack {
                                    Text(album.name).font(.headline)
                                    Spacer()
                                    // 💡 แก้ตัวการที่ทำให้แอปแครชตรงนี้ครับ (photoCount)
                                    Text("\(album.photoCount) รูป").foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                        Text("ต้องการสิทธิ์เข้าถึงรูปภาพ")
                            .font(.title2.bold())
                        Text("แอปจำเป็นต้องเข้าถึงอัลบั้มรูปภาพของคุณ เพื่อทำการสแกนสลิปโอนเงิน")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        Button("อนุญาตเข้าถึงรูปภาพ") {
                            Task {
                                await viewModel.requestPermission()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("ค้นหาอัลบั้มสลิป")
            .task {
                await viewModel.requestPermission()
            }
        }
    }
}
