//
//  ForgotPasswordViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 2/28/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Material
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {
    let minPasswordLength = 8
    var recoveryPassword: String? = "0000"
    var userEmail: String?

    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var confirmationCodeTextField: TextField?
    @IBOutlet weak var newPasswordTextField: TextField?
    @IBOutlet weak var confirmPasswordTextField: TextField?
    
    @IBOutlet var recoveryPasswordTextFields: [TextField]?
    
    var delegate: ForgotPasswordDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    // MARK: Actions
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.confirmationCodeTextField?.text?.isEmpty == true {
            self.showAlertControllerWithTitle(title: "Error".localized(), message: NSLocalizedString("Please enter the code.".localized(), comment: ""))
        } else if let newPasswordCount = self.newPasswordTextField?.text?.characters.count, let confirmPasswordСount = self.confirmPasswordTextField?.text?.characters.count, newPasswordCount < self.minPasswordLength || confirmPasswordСount < self.minPasswordLength {
                self.showAlertControllerWithTitle(title: "Error".localized(), message: NSLocalizedString("Password is too short (minimum is 8 characters).".localized(), comment: ""))
        } else if self.newPasswordTextField?.text != self.confirmPasswordTextField?.text {
            self.showAlertControllerWithTitle(title: "Error".localized(), message: NSLocalizedString("Passwords don't match.".localized(), comment: ""))
        } else if self.recoveryPassword != self.confirmationCodeTextField?.text {
            self.showAlertControllerWithTitle(title: "Error".localized(), message: NSLocalizedString("Recovery code doesn't match the code sent to email.".localized(), comment: ""))
        } else {
            if let newPassword = self.newPasswordTextField?.text {
                SVProgressHUD.show()
                ClientAPI.shared.changePassword(email: self.userEmail ?? "", newPassword: newPassword, withCompletion: { [weak self] error in
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        self?.showAlertControllerWithTitle(title: "Error".localized(), message: error.localizedDescription)
                        
                        return
                    }
                    
                    self?.delegate?.didChangePassword()
                })
            }
        }
    }
}

extension ForgotPasswordViewController: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
}

// MARK: Helpers
extension ForgotPasswordViewController {
    
    func configureUI() {
        self.configureInfoLabel()
        self.configureTextFields()
    }
    
    func configureInfoLabel() {
        self.infoLabel?.text = String(format: "We've sent a recovery code on your email\n%@", "\(self.userEmail)")
    }
    
    func configureTextFields() {
        self.confirmationCodeTextField?.placeholder = "Recovery code".localized()
        self.newPasswordTextField?.placeholder = "New password".localized()
        self.confirmPasswordTextField?.placeholder = "Confirm password".localized()
        
        if let recoveryPasswordTextFields = self.recoveryPasswordTextFields {
            for textField in recoveryPasswordTextFields {
                textField.isVisibilityIconButtonEnabled = true
                textField.dividerNormalColor = UIColor.white
                textField.clearIconButton?.tintColor = UIColor.white
                textField.placeholderLabel.textColor = UIColor.white
                textField.textColor = UIColor.white
            }
        }
        
        self.confirmationCodeTextField?.dividerColor = self.confirmationCodeTextField?.dividerActiveColor
        self.confirmationCodeTextField?.isVisibilityIconButtonEnabled = false
        self.confirmationCodeTextField?.becomeFirstResponder()
    }
}

