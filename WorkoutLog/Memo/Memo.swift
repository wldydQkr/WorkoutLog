//
//  Memo.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import Foundation

struct Memo {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    
    init(id: UUID = UUID(), title: String, content: String, date: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
    }
}
