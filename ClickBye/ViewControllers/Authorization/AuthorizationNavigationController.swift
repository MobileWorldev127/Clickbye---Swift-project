//
//  AuthorizationNavigationController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/20/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

final class AuthorizationNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
}

extension AuthorizationNavigationController: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
    static var storyboardName: UIStoryboard.Name {
        return .auth
    }
}

extension AuthorizationNavigationController: LogInViewControllerDelegate {
    // MARK: - LogInViewControllerDelegate
    func userWillChangeToSignUpViewController() {
        guard let signUpViewController = previewingViewController(SignUpViewController.self, navigationEnabled: false, configuration: { [weak self] viewController in
            viewController.delegate = self
        }) else {
            return
        }
        
        var viewControllers = self.viewControllers
        viewControllers[viewControllers.count - 1] = signUpViewController
        
        setViewControllers(viewControllers, animated: true)
    }
    
    func userWillCloseLogInViewController() {
        _ = popViewController(animated: true)
    }
}

extension AuthorizationNavigationController: SignUpViewControllerDelegate {
    // MARK: - SignUpViewControllerDelegate
    func userWillChangeToLogInViewController() {
        guard let logInViewController = previewingViewController(LogInViewController.self, navigationEnabled: false, configuration: { [weak self] viewController in
            viewController.delegate = self
        }) else {
            return
        }
        
        var viewControllers = self.viewControllers
        viewControllers[viewControllers.count - 1] = logInViewController

        setViewControllers(viewControllers, animated: true)
    }
    
    func userWillCloseSignUpViewController() {
        _ = popViewController(animated: true)
    }
}

private extension AuthorizationNavigationController {
    // MARK: - UI setup
    func configureUI() {
        navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .plain, target: self, action: nil)
    }
}
