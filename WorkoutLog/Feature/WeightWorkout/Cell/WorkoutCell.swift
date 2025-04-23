//
//  WorkoutCell.swift
//  WorkoutLog
//
//  Created by 박지용 on 4/20/25.
//

import UIKit
import SnapKit
import Then

final class WorkoutCell: UITableViewCell {

    var onUpdate: ((Double, Int) -> Void)?

    private let setLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }

    private let weightField = UITextField().then {
        $0.placeholder = "kg"
        $0.keyboardType = .decimalPad
        $0.borderStyle = .roundedRect
        $0.textAlignment = .center
    }

    private let repsField = UITextField().then {
        $0.placeholder = "회"
        $0.keyboardType = .numberPad
        $0.borderStyle = .roundedRect
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let kgLabel = UILabel().then {
        $0.text = "kg"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkGray
    }

    private let repsLabel = UILabel().then {
        $0.text = "회"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkGray
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        selectionStyle = .none

        let weightStack = UIStackView(arrangedSubviews: [weightField, kgLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        let repsStack = UIStackView(arrangedSubviews: [repsField, repsLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        let inputStack = UIStackView(arrangedSubviews: [weightStack, repsStack]).then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
            $0.alignment = .fill
        }

        let mainStack = UIStackView(arrangedSubviews: [setLabel, inputStack]).then {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.alignment = .center
            $0.distribution = .fill
        }

        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }

        mainStack.setContentHuggingPriority(.required, for: .vertical)
        mainStack.setContentCompressionResistancePriority(.required, for: .vertical)

        weightField.snp.makeConstraints { $0.height.equalTo(36) }
        repsField.snp.makeConstraints { $0.height.equalTo(36) }
    }

    private func setupBindings() {
        [weightField, repsField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }

    @objc private func textFieldDidChange() {
        let weight = Double(weightField.text ?? "") ?? 0
        let reps = Int(repsField.text ?? "") ?? 0
        onUpdate?(weight, reps)
    }

    func configure(set: Int, weight: Double, reps: Int) {
        setLabel.text = "\(set)세트"
        weightField.text = weight == 0 ? "" : "\(weight)"
        repsField.text = reps == 0 ? "" : "\(reps)"
    }
}
