import SwiftUI
import SwiftData

struct AddExcerptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var excerptText: String = ""
    
    // 提取设计稿里的主题薄荷绿
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    
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
                    // 取消按钮
                    Button(action: { dismiss() }) {
                        Text("取消")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isDark ? .twSlate300 : .twSlate600)
                            .frame(width: 80, height: 40)
                            .background(isDark ? Color.twSlate800 : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isDark ? Color.twSlate700 : Color.twSlate200, lineWidth: 1))
                            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // 确认保存按钮
                    Button(action: { dismiss() /* 之后写保存逻辑 */ }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 12, weight: .bold))
                            Text("确认保存")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 40)
                        .background(mintGreen) // 使用主题薄荷绿
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: mintGreen.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 32)
            }
        }
        .frame(width: 440, height: 480) // 锁定高级比例
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// ===============================================
// ✨ 独立预览环境
// ===============================================
#Preview("Add Excerpt Modal (Light)") {
    ZStack {
        Color.twSlate200.ignoresSafeArea()
        AddExcerptSheet()
    }
}

#Preview("Add Excerpt Modal (Dark)") {
    ZStack {
        Color.twSlate900.ignoresSafeArea()
        AddExcerptSheet()
            .preferredColorScheme(.dark)
    }
}
