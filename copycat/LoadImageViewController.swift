//
//  LoadImageViewController.swift
//  copycat
//
//  Created by Austin Tucker on 6/2/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import Photos
import Crashlytics
import SafariServices

class LoadImageViewController: UIViewController, UINavigationControllerDelegate {
    
    let viewModel = ViewModel()
    
    //MARK view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Load Image"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed(_:)))
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(loadImageButton)
        view.addSubview(previousImageButton)
        setupLoadImageButton()
        setupPreviousImageButton()
        displayWelcomeMessage()
    }
    
    //MARK Buttons, constraints and selector functions
    
    let loadImageButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Load New Image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(loadImageButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    let previousImageButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Select Previous Image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(previousImageButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    func setupLoadImageButton() {
        loadImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadImageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        loadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loadImageButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
    }
    
    func setupPreviousImageButton() {
        previousImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        previousImageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        previousImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        previousImageButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
    }
    
    func logoutButtonPressed(_ sender: UIBarButtonItem) {
        if viewModel.firebaseLogsOut() {
            self.navigationController?.popViewController(animated: true)
        }
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
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
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
    
    func previousImageButtonPressed(_ sender: UIButton) {
        self.navigationController?.pushViewController(ImagesCollectionViewController(), animated: true)
    }
    
    func displayWelcomeMessage() {
        if viewModel.firebaseFetchUsername() != "" {
            let alert = UIAlertController(title: "Login Successful", message: "Welcome back, \(viewModel.firebaseFetchUsername())).", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK SFSafariViewControllerDelegate
extension LoadImageViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.pushViewController(CopyCatViewController(), animated: true)
    }
}

//MARK UIImagePickerControllerDelegate
extension LoadImageViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.navigationController?.pushViewController(CopyCatViewController(), animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        viewModel.storeSelectedImageFromPicker(info: info)
        picker.popViewController(animated: true)
    }
}
