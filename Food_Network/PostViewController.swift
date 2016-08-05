//
//  PostViewController.swift
//  Food_Network
//
//  Created by Kenya Gordon on 7/11/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import Parse
import TesseractOCR

class PostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, G8TesseractDelegate{
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentsField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var imagePickerBoolean: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the UITextView to contain the placeholder text and set it to a light gray color to look like placeholder text.
        ingredientsTextView.text = "Input ingredients as a comma seperated list. ex: garlic,onions..."
        ingredientsTextView.textColor = UIColor.lightGrayColor()
        instructionsTextView.text = "1. Add instructions"
        instructionsTextView.textColor = UIColor.lightGrayColor()
        ingredientsTextView.delegate = self
        instructionsTextView.delegate = self
        //tapGesture
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyBoard))
        self.view!.addGestureRecognizer(tapGesture)
        
        //Below I am setting the content size so the scrollView knows how far to scroll inside of the CGSize I am getting the width (the size of the frame of the scrollView) and the height which is obtained by getting the origin of the last element (commentsField) and adding its height to get how far down the scrollView should go.
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: recipeImage.frame.origin.y + recipeImage.frame.height + 35)
        // Do any additional setup after loading the view.
        
        //to populate food api recipes
        //FoodApi.populate("broccoli")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if imagePickerBoolean == true {
            //imagepicker for take photo or upload photo
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                recipeImage.contentMode = .ScaleAspectFit
                recipeImage.image = pickedImage
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            //image picker for taking picture of instructons
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            // Dismiss UIImagePickerController to go back to your original view controller
            dismissViewControllerAnimated(true, completion: nil)
            self.performImageRecognition(editedImage)
        }
    }
    
    @IBAction func uploadImageButtonTapped(sender: UIButton) {
        imagePickerBoolean = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonTapped(sender: AnyObject) {
        imagePickerBoolean = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButton(sender: UIButton) {
        if let image = recipeImage.image{
            let resizedImage = Recipe.resize(image, newSize: CGSize(width:240, height:128))
            let ingredients = ingredientsTextView.text.lowercaseString
            let ingredientsArray = ingredients.componentsSeparatedByString(",")
            Recipe.postRecipe(resizedImage, withTitle: titleField.text, withIngredients: ingredientsArray, withInstructions: instructionsTextView.text, withComments: commentsField.text) { (success: Bool, error: NSError?) in
                if success {
                    
                    //declare and initialize UIAlertController
                    let alertController = UIAlertController(title: "Congratulations", message: "Your recipe was posted successfully", preferredStyle: .Alert)
                    
                    // give UIAlertController an action, which has an ok button,that cancels out the popup
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    
                    //presents UIAlertController on the screen when post is pressed
                    self.presentViewController(alertController, animated: true, completion: nil)
                    print("Posted new recipe!")
                    self.ingredientsTextView.text = "Input ingredients as a comma seperated list. ex: garlic,onions..."
                    self.ingredientsTextView.textColor = UIColor.lightGrayColor()
                    self.instructionsTextView.text = "1. Add instructions"
                    self.instructionsTextView.textColor = UIColor.lightGrayColor()
                    self.commentsField.placeholder = "comment"
                    self.commentsField.text = ""
                    self.titleField.placeholder = "Title"
                    self.titleField.text = ""
                    self.recipeImage.image = nil
                } else {
                    print(error?.localizedDescription)
                }
            }
            
        }
    }
    
    // when the user begins to edit the text view, if the text view contains a placeholder clear the placeholder text and set the text color to black in order to accommodate the user's entry.
    func textViewDidBeginEditing(textView: UITextView) {
        if ingredientsTextView == textView{
            if ingredientsTextView.textColor == UIColor.lightGrayColor(){
                ingredientsTextView.text = ""
                ingredientsTextView.textColor = UIColor.blackColor()
            }
        }
        else if instructionsTextView == textView{
            if instructionsTextView.textColor == UIColor.lightGrayColor(){
                instructionsTextView.text = ""
                instructionsTextView.textColor = UIColor.blackColor()
            }
        }
    }
    
    //when the user finishes editing the text view, if the text view is empty, reset placeholder text and set its color to light gray.
    func textViewDidEndEditing(textView: UITextView) {
        if ingredientsTextView.text.isEmpty{
            ingredientsTextView.text = "Input ingredients as a comma seperated list. ex: garlic,onions..."
            ingredientsTextView.textColor = UIColor.lightGrayColor()
        }
        else if instructionsTextView.text.isEmpty{
            instructionsTextView.text = "1. Add instructions"
            instructionsTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    @IBAction func takePhotoForInstructions(sender: AnyObject) {
        imagePickerBoolean = false
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func performImageRecognition(image: UIImage) {
        //turn image taken in takePhotoForInstructions into text that will go into instructionsTextView
        var tesseract = G8Tesseract(language: "eng")
        tesseract.delegate = self;
        //tesseract.setVariableValue("01234567890", forKey: "tessedit_char_whitelist");
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite();
        tesseract.recognize();
        instructionsTextView.text = ""
        instructionsTextView.textColor = UIColor.blackColor()
        instructionsTextView.text = tesseract.recognizedText
    }
    
    //function to hideKeyboard
    func hideKeyBoard() {
        titleField.resignFirstResponder()
        ingredientsTextView.resignFirstResponder()
        instructionsTextView.resignFirstResponder()
        commentsField.resignFirstResponder()
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}