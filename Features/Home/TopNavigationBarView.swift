import SwiftUI

struct TopNavigationBarView: View {
    @Binding var currentMainTab: String
    @Binding var showAddModal: Bool
    @Binding var isDarkMode: Bool
    var mainTabNamespace: Namespace.ID
    
    // ✨ 3D图标已替换为具有空间感的图形图标 "cube.fill"
    let mainTabs = [
        ("阅读主页", "house.fill"),
        ("全景画廊", "square.grid.2x2.fill"),
        ("3D漫游", "cube.fill"),
        ("年度轨迹", "timelapse"),
        ("月度记录", "calendar")
    ]
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(mainTabs, id: \.0) { tab in
                    let title = tab.0
                    let icon = tab.1
                    let isActive = currentMainTab == title
                    
                    let activeTextColor = isDarkMode ? Color.white : Color.twSlate900
                    let inactiveTextColor = isDarkMode ? Color.twSlate400 : Color.twSlate500
                    
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
                                    .scaleEffect(isActive ? 1.05 : 1.0)
                                Text(title)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(isActive ? activeTextColor : inactiveTextColor)
                            .shadow(color: .black.opacity(isActive && isDarkMode ? 0.3 : 0), radius: 2, y: 1)
                        }
                        .frame(height: 44).frame(maxWidth: .infinity).contentShape(Capsule())
                    }
                    .buttonStyle(.plain).pointingHand()
                }
            }
            .padding(6).frame(width: 660)
            .liquidGlass(cornerRadius: 100, isDark: isDarkMode)
            
            HStack(alignment: .center) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isDarkMode.toggle() }
                }) {
                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .twSky400 : .orange)
                        .frame(width: 50, height: 50)
                        .liquidGlass(cornerRadius: 25, isDark: isDarkMode)
                }
                .buttonStyle(.plain).pointingHand()
                
                Spacer()
                
                HomeAddBookButton {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showAddModal = true }
                }
            }
        }
        .padding(.horizontal, 30).padding(.top, 20).padding(.bottom, 24)
    }
}
