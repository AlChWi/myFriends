//
//  EditFriendInfoTableViewController.swift
//  My Friends
//
//  Created by Алексей Перов on 27.09.2019.
//  Copyright © 2019 Алексей Перов. All rights reserved.
//

import UIKit
import Kingfisher

class EditFriendInfoTableViewController: UITableViewController {
    
    //MARK: - OUTLETS -
    @IBOutlet weak private var doneButton: UIBarButtonItem!
    @IBOutlet weak private var userEmailTextField: UITextField!
    @IBOutlet weak private var userPhoneTextField: UITextField!
    @IBOutlet weak private var userSurnameTextField: UITextField!
    @IBOutlet weak private var userNameTextField: UITextField!
    @IBOutlet weak private var userPhotoImageView: UIImageView!
    
    //MARK: - PRIVATE VARIABLES -
    private var initialInfo: UserEntity?
    private var finalInfo: User?

    //MARK: - LIFE CYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()

        enableTapGestureFor(imageView: userPhotoImageView)
        setUserImageFor(imageView: userPhotoImageView)
        fillTextFieldsInfo()
    }
    
    //MARK: - CONFIGURE -
    func configure(forUser user: UserEntity) {
        self.initialInfo = user
        self.finalInfo = User(entity: user)
    }
    
    //MARK: - PRIVATE METHODS -
    private func enableTapGestureFor(imageView: UIImageView) {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        imageView.addGestureRecognizer(imageTapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    private func setUserImageFor(imageView: UIImageView) {
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        if let customImage = initialInfo?.image {
            imageView.image = UIImage(data: customImage)
        } else {
            imageView.kf.setImage(with: initialInfo?.imageOnServer)
        }
    }
    
    private func fillTextFieldsInfo() {
        userNameTextField.text = initialInfo?.firstName
        userSurnameTextField.text = initialInfo?.lastName
        userPhoneTextField.text = initialInfo?.phone
        userEmailTextField.text = initialInfo?.email
    }
    
    @objc private func openImagePicker(_ sender: UITapGestureRecognizer) {
        let alertSheet = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        let chooseFromPhotoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) { (UIAlertAction) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        alertSheet.addAction(chooseFromPhotoLibraryAction)
        
        let removePhotoAction = UIAlertAction(title: "Remove custom photo", style: .destructive) { (UIAlertAction) in
            self.finalInfo?.image = nil
            self.userPhotoImageView.kf.setImage(with: self.finalInfo?.imageOnServer)
        }
        alertSheet.addAction(removePhotoAction)
        if finalInfo?.image == nil {
            removePhotoAction.isEnabled = false
        } else {
            removePhotoAction.isEnabled = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            
        }
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true)
    }
 
    @IBAction private func userNameTextFieldDidChange(_ sender: UITextField) {
        finalInfo?.firstName = sender.text ?? ""
        if sender.text?.isEmpty ?? true {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    @IBAction private func userSurnameTextFieldDidChange(_ sender: UITextField) {
        finalInfo?.lastName = sender.text ?? ""
        if sender.text?.isEmpty ?? true {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    @IBAction private func userPhoneTextFieldDidChange(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            if text.isValidPhoneNumber(), text.count < 20 && text.count > 3 {
                finalInfo?.phone = text
                doneButton.isEnabled = true
                userPhoneTextField.layer.borderWidth = 0
            } else {
                userPhoneTextField.layer.borderColor = UIColor.red.cgColor
                userPhoneTextField.layer.borderWidth = 1
                userPhoneTextField.layer.cornerRadius = 8
                userPhoneTextField.layer.masksToBounds = true
                doneButton.isEnabled = false
            }
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction private func userEmailTextFieldDidChange(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            if text.isValidEmail(), text.count < 200 && text.count > 3 {
                finalInfo?.email = text
                doneButton.isEnabled = true
                userEmailTextField.layer.borderWidth = 0
            } else {
                userEmailTextField.layer.borderColor = UIColor.red.cgColor
                userEmailTextField.layer.borderWidth = 1
                userEmailTextField.layer.cornerRadius = 8
                userEmailTextField.layer.masksToBounds = true
                doneButton.isEnabled = false
            }
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIBarButtonItem) {
        initialInfo?.firstName = finalInfo?.firstName
        initialInfo?.lastName = finalInfo?.lastName
        initialInfo?.email = finalInfo?.email
        initialInfo?.phone = finalInfo?.phone
        initialInfo?.image = finalInfo?.image
        do {
            try DataService.shared.persistentContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate -
extension EditFriendInfoTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let pngData = image?.pngData() else { return }
        finalInfo?.image = pngData
        userPhotoImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
}
