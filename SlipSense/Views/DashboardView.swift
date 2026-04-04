import SwiftUI
import SwiftData
import Charts

// ตัวเลือกช่วงเวลาของ Dashboard
enum DashboardTimeframe: String, CaseIterable {
    case week = "7 วันล่าสุด"
    case month = "30 วันล่าสุด"
}

// โครงสร้างข้อมูลสำหรับกราฟแนวโน้มรายวัน
struct DailyExpense: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

struct TimeSpendData: Identifiable {
    let id = UUID()
    let period: String
    let amount: Double
    let sortOrder: Int
}

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SlipRecord.scanDate, order: .reverse) private var slips: [SlipRecord]
    
    @State private var selectedTimeframe: DashboardTimeframe = .week
    
    var daysInPeriod: Int {
        selectedTimeframe == .week ? 7 : 30
    }
    
    var currentPeriodTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -daysInPeriod, to: now)!
        return slips.filter { $0.scanDate >= startDate && $0.scanDate <= now }
                    .reduce(0) { $0 + $1.amount }
    }
    
    var previousPeriodTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        let startDateOfCurrent = calendar.date(byAdding: .day, value: -daysInPeriod, to: now)!
        let startDateOfPrevious = calendar.date(byAdding: .day, value: -(daysInPeriod * 2), to: now)!
        return slips.filter { $0.scanDate >= startDateOfPrevious && $0.scanDate < startDateOfCurrent }
                    .reduce(0) { $0 + $1.amount }
    }
    
    var percentageChange: Double {
        if previousPeriodTotal == 0 { return 0 }
        return ((currentPeriodTotal - previousPeriodTotal) / previousPeriodTotal) * 100
    }
    
    var ringProgress: Double {
        if previousPeriodTotal == 0 { return 0 }
        return min(currentPeriodTotal / previousPeriodTotal, 1.0)
    }
    
    var chartData: [DailyExpense] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var data: [DailyExpense] = []
        for i in (0..<daysInPeriod).reversed() {
            if let targetDate = calendar.date(byAdding: .day, value: -i, to: today) {
                let daySlips = slips.filter { calendar.isDate($0.scanDate, inSameDayAs: targetDate) }
                let dailyTotal = daySlips.reduce(0) { $0 + $1.amount }
                data.append(DailyExpense(date: targetDate, amount: dailyTotal))
            }
        }
        return data
    }
    
    var timeSpendData: [TimeSpendData] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -daysInPeriod, to: now)!
        let periodSlips = slips.filter { $0.scanDate >= startDate && $0.scanDate <= now }
        
        var morning = 0.0
        var afternoon = 0.0
        var evening = 0.0
        var night = 0.0
        
        for slip in periodSlips {
            let hour = calendar.component(.hour, from: slip.scanDate)
            if hour >= 6 && hour < 12 { morning += slip.amount }
            else if hour >= 12 && hour < 18 { afternoon += slip.amount }
            else if hour >= 18 && hour < 22 { evening += slip.amount }
            else { night += slip.amount }
        }
        
        return [
            TimeSpendData(period: "เช้า (06-12)", amount: morning, sortOrder: 0),
            TimeSpendData(period: "บ่าย (12-18)", amount: afternoon, sortOrder: 1),
            TimeSpendData(period: "ค่ำ (18-22)", amount: evening, sortOrder: 2),
            TimeSpendData(period: "ดึก (22-06)", amount: night, sortOrder: 3)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    Picker("ช่วงเวลา", selection: $selectedTimeframe) {
                        ForEach(DashboardTimeframe.allCases, id: \.self) { timeframe in
                            Text(LocalizedStringKey(timeframe.rawValue)).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 20)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(previousPeriodTotal == 0 ? 1.0 : ringProgress))
                                .stroke(
                                    AngularGradient(
                                        colors: currentPeriodTotal > previousPeriodTotal ? [.red, .pink] : [.orange, .yellow],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: ringProgress)
                            
                            // 💡 แก้ไขส่วนตัวเลขในวงแหวน (เปลี่ยน THB เป็น บาท และย้ายลงข้างล่าง)
                            VStack(spacing: 2) {
                                Text("ใช้จ่ายไปแล้ว")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(currentPeriodTotal, format: .number.precision(.fractionLength(2)))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(currentPeriodTotal > previousPeriodTotal && previousPeriodTotal > 0 ? .red : .primary)
                                    .minimumScaleFactor(0.5) // ย่อขนาดฟอนต์อัตโนมัติถ้าเลขยาวเกินไป
                                    .lineLimit(1)
                                    .padding(.horizontal, 30)
                                
                                Text("บาท")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 220, height: 220)
                        
                        Group {
                            if previousPeriodTotal == 0 {
                                Text("💡 กำลังเรียนรู้พฤติกรรมการใช้เงินของคุณ...")
                                    .foregroundStyle(.blue)
                            } else if currentPeriodTotal > previousPeriodTotal {
                                Text("⚠️ ระวัง! จ่ายเยอะกว่ารอบที่แล้ว \(abs(percentageChange), specifier: "%.1f")%")
                                    .foregroundStyle(.red)
                            } else {
                                Text("🎉 ยอดเยี่ยม! จ่ายน้อยกว่ารอบที่แล้ว \(abs(percentageChange), specifier: "%.1f")%")
                                    .foregroundStyle(.green)
                            }
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    
                    // --- กราฟแท่ง (Bar Chart) รายวัน ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("พฤติกรรมย้อนหลัง \(daysInPeriod) วัน")
                            .font(.headline)
                        
                        Chart(chartData) { item in
                            BarMark(
                                x: .value("วันที่", item.date, unit: .day),
                                y: .value("ยอดเงิน", item.amount)
                            )
                            .foregroundStyle(currentPeriodTotal > previousPeriodTotal ?
                                LinearGradient(colors: [.red.opacity(0.8), .pink.opacity(0.5)], startPoint: .top, endPoint: .bottom) :
                                LinearGradient(colors: [.orange.opacity(0.8), .yellow.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(4)
                            // 💡 เพิ่มตัวเลขยอดเงินเป๊ะๆ ไว้บนหัวกราฟแต่ละแท่ง
                            .annotation(position: .top) {
                                                            if item.amount > 0 && selectedTimeframe == .week {
                                                                Text(item.amount, format: .number.precision(.fractionLength(0)))
                                                                    .font(.system(size: 10, weight: .medium))
                                                                    .foregroundStyle(.secondary)
                                                            }
                                                        }
                        }
                        // ขยับความสูงกราฟนิดหน่อยเพื่อเผื่อพื้นที่ให้ตัวเลขด้านบน
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: selectedTimeframe == .week ? 1 : 5)) { _ in
                                AxisValueLabel(format: .dateTime.day().month(.defaultDigits))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("ช่วงเวลาที่เสียเงินเยอะที่สุด")
                            .font(.headline)
                        
                        Chart(timeSpendData.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                            BarMark(
                                x: .value("ยอดเงิน", item.amount),
                                y: .value("ช่วงเวลา", NSLocalizedString(item.period, comment: ""))
                            )
                            .foregroundStyle(LinearGradient(colors: [.indigo.opacity(0.8), .purple.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(4)
                            .annotation(position: .trailing) {
                                if item.amount > 0 {
                                    // 💡 แก้เป็นบาทให้คุมโทน
                                    Text("\(item.amount, format: .number.precision(.fractionLength(0)))")
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
                    .cornerRadius(15)
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("ประวัติการใช้จ่ายล่าสุด")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if slips.isEmpty {
                            Text("ยังไม่มีข้อมูลสแกนรายจ่าย")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            VStack(spacing: 0) {
                                ForEach(slips.prefix(10)) { slip in
                                    HStack(spacing: 16) {
                                        Image(systemName: "cart.fill")
                                            .foregroundStyle(.orange)
                                            .font(.title2)
                                            .frame(width: 44, height: 44)
                                            .background(Color.orange.opacity(0.15))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading) {
                                            Text("รายการใช้จ่าย")
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(slip.scanDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        // 💡 แก้ THB เป็นคำว่า บาท ตรงประวัติล่าสุดด้วยครับ
                                        Text("- \(slip.amount, format: .number.precision(.fractionLength(2))) บาท")
                                            .font(.body)
                                            .bold()
                                    }
                                    .padding()
                                    
                                    if slip.id != slips.prefix(10).last?.id {
                                        Divider().padding(.leading, 70)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("แดชบอร์ด")
            .background(Color(.systemGroupedBackground))
        }
    }
}
