import SwiftData
import SwiftUI

struct AddExcerptSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool
    
    @State private var excerptText: String = ""
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    let book: Book
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack(alignment: .topLeading) {
            // 保留极光氛围效果，垫在内容下方
            Circle()
                .fill(mintGreen.opacity(isDark ? 0.2 : 0.3))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: -60, y: -60)
                .allowsHitTesting(false)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(mintGreen)
                    
                    Text("新增摘录")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isDark ? .white : .twSlate800)
                }
                .padding(.top, 36).padding(.horizontal, 36)
                
                ZStack(alignment: .topLeading) {
                    if excerptText.isEmpty {
                        Text("输入那些值得被铭记的内容...")
                            .font(.system(size: 15))
                            .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                            .padding(.top, 16).padding(.leading, 16)
                            .zIndex(1)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $excerptText)
                        .font(.system(size: 15))
                        .foregroundColor(isDark ? .white : .twSlate800)
                        .scrollContentBackground(.hidden)
                }
                .frame(height: 220)
                .liquidInput(isDark: isDark, cornerRadius: 16)
                .padding(.horizontal, 36)
                
                Spacer()
                
                Rectangle()
                    .fill(isDark ? Color.white.opacity(0.05) : Color.twSlate100)
                    .frame(height: 1).padding(.horizontal, 36)
                
                HStack {
                    HoverCancelButton(isDark: isDark) { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isPresented = false
                    } }
                    Spacer()
                    ExcerptSubmitButton { saveExcerpt() }
                }
                .padding(.horizontal, 36).padding(.bottom, 32)
            }
        }
        .frame(width: 440, height: 480)
        // ✨ 套上弹窗三连！
        .liquidSheet(isDark: isDark)
        .shadow(color: .black.opacity(isDark ? 0.5 : 0.15), radius: 40, y: 20)
        .presentationBackground(.clear)
    }
    
    private func saveExcerpt() {
        guard !excerptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newExcerpt = Excerpt(content: excerptText)
        if book.excerpts == nil { book.excerpts = [] }
        book.excerpts?.append(newExcerpt)
        try? modelContext.save()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isPresented = false
                }
    }
}
