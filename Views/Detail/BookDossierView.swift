import SwiftUI
import SwiftData

struct BookDossierView: View {
    @Bindable var book: Book
    
    let predefinedTags = ["哲学", "历史", "人文", "科技", "编程", "艺术"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.primary)
                Text(book.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Label("当前状态", systemImage: "book.fill")
                    .foregroundColor(.secondary)
                
                Picker("状态", selection: $book.status) {
                    Text("待读").tag("UNREAD")
                    Text("在读").tag("READING")
                    Text("已读完").tag("FINISHED")
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("阅读旅程", systemImage: "calendar")
                    .foregroundColor(.secondary)
                
                if book.status == "UNREAD" {
                    Text("Waiting for the journey to begin...")
                        .font(.callout).italic()
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    HStack {
                        DatePicker("", selection: Binding(
                            get: { book.startTime ?? Date() },
                            set: { book.startTime = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        
                        Text("至").foregroundColor(.secondary)
                        
                        DatePicker("", selection: Binding(
                            get: { book.endTime ?? Date() },
                            set: { book.endTime = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                        .disabled(book.status != "FINISHED")
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("个人评价", systemImage: "star.fill")
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= book.rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(index <= book.rating ? .yellow : .gray.opacity(0.3))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    book.rating = index
                                }
                            }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Label("知识标签 (\(book.tags.count)/3)", systemImage: "tag.fill")
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(predefinedTags, id: \.self) { tag in
                            let isSelected = book.tags.contains(tag)
                            
                            Text(tag)
                                .font(.subheadline).bold()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.indigo : Color.secondary.opacity(0.1))
                                .foregroundColor(isSelected ? .white : .primary)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        if isSelected {
                                            book.tags.removeAll { $0 == tag }
                                        } else if book.tags.count < 3 {
                                            book.tags.append(tag)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(30)
        .glassEffect(cornerRadius: 32)
    }
}

// ✨ 新增：面板独立预览
#Preview {
    let book = Book(title: "月亮与六便士", author: "毛姆", status: "READING", rating: 5, tags: ["文学", "哲学"])
    
    return ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        BookDossierView(book: book).padding()
    }
}
