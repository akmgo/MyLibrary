import Foundation
import SQLite3

/// 1. 新增：用于接收 Apple Books 摘录的数据结构
public struct AppleAnnotation {
    public var uuid: String
    public var text: String
    public var creationDate: Date
}

public class AppleBooksDBUtils {
    /// 根据书名查找 Apple Books 中的书籍阅读进度
    /// - Parameter title: 需要查找的书名
    /// - Returns: 返回 0 到 100 的整数进度。如果没找到则返回 nil
    public static func fetchBookProgress(byTitle title: String) -> Int? {
        let libraryDir = "~/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary"
        guard let dbPath = findDatabasePath(directory: libraryDir) else { return nil }
        
        var db: OpaquePointer?
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK { return nil }
        defer { sqlite3_close(db) }
        
        // 仅查询 ZREADINGPROGRESS
        let query = "SELECT ZREADINGPROGRESS FROM ZBKLIBRARYASSET WHERE ZTITLE = ? COLLATE NOCASE LIMIT 1"
        var statement: OpaquePointer?
        var progressInt: Int? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let titleStr = title as NSString
            sqlite3_bind_text(statement, 1, titleStr.utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                // 提取进度 (0.0 - 1.0 的 Double)，并转换为 0 - 100 的 Int
                let progressDouble = sqlite3_column_double(statement, 0)
                progressInt = Int(progressDouble * 100)
            }
        }
        
        sqlite3_finalize(statement)
        return progressInt
    }
    
    private static func findDatabasePath(directory: String) -> String? {
        let expandedDir = NSString(string: directory).expandingTildeInPath
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: expandedDir)
            if let sqliteFile = files.first(where: { $0.hasSuffix(".sqlite") && !$0.contains("-wal") && !$0.contains("-shm") }) {
                return "\(expandedDir)/\(sqliteFile)"
            }
        } catch {}
        return nil
    }
    
    /// ✨ 1. 根据书名，先去 Library 库里查出这本书的底层 ID (AssetID)
    public static func fetchAssetId(byTitle title: String) -> String? {
        let libraryDir = "~/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary"
        guard let dbPath = findDatabasePath(directory: libraryDir) else { return nil }
            
        var db: OpaquePointer?
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK { return nil }
        defer { sqlite3_close(db) }
            
        // 查询书籍的 ZASSETID
        let query = "SELECT ZASSETID FROM ZBKLIBRARYASSET WHERE ZTITLE = ? COLLATE NOCASE LIMIT 1"
        var statement: OpaquePointer?
        var assetId: String? = nil
            
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let titleStr = title as NSString
            sqlite3_bind_text(statement, 1, titleStr.utf8String, -1, nil)
                
            if sqlite3_step(statement) == SQLITE_ROW {
                if let idPtr = sqlite3_column_text(statement, 0) {
                    assetId = String(cString: idPtr)
                }
            }
        }
        sqlite3_finalize(statement)
        return assetId
    }
        
    /// ✨ 2. 根据 AssetID，去 Annotation 库里把这本书的所有高亮摘录捞出来
    public static func fetchAnnotations(forAssetId assetId: String) -> [AppleAnnotation] {
        let annotationDir = "~/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation"
        guard let dbPath = findDatabasePath(directory: annotationDir) else { return [] }
            
        var db: OpaquePointer?
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK { return [] }
        defer { sqlite3_close(db) }
            
        // 查询条件：匹配 AssetID，且未被删除 (ZANNOTATIONDELETED = 0)，且选中文本不为空
        let query = """
            SELECT ZANNOTATIONUUID, ZANNOTATIONSELECTEDTEXT, ZANNOTATIONCREATIONDATE 
            FROM ZAEANNOTATION 
            WHERE ZANNOTATIONASSETID = ? AND ZANNOTATIONDELETED = 0 AND ZANNOTATIONSELECTEDTEXT IS NOT NULL
        """
            
        var statement: OpaquePointer?
        var results: [AppleAnnotation] = []
            
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            let assetIdStr = assetId as NSString
            sqlite3_bind_text(statement, 1, assetIdStr.utf8String, -1, nil)
                
            while sqlite3_step(statement) == SQLITE_ROW {
                // 1. 提取 UUID
                let uuid = String(cString: sqlite3_column_text(statement, 0))
                    
                // 2. 提取摘录文本
                let text = String(cString: sqlite3_column_text(statement, 1))
                    
                // 3. 提取并转换苹果时间戳为正常的 Date 对象
                let timestamp = sqlite3_column_double(statement, 2)
                let date = Date(timeIntervalSinceReferenceDate: timestamp)
                    
                results.append(AppleAnnotation(uuid: uuid, text: text, creationDate: date))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
}
