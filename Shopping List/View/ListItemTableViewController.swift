//
//  ListItemTableViewController.swift
//  Shopping List
//
//  Created by Metin Yıldız on 25.10.2020.
//

import UIKit
import CoreData

class ListItemTableViewController: UITableViewController {
    
    private let viewModel = ListItemTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchItems()
    }
    
    private func setupUI() {
        clearsSelectionOnViewWillAppear = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    //MARK: - Add Action
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        viewModel.addTapped()
    }
}

// MARK: - Table view data source

extension ListItemTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shoppingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = self.viewModel.shoppingItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Created trailinig swipe action
        let remove = UIContextualAction(style: .destructive, title: "Remove") { (action, UIView, _) in
            self.viewModel.removeItem(listItem: self.viewModel.shoppingItems[indexPath.row])
            self.viewModel.shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Created leading swipe action
        let update = UIContextualAction(style: .normal, title: "Update") { (action, UIView, _) in
            self.viewModel.updateItem(listItem: self.viewModel.shoppingItems[indexPath.row])
            tableView.reloadData()
        }
        
        update.backgroundColor = UIColor.init(displayP3Red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [update])
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Bag \(section + 1)"
    }
}

extension ListItemTableViewController: ListItemTableViewModelProtocol {
    func tableViewReloadData() {
        tableView.reloadData()
    }
    
    func presentAlert(_ view: UIAlertController) {
        present(view, animated: true, completion: nil)
    }
}
