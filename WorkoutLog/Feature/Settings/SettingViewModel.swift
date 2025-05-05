//
//  SettingViewModel.swift
//  WorkoutLog
//
//  Created by 박지용 on 5/5/25.
//

import Foundation

enum SettingSection: Int, CaseIterable {
    case 내정보, 기타, 도움말

    var title: String {
        switch self {
        case .내정보: return "내 정보"
        case .기타: return "기타"
        case .도움말: return "도움말"
        }
    }

    var items: [String] {
        switch self {
        case .내정보:
            return ["프로필 편집"]
        case .기타:
            return ["1RM 계산기", "휴식 타이머"]
        case .도움말:
            return ["문의하기"]
        }
    }
}

final class SettingViewModel {
    var sections: [SettingSection] {
        return SettingSection.allCases
    }

    func items(for section: Int) -> [String] {
        guard let section = SettingSection(rawValue: section) else { return [] }
        return section.items
    }

    func title(for section: Int) -> String? {
        return SettingSection(rawValue: section)?.title
    }
}
