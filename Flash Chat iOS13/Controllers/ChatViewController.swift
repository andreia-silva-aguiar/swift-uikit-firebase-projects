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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    //create the reference
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        // 1. Configura a TableView
         //   tableView.dataSource = self
        //do not forgot to add the identifier to the UITableViewCell
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)

            
        loadMessage()
            
        
    }
    
    func loadMessage() {
        
        //db.collection(K.FStore.collectionName).getDocuments { (querySnapshot, error) in
        //replace getDocuments for addSnapshotListener, so every time when has a new message, the screen will updade automatic
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
                
            } else {
                if let snapshotDocuments = querySnapshot?.documents{
                    
                    for doc in snapshotDocuments { //each doc
                        let data = doc.data()
                        //because the dicionary can be optional Any type, we have conditionally downcast to cast it intpo a string
                        if let sender = data[K.FStore.senderField] as? String , let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: sender, body: messageBody)
                            //add the message inside the message array
                            self.messages.append(newMessage)
                            

                        }
                        print("Current data: \(data)")
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        //"?" if not nill
        if let messageBody = messageTextfield.text , let messageSender = Auth.auth().currentUser?.email {
            //make sure select the "addDocument" that has completion
            db.collection(K.FStore.collectionName).addDocument(data:
                     [K.FStore.senderField: messageSender,
                      K.FStore.bodyField: messageBody,
                      K.FStore.dateField: Date().timeIntervalSince1970
                     ]) { (error) in
                            if let error {
                                print ("There was an issue data to firestore")
                            } else {
                                print ("Successfully saved data")
                            }
                        }
        }
        
    }
    

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    

}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text =  messages[indexPath.row].body
        //delete the line inside the screen
        return cell
    }
    
    
}


    
