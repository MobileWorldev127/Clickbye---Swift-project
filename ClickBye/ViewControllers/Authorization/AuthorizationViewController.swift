//
//  AuthorizationViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKLoginKit
import Analytics
import KeychainAccess

final class AuthorizationViewController: UIViewController {
    @IBOutlet fileprivate weak var logoImageView: UIImageView?
    @IBOutlet fileprivate weak var logInViaFacebookButton: UIButton?
    @IBOutlet fileprivate weak var logInButton: UIButton?
    @IBOutlet fileprivate weak var signUpButton: UIButton?
    @IBOutlet fileprivate weak var skipButton: UIButton?
    
    @IBOutlet fileprivate weak var backgroundImageView: UIImageView?
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var descriptionLabel: UILabel?
    @IBOutlet fileprivate weak var loadingLogoImageView: UIImageView?
    
    fileprivate typealias ImageDescriptionItem = (title: String, imagePath: String)
    fileprivate var imageDescriptionItems = [ImageDescriptionItem]()
    fileprivate var currentImageDescriptionPosition = 1
    fileprivate var imageDescriptionTimer: Timer?
    
    fileprivate var userName: String?
    fileprivate var userEmailAddress: String?

    fileprivate let imageDescriptionTimerInterval: TimeInterval = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let _ = FBSDKAccessToken.current() {
            self.loadFacebookProfile(tokenString: FBSDKAccessToken.current().tokenString)
        }
        
        if Keychain(service: Constants.Keychain.appServiceID)["email"]?.isEmpty == false {
            present(ChoseFlyView.self, navigationEnabled: true, animated: false, completion: { viewController in
                self.loadingLogoImageView?.isHidden = true
            })
        } else {
            self.loadingLogoImageView?.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startImagesAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopImagesAnimation()
    }
}

extension AuthorizationViewController: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
    static var storyboardName: UIStoryboard.Name {
        return .auth
    }
}

private extension AuthorizationViewController {
    // MARK: Facebook Login
    func logInViaFacebook() {
        SEGAnalytics.shared().track("Prehost_FBRegistration_Clicked")
        
        FacebookAPI.shared.logIn(from: self.parent) { [weak self] loginResult in
            if loginResult?.isCancelled == false,
                let tokenString = loginResult?.token.tokenString {
                self?.loadFacebookProfile(tokenString: tokenString)
            }
        }
    }
    
    func loadFacebookProfile(tokenString: String) {
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()

        FacebookAPI.shared.fetchUserProfile { [weak self] userProfile, error in
            guard let userProfile = userProfile,
                let emailAddress = userProfile.email,
                let userIdentifier = userProfile.userIdentifier else {
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        self?.showAlertControllerWithTitle(title: "Error".localized, message: error.localizedDescription)
                    }
                    
                    self?.loadingLogoImageView?.isHidden = true
                    
                    return
            }
            
            ClientAPI.shared.signUpViaFacebook(email: emailAddress, userIdentifier: userIdentifier, facebookAccessToken: tokenString, completion: { [weak self] success, error in
                SVProgressHUD.dismiss()
                
                guard success else {
                    if let error = error {
                        self?.showAlertControllerWithTitle(title: "Error".localized, message: error.localizedDescription)
                    }

                    self?.loadingLogoImageView?.isHidden = true
                    return
                }
                
                SEGAnalytics.shared().identify(userProfile.userIdentifier ?? emailAddress, traits: userProfile.analyticsTraits)
                
                Keychain(service: Constants.Keychain.appServiceID)["email"] = emailAddress
                
                self?.presentChooseFlyViewController(with: userProfile)
            })
        }
    }
}

private extension AuthorizationViewController {
    // MARK: - UI setup
    func configureUI() {
        configureImageDescriptionItems()
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13.0),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let buttonTitleStr = NSMutableAttributedString(string: "here".localized(), attributes:attrs)
        self.logInButton?.setAttributedTitle(buttonTitleStr, for: .normal)
    }
    
    func configureImageDescriptionItems() {
        imageDescriptionItems.append(ImageDescriptionItem(title: "DISCOVER NEW PLACES TO FALL IN LOVE WITH".localized, imagePath: "4"))
        imageDescriptionItems.append(ImageDescriptionItem(title: "SAVE YOUR DESTINATIONS, CREATE YOUR WISH LIST".localized, imagePath: "5"))
        imageDescriptionItems.append(ImageDescriptionItem(title: "CREATE YOUR ACCOUNT TO ENJOY THE SIMPLICITY".localized, imagePath: "8"))
        imageDescriptionItems.append(ImageDescriptionItem(title: "FIND NEW DESTINATIONS TO LOVE WITH ONE CLICK".localized, imagePath: "6"))
    }
    
    func startImagesAnimation() {
        imageDescriptionTimer = Timer.scheduledTimer(timeInterval: self.imageDescriptionTimerInterval, target: self, selector: #selector(changeBackgroundImage), userInfo: nil, repeats: true)
    }
    
    func stopImagesAnimation() {
        imageDescriptionTimer?.invalidate()
        imageDescriptionTimer = nil
    }
    
    @objc func changeBackgroundImage() {
        if currentImageDescriptionPosition >= imageDescriptionItems.count {
            currentImageDescriptionPosition = 0
        }

        let imageDescriptionItem = imageDescriptionItems[currentImageDescriptionPosition]
        
        backgroundImageView?.image = UIImage(named: imageDescriptionItem.imagePath)
        titleLabel?.text = imageDescriptionItem.title

        currentImageDescriptionPosition += 1
    }
    
    // MARK: - UIButton selectors

    @IBAction func logInViaFacebookButtonPressed(_ sender: UIButton) {
        logInViaFacebook()
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        presentLogInViewController()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        presentSignUpViewController()
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        presentSkipAuthAlert()
    }
    
    // MARK: - Navigation
    
    func presentSkipAuthAlert() {
        SEGAnalytics.shared().track("Prehost_Skip_Clicked")
        
        let title = "Are you sure".localized
        let message = "Join us and create your Wish List to find back easily your favorite destinations!".localized
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let connectAction = UIAlertAction(title: "Connect".localized, style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Later".localized, style: .default) { [weak self] action in
            self?.presentChooseFlyViewController(with: User())
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(connectAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentChooseFlyViewController(with userProfile: User) {
        present(ChoseFlyView.self, navigationEnabled: true, completion: { viewController in
            self.loadingLogoImageView?.isHidden = true
        })
    }
    
    func presentSignUpViewController() {
        navigationController?.push(SignUpViewController.self, configuration: { [weak self] viewController in
            viewController.delegate = self?.navigationController as? AuthorizationNavigationController
        })
    }
    
    func presentLogInViewController() {
        navigationController?.push(LogInViewController.self, configuration: { [weak self] viewController in
            viewController.delegate = self?.navigationController as? AuthorizationNavigationController
        })
    }
}
