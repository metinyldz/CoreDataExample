//
//  ListItemTableViewModel.swift
//  Shopping List
//
//  Created by Metin Yıldız on 10.12.2023.
//

import Foundation
import UIKit
import CoreData

protocol ListItemTableViewModelProtocol: AnyObject {
    func tableViewReloadData()
    func presentAlert(_ view: UIAlertController)
}

class ListItemTableViewModel {
    weak var delegate: ListItemTableViewModelProtocol?
    
    var shoppingItems = [String]()
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
            delegate?.tableViewReloadData()
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
        delegate?.presentAlert(popup)
    }
    
    func addTapped() {
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
        delegate?.presentAlert(popup)
    }
}
