import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// 录入与编辑弹窗
struct BookEditorSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool
    
    var bookToEdit: Book? = nil
    
    @State private var titleInput: String = ""
    @State private var authorInput: String = ""
    @State private var selectedCoverData: Data? = nil
    @State private var isShowingImagePicker = false
    @State private var hasCover: Bool = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        let isEdit = bookToEdit != nil
        
        VStack(spacing: 0) {
            // ================= 1. 顶部 Header (保持原有位置不动) =================
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
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.twSlate400)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            .padding(.bottom, 24)
            
            // ================= 2. 中间表单与封面区 (✨ 绝对对齐引擎) =================
            HStack(alignment: .top, spacing: 40) {
                
                // 👉 左侧：双塔左区 (强制高度 266px)
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部：书名输入框 (将死死顶住上边缘)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("书名").font(.system(size: 12, weight: .bold)).foregroundColor(.twSlate400)
                        CustomTextField(placeholder: "例如：活着", text: $titleInput, icon: "magnifyingglass", isDark: isDark)
                    }
                    
                    Spacer(minLength: 0) // ✨ 弹簧：自适应撑开
                    
                    // ✨ 全新设计的星耀分隔符
                    MetadataDivider(isDark: isDark)
                    
                    Spacer(minLength: 0) // ✨ 弹簧：自适应撑开
                    
                    // 底部：作者输入框 (将死死踩住下边缘)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("作者").font(.system(size: 12, weight: .bold)).foregroundColor(.twSlate400)
                        CustomTextField(placeholder: "例如：余华", text: $authorInput, icon: nil, isDark: isDark)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 266) // ✨ 核心秘诀：与右侧严格等高
                
                // 👉 右侧：双塔右区 (强制高度 266px)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Label("实体封面图", systemImage: "photo")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.twIndigo500)
                            .frame(height: 18) // ✨ 锁定标签高度
                    }
                    
                    Button(action: { isShowingImagePicker = true }) {
                        if let data = selectedCoverData {
                            LocalCoverView(coverData: data, fallbackTitle: titleInput.isEmpty ? "暂无书名" : titleInput)
                                .frame(width: 160, height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2), lineWidth: 0.5))
                                .shadow(color: .black.opacity(0.2), radius: 15, y: 10)
                        } else {
                            DashedDropzoneView(isDark: isDark)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 160, height: 240) // ✨ 锁定图片区域高度
                    .fileImporter(isPresented: $isShowingImagePicker, allowedContentTypes: [.image], allowsMultipleSelection: false) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            if selectedFile.startAccessingSecurityScopedResource() {
                                defer { selectedFile.stopAccessingSecurityScopedResource() }
                                let data = try Data(contentsOf: selectedFile)
                                selectedCoverData = data
                            }
                        } catch { print("读取图片失败: \(error)") }
                    }
                    .onDrop(of: [UTType.image], isTargeted: nil) { providers in
                        if let provider = providers.first {
                            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                                if let data = data { DispatchQueue.main.async { self.selectedCoverData = data } }
                            }
                            return true
                        }
                        return false
                    }
                }
                .frame(width: 160, height: 266) // ✨ 核心秘诀：18 + 8 + 240 = 266，右侧高度严格锁死
            }
            .padding(.horizontal, 32)
            
            Spacer() // 把底部按钮推向最下方
            
            // ================= 3. 底部 Footer =================
            HStack {
                HoverCancelButton(isDark: isDark) { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isPresented = false
                } }
                Spacer()
                
                let isFormEmpty = titleInput.trimmingCharacters(in: .whitespaces).isEmpty || authorInput.trimmingCharacters(in: .whitespaces).isEmpty
                let hasChanges = bookToEdit == nil ? true : (titleInput != bookToEdit?.title || authorInput != bookToEdit?.author || selectedCoverData != bookToEdit?.coverData)
                let shouldDisable = isFormEmpty || !hasChanges
                                
                EditorSubmitButton(isEdit: isEdit, isDisabled: shouldDisable, isDark: isDark) { saveBook() }
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .frame(width: 700, height: 490) // 调整到恰到好处的包裹高度
        .liquidSheet(isDark: isDark)
        .shadow(color: .black.opacity(isDark ? 0.5 : 0.15), radius: 40, y: 20)
        .presentationBackground(.clear)
        .onAppear {
            if let book = bookToEdit {
                titleInput = book.title
                authorInput = book.author
                selectedCoverData = book.coverData
            }
        }
    }
    
    private func saveBook() {
        guard !titleInput.isEmpty, !authorInput.isEmpty else { return }
        if let book = bookToEdit {
            book.title = titleInput
            book.author = authorInput
            book.coverData = selectedCoverData
        } else {
            let newBook = Book(title: titleInput, author: authorInput, status: "UNREAD", tags: [])
            newBook.coverData = selectedCoverData
            modelContext.insert(newBook)
        }
        try? modelContext.save()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isPresented = false
        }
    }
}

