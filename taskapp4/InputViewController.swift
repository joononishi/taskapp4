import UIKit
import RealmSwift

//UITextFieldDelegateプロトコルを用いてtitleTextFieldが変更された際に呼び出されるメソッドを追加
class InputViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
      var task: Task!  // TaskはあらかじめRealmで定義されているオブジェクトを想定しています。
      
    var tasksByCategory: [String: [String]] = [
        "音楽制作": ["作編曲", "リハーサル", "レコーディング", "ミキシング", "スコア"],
        "パフォーマンス": ["ライブ企画", "チケット販売", "スケジュール管理", "セットリスト作り", "機材"],
        "マーケティング": ["SNS", "ニュースレター", "ウェブサイト", "広告", "イベント"],
        "研究": ["音楽分析", "テクノロジー", "SNS分析", "個人レッスン", "練習法"],
        "自己管理": ["機材整理", "メール整理", "経費", "ネットワーキング", "健康"]
    ]
      
      override func viewDidLoad() {
          super.viewDidLoad()

          // キーボードを閉じるジェスチャー
          let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
          self.view.addGestureRecognizer(tapGesture)

          // UITextFieldDelegateの設定
          titleTextField.delegate = self

          // 既存のタスクデータをUIに反映
          titleTextField.text = task.title
          categoryTextField.text = task.category // カテゴリも反映
          contentsTextView.text = task.contents
          datePicker.date = task.date
      }
      
      // 画面が閉じる前にデータをRealmに保存
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)

          try! realm.write {
              self.task.title = self.titleTextField.text!
              self.task.contents = self.contentsTextView.text
              self.task.date = self.datePicker.date
              self.task.category = self.categoryTextField.text! // カテゴリも保存
              self.realm.add(self.task, update: .modified)
          }
          
          // 通知設定のコードなどがあれば、ここに追記
      }
      
      // キーボードを閉じるメソッド
      @objc func dismissKeyboard() {
          view.endEditing(true)
      }
      
      // タスク名が変更されたときにカテゴリも自動で設定するメソッド
      func textFieldDidChangeSelection(_ textField: UITextField) {
          if textField == titleTextField {
              for (category, tasks) in tasksByCategory {
                  if tasks.contains(textField.text!) {
                      categoryTextField.text = category
                      break
                  }
              }
          }
      }
  }
