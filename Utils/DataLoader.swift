import Foundation
import SwiftData
import SwiftUI

/// 临时的原始数据结构，用于解析
struct RawBook {
    let title: String
    let author: String
    let status: String
    let startTime: String?
    let endTime: String?
    let rating: Int?
    let tags: [String]?
}

@MainActor
class DataLoader {
    /// 你的全部真实数据
    static let rawBooks: [RawBook] = [
        RawBook(title: "论美国的民主", author: "托克维尔", status: "FINISHED", startTime: "2025-10-26", endTime: "2026-01-01", rating: 5, tags: ["人文", "政治", "社会"]),
        RawBook(title: "万历十五年", author: "黄仁宇", status: "FINISHED", startTime: "2026-02-15", endTime: "2026-02-26", rating: 4, tags: ["传记", "历史", "政治"]),
        RawBook(title: "你当像鸟飞往你的山", author: "塔拉·韦斯特弗", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "理想国", author: "柏拉图", status: "FINISHED", startTime: "2025-12-13", endTime: "2026-01-01", rating: 4, tags: ["哲学", "思考", "政治"]),
        RawBook(title: "一个人的朝圣2：奎妮的情歌", author: "蕾秋·乔伊斯", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "明朝那些事儿", author: "当年明月", status: "FINISHED", startTime: "2025-04-12", endTime: "2026-01-01", rating: 5, tags: ["人文", "历史", "思考"]),
        RawBook(title: "娱乐至死", author: "尼尔·波兹曼", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "人类简史：从动物到上帝", author: "Yuval Noah Harari", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "一个人的朝圣", author: "蕾秋·乔伊斯", status: "FINISHED", startTime: "2017-04-06", endTime: "2026-01-01", rating: 3, tags: ["人文", "文学", "成长"]),
        RawBook(title: "月亮与六便士", author: "威廉·萨默赛特·毛姆", status: "FINISHED", startTime: "2020-10-05", endTime: "2026-01-01", rating: 5, tags: ["人文", "思考", "文学"]),
        RawBook(title: "乌合之众", author: "古斯塔夫·勒庞", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "二十四史", author: "《二十四史》编委会", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "忏悔录", author: "卢梭", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "贫穷的本质", author: "阿比吉特·班纳吉；埃斯特·迪弗洛", status: "FINISHED", startTime: "2025-02-07", endTime: "2026-01-01", rating: 4, tags: ["思考", "社会", "经济"]),
        RawBook(title: "第一性原理", author: "李善友", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "江城", author: "彼得·海斯勒", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "毛泽东选集", author: "毛泽东", status: "READING", startTime: "2026-03-03", endTime: nil, rating: nil, tags: nil),
        RawBook(title: "沉默的大多数", author: "王小波", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "奥德赛", author: "荷马", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "霍乱时期的爱情", author: "加西亚·马尔克斯", status: "FINISHED", startTime: "2026-01-03", endTime: "2026-01-08", rating: 5, tags: ["人文", "思考", "经典"]),
        RawBook(title: "三体", author: "刘慈欣", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "飘", author: "玛格丽特·米切尔", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "国富论", author: "亚当·斯密", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "追风筝的人", author: "卡勒德·胡赛尼", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "悉达多", author: "赫尔曼·黑塞", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "活着", author: "余华", status: "FINISHED", startTime: "2026-02-27", endTime: "2026-03-03", rating: 5, tags: ["人文", "文学", "成长"]),
        RawBook(title: "百年孤独", author: "加西亚·马尔克斯", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "杀死一只知更鸟", author: "哈珀·李", status: "FINISHED", startTime: "2026-01-26", endTime: "2026-02-14", rating: 4, tags: ["人文", "教育", "社会"]),
        RawBook(title: "文明的冲突", author: "塞缪尔·P·亨廷顿", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "共产党宣言", author: "马克思；恩格斯", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "法律的悖论", author: "罗翔", status: "FINISHED", startTime: "2025-04-17", endTime: "2026-01-01", rating: 4, tags: ["人文", "哲学", "法律"]),
        RawBook(title: "朝花夕拾", author: "鲁迅", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "撒哈拉的故事", author: "三毛", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "挪威的森林", author: "村上春树", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "资本论", author: "卡尔·马克思", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "呐喊", author: "鲁迅", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "如何阅读一本书", author: "莫提默·J·艾德勒；查尔斯·范多伦；加西亚·马尔克斯", status: "FINISHED", startTime: "2025-09-18", endTime: "2026-01-01", rating: 3, tags: ["思考", "教育", "成长"]),
        RawBook(title: "局外人", author: "阿尔贝·加缪", status: "FINISHED", startTime: "2026-01-09", endTime: "2026-01-10", rating: 4, tags: ["人文", "思考", "社会"]),
        RawBook(title: "人性的弱点", author: "戴尔·卡耐基", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "君主论", author: "马基雅维利", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "美的历程", author: "李泽厚", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil),
        RawBook(title: "罪与罚", author: "陀思妥耶夫斯基", status: "FINISHED", startTime: "2025-06-12", endTime: "2026-01-01", rating: 4, tags: ["人文", "哲学", "文学"]),
        RawBook(title: "艺术的故事", author: "恩斯特·贡布里希", status: "FINISHED", startTime: "2026-01-11", endTime: "2026-01-25", rating: 4, tags: ["历史", "科普", "艺术"]),
        RawBook(title: "茶花女", author: "小亚历山大·仲马", status: "UNREAD", startTime: nil, endTime: nil, rating: nil, tags: nil)
    ]

    /// 执行一次性导入逻辑
    static func importDataIfNeeded(context: ModelContext) {
        // 1. 检查数据库是否已经有数据，防止每次打开 App 都重复导入
        let descriptor = FetchDescriptor<Book>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        if existingCount > 0 {
            print("📦 数据库已有数据，跳过初始装载。")
            return
        }
        
        print("🚀 开始装载初始书籍数据...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for raw in rawBooks {
            // 2. 将字符串日期转换为 Date 对象
            let start = raw.startTime != nil ? dateFormatter.date(from: raw.startTime!) : nil
            let end = raw.endTime != nil ? dateFormatter.date(from: raw.endTime!) : nil
            
            // 3. 动态从 Assets 读取图片并转换为 Data
            // 因为这是 macOS 应用，我们使用 NSImage。如果是 iOS 则使用 UIImage
            var imageData: Data? = nil
            #if os(macOS)
            if let image = NSImage(named: raw.title) {
                imageData = image.tiffRepresentation
            }
            #else
            if let image = UIImage(named: raw.title) {
                imageData = image.jpegData(compressionQuality: 0.8)
            }
            #endif
            
            if imageData == nil {
                print("⚠️ 警告：找不到书名对应的封面图片 -> \(raw.title)")
            }
            
            // 4. 创建 SwiftData 实体并塞入数据
            let newBook = Book(
                title: raw.title,
                author: raw.author,
                coverData: imageData, // ✨ 把 coverData 挪到了这里
                status: raw.status,
                rating: raw.rating ?? 0,
                tags: raw.tags ?? [],
                startTime: start,
                endTime: end
            )
            
            // 5. 插入数据库
            context.insert(newBook)
        }
        
        // 强行保存
        try? context.save()
        print("✅ 初始书籍装载完毕！共装载 \(rawBooks.count) 本书。")
    }
}
