import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!  // Storyboard上に追加したUITextFieldと接続
    
    let realm = try! Realm()
       var taskArray: Results<Task>!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           tableView.delegate = self
           tableView.dataSource = self
           searchTextField.delegate = self
           
           taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
           
           searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
           
           if taskArray.isEmpty {
               presetTasks()
           }
       }
       
       @objc func textFieldDidChange(_ textField: UITextField) {
           if let searchText = textField.text, !searchText.isEmpty {
               taskArray = realm.objects(Task.self).filter("category CONTAINS[c] %@", searchText).sorted(byKeyPath: "date", ascending: true)
           } else {
               taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
           }
           tableView.reloadData()
       }
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let inputViewController = segue.destination as? InputViewController {
               if segue.identifier == "cellSegue" {
                   if let indexPath = self.tableView.indexPathForSelectedRow {
                       inputViewController.task = taskArray[indexPath.row]
                   }
               } else {
                   inputViewController.task = Task()
               }
           }
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: "cellSegue",sender: nil)
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return taskArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           let task = taskArray[indexPath.row]
           cell.textLabel?.text = task.title
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd HH:mm"
           let dateString: String = formatter.string(from: task.date)
           cell.detailTextLabel?.text = dateString
           return cell
       }
       
       func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return .delete
       }
       
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               let task = self.taskArray[indexPath.row]
               let center = UNUserNotificationCenter.current()
               center.removePendingNotificationRequests(withIdentifiers: [String(describing: task.id)])
               try! realm.write {
                   self.realm.delete(task)
                   tableView.deleteRows(at: [indexPath], with: .fade)
               }
           }
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           tableView.reloadData()
       }
       
    private func presetTasks() {
        let categories = ["音楽制作", "パフォーマンス", "マーケティング", "研究", "自己管理"]
        let tasksByCategory: [String: [String]] = [
            "音楽制作": ["作編曲", "リハーサル", "レコーディング", "ミキシング", "スコア"],
            "パフォーマンス": ["ライブ企画", "チケット販売", "スケジュール管理", "セットリスト作り", "機材"],
            "マーケティング": ["SNS", "ニュースレター", "ウェブサイト", "広告", "イベント"],
            "研究": ["音楽分析", "テクノロジー", "SNS分析", "個人レッスン", "練習法"],
            "自己管理": ["機材整理", "メール整理", "経費", "ネットワーキング", "健康"]
        ]

           let date = Date()
           
           try! realm.write {
               for (category, tasks) in tasksByCategory {
                   for task in tasks {
                       let newTask = Task()
                       newTask.title = task
                       newTask.category = category
                       newTask.date = date
                       realm.add(newTask)
                   }
               }
           }
       }
   
    }
