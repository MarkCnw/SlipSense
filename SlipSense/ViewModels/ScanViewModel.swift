import Foundation
import Photos
import SwiftUI

@Observable
class ScanViewModel {
    // ถือครอง Service เอาไว้ใช้งาน
    private var photoService = PhotoService()
    
    // ส่งผ่านข้อมูลให้ View
    var hasPermission: Bool {
        return photoService.hasPermission
    }
    
    var albums: [AlbumInfo] {
        return photoService.albums
    }
    
    // สั่งขอสิทธิ์การเข้าถึงรูป
    func requestPermission() async {
        await photoService.requestPermission()
    }
    
    // ปล่อย Service ให้หน้าถัดไปใช้งาน
    func getService() -> PhotoService {
        return photoService
    }
}
