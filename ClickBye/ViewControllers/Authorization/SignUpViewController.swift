//
//  SignUpViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Material
import TPKeyboardAvoiding
import SVProgressHUD
import Analytics
import KeychainAccess

protocol SignUpViewControllerDelegate: class {
    func userWillChangeToLogInViewController()
    func userWillCloseSignUpViewController()
}

final class SignUpViewController: UIViewController {
    @IBOutlet fileprivate weak var contentScrollView: TPKeyboardAvoidingScrollView?
    @IBOutlet fileprivate weak var firstNameTextField: ErrorTextField?
    @IBOutlet fileprivate weak var lastNameTextField: ErrorTextField?
    @IBOutlet fileprivate weak var emailTextField: ErrorTextField?
    @IBOutlet fileprivate weak var passwordTextField: ErrorTextField?
    @IBOutlet fileprivate weak var confirmPasswordTextField: ErrorTextField?
    
    @IBOutlet fileprivate weak var logInButton: UIButton?
    @IBOutlet fileprivate weak var signUpButton: UIButton?
    @IBOutlet fileprivate var termsButton: UIButton?
    @IBOutlet fileprivate var privacyButton: UIButton?
    
    @IBOutlet fileprivate weak var firstNameTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var emailTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var passwordTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var confirmPasswordTextFieldBottomSpaceConstraint: NSLayoutConstraint?
    
    weak var delegate: SignUpViewControllerDelegate?
    
    fileprivate enum SignUpConstants {
        static let incorrectFirstName = "First Name is not correct".localized
        static let incorrectLastName = "Last Name is not correct".localized
        static let incorrectEmailAddress = "Email is not correct".localized
        static let incorrectPassword = "Use at least 8 characters".localized
        static let incorrectConfirmPassword = "Password don't match".localized
        static let minimumPasswordLength = 8
        static let textFieldDefaultBottomSpace: CGFloat = 32
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
        
        _ = firstNameTextField?.becomeFirstResponder()
    }
}

extension SignUpViewController: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
    static var storyboardName: UIStoryboard.Name {
        return .auth
    }
}

private extension SignUpViewController {
    // MARK: - API Communication methods
    func signUp(firstName: String,
                lastName: String,
                emailAddress: String,
                password: String) {
        SEGAnalytics.shared().track("Prehost_SignUp_Clicked")
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()
        
        ClientAPI.shared.signUp(email: emailAddress, password: password, firstName: firstName, lastName: lastName) { [weak self] success, error in
            guard success else {
                SVProgressHUD.dismiss()
                
                if let error = error {
                    self?.showAlertControllerWithTitle(title: "Error".localized, message: error.localizedDescription)
                }
                
                return
            }
            
            SEGAnalytics.shared().identify(emailAddress, traits: ["RegType": "click-bye",
                                                                  "firstName" : firstName,
                                                                  "lastName" : lastName,
                                                                  "email" : emailAddress])
            Keychain(service: Constants.Keychain.appServiceID)["email"] = emailAddress
            
            SVProgressHUD.showSuccess(withStatus: nil)
            self?.present(ChoseFlyView.self, navigationEnabled: true)
        }
    }
}

extension SignUpViewController: TextFieldDelegate {
    // MARK: TextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, paddingEnabled: false)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if contentScrollView?.focusNextTextField() == false {
            view.endEditing(true)
            prepareSignUpProcedure()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, paddingEnabled: false)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        handleTextFieldPadding(textField: textField as? ErrorTextField, paddingEnabled: false)
    }
}

private extension SignUpViewController {
    // MARK: - UI setup
    func configureUI() {
        self.navigationController?.navigationBar.barTintColor = Theme.Colors.brightRed
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13.0),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let buttonTitleStr = NSMutableAttributedString(string: "here".localized(), attributes:attrs)
        self.logInButton?.setAttributedTitle(buttonTitleStr, for: .normal)
        
