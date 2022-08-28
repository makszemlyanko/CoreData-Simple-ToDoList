//
//  ViewController.swift
//  CoreData_SimpleToDoList
//
//  Created by Maks Kokos on 28.08.2022.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Getting context
        let context = getContext()
        // Getting data from DataCore
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            self.tasks = tasks.reversed()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { action in
            let tf = alertController.textFields?.first
            if let newTaskTitle = tf?.text {
                self.saveTaskTitle(withTitle: newTaskTitle)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in }
        
        alertController.addTextField { (_) in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Save task in CoreData
    private func saveTaskTitle(withTitle title: String) {
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            self.tasks.insert(taskObject, at: 0)
            self.tableView.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            // Delete from DataCore
            let context = getContext()
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            if var objects = try? context.fetch(fetchRequest) {
                objects.reverse()
                let task = objects[indexPath.row]
                context.delete(task)
                
                do {
                    try context.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}
