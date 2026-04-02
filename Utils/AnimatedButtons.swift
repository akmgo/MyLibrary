import SwiftUI

// MARK: - 1. 主页：录入新书按钮
struct HomeAddBookButton: View {
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Label(
                title: { Text("录入新书").font(.system(size: 14, weight: .bold)) },
                icon: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        // ✨ 动画：顺时针旋转90度
                        .rotationEffect(.degrees(isHovered ? 90 : 0))
                }
            )
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
            // ✨ 动画：阴影呼吸扩大，整体轻微上浮
            .shadow(color: .indigo.opacity(isHovered ? 0.6 : 0.3), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 2. 详情页：返回书架按钮
struct HoverBackButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
                    // ✨ 动画：箭头向左拉扯暗示退后
                    .offset(x: isHovered ? -4 : 0)
                Text("返回书架").font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(isDark ? .twSlate300 : .twSlate600)
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(isDark ? Color.twSlate800.opacity(isHovered ? 0.9 : 0.6) : Color.white.opacity(isHovered ? 0.9 : 0.6))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isDark ? Color.white.opacity(0.05) : Color.white.opacity(0.6), lineWidth: 1))
            .shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isHovered = h } }
    }
}

// MARK: - 3. 详情页：编辑按钮
struct HoverEditButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "pencil")
                    // ✨ 动画：笔尖抬起准备书写
                    .rotationEffect(.degrees(isHovered ? 15 : 0))
                    .offset(x: isHovered ? 2 : 0, y: isHovered ? -2 : 0)
                Text("编辑")
            }
            .font(.system(size: 14, weight: .bold))
            // ✨ 动画：染上天际蓝
            .foregroundColor(isHovered ? .white : (isDark ? .twSlate300 : .twSlate600))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(isHovered ? Color.blue : (isDark ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6)))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isHovered ? Color.blue.opacity(0.5) : (isDark ? Color.white.opacity(0.05) : Color.white.opacity(0.6)), lineWidth: 1))
            .shadow(color: isHovered ? Color.blue.opacity(0.4) : .clear, radius: 8, y: 4)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 4. 详情页：删除按钮
struct HoverDeleteButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "trash")
                    // ✨ 动画：垃圾桶倾斜警告
                    .rotationEffect(.degrees(isHovered ? -15 : 0))
                Text("删除")
            }
            .font(.system(size: 14, weight: .bold))
            // ✨ 动画：染上危险红
            .foregroundColor(isHovered ? .white : .red)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(isHovered ? Color.red : (isDark ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6)))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isHovered ? Color.red.opacity(0.5) : Color.red.opacity(0.3), lineWidth: 1))
            .shadow(color: isHovered ? Color.red.opacity(0.4) : .clear, radius: 8, y: 4)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { isHovered = h } }
    }
}

// MARK: - 5. 详情页：添加摘录按钮
struct DetailAddExcerptButton: View {
    let action: () -> Void
    @State private var isHovered = false
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    // ✨ 动画：加号欢快跳跃
                    .offset(y: isHovered ? -3 : 0)
                Text("添加摘录")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .background(mintGreen)
            .clipShape(Capsule())
            .shadow(color: mintGreen.opacity(isHovered ? 0.6 : 0.4), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        // 赋予一点额外的弹簧反馈
        .onHover { h in withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) { isHovered = h } }
    }
}

// MARK: - 6. 摘录弹窗：确认保存按钮
struct ExcerptSubmitButton: View {
    let action: () -> Void
    @State private var isHovered = false
    let mintGreen = Color(red: 0.46, green: 0.81, blue: 0.67)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 12, weight: .bold))
                    // ✨ 动画：纸飞机抬起机头起飞
                    .rotationEffect(.degrees(isHovered ? -15 : 0))
                    .offset(x: isHovered ? 2 : 0, y: isHovered ? -2 : 0)
                Text("确认保存")
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 120, height: 40)
            .background(mintGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: mintGreen.opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 7. 弹窗：通用取消按钮 (✨ 优雅微红呼吸动效)
struct HoverCancelButton: View {
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text("取消")
                .font(.system(size: 14, weight: .bold))
                // ✨ 动画：悬浮时文字变成精致的警示红
                .foregroundColor(isHovered ? .red : (isDark ? .twSlate400 : .twSlate500))
                .frame(width: 80, height: 44)
                // ✨ 动画：背景透出极浅的红晕
                .background(isHovered ? Color.red.opacity(isDark ? 0.15 : 0.08) : (isDark ? Color.twSlate800 : .white))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        // ✨ 动画：边框染上浅红
                        .stroke(isHovered ? Color.red.opacity(0.4) : (isDark ? Color.twSlate700 : Color.twSlate200), lineWidth: 1)
                )
                // ✨ 动画：红色呼吸阴影与按压阻尼感
                .shadow(color: isHovered ? Color.red.opacity(0.2) : .clear, radius: isHovered ? 8 : 0, y: isHovered ? 4 : 0)
                .scaleEffect(isHovered ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 8. 图书录入弹窗：确认/保存按钮
struct EditorSubmitButton: View {
    let isEdit: Bool
    let isDisabled: Bool
    let isDark: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !isEdit {
                    Image(systemName: "plus")
                        // ✨ 动画：加号旋转
                        .rotationEffect(.degrees(isHovered && !isDisabled ? 90 : 0))
                } else {
                    Image(systemName: "checkmark.circle")
                        // ✨ 动画：保存成功的心跳缩放
                        .scaleEffect(isHovered && !isDisabled ? 1.1 : 1.0)
                }
                Text(isEdit ? "保存修改" : "确认录入")
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(isDisabled ? (isDark ? .twSlate500 : .twSlate400) : .white)
            .frame(width: 120, height: 44)
            // ✨ 修复置灰逻辑：只有数据不合法时才置灰，合法时亮起主色调
            .background(
                isDisabled
                ? (isDark ? Color.twSlate800.opacity(0.6) : Color.twSlate100)
                : Color.twIndigo600
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            // ✨ 动画：靛蓝光晕与悬浮
            .shadow(color: isDisabled ? .clear : Color.twIndigo600.opacity(isHovered ? 0.5 : 0.3), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
            .offset(y: isHovered && !isDisabled ? -2 : 0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled) // 真正的表单验证拦截
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
    }
}
