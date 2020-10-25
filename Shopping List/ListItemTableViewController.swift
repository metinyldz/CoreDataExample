//
//  ListItemTableViewController.swift
//  Shopping List
//
//  Created by Metin Yıldız on 25.10.2020.
//

import UIKit
import CoreData

class ListItemTableViewController: UITableViewController {
    
    var shoppingItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fetchItems()
    }
    //MARK: - Core Data Processing
    
    func createItem(lisItem: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Bag", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(lisItem, forKey: "item")
        
        do {
            try managedContext.save()
        } catch let error {
            print("Item can't be created: \(error.localizedDescription)")
        }
    }
    
    func fetchItems() {
        shoppingItems.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bag")
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            for item in fetchResults as![NSManagedObject] {
                shoppingItems.append(item.value(forKey: "item") as! String)
            }
            self.tableView.reloadData()
        } catch let error {
            print("Item can't be fetched: \(error.localizedDescription)")
        }
        
    }
    
//    func deleteItem(indexPathRow: Int) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let itemToRemove = self.shoppingItems[indexPathRow] as! NSManagedObject
//        managedContext.delete(itemToRemove)
//        
//    }
    
    //MARK: - Add Action
    
    @objc
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: "Add Item", message: "Add items into your bag.", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            self.createItem(lisItem: popup.textFields?.first?.text ?? "Error")
            self.fetchItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        popup.addAction(saveAction)
        popup.addAction(cancelAction)
        self.present(popup, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        cell.textLabel?.text = self.shoppingItems[indexPath.row]
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        // Created Swipe Action
//        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
//            
//            
//            
//        }
//        
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Bag \(section + 1)"
    }

}
