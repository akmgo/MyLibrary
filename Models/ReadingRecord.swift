import SwiftData
import SwiftUI

@Model
class ReadingRecord {
    var id: String
    var date: Date // 打卡日期
    var book: Book? // 关联的在读书籍（可以为空，代表仅打卡未指定书籍）
    
    init(date: Date = Date(), book: Book? = nil) {
        self.id = UUID().uuidString
        // 为了方便按天查询，我们抹去具体的时间（时分秒），只保留年月日
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.date = calendar.date(from: components) ?? date
        self.book = book
    }
}
