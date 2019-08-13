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
import SafariServices
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
    @IBAction func loginToSpotify(_ sender: Any) {
        SpotifyLoginPresenter.login(from: self, scopes: [.userReadCurrentlyPlaying])
    }
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            //Show an invalid URL error alert
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLayoutSubviews() {
  
        runGradient()
        imageView.blink()
    }
    @IBAction func termsOfServiceBtn(_ sender: Any) {
        self.showSafariVC(for: "https://www.coverly.app/tos")
    }
    func runGradient() {
        
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 3.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
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
        //loginButton?.center = self.view.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loginSuccessful() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginRefresh"), object: nil)
    }
}
extension UIView {
    func blink(duration: Double=1.0, repeatCount: Int=5) {
        self.alpha = 0.3;
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: { [weak self] in
                        UIView.setAnimationRepeatCount(Float(repeatCount) + 0.5)
                        self?.alpha = 0.8
            }
        )
    }
}
    
