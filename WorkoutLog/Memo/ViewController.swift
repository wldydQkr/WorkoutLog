//
//  ViewController.swift
//  WorkoutLog
//
//  Created by 박지용 on 3/29/25.
//

import UIKit

final class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private var memos: [Memo] = []
    private let memoManager = MemoManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMemos()
    }
    
    private func loadMemos() {
        memos = memoManager.getAllMemos()
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "메모 목록"
        
        // 테이블 뷰 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MemoCell")
        
        // 추가 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        // 레이아웃
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func addButtonTapped() {
        let detailVC = MemoDetailViewController(mode: .create, memo: nil)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath)
        let memo = memos[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = memo.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        content.secondaryText = dateFormatter.string(from: memo.date)
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let memo = memos[indexPath.row]
        let detailVC = MemoDetailViewController(mode: .view, memo: memo)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            if memoManager.deleteMemo(id: memo.id) {
                memos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
