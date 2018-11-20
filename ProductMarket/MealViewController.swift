//
//  ViewController.swift
//  ProductMarket
//
//  Created by Aday on 15/11/18.
//  Copyright © 2018 sf. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate,
                        UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: properties
    @IBOutlet weak var mealNameInput: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by "mealTableViewController" in 'prepare(for:sender:) or constructed as part of adding a new meal
     */
    var meal: Meal?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mealNameInput.delegate = self
        
        //Set up views if editing an existing meal
        if let meal = meal {
            navigationItem.title = meal.name
            mealNameInput.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        //Enable the Save button only if the text field has a valid Meal name
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Dismiss the picker if the user cancels
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)");
            
        }
        
        //Set photoImageView to display the selected image
        photoImageView.image = selectedImage;
        
        //Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        //Depending on style of presentation (modal or push), this view controller needs to be dismissed in two different ways
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated:true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
        
    }
    
    
    //This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        //Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed. cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = mealNameInput.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        //Set the meal to be passed to MealTableViewController after the unwind segue
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    //MARK: actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        //Hide keyboard if the user tapped before trying to select an image
        mealNameInput.resignFirstResponder();
        
        //ImagePickerController is a view controller that lets a user pick media from ther photo library
        let imagePickerController = UIImagePickerController();
        
        //Only allow photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary;
        
        //Make sure ViewController is notified when theuser picks an image
        imagePickerController.delegate = self;
        
        present(imagePickerController, animated: true, completion: nil);
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        //Disable the Save Button if the text field is empty 
        let text = mealNameInput.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

}

