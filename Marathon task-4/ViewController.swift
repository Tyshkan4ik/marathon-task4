//
//  ViewController.swift
//  Marathon task-4
//
//  Created by Виталий Троицкий on 10.03.2023.
//

import UIKit

enum Section: Hashable {
    case first
}

struct Details: Hashable {
    
    var title: Int
    var checkMark: Bool
    var index: Int
}

class ViewController: UIViewController, UITableViewDelegate {
    
    var details = [Details]()
    
    var myArray = Array(0...32)
    
    var dataSource: UITableViewDiffableDataSource<Section, Details>?
    
    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "Shuffle"
        button.target = self
        button.action = #selector(clickButton)
        return button
    }()
    
    func setupNumbers() {
        for i in myArray {
            details.append(Details(title: i, checkMark: false, index: 1))
        }
        details.sort {
            $0.index<$1.index
        }
    }
    
    @objc
    func clickButton() {
            self.details.shuffle()
        dataSource?.defaultRowAnimation = .left
        reloadData()
    }
    
    private lazy var table: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 10
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupNavigationItem()
        setupElement()
        setupConstraints()
        setupNumbers()
        setupTableView()
        createDataSource()
        reloadData()
    }
    
    private func setupNavigationItem() {
        title = "Task 4"
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setupElement() {
        view.addSubview(table)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupTableView() {
      table.delegate = self
    }
    
    func createDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Details>(tableView: table, cellProvider: { tableView, indexPath, model -> UITableViewCell? in
    
            var cell: UITableViewCell
            if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
                cell = reuseCell
            } else {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "\(model.title)"
            cell.contentConfiguration = configuration
            if model.checkMark == true {
                cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark"))
            } else {
                cell.accessoryView = nil
            }
            return cell
        })
    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Details >()
        snapshot.appendSections([.first])
        snapshot.appendItems(details, toSection: .first)
            dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func moveRow(index: IndexPath) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Details>()
        snapshot.appendSections([.first])
        snapshot.appendItems(details, toSection: .first)
        let itemFirst = snapshot.itemIdentifiers[0]
        let indexCurrent = snapshot.itemIdentifiers[index.row]
        if index.row != 0 {
            snapshot.moveItem(indexCurrent, beforeItem: itemFirst)
            reloadArrayDetails(index: index)
            }
        UIView.animate(withDuration: 0.5) {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func reloadArrayDetails(index: IndexPath) {
        if index.row != 0 {
            let item = details[index.row]
            details.remove(at: index.row)
            details.insert(item, at: 0)
        }
    }
    
    func addCheckMark(index: IndexPath) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Details >()
        snapshot.appendSections([.first])
        if self.details[index.row].checkMark == false {
            self.details[index.row].checkMark = true
        } else {
            self.details[index.row].checkMark = false
        }
        snapshot.appendItems(details, toSection: .first)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        addCheckMark(index: indexPath)
        if let item = dataSource?.itemIdentifier(for: indexPath){
            if item.checkMark == true {
                moveRow(index: indexPath)
            } else {
                reloadData()
            }
        }
    }
}

