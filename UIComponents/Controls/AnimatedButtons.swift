import SwiftUI
import SwiftData

// MARK: - 全局公用输入组件
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
                Image(systemName: icon).foregroundColor(.twSlate400).font(.system(size: 16, weight: .medium))
            }
        }
        .liquidInput(isDark: isDark, cornerRadius: 24)
    }
}

// MARK: - 主页录入书籍大按钮
struct HomeAddBookButton: View {
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            Label(
                title: { Text("录入新书").font(.system(size: 14, weight: .bold)) },
                icon: { Image(systemName: "plus").font(.system(size: 14, weight: .bold)).rotationEffect(.degrees(isHovered ? 90 : 0)) }
            )
            .foregroundColor(.white).padding(.horizontal, 22).frame(height: 48)
            .liquidButtonGlass(cornerRadius: 24, isDark: true, tintColor: isHovered ? .twIndigo600 : .twIndigo500)
            .shadow(color: .twIndigo600.opacity(isHovered ? 0.4 : 0.2), radius: isHovered ? 15 : 8, y: isHovered ? 8 : 4)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 详情页操作按钮组 (返回/编辑/删除/摘录)
struct HoverBackButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left").font(.system(size: 16, weight: .bold)).offset(x: isHovered ? -4 : 0)
                Text("返回书架").font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(isDark ? .white : .twSlate800).padding(.horizontal, 20).frame(height: 48)
            .liquidButtonGlass(cornerRadius: 24, isDark: isDark, tintColor: isHovered ? (isDark ? .white.opacity(0.1) : .black.opacity(0.05)) : nil)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

struct HoverEditButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "pencil").rotationEffect(.degrees(isHovered ? 15 : 0))
                Text("编辑")
            }
            .font(.system(size: 13, weight: .bold)).foregroundColor(isHovered ? .white : .blue).frame(width: 80, height: 38)
            .liquidButtonGlass(cornerRadius: 19, isDark: isDark, tintColor: isHovered ? Color.blue.opacity(0.8) : Color.blue.opacity(0.1))
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

struct HoverDeleteButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "trash").rotationEffect(.degrees(isHovered ? -15 : 0))
                Text("删除")
            }
            .font(.system(size: 14, weight: .bold)).foregroundColor(isHovered ? .white : .red).padding(.horizontal, 20).frame(height: 40)
            .liquidButtonGlass(cornerRadius: 20, isDark: isDark, tintColor: isHovered ? Color.red.opacity(0.8) : Color.red.opacity(0.05)).offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

struct DetailAddExcerptButton: View {
    let action: () -> Void
    @State private var isHovered = false
    let mintGreen = Color(hex: "71d4b2")
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill").offset(y: isHovered ? -3 : 0)
                Text("添加摘录")
            }
            .font(.system(size: 14, weight: .bold)).foregroundColor(.white).padding(.horizontal, 20).frame(height: 44)
            .liquidButtonGlass(cornerRadius: 22, isDark: true, tintColor: isHovered ? mintGreen : mintGreen.opacity(0.8))
            .shadow(color: mintGreen.opacity(isHovered ? 0.4 : 0.2), radius: 10, y: 5)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

// MARK: - 弹窗内部操作按钮 (保存/提交/取消)
struct ExcerptSubmitButton: View {
    let action: () -> Void
    @State private var isHovered = false
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "paperplane.fill").font(.system(size: 12, weight: .bold)).rotationEffect(.degrees(isHovered ? -15 : 0)).offset(x: isHovered ? 2 : 0, y: isHovered ? -2 : 0)
                Text("确认保存")
            }
            .font(.system(size: 14, weight: .bold)).foregroundColor(.white).frame(width: 120, height: 44)
            .liquidButtonGlass(cornerRadius: 12, isDark: true, tintColor: isHovered ? mintGreen : mintGreen.opacity(0.8))
            .shadow(color: mintGreen.opacity(isHovered ? 0.4 : 0.2), radius: isHovered ? 12 : 6, y: isHovered ? 4 : 2)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

struct EditorSubmitButton: View {
    let isEdit: Bool
    let isDisabled: Bool
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isEdit ? "checkmark.circle" : "plus")
                    .rotationEffect(.degrees(!isEdit && isHovered && !isDisabled ? 90 : 0))
                    .scaleEffect(isEdit && isHovered && !isDisabled ? 1.1 : 1.0)
                Text(isEdit ? "保存修改" : "确认录入")
            }
            .font(.system(size: 14, weight: .bold)).foregroundColor(isDisabled ? (isDark ? .twSlate500 : .twSlate400) : .white).frame(width: 130, height: 46)
            .liquidButtonGlass(cornerRadius: 14, isDark: isDark, tintColor: isDisabled ? (isDark ? Color.twSlate800 : Color.twSlate100) : (isHovered ? .twIndigo600 : .twIndigo500))
            .shadow(color: isDisabled ? .clear : Color.twIndigo600.opacity(isHovered ? 0.4 : 0.2), radius: isHovered ? 12 : 6, y: isHovered ? 4 : 2)
            .offset(y: isHovered && !isDisabled ? -2 : 0)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

struct HoverCancelButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            Text("取消").font(.system(size: 14, weight: .bold)).foregroundColor(isHovered ? .white : .red.opacity(0.8)).frame(width: 80, height: 44)
                .liquidButtonGlass(cornerRadius: 12, isDark: isDark, tintColor: isHovered ? Color.red.opacity(0.7) : Color.red.opacity(0.05)).scaleEffect(isHovered ? 0.96 : 1.0)
        }
        .buttonStyle(.plain).pointingHand()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

// MARK: - Dashboard 看板打卡引擎
struct CheckInButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    
    @Binding var hasCheckedIn: Bool
    @State private var isLoading = false
    @State private var shimmerOffset: CGFloat = -1.0
    
    var body: some View {
        if !hasCheckedIn {
            Button(action: startCheckIn) {
                HStack(spacing: 8) {
                    if isLoading { ProgressView().controlSize(.small).brightness(2) }
                    else { Image(systemName: "flame.fill").symbolEffect(.bounce, options: .repeating) }
                    Text(isLoading ? "神经同步中..." : "启动今日共鸣")
                }
                .font(.system(size: 13, weight: .bold)).foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 10)
                .background(
                    ZStack {
                        Capsule().fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        Capsule().fill(LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing)).offset(x: shimmerOffset * 100)
                    }
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
            }
            .buttonStyle(.plain).pointingHand()
            .onAppear { withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { shimmerOffset = 2.0 } }
        } else {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("今日频段已同步")
            }
            .font(.system(size: 13, weight: .bold)).foregroundColor(.green).padding(.horizontal, 20).padding(.vertical, 10)
            .background(Color.green.opacity(0.1)).clipShape(Capsule()).overlay(Capsule().stroke(Color.green.opacity(0.2), lineWidth: 1))
        }
    }
    
    func startCheckIn() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                isLoading = false; hasCheckedIn = true
                let newRecord = ReadingRecord(date: Date(), book: readingBooks.first)
                modelContext.insert(newRecord)
                try? modelContext.save()
            }
        }
    }
}
