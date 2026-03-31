// Components/BookCardView.swift
import SwiftUI

struct BookCardView: View {
    var title: String
    var author: String
    // ✨ 替换为 Data 类型
    var coverData: Data?
    var tags: [String]
    var rating: Int
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // ✨ 直接使用我们自己写的本地封面组件
            LocalCoverView(coverData: coverData, fallbackTitle: title)
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline).fontWeight(.bold).lineLimit(1)
                Text(author).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                Spacer()
                
                HStack {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        Text(tag).font(.caption2).fontWeight(.bold)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                if rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<rating, id: \.self) { _ in
                            Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption2)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            Spacer()
        }
        .padding(16)
        .frame(height: 150)
        .glassEffect(cornerRadius: 20)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in isHovered = hovering }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
        BookCardView(title: "示例书籍", author: "作者名字", coverData: nil, tags: ["科幻", "经典"], rating: 4).padding()
    }
}
