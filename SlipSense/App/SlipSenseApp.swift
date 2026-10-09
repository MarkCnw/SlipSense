import SwiftUI
import SwiftData
import BackgroundTasks
import Photos

@main
struct SlipSenseApp: App {
    @AppStorage("appTheme") private var appTheme: Int = 0
    @Environment(\.scenePhase) private var scenePhase
    
    private let refreshTaskId = "com.markcnw.slipsense.refresh"
    
    init() {
        registerBackgroundTask()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: SlipRecord.self)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                scheduleAppRefresh()
            }
        }
    }
    
    // MARK: - Background Tasks
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskId, using: nil) { task in
            guard let appRefreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: appRefreshTask)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // ให้ระบบพิจารณาหลังผ่านไป 30 นาที
        try? BGTaskScheduler.shared.submit(request)
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let backgroundTask = Task {
            guard let container = try? ModelContainer(for: SlipRecord.self) else {
                task.setTaskCompleted(success: false)
                return
            }
            
            let photoService = PhotoService()
            let isAllowed = await photoService.checkPhotoPermission()
            
            if isAllowed {
                let lastSyncDate = (UserDefaults.standard.object(forKey: "LastBankSyncDate") as? Date)
                    ?? (UserDefaults.standard.object(forKey: "LastPhotoSyncDate") as? Date)
                    ?? Calendar.current.startOfDay(for: Date())
                
                let collections = photoService.fetchTargetBankCollections()
                var newAssets: [PHAsset] = []
                for col in collections {
                    newAssets.append(contentsOf: photoService.fetchNewPhotos(in: col, since: lastSyncDate))
                }
                
                if !newAssets.isEmpty {
                    let worker = SlipScanWorker(modelContainer: container)
                    await worker.batchScan(assets: newAssets, imageProvider: PhotoImageProvider()) { _ in }
                    UserDefaults.standard.set(Date(), forKey: "LastBankSyncDate")
                    UserDefaults.standard.set(Date(), forKey: "LastPhotoSyncDate")
                }
            }
            
            // อัปเดตข้อมูลให้ Widget
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let descriptor = FetchDescriptor<SlipRecord>(
                predicate: #Predicate<SlipRecord> { $0.scanDate >= startOfDay && !$0.isSelfTransfer }
            )
            let todaySlips = (try? container.mainContext.fetch(descriptor)) ?? []
            SlipWidgetDataManager.shared.updateTodayExpense(from: todaySlips)
            
            task.setTaskCompleted(success: true)
        }
        
        task.expirationHandler = {
            backgroundTask.cancel()
        }
    }
}
