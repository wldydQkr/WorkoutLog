//
//  WeightWorkoutInputView.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/8/25.
//

import UIKit

final class WeightWorkoutInputView: UIView {

    var onUpdate: ((Int, Int, Double) -> Void)?
    var onRemove: (() -> Void)?

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

    private let closeButton = UIButton(type: .system).then {
        $0.setTitle("✕", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20)
    }

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
        $0.tintColor = .black
    }

    private let addButton = UIButton(type: .system).then {
        $0.setTitle("+ 세트 추가", for: .normal)
        $0.tintColor = .black
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
        let headerStack = UIStackView(arrangedSubviews: [
            titleLabel,
            closeButton
        ]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

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
            headerStack,
            inputContainer,
            buttonStack
        ]).then {
            $0.axis = .vertical
            $0.spacing = 12
        }

        mainStack.setContentHuggingPriority(.required, for: .vertical)

        addSubview(mainStack)

        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
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
        closeButton.addTarget(self, action: #selector(removeSelf), for: .touchUpInside)
    }

    @objc private func addSet() {
        setCount += 1
        let newInputStack = createInputStack()
        inputContainer.addArrangedSubview(newInputStack)
    }

    @objc private func deleteSet() {
        guard setCount > 1 else { return }
        if let lastInputStack = inputContainer.arrangedSubviews.last {
            inputContainer.removeArrangedSubview(lastInputStack)
            lastInputStack.removeFromSuperview()
            setCount -= 1
        }
    }

    @objc private func removeSelf() {
        guard let viewController = self.findViewController() else {
            removeFromSuperview()
            return
        }

        let alert = UIAlertController(title: "삭제 확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.removeFromSuperview()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }

    func configure(with workout: WeightWorkout) {
        titleLabel.text = workout.exerciseName
        // 기존 세트들 제거
        inputContainer.arrangedSubviews.forEach {
            inputContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        setCount = 1 // 세트 수 초기화

        let inputStack = createInputStack()
        if let label = inputStack.arrangedSubviews[0] as? UILabel {
            label.text = "\(setCount)세트"
        }
        if let weightField = inputStack.arrangedSubviews[1] as? UITextField {
            weightField.text = "\(Int(workout.weight))"
        }
        if let repsField = inputStack.arrangedSubviews[3] as? UITextField {
            repsField.text = "\(workout.repetitions)"
        }
        inputContainer.addArrangedSubview(inputStack)
    }

    func configureTitle(_ title: String) {
        titleLabel.text = title
    }
}
