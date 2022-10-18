//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Doolot on 17/10/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class TasksViewController: UIViewController {
    
    var user: User!
    var ref: DatabaseReference!
    var arrayTask = Array<Task>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value) { [weak self] (snapshot) in
            var tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                tasks.append(task)
            }
            self?.arrayTask = tasks
            self?.tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let allertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        allertController.addTextField()
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            
            guard let textField = allertController.textFields?.first, textField.text != "" else { return }
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(["title": task.title, "userId": task.userId, "completed": task.completed])
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        allertController.addAction(save)
        allertController.addAction(cancel)
        
        present(allertController, animated: true)
    }
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        // Мы должны выйти из данного профиля
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        // Затем Экран мы отпускаем
        dismiss(animated: true)
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTask.count
    }
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        let task = arrayTask[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: isCompleted)

        return cell
    }
    // Базовый функционал для редоктирования наших ячеек
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = arrayTask[indexPath.row]
            task.ref?.removeValue()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = arrayTask[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])

    }
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
}
