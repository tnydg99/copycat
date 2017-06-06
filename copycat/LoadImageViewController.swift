//
//  LoadImageViewController.swift
//  copycat
//
//  Created by Austin Tucker on 6/2/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseAuth
import Crashlytics
import SafariServices

class LoadImageViewController: UIViewController, SFSafariViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let loadImageButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Load Image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(loadImageButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Load Image"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed(_:)))
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(loadImageButton)
        setupLoadImageButton()
    }
    
    func logoutButtonPressed(_ sender: UIBarButtonItem) {
        if Auth.auth().currentUser?.uid != nil {
            do {
                try Auth.auth().signOut()
                self.navigationController?.popViewController(animated: true)
            } catch {
                print(error)
            }
        }
    }
    
    func setupLoadImageButton() {
        loadImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadImageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loadImageButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
    }
    
    func loadImageButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://images.google.com/") else {
            return
        }
        let imageAlert = UIAlertController(title: "Load Image", message: "Please select a location to load images from.", preferredStyle: .actionSheet)
        let safariAction = UIAlertAction(title: "Safari", style: .default, handler: {
        _ in
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true, completion: nil)
        })
        let photosAction = UIAlertAction(title: "Photos", style: .default, handler: {
        _ in
            let imagePicker = UIImagePickerController(rootViewController: ImagePickerViewController())
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                imagePicker.mediaTypes = mediaTypes
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("error loading photo library.")
            }
        })
        
        imageAlert.addAction(safariAction)
        imageAlert.addAction(photosAction)
        present(imageAlert, animated: true, completion: nil)
    }
    
    //MARK SFSafariViewControllerDelegate
    
//    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
//        
//    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.pushViewController(CopyCatViewController(), animated: true)
    }
    
    //MARK ImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.pushViewController(CopyCatViewController(), animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }

}
