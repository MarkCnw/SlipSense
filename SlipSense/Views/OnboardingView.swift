import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        // ✅ 1. เพิ่ม ZStack เพื่อปูสี Background ไว้ชั้นล่างสุด
        ZStack {
            // ✅ 2. ใส่สี Background ที่ต้องการ (เช่น .white, .gray.opacity(0.1), หรือ Color("ชื่อสีในAssets"))
            Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            VStack {
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(page.image)
                                .resizable()
                                .scaledToFit()
                                // ✅ 3. ปรับขนาดรูปภาพให้ใหญ่ขึ้นตรงนี้ (ลองแก้ตัวเลขดูได้ครับ)
                                .frame(width: 200, height: 200)
                                .foregroundStyle(page.color)
                                .padding(.bottom, 30)
                            
                            Text(page.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(page.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack {
                    if viewModel.isLastPage {
                        Button {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        } label: {
                            Text("เริ่มต้นใช้งาน")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                    } else {
                        Button {
                            withAnimation {
                                viewModel.nextPage()
                            }
                        } label: {
                            Text("ถัดไป")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 50)
                .animation(.easeInOut, value: viewModel.currentPage)
            }
        }
    }
}
