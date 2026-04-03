import SwiftUI

struct TopNavigationBarView: View {
    @Binding var currentMainTab: String
    @Binding var showAddModal: Bool
    @Binding var isDarkMode: Bool
    var mainTabNamespace: Namespace.ID
    
    // ✨ 追踪悬浮状态
    @State private var hoveredTab: String? = nil
    @State private var isHoveringAdd = false // 追踪添加按钮
    
    let mainTabs = [
        ("阅读主页", "house.fill"),
        ("全景画廊", "square.grid.2x2.fill"),
        ("3D漫游", "cube.fill"),
        ("年度轨迹", "timelapse"),
        ("月度记录", "calendar")
    ]
    
    var body: some View {
        ZStack {
            // ================= 1. 绝对居中的主导航 =================
            HStack(spacing: 0) {
                ForEach(mainTabs, id: \.0) { tab in
                    let title = tab.0
                    let icon = tab.1
                    let isActive = currentMainTab == title
                    let isHovered = hoveredTab == title
                    
                    let activeTextColor = isDarkMode ? Color.white : Color.twSlate900
                    let inactiveTextColor = isDarkMode ? Color.twSlate400 : Color.twSlate500
                    let hoverTextColor = isDarkMode ? Color.white.opacity(0.85) : Color.twSlate700
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0.2)) {
                            currentMainTab = title
                        }
                    }) {
                        ZStack {
                            if isActive {
                                Capsule()
                                    .fill(isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.08))
                                    .matchedGeometryEffect(id: "main-nav-tab", in: mainTabNamespace)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: icon)
                                    .font(.system(size: 15, weight: isActive ? .bold : .medium))
                                Text(title)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(isActive ? activeTextColor : (isHovered ? hoverTextColor : inactiveTextColor))
                            .scaleEffect((isHovered || isActive) ? 1.05 : 1.0)
                            .shadow(color: .black.opacity(isActive && isDarkMode ? 0.3 : 0), radius: 2, y: 1)
                        }
                        .frame(height: 44).frame(maxWidth: .infinity).contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .pointingHand()
                    .onHover { h in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { hoveredTab = h ? title : nil }
                    }
                }
            }
            .padding(6)
            .frame(width: 660)
            // ✨ 适配新版引擎的 radius 参数 (保留 100 以渲染完美的大胶囊体)
            .liquidGlass(radius: 100, isDark: isDarkMode)
            
            // ================= 2. 右侧对齐的录入新书按钮 =================
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showAddModal = true }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("录入新书")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(isDarkMode ? .white : .twSlate800)
                    .brightness(isHoveringAdd ? (isDarkMode ? 0.2 : -0.2) : 0)
                    .scaleEffect(isHoveringAdd ? 1.05 : 1.0)
                    .padding(.horizontal, 20)
                    // ✨ 保持高度 44，与中间导航栏完美等高协调
                    .frame(height: 44)
                    // ✨ 适配新版引擎的 radius 参数 (保留 22 以完美渲染高度为 44 的标准胶囊)
                    .liquidGlass(radius: 22, isDark: isDarkMode)
                }
                .buttonStyle(.plain).pointingHand()
                .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isHoveringAdd = h } }
            }
        }
        // ✨ 设置两边边距，让 Add 按钮留在右侧但不会紧贴屏幕边缘
        .padding(.horizontal, 40)
        .padding(.top, 60)
    }
}
