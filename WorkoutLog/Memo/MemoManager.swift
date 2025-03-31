//
//  MemoManager.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import Foundation

final class MemoManager {
    static let shared = MemoManager()
    
    private init() {}
    
    private var memos: [Memo] = []
    
    func getAllMemos() -> [Memo] {
        return memos
    }
    
    func getMemo(id: UUID) -> Memo? {
        return memos.first { $0.id == id }
    }
    
    func addMemo(title: String, content: String) -> Memo {
        let newMemo = Memo(title: title, content: content)
        memos.append(newMemo)
        return newMemo
    }
    
    func updateMemo(id: UUID, title: String, content: String) -> Bool {
        guard let index = memos.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        memos[index] = Memo(id: id, title: title, content: content)
        return true
    }
    
    func deleteMemo(id: UUID) -> Bool {
        guard let index = memos.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        memos.remove(at: index)
        return true
    }
}
