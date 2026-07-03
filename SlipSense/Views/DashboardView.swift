import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    // 📍 1. ดึง ModelContext สำหรับเซฟข้อมูลลงฐานข้อมูล
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    @State private var viewModel = DashboardViewModel()
    
    // 📍 2. ประกาศตัวแปร Services สำหรับทำ Auto-Sync เบื้องหลัง
    @State private var photoProvider = PhotoImageProvider()
    @State private var photoService = PhotoService()

    
    var body: some View {
        NavigationStack {
            ScrollView {
                let periodSlips = viewModel.filteredSlips(from: slips)
                
                VStack(spacing: 25) {
                    TimeFramePickerSection(viewModel: viewModel)
                    DonutChartSection(
                        viewModel: viewModel,
                        currentPeriodTotal: viewModel.totalAmount(from: periodSlips),
                        bankSpendData: viewModel.bankSpendData(from: periodSlips)
                    )
                    DailyTrendChartSection(
                        viewModel: viewModel,
                        chartData: viewModel.chartData(from: periodSlips)
                    )
                    TimeSpendChartSection(
                        timeSpendData: viewModel.timeSpendData(from: periodSlips)
                    )
                    
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("แดชบอร์ด")
            .background(Color(.systemGroupedBackground))
            
            // 📍 3. สั่งให้ AI วิ่งไปหาสลิปใหม่ทันทีที่หน้าแดชบอร์ดเปิดขึ้นมา
            .task {
                await viewModel.autoSyncBankSlips(
                    context: modelContext,
                    photoProvider: photoProvider,
                    photoService: photoService,
                  
                )
            }
            
            .onChange(of: viewModel.selectedTimeframe) { _, newValue in
                if newValue == .custom {
                    viewModel.showDatePickerSheet = true
                }
            }
            .sheet(isPresented: $viewModel.showDatePickerSheet) {
                DatePickerSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Subviews

struct TimeFramePickerSection: View {
    @Bindable var viewModel: DashboardViewModel
    
    var body: some View {
        Picker("ช่วงเวลา", selection: $viewModel.selectedTimeframe) {
            ForEach(DashboardTimeframe.allCases, id: \.self) { timeframe in
                Text(LocalizedStringKey(timeframe.rawValue)).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct DonutChartSection: View {
    let viewModel: DashboardViewModel
    let currentPeriodTotal: Double
    let bankSpendData: [BankSpendData]
    
    private let bankColors: KeyValuePairs<String, Color> = [
        "กสิกร": .green,
        "ไทยพาณิชย์": .purple,
        "กรุงเทพ": .blue,
        "กรุงไทย": .cyan,
        "กรุงศรี": .yellow,
        "TTB": .orange,
        "ออมสิน": .pink,
        "ไม่ระบุ": .gray
    ]
    
    private func colorForBank(_ name: String) -> Color {
        bankColors.first(where: { $0.key == name })?.value ?? .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("สัดส่วนการโอน")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("แยกตามธนาคาร")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                if let top = bankSpendData.first {
                    Text("สูงสุด: \(viewModel.displayBankName(fromCode: top.bank.rawValue))")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Capsule())
                }
            }

            if currentPeriodTotal > 0 {
                HStack(spacing: 16) {
                    Chart(bankSpendData) { item in
                        SectorMark(
                            angle: .value("ยอดเงิน", item.amount),
                            innerRadius: .ratio(0.70),
                            angularInset: 2
                        )
                        .cornerRadius(6)
                        .foregroundStyle(by: .value("ธนาคาร", viewModel.displayBankName(fromCode: item.bank.rawValue)))
                        .opacity(0.95)
                    }
                    .frame(width: 210, height: 210)
                    .chartForegroundStyleScale(bankColors)
                    .chartLegend(.hidden)
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            if let frame = chartProxy.plotFrame {
                                let rect = geometry[frame]
                                VStack(spacing: 4) {
                                    Text("รวมทั้งหมด")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(currentPeriodTotal, format: .number.precision(.fractionLength(0)))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .contentTransition(.numericText())
                                    Text("บาท")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .position(x: rect.midX, y: rect.midY)
                            }
                        }
                    }
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .padding(24)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(bankSpendData.prefix(5)) { item in
                            let name = viewModel.displayBankName(fromCode: item.bank.rawValue)
                            let percent = (item.amount / currentPeriodTotal) * 100
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(colorForBank(name))
                                    .frame(width: 10, height: 10)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(name)
                                        .font(.caption.weight(.semibold))
                                        .lineLimit(1)
                                    Text("\(percent, specifier: "%.1f")% • \(item.amount, format: .number.precision(.fractionLength(0)))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }

                        if bankSpendData.count > 5 {
                            Text("และอีก \(bankSpendData.count - 5) ธนาคาร")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top, 6)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(.systemGray4))
                    Text("ไม่มีข้อมูลการใช้จ่ายในช่วงเวลานี้")
                        .foregroundStyle(.secondary)
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 8)
        )
        .padding(.horizontal)
    }
}

struct DailyTrendChartSection: View {
    let viewModel: DashboardViewModel
    let chartData: [DailyExpense]
    
    private let dailyChartGradient = LinearGradient(
        colors: [Color.indigo.opacity(0.8), Color.blue.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("แนวโน้มการใช้จ่าย \(viewModel.daysInPeriod) วัน")
                .font(.headline)
            
            Chart(chartData) { item in
                BarMark(
                    x: .value("วันที่", item.date, unit: .day),
                    y: .value("ยอดเงิน", item.amount)
                )
                .foregroundStyle(dailyChartGradient)
                .cornerRadius(4)
                .annotation(position: .top) {
                    if item.amount > 0 && viewModel.selectedTimeframe == .week {
                        Text(item.amount, format: .number.precision(.fractionLength(0)))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: viewModel.selectedTimeframe == .week ? 1 : 5)) { _ in
                    AxisValueLabel(format: .dateTime.day().month(.defaultDigits))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct TimeSpendChartSection: View {
    let timeSpendData: [TimeSpendData]
    
    private let timeSpendGradient = LinearGradient(
        colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.5)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ช่วงเวลาที่เสียเงินเยอะที่สุด")
                .font(.headline)
            
            Chart(timeSpendData) { item in
                BarMark(
                    x: .value("ยอดเงิน", item.amount),
                    y: .value("ช่วงเวลา", item.period)
                )
                .foregroundStyle(timeSpendGradient)
                .cornerRadius(4)
                .annotation(position: .trailing) {
                    if item.amount > 0 {
                        Text(item.amount, format: .number.precision(.fractionLength(0)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 180)
            .chartXAxis(.hidden)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}



struct DatePickerSheet: View {
    @Bindable var viewModel: DashboardViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("วันเริ่มต้น", selection: $viewModel.customStartDate, displayedComponents: .date)
                DatePicker("วันสิ้นสุด", selection: $viewModel.customEndDate, displayedComponents: .date)
            }
            .navigationTitle("เลือกช่วงเวลา")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("ตกลง") {
                        viewModel.showDatePickerSheet = false
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
    }
}
