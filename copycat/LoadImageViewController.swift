//
//  LoadImageViewController.swift
//  copycat
//
//  Created by Austin Tucker on 6/2/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit
import SafariServices
import Photos

class LoadImageViewController: UIViewController, SFSafariViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadImageButtonPressed(_ sender: UIButton) {
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
            guard let imagePicker = self.storyboard?.instantiateViewController(withIdentifier: "UIImagePickerController") as? UIImagePickerController else {
                return
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK SFSafariViewControllerDelegate
    
//    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
//        
//    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        performSegue(withIdentifier: "toCopycat", sender: nil)
    }
    
    //MARK ImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        performSegue(withIdentifier: "toCopycat", sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    }

}
