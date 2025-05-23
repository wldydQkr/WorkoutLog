//
//  WorkoutCalendarSummaryViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/15/25.
//

import UIKit
import RealmSwift
import SnapKit
import Then

final class WorkoutCalendarSummaryViewController: UIViewController {

    private let viewModel = WorkoutCalendarSummaryViewModel()
    
    private let calendarView = UICalendarView().then {
        $0.tintColor = .black
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.fontDesign = .monospaced
        $0.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture)
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.preservesSuperviewLayoutMargins = false
    }
    
    private let scrollView = UIScrollView()

    private let contentStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    private let summaryLabel = UILabel().then {
        $0.text = "날짜를 선택하세요"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .label
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private let exerciseListLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTransparentStatusBar()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()

        calendarView.delegate = self
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)

        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        (calendarView.selectionBehavior as? UICalendarSelectionSingleDate)?.setSelected(today, animated: false)
        if let todayDate = Calendar.current.date(from: today) {
            updateSummary(for: todayDate)
        }
    }

    private func setupUI() {
        // Add scrollView to view
        view.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // Add contentStack to scrollView
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        // Create and add calendarContainer to contentStack
        let calendarContainer = UIView()
        contentStack.addArrangedSubview(calendarContainer)
        
        // Now that calendarContainer is in the view hierarchy, add calendarView to it
        calendarContainer.addSubview(calendarView)
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        calendarContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.width * 1.15)
        }

        // Add spacer
//        let spacer = UIView()
//        contentStack.addArrangedSubview(spacer)
//        spacer.snp.makeConstraints {
//            $0.height.equalTo(20)
//        }

        // Create labelStack
        let labelStack = UIStackView(arrangedSubviews: [summaryLabel, exerciseListLabel]).then {
            $0.axis = .vertical
            $0.spacing = 8
        }

        // Create and add labelContainer
        let labelContainer = UIView().then {
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        
        contentStack.addArrangedSubview(labelContainer)
        
        // Now that labelContainer is in the view hierarchy, add labelStack to it
        labelContainer.addSubview(labelStack)
        labelStack.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(labelContainer).inset(16)
        }

        labelContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        // Add bottom spacer
        let bottomSpacer = UIView()
        contentStack.addArrangedSubview(bottomSpacer)
        bottomSpacer.snp.makeConstraints {
            $0.height.equalTo(20)
        }
    }

    private func updateSummary(for date: Date) {
        let result = viewModel.summary(for: date)
        summaryLabel.text = result.summaryText
        exerciseListLabel.text = result.exerciseList
    }
}

extension WorkoutCalendarSummaryViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        return viewModel.hasData(on: date) ? .default(color: .black) : nil
    }
}

extension WorkoutCalendarSummaryViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let components = dateComponents,
              let date = Calendar.current.date(from: components) else { return }
        updateSummary(for: date)
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct WorkoutCalendarSummaryViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            WorkoutCalendarSummaryViewController()
        }
        .ignoresSafeArea()
    }
}

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: () -> ViewController

    init(_ builder: @escaping () -> ViewController) {
        self.viewController = builder
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif
