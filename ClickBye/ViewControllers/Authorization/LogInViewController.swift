//
//  LogInViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Material
import SVProgressHUD
import TPKeyboardAvoiding
import Analytics
import KeychainAccess

protocol LogInViewControllerDelegate: class {
    func userWillChangeToSignUpViewController()
    func userWillCloseLogInViewController()
}

final class LogInViewController: UIViewController {
    @IBOutlet fileprivate weak var contentScrollView: TPKeyboardAvoidingScrollView?
    @IBOutlet fileprivate weak var emailTextField: ErrorTextField?
    @IBOutlet fileprivate weak var passwordTextField: ErrorTextField?
    @IBOutlet fileprivate weak var logInButton: UIButton?
    @IBOutlet fileprivate weak var signUpButton: UIButton?
    @IBOutlet fileprivate weak var forgotPasswordButton: UIButton?

    @IBOutlet fileprivate weak var emailTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var passwordTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    
    weak var delegate: LogInViewControllerDelegate?
    
    fileprivate enum LogInConstants {
        static let incorrectEmailAddress = "Email is not correct".localized
        static let incorrectPassword = "Use at least 8 characters".localized
        static let passwordSuccessfullyChanged = "Successfully changed user password".localized
        static let minimumPasswordLength = 8
        static let emailTextFieldDefaultBottomSpace: CGFloat = 32
        static let passwordTextFieldDefaultBottomSpace: CGFloat = 10
        static let textFieldErrorMessagePadding: CGFloat = 18
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = emailTextField?.becomeFirstResponder()
    }
}

extension LogInViewController: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
    static var storyboardName: UIStoryboard.Name {
        return .auth
    }
}

extension LogInViewController: ForgotPasswordDelegate {
    // MARK: - ForgotPasswordDelegate
    func didChangePassword() {
        dismiss(animated: true) { [weak self] in
            self?.showAlertControllerWithTitle(title: String(), message: LogInConstants.passwordSuccessfullyChanged)
        }
    }
}

private extension LogInViewController {
    // MARK: - API Communication methods
    func restorePassword(for emailAddress: String) {
        SEGAnalytics.shared().track("Prehost_ForgotPassword_Clicked")
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()
        
        ClientAPI.shared.restorePassword(email: emailAddress) { [weak self] error in
            SVProgressHUD.dismiss()
            
            if let error = error {
                self?.showAlertControllerWithTitle(title: "Error".localized, message: error.localizedDescription)
            } else {
                self?.presentForgotPasswordViewController(for: emailAddress)
            }
        }
    }
    
    func logIn(email: String,
               password: String) {
        SEGAnalytics.shared().track("Prehost_LogIn_Clicked")
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()
        
        ClientAPI.shared.logIn(email: email, password: password) { [weak self] success, error in
            guard success else {
                SVProgressHUD.dismiss()
                
                if let error = error {
                    self?.showAlertControllerWithTitle(title: "Error".localized, message: error.localizedDescription)
                }

                return
            }
            
            SEGAnalytics.shared().identify(email)
            Keychain(service: Constants.Keychain.appServiceID)["email"] = email
            
            SVProgressHUD.showSuccess(withStatus: nil)
            self?.present(ChoseFlyView.self, navigationEnabled: true)
        }
    }
}

extension LogInViewController: TextFieldDelegate {
    // MARK: TextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, enabled: false)

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if contentScrollView?.focusNextTextField() == false {
            view.endEditing(true)
            prepareLogInProcedure()
        }

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, enabled: false)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, enabled: false)
    }
}

private extension LogInViewController {
    // MARK: - UI setup
    func configureUI() {
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13.0),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let buttonTitleStr = NSMutableAttributedString(string: "Sign up here".localized(), attributes:attrs)
        self.signUpButton?.setAttributedTitle(buttonTitleStr, for: .normal)
        
