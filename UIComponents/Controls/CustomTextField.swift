import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String?
    var isDark: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .foregroundColor(isDark ? .white : .twSlate800)
            
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.twSlate400)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        // ✨ 一键调用液态内凹效果，彻底替代死板背景
        .liquidInput(isDark: isDark, cornerRadius: 24)
    }
}
