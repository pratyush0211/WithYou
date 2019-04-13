//
//  ViewController.swift
//  With You
//
//  Created by techjini on 12/04/19.
//  Copyright © 2019 techjini. All rights reserved.
//


import UIKit
import CoreData

class WYTodoListViewController: UITableViewController {
    
    var itemArray: [NSManagedObject] = []
    var pullToRefresh = UIRefreshControl()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedContext: NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpView()
        setUpPullToRefresh()
        fetchFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpNavigationBar() {
        self.title = "Todo List"
        self.navigationController?.navigationBar.barTintColor = UIColor.inchWormGreen
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func setUpView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.managedContext = appDelegate?.persistentContainer.viewContext
    }
    
    func setUpPullToRefresh() {
        pullToRefresh.attributedTitle = NSAttributedString(string: "Syncing your todo list..")
        pullToRefresh.addTarget(self, action: #selector(pullToRefreshAction(_:)), for: .valueChanged)
        self.tableView.addSubview(pullToRefresh)
    }
    
    func showAddItemAlertView() {
        let alert = UIAlertController(title: "Add Item", message: "Add a goal/task/note for today", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let inputText = alert.textFields?.first?.text, !inputText.isEmpty {
                self.saveToCoreData(item: inputText)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        alert.view.tintColor = UIColor.persianBlue
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func pullToRefreshAction(_ sender: UIRefreshControl) {
        self.fetchFromCoreData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let item  = itemArray[indexPath.row].value(forKey: "itemName") as? String {
            cell.textLabel?.text = item
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") { (action, indexPath) in
            self.managedContext.delete(self.itemArray[indexPath.row])
        }
        let edit = UITableViewRowAction.init(style: .destructive, title: "Edit") { (action, indexPath) in
            self.presentEditAlert(index: indexPath)
        }
        delete.backgroundColor = UIColor.persianBlue
        edit.backgroundColor = UIColor.cyberYellow
        return [delete, edit]
    }
    
    func presentEditAlert(index: IndexPath) {
        let alert = UIAlertController(title: "Edit Item", message: "Change the item name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            if let inputText = alert.textFields?.first?.text, !inputText.isEmpty {
                let item = self.itemArray[index.row]
                item.setValue(inputText, forKey: "itemName")
                do {
                    try self.managedContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        alert.view.tintColor = UIColor.persianBlue
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addItemButtonTapAction(_ sender: Any) {
        self.showAddItemAlertView()
    }
}

extension WYTodoListViewController {
    
    func saveToCoreData(item: String) {
        if let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: managedContext) {
            let todoList = NSManagedObject(entity: entity, insertInto: managedContext)
            todoList.setValue(item, forKey: "itemName")
            do {
                try self.managedContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Something went wrong")
        }
    }
    
    func fetchFromCoreData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoList")
        do {
            itemArray = try self.managedContext.fetch(fetchRequest)
            self.tableView.reloadData()
            if self.pullToRefresh.isRefreshing {
                self.pullToRefresh.endRefreshing()
            }
        } catch {
            print (error.localizedDescription)
        }
    }
}

