//
//  WeightWorkoutInputView.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit

final class WeightWorkoutInputView: UIView {

    var onUpdate: ((Int, Int, Double) -> Void)?

    private var setCount: Int = 1 {
        didSet {
            // Update the set labels in the input stacks
            for (index, subview) in inputContainer.arrangedSubviews.enumerated() {
                if let stack = subview as? UIStackView,
                   let label = stack.arrangedSubviews.first as? UILabel {
                    label.text = "\(index + 1)세트"
                }
            }
        }
    }

    private let scrollView = UIScrollView()

    private let inputContainer = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }

    private let titleLabel = UILabel().then {
        $0.text = "덤벨 플라이 (가슴)"
        $0.font = .boldSystemFont(ofSize: 18)
    }

    private let deleteButton = UIButton(type: .system).then {
        $0.setTitle("- 세트 삭제", for: .normal)
    }

    private let addButton = UIButton(type: .system).then {
        $0.setTitle("+ 세트 추가", for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        let initialInputStack = createInputStack()
        inputContainer.addArrangedSubview(initialInputStack)

        let buttonStack = UIStackView(arrangedSubviews: [
            deleteButton,
            addButton
        ]).then {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.distribution = .fillEqually
        }

        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            inputContainer,
            buttonStack
        ]).then {
            $0.axis = .vertical
            $0.spacing = 12
        }

        mainStack.setContentHuggingPriority(.required, for: .vertical)

        scrollView.addSubview(mainStack)
        scrollView.alwaysBounceVertical = true
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mainStack.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(16)
            $0.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom).inset(16)
            $0.leading.equalTo(scrollView.contentLayoutGuide.snp.leading).offset(16)
            $0.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing).inset(16)
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width).offset(-32)
        }
    }

    private func createInputStack() -> UIStackView {
        let setLabel = UILabel().then {
            $0.text = "\(setCount)세트"
            $0.font = .systemFont(ofSize: 16)
        }

        let weightTextField = UITextField().then {
            $0.placeholder = "0"
            $0.keyboardType = .numberPad
            $0.textAlignment = .center
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 10
            $0.snp.makeConstraints { $0.width.equalTo(60); $0.height.equalTo(36) }
        }

        let kgLabel = UILabel().then {
            $0.text = "kg"
            $0.font = .systemFont(ofSize: 16)
        }

        let repsTextField = UITextField().then {
            $0.placeholder = "0"
            $0.keyboardType = .numberPad
            $0.textAlignment = .center
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 10
            $0.snp.makeConstraints { $0.width.equalTo(60); $0.height.equalTo(36) }
        }

        let repsLabel = UILabel().then {
            $0.text = "회"
            $0.font = .systemFont(ofSize: 16)
        }

        let stack = UIStackView(arrangedSubviews: [
            setLabel,
            weightTextField,
            kgLabel,
            repsTextField,
            repsLabel
        ]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            $0.distribution = .fill
        }

        stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stack.isLayoutMarginsRelativeArrangement = true

        return stack
    }

    private func setupBindings() {
        addButton.addTarget(self, action: #selector(addSet), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteSet), for: .touchUpInside)
    }

    @objc private func addSet() {
        setCount += 1
        let newInputStack = createInputStack()
        inputContainer.addArrangedSubview(newInputStack)
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(
                x: 0,
                y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom
            )
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    @objc private func deleteSet() {
        guard setCount > 1 else { return }
        if let lastInputStack = inputContainer.arrangedSubviews.last {
            inputContainer.removeArrangedSubview(lastInputStack)
            lastInputStack.removeFromSuperview()
            setCount -= 1
        }
    }
}