        let termsAttrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 12.0),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let termsTitleStr = NSMutableAttributedString(string: "Terms & Conditions".localized(), attributes:termsAttrs)
        self.termsButton?.setAttributedTitle(termsTitleStr, for: .normal)
        
        let privacyTitleStr = NSMutableAttributedString(string: "Privacy Policy".localized(), attributes:termsAttrs)
        self.privacyButton?.setAttributedTitle(privacyTitleStr, for: .normal)
        
        firstNameTextField?.placeholder = "First Name".localized()
        firstNameTextField?.detail = SignUpConstants.incorrectFirstName
        configureErrorTextField(firstNameTextField)

        lastNameTextField?.placeholder = "Last Name".localized()
        lastNameTextField?.detail = SignUpConstants.incorrectLastName
        configureErrorTextField(lastNameTextField)

        emailTextField?.placeholder = "Email".localized()
        emailTextField?.detail = SignUpConstants.incorrectEmailAddress
        configureErrorTextField(emailTextField)
        
        passwordTextField?.placeholder = "Password".localized()
        passwordTextField?.detail = SignUpConstants.incorrectPassword
        configurePasswordTextField(passwordTextField)
        
        confirmPasswordTextField?.placeholder = "Confirm Password".localized()
        confirmPasswordTextField?.detail = SignUpConstants.incorrectConfirmPassword
        configurePasswordTextField(confirmPasswordTextField)
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
        view.endEditing(true)
        delegate?.userWillChangeToLogInViewController()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        prepareSignUpProcedure()
    }
    
    @IBAction func closeViewControllerButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        delegate?.userWillCloseSignUpViewController()
    }
    
    @IBAction func termsButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        
        if let webViewController = WebViewController.webViewController() as? WebViewController {
            webViewController.title = "Terms & Conditions".localized()
            webViewController.link = Constants.URLs.termsURL
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    @IBAction func policyButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        
        if let webViewController = WebViewController.webViewController() as? WebViewController {
            webViewController.title = "Privacy Policy".localized()
            webViewController.link = Constants.URLs.policyURL
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    // MARK: - UI helpers
    
    func prepareSignUpProcedure() {
        guard let firstName = firstNameTextField?.text,
            let lastName = lastNameTextField?.text,
            let emailAddress = emailTextField?.text,
            let password = passwordTextField?.text,
            let confirmPassword = confirmPasswordTextField?.text else {
                return
        }
        
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            firstNameTextField?.isErrorRevealed = true
            handleTextFieldPadding(textField: firstNameTextField, paddingEnabled: true)

            return
        }
        
        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            lastNameTextField?.isErrorRevealed = true
            handleTextFieldPadding(textField: firstNameTextField, paddingEnabled: true)

            return
        }
        
        guard emailAddress.isEmail() else {
            emailTextField?.isErrorRevealed = true
            handleTextFieldPadding(textField: emailTextField, paddingEnabled: true)

            return
        }
        
        guard password.characters.count >= SignUpConstants.minimumPasswordLength else {
            passwordTextField?.isErrorRevealed = true
            handleTextFieldPadding(textField: passwordTextField, paddingEnabled: true)

            return
        }
        
        guard password == confirmPassword else {
            confirmPasswordTextField?.isErrorRevealed = true
            handleTextFieldPadding(textField: confirmPasswordTextField, paddingEnabled: true)

            return
        }
        
        view.endEditing(true)
        signUp(firstName: firstName, lastName: lastName, emailAddress: emailAddress, password: password)
    }
    
    func handleTextFieldPadding(textField: ErrorTextField?,
                                paddingEnabled: Bool) {
        if textField == firstNameTextField || textField == lastNameTextField {
            setupTextFieldBottomLayoutConstraint(firstNameTextFieldBottomSpaceConstraint, paddingEnabled: paddingEnabled)
        } else if textField == emailTextField {
            setupTextFieldBottomLayoutConstraint(emailTextFieldBottomSpaceConstraint, paddingEnabled: paddingEnabled)
        } else if textField == passwordTextField {
            setupTextFieldBottomLayoutConstraint(passwordTextFieldBottomSpaceConstraint, paddingEnabled: paddingEnabled)
        } else if textField == confirmPasswordTextField {
            setupTextFieldBottomLayoutConstraint(confirmPasswordTextFieldBottomSpaceConstraint, paddingEnabled: paddingEnabled)
        }
    }
    
    func setupTextFieldBottomLayoutConstraint(_ layoutConstraint: NSLayoutConstraint?,
                                              paddingEnabled: Bool) {
        layoutConstraint?.constant = SignUpConstants.textFieldDefaultBottomSpace + (paddingEnabled ? SignUpConstants.textFieldErrorMessagePadding : 0)
        
        UIView.animate(withDuration: 0) { 
            self.view.layoutIfNeeded()
        }
    }
}
