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
    
    func removeItem(listItem: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        if let result = try? managedContext.fetch(fetchRequest) {
            for item in result {
                managedContext.delete(item)
            }
            
            do {
                try managedContext.save()
                print("Item saved.")
            } catch let error {
                print("It can't be deleted: \(error.localizedDescription)")
            }
            
        }

    }
    
    func updateItem(listItem: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Bag")
        fetchRequest.predicate = NSPredicate(format: "item = %@", listItem)
        
        let popup = UIAlertController(title: "Update Item", message: "Update Item in your bag.", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        let saveAction = UIAlertAction(title: "Update", style: .default) { (_) in
            
            do {
                let result = try managedContext.fetch(fetchRequest)
                print(result[0])
                let item = result[0]
                item.setValue(popup.textFields?.first?.text, forKey: "item")
                try managedContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
            
            self.fetchItems()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        popup.addAction(saveAction)
        popup.addAction(cancelAction)
        self.present(popup, animated: true, completion: nil)
    }
    
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Created trailinig swipe action
        let remove = UIContextualAction(style: .destructive, title: "Remove") { (action, UIView, _) in
            self.removeItem(listItem: self.shoppingItems[indexPath.row])
            self.shoppingItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Created leading swipe action
        let update = UIContextualAction(style: .normal, title: "Update") { (action, UIView, _) in
            self.updateItem(listItem: self.shoppingItems[indexPath.row])
            tableView.reloadData()
        }
        
        update.backgroundColor = UIColor.init(displayP3Red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [update])
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Bag \(section + 1)"
    }

}
