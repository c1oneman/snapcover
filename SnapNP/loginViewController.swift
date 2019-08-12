//
//  loginViewController.swift
//  SnapNP
//
//  Created by Clay Loneman on 6/7/19.
//  Copyright © 2019 Clay Loneman. All rights reserved.
//

import Foundation
import UIKit
import SpotifyLogin
import SwiftVideoBackground
class LogInViewController: UIViewController {
    
    var loginButton: UIButton?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
       
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessful),
                                               name: .SpotifyLoginSuccessful,
                                               object: nil)
    }
    override func viewDidLayoutSubviews() {
        
        let button = SpotifyLoginButton(viewController: self,
                                        scopes: [.userReadCurrentlyPlaying])
        let xPostion:CGFloat = 0
        let yPostion:CGFloat = 100
        let buttonWidth:CGFloat = self.view.frame.width * 0.7
        
        let buttonHeight:CGFloat = self.view.frame.width * 0.16
        
        button.frame = CGRect(x:xPostion + self.view.frame.width/2 - buttonWidth/2, y:self.view.frame.size.height - yPostion, width:buttonWidth, height:buttonHeight)
        self.view.addSubview(button)
        self.loginButton = button
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 255.00/255.0, green: 252.00/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255/255.0, green: 252/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton?.center = self.view.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loginSuccessful() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginRefresh"), object: nil)
    }
}
    
