import SwiftData
import SwiftUI

struct CheckInButton: View {
    // ✨ 1. 引入数据库上下文
    @Environment(\.modelContext) private var modelContext
    // ✨ 2. 查询当前正在阅读的书籍
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    
    @Binding var hasCheckedIn: Bool
    @State private var isLoading = false
    @State private var shimmerOffset: CGFloat = -1.0
    
    var body: some View {
        if !hasCheckedIn {
            Button(action: startCheckIn) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().controlSize(.small).brightness(2)
                    } else {
                        Image(systemName: "flame.fill")
                            .symbolEffect(.bounce, options: .repeating)
                    }
                    Text(isLoading ? "神经同步中..." : "启动今日共鸣")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        Capsule().fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        
                        // 扫光特效
                        Capsule()
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                            .offset(x: shimmerOffset * 100)
                    }
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(.plain)
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    shimmerOffset = 2.0
                }
            }
        } else {
            // 已同步状态
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("今日频段已同步")
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.green)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.green.opacity(0.2), lineWidth: 1))
        }
    }
    
    func startCheckIn() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                isLoading = false
                hasCheckedIn = true
                
                // ✨ 3. 终极闭环：在动画结束的瞬间，把记录写进数据库！
                let currentBook = readingBooks.first
                let newRecord = ReadingRecord(date: Date(), book: currentBook)
                modelContext.insert(newRecord)
                try? modelContext.save()
            }
        }
    }
}
