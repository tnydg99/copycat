//
//  ViewModel.swift
//  copycat
//
//  Created by Austin Tucker on 6/7/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics

class ViewModel: FirebaseFetchDelegate {
    let storedImages: [Data] = {
        return FirebaseModel.sharedInstance.storedImages
    }()
    
    func firebaseRegisters(email: String, password: String, name: String) -> Bool {
        var registration: Bool = false
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if error != nil {
                print(error ?? "error")
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
                    return
                }
                Crashlytics.sharedInstance().setUserEmail(email)
                registration = true
            })
        })
        return registration
    }
    
    func firebaseLogsIn(email: String, password: String) -> Bool {
        var login: Bool = false
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            if error != nil {
                print(error ?? "error")
                return
            }
            Crashlytics.sharedInstance().setUserEmail(email)
            login = true
        })
        return login
    }
    
    func firebaseLogsOut() -> Bool {
        var logout: Bool = true
        if Auth.auth().currentUser?.uid != nil {
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
                logout = false
            }
        }
        return logout
    }
    
    func firebaseFetchUsername() -> String {
        var name: String = ""
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no firebase user logged in")
            return name
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                name = dictionary["name"] as! String
            }
        }, withCancel: nil)
        return name
    }

    func storeSelectedImageFromPicker(info: [String : Any]) {
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
    
    func getDataFromFirebase() {
        FirebaseModel.sharedInstance.fetchImagesFromFirebase()
    }
}
