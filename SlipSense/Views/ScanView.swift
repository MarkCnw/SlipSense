import SwiftUI

struct ScanView: View {
    // 💡 สังเกตว่าเราไม่ต้องมีคำว่า private ก็ได้ และตอนเรียกใช้จะไม่ใส่ $
    @State var photoManager = PhotoManager()
    
    var body: some View {
        NavigationStack {
            Group {
                
                if photoManager.hasPermission {
                    // 💡 ตรงนี้ต้องเป็น photoManager.albums เฉยๆ (ห้ามมี $)
                    List(photoManager.albums) { album in
                                            // 💡 เอา NavigationLink มาครอบตรงนี้! เพื่อเชื่อมไปหน้า AlbumDetailView
                                            NavigationLink(destination: AlbumDetailView(album: album, photoManager: photoManager)) {
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
                            Task { await photoManager.requestPermission() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("ค้นหาอัลบั้มสลิป")
            .task {
                await photoManager.requestPermission()
            }
        }
    }
}

#Preview {
    ContentView()
}
