//
//  FirebaseModel.swift
//  copycat
//
//  Created by Austin Tucker on 6/6/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FirebaseModel: NSObject {
    static var sharedInstance = FirebaseModel()
    private override init() { }
    var currentImage: Data?
    var storedImages:  [Data] = []
    
    func fetchImagesFromFirebase() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("no current user active")
            return
        }
        let storedImagesReference = Database.database().reference().child("users").child(currentUserUID).child("storedImages")
        storedImagesReference.observeSingleEvent(of: .value, with: {
            (snapshot) in
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let imageName = childSnapshot.key
                let storage = Storage.storage().reference()
                let imageReference = storage.child(imageName)
                imageReference.getData(maxSize: 5 * 1024 * 1024, completion: { data, error in
                    if error != nil {
                        print(error ?? "error")
                    } else {
                        self.storedImages.append(data!)
                    }
                })
            }
        })
    }
    
    func storeImageToFirebase(_ pngImage: Data) {
        let uuid = UUID()
        let imageName = "\(uuid.uuidString).png"
        let storage = Storage.storage().reference().child(imageName)
        storage.putData(pngImage, metadata: nil, completion: {
            (metadata, error) in
            if error != nil {
                print(error ?? "error")
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            let reference: DatabaseReference = Database.database().reference()
            let imageReference = reference.child("users").child(uid).child("storedImages")
            
            guard let values = ["\(uuid.uuidString)" : metadata?.downloadURL()?.absoluteString] as? [String: String] else {
                return
            }
            imageReference.updateChildValues(values, withCompletionBlock: {
                (err, reference) in
                if err != nil {
                    print(err ?? "error")
                    return
                }
            })
        })
    }    
}
