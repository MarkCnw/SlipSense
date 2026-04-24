import SwiftUI

struct ScanView: View {
    // 💡 สังเกตว่าเราไม่ต้องมีคำว่า private ก็ได้ และตอนเรียกใช้จะไม่ใส่ $
    
    @State private var photoService = PhotoService()
    @State private var slipParserService = SlipParserService()
    @State private var slipRecordService = SlipRecordService()
    
    var body: some View {
        NavigationStack {
            Group {
                
                if photoService.hasPermission {
                    
                    List(photoService.albums) { album in
                        // 💡 เอา NavigationLink มาครอบตรงนี้! เพื่อเชื่อมไปหน้า AlbumDetailView
                        NavigationLink(destination: AlbumDetailView(album: album, photoService: photoService)) {
                            HStack {
                                Text(album.name).font(.headline)
                                Spacer()
                                Text("\(album.photoCount) รูป").foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("กรุณาอนุญาตการเข้าถึงรูปภาพ")
                            .font(.headline)
                        
                        Button("ขออนุญาตอีกครั้ง") {
                            Task { await photoService.requestPermission() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("ค้นหาอัลบั้มสลิป")
            .task {
                await photoService.requestPermission()
            }
        }
    }
}

#Preview {
    ContentView()
}
