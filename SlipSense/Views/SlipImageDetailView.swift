import SwiftUI

struct SlipImageDetailView: View {
    let slip: SlipRecord
    @State private var viewModel = SlipImageDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                    } else if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("กำลังโหลดรูปภาพ...")
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 400)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundStyle(.tertiary)
                            Text("ไม่พบรูปภาพสลิปในเครื่อง")
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 400)
                    }
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    DetailRow(title: "ธนาคาร", value: slip.bankName)
                    Divider()
                    DetailRow(title: "วันที่และเวลา", value: slip.scanDate.formatted(date: .abbreviated, time: .shortened))
                    Divider()
                    DetailRow(title: "ยอดเงิน", value: slip.amount.formatted(.currency(code: "THB")), isHighlight: true)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("รายละเอียดสลิป")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.loadImage(assetIdentifier: slip.assetIdentifier)
        }
    }
}


