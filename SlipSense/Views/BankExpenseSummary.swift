//
//  BankExpenseSummary.swift
//  SlipSense
//
//  Created by MarkCnw on 7/21/26.
//


import SwiftUI
import SwiftData
import Charts // 💡 อย่าลืม import ตัวนี้ครับสำคัญมาก

// 1. สร้าง Struct โครงสร้างข้อมูลสำหรับกราฟโดยเฉพาะ
struct BankExpenseSummary: Identifiable {
    let id = UUID()
    let bankName: String
    let totalAmount: Double
}

struct ExpenseChartView: View {
    // 💡 ดึงข้อมูลสลิปทั้งหมดจากระบบหลังบ้าน
    @Query private var slips: [SlipRecord]
    
    // 2. ฟังก์ชันคำนวณและจัดกลุ่มยอดเงิน
    var chartData: [BankExpenseSummary] {
        // จัดกลุ่มสลิปแยกตามชื่อธนาคาร
        let grouped = Dictionary(grouping: slips, by: { $0.bankName })
        
        // หาผลรวมยอดเงินของแต่ละธนาคาร
        let summaries = grouped.map { (bank, bankSlips) in
            // 💡 ทริค: กรองสลิปที่ 'โอนให้ตัวเอง' ออกไปก่อนบวกเลข จะได้ยอดรายจ่ายจริงๆ
            let realExpenses = bankSlips.filter { !$0.isSelfTransfer }
            let total = realExpenses.reduce(0) { $0 + $1.amount }
            
            return BankExpenseSummary(bankName: bank, totalAmount: total)
        }
        
        // กรองธนาคารที่ยอดรวมเป็น 0 ออก และเรียงจากยอดจ่ายมากไปน้อย
        return summaries
            .filter { $0.totalAmount > 0 }
            .sorted { $0.totalAmount > $1.totalAmount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("รายจ่ายตามธนาคาร")
                    .font(.headline)
                Text("รวมยอดจากการสแกนสลิปที่ไม่ใช่การโอนเข้าตัวเอง")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)
            
            if chartData.isEmpty {
                // หน้าตาตอนยังไม่มีข้อมูลสแกน
                Text("ยังไม่มีข้อมูลยอดใช้จ่าย")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
            } else {
                // 3. เริ่มวาดกราฟ
                Chart(chartData) { item in
                    BarMark(
                        x: .value("ยอดเงิน", item.totalAmount),
                        y: .value("ธนาคาร", item.bankName)
                    )
                    // เปลี่ยนสีแท่งกราฟอัตโนมัติตามชื่อธนาคาร
                    .foregroundStyle(by: .value("ธนาคาร", item.bankName))
                    // ลบมุมกราฟให้โค้งมนดูมินิมอล
                    .cornerRadius(6)
                    // ใส่ตัวเลขกำกับไว้ที่ปลายแท่งกราฟ
                    .annotation(position: .trailing, alignment: .leading) {
                        Text(item.totalAmount.formatted(.currency(code: "THB").precision(.fractionLength(0))))
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(minHeight: 250) // กำหนดความสูงขั้นต่ำให้กราฟดูไม่อึดอัด
                // ซ่อนจุดสีบอกชื่อธนาคารด้านล่าง (เพราะมีชื่อธนาคารบอกที่แกน Y อยู่แล้ว)
                .chartLegend(.hidden)
            }
        }
        .padding()
        // ใส่กล่องพื้นหลังพร้อมลบมุม 
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ExpenseChartView()
}