import SwiftData
import SwiftUI

struct AddExcerptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @State private var excerptText: String = ""
    
    /// 提取设计稿里的主题薄荷绿
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    
    let book: Book
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack(alignment: .topLeading) {
            // ================= 1. 纯净背景层 =================
            (isDark ? Color.twSlate900 : .white)
                .ignoresSafeArea()
            
            // ================= 2. 左上角氛围光晕 =================
            Circle()
                .fill(mintGreen.opacity(isDark ? 0.15 : 0.12))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .offset(x: -60, y: -60)
                .allowsHitTesting(false)
            
            VStack(alignment: .leading, spacing: 20) {
                // ================= 3. 顶部 Header =================
                HStack(spacing: 12) {
                    Image(systemName: "text.quote") // 原生双引号图标
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(mintGreen)
                    
                    Text("新增摘录")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isDark ? .white : .twSlate800)
                }
                .padding(.top, 36)
                .padding(.horizontal, 36)
                
                // ================= 4. 文本编辑区 =================
                ZStack(alignment: .topLeading) {
                    // 障眼法：自定义的占位符 Placeholder
                    if excerptText.isEmpty {
                        Text("输入那些值得被铭记的内容...")
                            .font(.system(size: 15))
                            .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                            .padding(.top, 16)
                            .padding(.leading, 16)
                            .zIndex(1)
                            .allowsHitTesting(false) // 允许点击穿透，不阻碍输入
                    }
                    
                    // 真正的多行输入框
                    TextEditor(text: $excerptText)
                        .font(.system(size: 15))
                        .foregroundColor(isDark ? .white : .twSlate800)
                        // 隐藏原生背景，暴露底层的细致设计
                        .scrollContentBackground(.hidden)
                        .padding(10)
                }
                .frame(height: 220)
                .background(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate50)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 36)
                
                Spacer()
                
                // ================= 5. 分割线 =================
                Rectangle()
                    .fill(isDark ? Color.white.opacity(0.05) : Color.twSlate100)
                    .frame(height: 1)
                    .padding(.horizontal, 36)
                
                // ================= 6. 底部 Footer 按钮 =================
                HStack {
                    HoverCancelButton(isDark: isDark) {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    // 确认保存按钮 (替换为纸飞机起飞组件)
                    ExcerptSubmitButton {
                        saveExcerpt()
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 32)
            }
        }
        .frame(width: 440, height: 480) // 锁定高级比例
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private func saveExcerpt() {
        guard !excerptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            
        let newExcerpt = Excerpt(content: excerptText)
            
        // 如果数组还没初始化，先给个空数组
        if book.excerpts == nil {
            book.excerpts = []
        }
        // 追加进去
        book.excerpts?.append(newExcerpt)
            
        try? modelContext.save()
        dismiss() // 保存完自动关窗
    }
}
