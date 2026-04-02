import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct BookEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    /// 判断是新增还是编辑
    var bookToEdit: Book? = nil
    
    @State private var titleInput: String = ""
    @State private var authorInput: String = ""
    
    @State private var selectedCoverData: Data? = nil
    @State private var isShowingImagePicker = false
    
    /// 模拟是否有封面图片
    @State private var hasCover: Bool = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        let isEdit = bookToEdit != nil
        
        VStack(spacing: 0) {
            // ================= 1. 顶部 Header =================
            HStack(alignment: .center) {
                HStack(spacing: 12) {
                    Image(systemName: isEdit ? "book.closed.fill" : "plus.square.dashed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.twIndigo600)
                    
                    Text(isEdit ? "编辑档案" : "添置新书")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isDark ? .white : .twSlate800)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.twSlate400)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // ================= 2. 中间表单与封面区 =================
            HStack(alignment: .top, spacing: 40) {
                // 👉 左侧：输入表单区
                VStack(alignment: .leading, spacing: 24) {
                    // 书名输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("书名")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.twSlate400)
                        
                        CustomTextField(
                            placeholder: "例如：活着",
                            text: $titleInput,
                            icon: "magnifyingglass",
                            isDark: isDark
                        )
                    }
                    Spacer()
                    
                    // Metadata 分割线
                    MetadataDivider(isDark: isDark)
                    
                    // 作者输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作者")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.twSlate400)
                        
                        CustomTextField(
                            placeholder: "例如：余华",
                            text: $authorInput,
                            icon: nil,
                            isDark: isDark
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                
                // 👉 右侧：封面上传区
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Label("实体封面图", systemImage: "photo")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.twIndigo500)
                    }
                                    
                    // ✨ 将整个封面区变成一个大按钮
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        if let data = selectedCoverData {
                            // ✨ 状态 A：有图了！直接调用你的 LocalCoverView 渲染
                            LocalCoverView(coverData: data, fallbackTitle: titleInput.isEmpty ? "暂无书名" : titleInput)
                                .frame(width: 160, height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        } else {
                            // ✨ 状态 B：没图，显示虚线框
                            DashedDropzoneView(isDark: isDark)
                        }
                    }
                    .buttonStyle(.plain)
                    // ✨ 核心 1：点击弹出文件选择器 (跨平台支持)
                    .fileImporter(
                        isPresented: $isShowingImagePicker,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            // 请求安全访问权限 (macOS 沙盒机制必需)
                            if selectedFile.startAccessingSecurityScopedResource() {
                                defer { selectedFile.stopAccessingSecurityScopedResource() }
                                let data = try Data(contentsOf: selectedFile)
                                selectedCoverData = data // 赋值给界面！
                            }
                        } catch {
                            print("读取图片失败: \(error)")
                        }
                    }
                    // ✨ 核心 2：支持直接从桌面拖拽图片进来！
                    .onDrop(of: [UTType.image], isTargeted: nil) { providers in
                        if let provider = providers.first {
                            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.selectedCoverData = data // 赋值给界面！
                                    }
                                }
                            }
                            return true
                        }
                        return false
                    }
                }
                .frame(width: 160)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // ================= 3. 底部 Footer =================
            HStack {
                // 👉 1. 替换为动效取消按钮
                HoverCancelButton(isDark: isDark) {
                    dismiss()
                }
                            
                Spacer()
                
                // ✨ 1. 基本校验：不能为空
                let isFormEmpty = titleInput.trimmingCharacters(in: .whitespaces).isEmpty || authorInput.trimmingCharacters(in: .whitespaces).isEmpty
                                
                // ✨ 2. 脏数据校验：是否和数据库里的原数据有差异？
                let hasChanges = bookToEdit == nil ? true : (
                    titleInput != bookToEdit?.title ||
                        authorInput != bookToEdit?.author ||
                        selectedCoverData != bookToEdit?.coverData
                )
                            
                // ✨ 3. 终极判断：要么是空的，要么没修改，都会被封印！
                let shouldDisable = isFormEmpty || !hasChanges
                            
                EditorSubmitButton(
                    isEdit: isEdit,
                    isDisabled: shouldDisable, // ✨ 完美修复：由输入框内容决定是否可点击！
                    isDark: isDark
                ) {
                    saveBook()
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .frame(width: 600, height: 420)
        .background(isDark ? Color.twSlate900 : .white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(isDark ? 0.3 : 0.08), radius: 30, y: 15)
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1))
        .onAppear {
            if let book = bookToEdit {
                titleInput = book.title
                authorInput = book.author
                selectedCoverData = book.coverData // ✨ 载入已有封面！
            }
        }
    }
    
    private func saveBook() {
        guard !titleInput.isEmpty, !authorInput.isEmpty else { return }
            
        if let book = bookToEdit {
            book.title = titleInput
            book.author = authorInput
            book.coverData = selectedCoverData // ✨ 保存新封面！
        } else {
            let newBook = Book(title: titleInput, author: authorInput, status: "UNREAD", tags: [])
            newBook.coverData = selectedCoverData // ✨ 保存新封面！
            modelContext.insert(newBook)
        }
            
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - 自定义子组件

/// 自定义圆角输入框
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
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(isDark ? Color.twSlate950 : Color.twSlate50) // 极浅的底色
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isDark ? Color.twSlate800 : Color.twSlate200, lineWidth: 1)
        )
    }
}

/// 中间的 Metadata 分割线
struct MetadataDivider: View {
    var isDark: Bool
    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(isDark ? Color.twSlate800 : Color.twSlate200)
                .frame(height: 1)
            
            HStack(spacing: 6) {
                Circle().fill(Color.twIndigo400).frame(width: 6, height: 6)
                Text("METADATA")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.twSlate500)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(isDark ? Color.twSlate800 : .white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isDark ? Color.twSlate700 : Color.twSlate200, lineWidth: 1))
            .shadow(color: .black.opacity(isDark ? 0.2 : 0.02), radius: 4, y: 2)
            
            Rectangle()
                .fill(isDark ? Color.twSlate800 : Color.twSlate200)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

/// 虚线拖拽上传区
struct DashedDropzoneView: View {
    var isDark: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isDark ? Color.twIndigo500.opacity(0.4) : Color.twIndigo400.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 6])
                )
                .background(isDark ? Color.twIndigo900.opacity(0.1) : Color.twIndigo50.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 12) {
                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.twIndigo400)
                
                VStack(spacing: 4) {
                    Text("点击或拖拽")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.twIndigo500)
                    Text("比例 2:3")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.twIndigo400.opacity(0.8))
                }
            }
        }
        .frame(width: 160, height: 240)
    }
}

/// 辅助色扩展，用于模拟截图里的纯色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ===============================================
// ✨ 独立预览环境
// ===============================================
#Preview("Add Book Modal (Light)") {
    ZStack {
        Color.twSlate100.ignoresSafeArea()
        BookEditorSheet(bookToEdit: nil)
    }
}

#Preview("Edit Book Modal (Light)") {
    ZStack {
        Color.twSlate100.ignoresSafeArea()
        BookEditorSheet(bookToEdit: Book(title: "毛泽东选集", author: "毛泽东", status: "UNREAD", tags: []))
    }
}
