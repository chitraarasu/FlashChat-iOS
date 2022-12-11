//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = [
    ]
    
    let db = Firestore.firestore()
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
      try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessage();
    }
    
    func loadMessage(){
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            if let e = error {
                print("error \(e)")
            } else {
                self.messages = []
                if let snapDocument = querySnapshot?.documents {
                    for doc in snapDocument  {
                        let data  = doc.data()
                        if let message = data[K.FStore.bodyField], let sender = data[K.FStore.senderField] {
                            let messageModel = Message(sender: sender as! String, body: message as! String)
                            self.messages.append(messageModel)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let message = messageTextfield.text, let sender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: sender,
                K.FStore.bodyField: message,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
        } else {
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
        }
        
        return cell
    }
    
}