// MARK: - ✨ 纯视觉装饰条：全息星核 (Optical Core Divider)
struct MetadataDivider: View {
    var isDark: Bool
    
    // ✨ 注入灵魂：一个极缓的自转状态
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            
            // ================= 1. 左侧能量轨迹 =================
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color.clear, isDark ? Color.twIndigo500.opacity(0.6) : Color.twIndigo400],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1)
            
            // ================= 2. 左侧几何节点 =================
            HStack(spacing: 5) {
                Circle().fill(isDark ? Color.twSlate600 : Color.twSlate300).frame(width: 3, height: 3)
                Circle().fill(isDark ? Color.twIndigo400 : Color.twIndigo400).frame(width: 4, height: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(isDark ? .twSlate500 : .twSlate400)
            }
            
            // ================= 3. 核心：全息星核 =================
            ZStack {
                // 外层：流光自转圆环
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.twIndigo500, .twSky300, .purple],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 24, height: 24)
                    // ✨ 核心动效：无尽的缓慢自转
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .shadow(color: .twIndigo500.opacity(isDark ? 0.6 : 0.3), radius: 6)
                
                // 内层：静止的晶体菱形
                Image(systemName: "rhombus.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.twSky300, .twIndigo500],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                
                // 点缀：溢出的星光
                Image(systemName: "sparkle")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.purple)
                    .offset(x: 10, y: -10)
                    .scaleEffect(isAnimating ? 1.1 : 0.9) // ✨ 微小的呼吸缩放
            }
            .padding(.horizontal, 4)
            
            // ================= 4. 右侧几何节点 =================
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                Circle().fill(isDark ? Color.twPurple400 : Color.twPurple400).frame(width: 4, height: 4)
                Circle().fill(isDark ? Color.twSlate600 : Color.twSlate300).frame(width: 3, height: 3)
            }
            
            // ================= 5. 右侧能量轨迹 =================
            Rectangle()
                .fill(LinearGradient(
                    colors: [isDark ? Color.twPurple500.opacity(0.6) : Color.twPurple400, Color.clear],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(height: 1)
        }
        .padding(.vertical, 8) // 保持高度约束的弹簧空间
        .onAppear {
            // ✨ 触发 8 秒一圈的极缓动态，不抢眼但赋予了生命力
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct DashedDropzoneView: View {
    var isDark: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isDark ? Color.twIndigo500.opacity(0.4) : Color.twIndigo400.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                .background(isDark ? Color.twIndigo900.opacity(0.1) : Color.twIndigo50.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(spacing: 12) {
                Image(systemName: "icloud.and.arrow.up").font(.system(size: 32, weight: .light)).foregroundColor(.twIndigo400)
                VStack(spacing: 4) {
                    Text("点击或拖拽").font(.system(size: 12, weight: .bold)).foregroundColor(.twIndigo500)
                    Text("比例 2:3").font(.system(size: 10, weight: .medium)).foregroundColor(.twIndigo400.opacity(0.8))
                }
            }
        }
        .frame(width: 160, height: 240)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
