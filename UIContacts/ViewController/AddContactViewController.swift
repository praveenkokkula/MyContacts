//
//  AddContactViewController.swift
//  UIContacts
//
//  Created by Praveen on 28/11/18.
//

import UIKit
import CoreData
class AddContactViewController: UIViewController,UINavigationControllerDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var contactImageView: UIImageView!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var mobileNumberField: UITextField!
    @IBOutlet var addContactBtn: UIButton!
    @IBOutlet var countryBtn: UIButton!
    @IBOutlet var mandateField: UILabel!
    var activeTextfield: UITextField?
    var didImageSet = false
    var didCountrySelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        mobileNumberField.delegate = self
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
        contactImageView.clipsToBounds = true
        contactImageView.layer.borderWidth = 1.0
        contactImageView.layer.masksToBounds = true
        contactImageView.image = UIImage(named: "contact")
        addContactBtn.layer.cornerRadius = 6.0
        addContactBtn.clipsToBounds = true
        addContactBtn.isEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        contactImageView.isUserInteractionEnabled = true
        contactImageView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addContactBtnAction(_ sender: Any) {
        guard let appdelegateContext = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appdelegateContext.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: ContactEntity, in: managedContext)
        let contact = NSManagedObject(entity: entity!, insertInto: managedContext)
        contact.setValue(firstNameField.text, forKey: FirstName)
        contact.setValue(lastNameField.text, forKey: LastName)
        contact.setValue(emailField.text, forKey: Email)
        contact.setValue(mobileNumberField.text, forKey:MobileNumber)
        contact.setValue(countryBtn.title(for: .normal), forKey:Country)
        if let contactImage = contactImageView.image {
            if let data = contactImage.pngRepresentationData {
                contact.setValue(data, forKey: ContactImage)
            } else if let data = contactImage.jpegRepresentationData {
                contact.setValue(data, forKey: ContactImage)
            }
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error in saving the contacts to Storage\(error.localizedDescription)")
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    @objc func keyboardWillShow(notification: Notification) {
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeTextfield != nil
        {
            if (!aRect.contains(activeTextfield!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeTextfield!.frame, animated: true)
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
      //  self.scrollView.isScrollEnabled = false
    }
    @objc func selectImage() {
        let actionSheet = UIAlertController(title: "Choose the Photo from", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (cameraAction) in
            if Platform.isSimulator{
                self.showSimulatorAlert()
            } else {
            let pickerFromCameraController = UIImagePickerController.init()
            pickerFromCameraController.delegate = self
            pickerFromCameraController.allowsEditing = true
            pickerFromCameraController.sourceType = UIImagePickerControllerSourceType.camera
            self.present(pickerFromCameraController, animated: true, completion: nil)
                }
            }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (galleryAction) in
            let pickerFromGalleryController = UIImagePickerController.init()
            pickerFromGalleryController.delegate = self
            pickerFromGalleryController.allowsEditing = true
            pickerFromGalleryController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(pickerFromGalleryController, animated: true, completion: nil)
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    func  showSimulatorAlert()  {
        let alert = UIAlertController(title: "Running in Simulator?", message: "Simulator won't support for Camera Action. Please select Gallery option", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func countryBtnAction(_ sender: Any) {
        let storyBorad = UIStoryboard.init(name: "Main", bundle: nil)
        let countryViewController = storyBorad.instantiateViewController(withIdentifier: "CountryViewController") as? CountryViewController
        countryViewController?.delegate = self
        guard let countryVc = countryViewController else {
            return
        }
        self.present(countryVc, animated: true, completion: nil)
    }
    func checkForTheValidations() {
        if firstNameField.text == NameValidator || lastNameField.text == NameValidator || emailField.text == EmailValidator || mobileNumberField.text == MobileNumberValidator || firstNameField.text == "" || lastNameField.text == "" || emailField.text == "" || mobileNumberField.text == "" {
            addContactBtn.isEnabled = false
        } else if !(didImageSet && didCountrySelected) {
            addContactBtn.isEnabled = false
        } else {
            addContactBtn.isEnabled = true
            mandateField.isHidden = true
        }
    }
}
extension AddContactViewController: CountryProtocol {
    func getCountryName(countryName: String) {
        guard countryName != "" else {
            DispatchQueue.main.async() {
                self.countryBtn.setTitle(CountryBtnName, for: .normal)
            }
            return
        }
        DispatchQueue.main.async() {
           self.countryBtn.setTitle(countryName, for: .normal)
        }
        didCountrySelected = true
        self.checkForTheValidations()
    }
}
extension AddContactViewController : UIImagePickerControllerDelegate {
    @objc  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerEditedImage]
        DispatchQueue.main.async {
            self.contactImageView.image = selectedImage as? UIImage
            self.didImageSet = true
            self.checkForTheValidations()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
extension UIImage {
    var pngRepresentationData: Data? {
        return UIImagePNGRepresentation(self)
    }
    var jpegRepresentationData: Data? {
        return UIImageJPEGRepresentation(self, 1.0)
    }
}
extension AddContactViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
        if textField.text == NameValidator || textField.text == EmailValidator || textField.text == MobileNumberValidator {
            textField.text = " "
        }
        activeTextfield = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
        if textField.tag == 100 || textField.tag == 101 {
            if let textEntered = textField.text  {
            if  validateUsername(str: textEntered) {
                textField.text = textEntered.capitalizingFirstLetter()
            } else  {
                textField.text = NameValidator
            }
        }
        } else if(textField.tag == 102) {
            if let textEntered = textField.text  {
                if textEntered.isEmail {
                } else  {
                    textField.text = EmailValidator
                }
            }
        activeTextfield = nil
        } else if (textField.tag == 103) {
            if let textEntered = textField.text  {
            if textEntered.count >= 10 && textEntered.count <= 15 {
                
            } else {
               textField.text = MobileNumberValidator
            }
        }
    }
        self.checkForTheValidations()
}
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 103 {
        let aSet = NSCharacterSet(charactersIn:"+0123456789-").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
        } else if textField.tag == 100 || textField.tag == 101 {
            let aSet = NSCharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        } else {
            return true
            }
    }
}
extension AddContactViewController {
    func validateUsername(str: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z ]{3,18}$", options: .caseInsensitive)
            if regex.matches(in: str, options: [], range: NSMakeRange(0, str.count)).count > 0 {
                return true
            }
        }
        catch {}
        return false
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
}
extension AddContactViewController {
    func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self,action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
