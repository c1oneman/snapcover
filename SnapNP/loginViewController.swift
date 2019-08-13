//
//  loginViewController.swift
//  SnapNP
//
//  Created by Clay Loneman on 6/7/19.
//  Copyright © 2019 Clay Loneman. All rights reserved.
//

import Foundation
import UIKit
import Pastel
import SpotifyLogin
import SwiftVideoBackground
class LogInViewController: UIViewController {
    
    var loginButton: UIButton?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessful),
                                               name: .SpotifyLoginSuccessful,
                                               object: nil)
    }
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
        let button = SpotifyLoginButton(viewController: self,
                                        scopes: [.userReadCurrentlyPlaying])
        let xPostion:CGFloat = 0
        let yPostion:CGFloat = 100
        let buttonWidth:CGFloat = self.view.frame.width * 0.7
        
        let buttonHeight:CGFloat = self.view.frame.width * 0.16
        
        button.frame = CGRect(x:xPostion + self.view.frame.width/2 - buttonWidth/2, y:self.view.frame.size.height - yPostion, width:buttonWidth, height:buttonHeight)
        self.view.addSubview(button)
        self.loginButton = button
            //setGradientBackground()
            
            let pastelView = PastelView(frame: self.view.bounds)
            
            // Custom Direction
            pastelView.startPastelPoint = .bottomLeft
            pastelView.endPastelPoint = .topRight
            
            // Custom Duration
            pastelView.animationDuration = 3.0
            
            // Custom Color
            pastelView.setColors([UIColor(red: 24/255, green: 78/255, blue: 104/255, alpha: 1.0),
                                  UIColor(red: 66/255, green: 230/255, blue: 149/255, alpha: 1.0),UIColor(red: 252/255, green: 227/255, blue: 138/255, alpha: 1.0)])
            pastelView.startAnimation()
            //252,227,138
            
            
            self.view.insertSubview(pastelView, at: 0)
        }
    }
    func setGradientBackground() {
        let colorTop =  UIColor(red: 0/255.0, green: 252/255.0, blue: 100/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 252/255.0, blue: 100/255.0, alpha: 1.0).cgColor
        
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
    
