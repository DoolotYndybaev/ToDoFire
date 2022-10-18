//
//  Tasks.swift
//  ToDoFire
//
//  Created by Doolot on 17/10/22.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let userId: String
    // ref - это ссылка
    let ref: DatabaseReference?
    var completed: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String:AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
}
