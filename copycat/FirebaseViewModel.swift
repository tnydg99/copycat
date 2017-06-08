//
//  FirebaseViewModel.swift
//  copycat
//
//  Created by Austin Tucker on 6/7/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics

class FirebaseViewModel: FirebaseFetchDelegate {
    let storedImages: [Data] = {
        return FirebaseModel.sharedInstance.storedImages
    }()
    
    var login: Bool?
    var username: String = ""
    
    func firebaseRegisterUser(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if error != nil {
                print(error ?? "error")
                self.login = false
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            let reference: DatabaseReference = Database.database().reference()
            let usersReference = reference.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: {
                (err, reference) in
                if err != nil {
                    print(err ?? "error")
                    self.login = false
                    return
                }
                Crashlytics.sharedInstance().setUserEmail(email)
                self.login = true
            })
        })
    }
    
    func firebaseLoginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            if error != nil {
                print(error ?? "error")
                self.login = false
                return
            }
            Crashlytics.sharedInstance().setUserEmail(email)
            self.login = true
        })
    }
    
    func firebaseLogoutUser() {
        if Auth.auth().currentUser?.uid != nil {
            do {
                try Auth.auth().signOut()
                self.login = false
            } catch {
                print(error)
                self.login = true
            }
        }
    }
    
    func firebaseFetchUsername() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no firebase user logged in")
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                self.username = dictionary["name"] as! String
            }
        }, withCancel: nil)
    }

    func firebaseStoreImage(info: [String : Any]) {
        DispatchQueue.global().async {
            var image: UIImage?
            if info.keys.contains(UIImagePickerControllerEditedImage) {
                image = info[UIImagePickerControllerEditedImage] as? UIImage
                FirebaseModel.sharedInstance.currentImage = UIImagePNGRepresentation(image!)
            } else {
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
                FirebaseModel.sharedInstance.currentImage = UIImagePNGRepresentation(image!)
            }
            FirebaseModel.sharedInstance.storeImageToFirebase(FirebaseModel.sharedInstance.currentImage!)
        }
    }
    
    func firebaseGetData() {
        FirebaseModel.sharedInstance.fetchImagesFromFirebase()
    }
}