        emailTextField?.placeholder = "Email".localized()
        emailTextField?.detail = LogInConstants.incorrectEmailAddress
        configureErrorTextField(emailTextField)
        
        passwordTextField?.placeholder = "Password".localized()
        passwordTextField?.detail = LogInConstants.incorrectPassword
        configurePasswordTextField(passwordTextField)
    }
    
    func configureErrorTextField(_ textField: ErrorTextField?) {
        textField?.textColor = .white
        textField?.dividerColor = .white
        textField?.detailColor = .flatRed
        textField?.placeholderNormalColor = .white
        textField?.placeholderActiveColor = .flatSkyBlue
        textField?.dividerActiveColor = .white
        textField?.dividerNormalColor = .white
    }
    
    func configurePasswordTextField(_ textField: ErrorTextField?) {
        configureErrorTextField(textField)
        
        textField?.isVisibilityIconButtonEnabled = true
        textField?.visibilityIconButton?.tintColor = Color.flatGray.withAlphaComponent(textField?.isSecureTextEntry == true ? 0.54 : 0.9)
    }
    
    // MARK: - UIButton selectors
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        prepareLogInProcedure()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        view.endEditing(true)

        delegate?.userWillChangeToSignUpViewController()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        prepareForgotPasswordProcedure()
    }
    
    @IBAction func closeViewControllerButtonPressed(_ sender: UIButton) {
        view.endEditing(true)

        delegate?.userWillCloseLogInViewController()
    }
    
    // MARK: - UI helpers
    
    func prepareForgotPasswordProcedure() {
        guard let emailAddress = emailTextField?.text,
            !emailAddress.isEmpty else {
                emailTextField?.isErrorRevealed = true
                
                return
        }
        
        guard emailAddress.isEmail() else {
            emailTextField?.isErrorRevealed = true
            handleEmailTextFieldBottomPadding(paddingEnabled: true)
            
            return
        }
        
        view.endEditing(true)
        restorePassword(for: emailAddress)
    }
    
    func prepareLogInProcedure() {
        guard let emailAddress = emailTextField?.text,
            let password = passwordTextField?.text else {
                return
        }
        
        guard emailAddress.isEmail() else {
            emailTextField?.isErrorRevealed = true
            handleEmailTextFieldBottomPadding(paddingEnabled: true)
            
            return
        }
        
        guard password.characters.count >= LogInConstants.minimumPasswordLength else {
            passwordTextField?.isErrorRevealed = true
            handlePasswordTextFieldBottomPadding(paddingEnabled: true)
            
            return
        }
        
        view.endEditing(true)
        logIn(email: emailAddress, password: password)
    }
    
    func handleTextFieldPadding(textField: ErrorTextField?,
                                enabled: Bool) {
        if textField == emailTextField {
            handleEmailTextFieldBottomPadding(paddingEnabled: enabled)
        } else if textField == passwordTextField {
            handlePasswordTextFieldBottomPadding(paddingEnabled: enabled)
        }
    }
    
    func handleEmailTextFieldBottomPadding(paddingEnabled: Bool) {
        emailTextFieldBottomSpaceConstraint?.constant = LogInConstants.emailTextFieldDefaultBottomSpace + (paddingEnabled ? LogInConstants.textFieldErrorMessagePadding : 0)
        
        UIView.animate(withDuration: 0) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func handlePasswordTextFieldBottomPadding(paddingEnabled: Bool) {
        passwordTextFieldBottomSpaceConstraint?.constant = LogInConstants.passwordTextFieldDefaultBottomSpace + (paddingEnabled ? LogInConstants.textFieldErrorMessagePadding : 0)
        
        UIView.animate(withDuration: 0) { 
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Navigation
    
    func presentForgotPasswordViewController(for emailAddress: String) {
        present(ForgotPasswordViewController.self, navigationEnabled: false, configuration: { [weak self] viewController in
            viewController.delegate = self
            viewController.userEmail = emailAddress
        })
    }
}
