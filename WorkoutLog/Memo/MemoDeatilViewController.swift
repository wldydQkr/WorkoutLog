//
//  MemoDeatilViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit

enum MemoMode {
    case create
    case view
    case edit
}

class MemoDetailViewController: UIViewController {
    
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private var currentMode: MemoMode
    private var memo: Memo?
    private let memoManager = MemoManager.shared
    
    init(mode: MemoMode, memo: Memo?) {
        self.currentMode = mode
        self.memo = memo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureBasedOnMode()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 제목 텍스트 필드
        titleTextField.font = UIFont.boldSystemFont(ofSize: 18)
        titleTextField.placeholder = "제목을 입력하세요"
        titleTextField.borderStyle = .roundedRect
        
        // 내용 텍스트 뷰
        contentTextView.font = UIFont.systemFont(ofSize: 16)
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 5
        
        // 레이아웃
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureBasedOnMode() {
        switch currentMode {
        case .create:
            title = "새 메모"
            setupCreateMode()
        case .view:
            title = "메모 보기"
            setupViewMode()
        case .edit:
            title = "메모 수정"
            setupEditMode()
        }
    }
    
    private func setupCreateMode() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    private func setupViewMode() {
        guard let memo = memo else { return }
        
        titleTextField.text = memo.title
        contentTextView.text = memo.content
        
        titleTextField.isEnabled = false
        contentTextView.isEditable = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    
    private func setupEditMode() {
        titleTextField.isEnabled = true
        contentTextView.isEditable = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(updateButtonTapped)
        )
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            showAlert(message: "제목과 내용을 입력해주세요")
            return
        }
        
        _ = memoManager.addMemo(title: title, content: content)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editButtonTapped() {
        currentMode = .edit
        configureBasedOnMode()
    }
    
    @objc private func updateButtonTapped() {
        guard let memo = memo else { return }
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            showAlert(message: "제목과 내용을 입력해주세요")
            return
        }
        
        if memoManager.updateMemo(id: memo.id, title: title, content: content) {
            self.memo = memoManager.getMemo(id: memo.id)
            currentMode = .view
            configureBasedOnMode()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
