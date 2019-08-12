//
//  ViewController.swift
//  SnapNP
//
//  Created by Clay Loneman on 6/7/19.
//  Copyright © 2019 Clay Loneman. All rights reserved.
//
import MessageUI
import SwiftyJSON
import SafariServices

import UIKit
import SCSDKCreativeKit
import AZDialogView
import SpotifyLogin
import MediaPlayer
import GoogleMobileAds
var adAble = true
var globalID = ""
var key = ""
var adsAllowed = false
var enableSpotifyMode = true
class ViewController: UIViewController, GADInterstitialDelegate, GADAppEventDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var searchBtnView: UIView!
    var red = 0
    var green = 0
    var imgURLpublic = ""
    var blue = 0
    @IBOutlet weak var stickerView: UIView!
    var didClick = false
    @IBOutlet weak var webView: UIWebView!
    var interstitial: GADInterstitial!
    @IBOutlet weak var tapNotif: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var create: UIButton!
    var gradientLayer = CAGradientLayer()
   // @IBOutlet weak var spotBtn: UIButton!
    @IBOutlet weak var styleBtn: UIButton!
    @IBOutlet weak var snaplogo: UIImageView!
    var snapAPI = SCSDKSnapAPI()
    var isBlackTheme = false
    var username = ""
    var extUrl = ""
    
    var artistName = ""
    var songTitle = ""
    var customImage = UIImage(named:"img.png")
    var urls = URL(string: "")
 
    @IBOutlet weak var logoView: UIView!
    
    @IBOutlet weak var versionLbl: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBtnView.roundCorners(corners: [.topLeft, .bottomLeft], radius: searchBtnView.frame.height/2)
        logoView.roundCorners(corners: [.bottomRight, .topRight], radius: searchBtnView.frame.height/2)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        versionLbl.text = "v.\(appVersion!)b.\(buildNumber!)"
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-7908027428647197/1619957489")
        interstitial = createAndLoadInterstitial()
        let request = GADRequest()
        interstitial.load(request)
        gradientLayer.frame = self.view.bounds
        
        // 3
        let color1 = UIColor.black.cgColor as CGColor
        let color2 = UIColor.black.cgColor as CGColor
        
        gradientLayer.colors = [color1, color2]
        
        // 4
        gradientLayer.locations = [0.0,1.0]
        
        // 5
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNote(_:)), name: Notification.Name(rawValue: "loginRefresh"), object: nil)
        
       stickerView.dropShadow()
       
        activity.isHidden = false
        activity.startAnimating()
      create.isHidden = true
       
        snaplogo.isHidden = true
        create.isEnabled = false
        //spotBtn.isHidden = true
        
        create.layer.cornerRadius = create.frame.height/2
        create.layer.borderWidth = 1
        create.layer.borderColor = UIColor.clear.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAllNotif), name: UIApplication.willEnterForegroundNotification, object: nil)
        snapAPI = SCSDKSnapAPI()
        iamgeView.isHidden = false
         interstitial.delegate = self
        refreshAll()
        
        }
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-7908027428647197/1112335805")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
      
        let alert = UIAlertController(title: "You rock.", message: "Thanks for supporting me!", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        //print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        let alert = UIAlertController(title: "You rock.", message: "Thanks for supporting me!", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //demoSendSticker()
        print("closed")
        interstitial = createAndLoadInterstitial()
        adAble = false
        
             self.demoSendSticker()
        
       
    }
    @objc func refreshNote(_ notification: Notification) {
        self.refreshAll()
    }
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        fetchFromID(idS: globalID)
    }
    @IBAction func searchAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "search") as! searchViewController
        self.present(vc, animated: true, completion: nil)
    
        
       
    }
    func refreshAll() {
        print("RefreshAll")
       interstitial = createAndLoadInterstitial()
            self.artistLbl.isHidden = true
            self.tapNotif.isHidden = true
            self.titleLbl.isHidden = true
            self.refreshView.alpha = 0.0
            self.activity.isHidden = false
            self.stickerView.isHidden = true
        create.isHidden = true
        snaplogo.isHidden = true
            //self.spotBtn.isHidden = false
            self.create.isEnabled = false
       
         activity.startAnimating()
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            
            if error != nil || token == nil {
                print("Error Auth; Launching Spotify signin")
                self!.showLogin()
            }
            else {
                print("Successful login")
                let usernameRec = SpotifyLogin.shared.username
                
                print(usernameRec!)
                self!.username = usernameRec!
                key = token!
                self!.fetchTrackRequest()
                //self!.fetchTrackRequest()
                
                print(token!)
            }
        }
    }
    @IBAction func createBtn(_ sender: Any) {
        self.create.titleLabel!.text = "..."
        didClick = true
        if interstitial.isReady && adAble && adsAllowed{
            interstitial.present(fromRootViewController: self)
        } else {
             interstitial = createAndLoadInterstitial()
            print("Ad wasn't ready")
            adAble = true
            self.demoSendSticker()
        }
        
    }
    func demoSendSticker() {
        /* Sticker to be used in the Snap */
        print("send sticker")
         let snap = SCSDKNoSnapContent()
        if #available(iOS 10.0, *) {
            let size = CGSize(width: stickerView.bounds.width, height: stickerView.bounds.height*2)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.pngData { ctx in
                
               // UIColor.clear.set()
                

                
               stickerView.drawHierarchy(in: stickerView.bounds, afterScreenUpdates: true)
                
            }
            let sticker = SCSDKSnapSticker(stickerImage: UIImage(data: image)!)
            snap.sticker = sticker
        } else {
            // Fallback on earlier versions
            let image = customImage!
             let sticker = SCSDKSnapSticker(stickerImage: image)
             snap.sticker = sticker
        }
        
       
        
        //let stickerImage = image/* Prepare a sticker image */
       
        /* Alternatively, use a URL instead */
        // let sticker = SCSDKSnapSticker(stickerUrl: stickerImageUrl, isAnimated: false)
        
        /* Modeling a Snap using SCSDKNoSnapContent */
       
        /* Optional */
        /* Optional */
        snap.caption = songTitle + "\n" + artistName
        print(extUrl)
        extUrl = extUrl.replacingOccurrences(of: " ", with: "%20")
        snap.attachmentUrl = extUrl
        view.isUserInteractionEnabled = false
        print("Next Sent")
        snapAPI.startSending(snap) { [weak self] (error: Error?) in
            self?.view.isUserInteractionEnabled = true
            
            // Handle response
        }
    }
    
    @IBOutlet weak var snapCoverlbl: UILabel!
    @IBAction func styleBtnAction(_ sender: Any) {
        tapNotif.isHidden = true
        if #available(iOS 10.0, *) {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.selectionChanged()
        } else {
            // Fallback on earlier versions
        }
        
        if isBlackTheme {
            snapCoverlbl.textColor = UIColor.white
            snapCoverlbl.shadowColor = UIColor.black
            isBlackTheme = false
        }
        else {
            snapCoverlbl.shadowColor = UIColor.white
            snapCoverlbl.textColor = UIColor.black
            isBlackTheme = true
        }
    }
    
    @objc private func refreshAllNotif() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.refreshAll()
        }
        
    }
  
    @IBAction func actionRefresh(_ sender: Any) {
       self.refreshAll()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var alreadyPressed = false
    @IBAction func backgroundPress(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [ .curveEaseOut], animations: {
            self.refreshView.alpha = 1.0
        }, completion: nil)
        if(alreadyPressed == false) {
            self.alreadyPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [ .curveEaseOut], animations: {
                   self.refreshView.alpha = 0.0
                }, completion: nil)
            self.alreadyPressed = false
            
        }
        }
    }
    @IBOutlet weak var refreshView: UIView!
    override func viewDidAppear(_ animated: Bool) {
        
       
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            
            if error != nil || token == nil {
                print("Error Auth; Launching Spotify signin")
                self!.showLogin()
            }
           else {
                print("Successful login")
                let usernameRec = SpotifyLogin.shared.username
                
                print(usernameRec!)
                self!.username = usernameRec!
                key = token!
                
                //self!.fetchTrackRequest()
                
                print(token!)
            }
            //self!.presentDialog()
        }
            
            
          
        }
    
    func fetchFromID(idS: String) {
        let string = "https://api.spotify.com/v1/tracks/\(idS)"
        var url = NSURL(string: string)
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization") //**
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "")
        let session = URLSession.shared
        
        do {
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                     let alert = UIAlertController(title: "Oh dear..", message: "fundamental networking error", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("response = \(String(describing: response))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let alert = UIAlertController(title: "Hmmm..", message: "Error loading: \(httpStatus.statusCode)", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
                
                do {
                    
                    let json = try JSON(data: data)
                    
                    
                    if let id = json["album"]["images"].array {
                        var stringURL = id[0]["url"].url
                        // let stringURL = self.stringify(json: id[0]["url"])
                        //self.urls = URL(string: stringURL!)
                        self.downloadImageSearch(from: stringURL!)
                        
                        // print(stringURL)
                        //self.getTempoOfID(id: id)
                        
                    }
                    
                    
                    if let title = json["name"].string {
                        self.songTitle = title
                        DispatchQueue.main.async() {
                        self.titleLbl.text = title
                        }
                         
                    }
                        print(self.songTitle)
                        //let replaced = self.songTitle.replacingOccurrences(of: " ", with: "-")
                        if let arts = json["artists"][0]["name"].string {
                            self.artistName = arts
                            if let name = json["external_urls"]["spotify"].string {
                                self.extUrl = "https://www.coverly.app/song?c=" + name + "&d=" + self.songTitle + "&e=" + self.artistName + "&f=" + self.imgURLpublic
                                DispatchQueue.main.async() {
                                self.artistLbl.text = self.artistName
                                }
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                
                catch {
                    
                }
            }
            task.resume()
          
        }
    
   
    }
     func presentDialog2() {
        let dialog = AZDialogViewController(title: "One sec..", message: "Checking Spotify for currently playing music.")
        
        let container = dialog.container
        let indicator = UIActivityIndicatorView(style: .gray)
        dialog.container.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        indicator.startAnimating()
        
        
       
        //dialog.animationDuration = 5.0
        dialog.customViewSizeRatio = 0.2
        dialog.dismissDirection = .none
        dialog.allowDragGesture = false
        dialog.dismissWithOutsideTouch = false
        dialog.show(in: self)
        
        var when = DispatchTime.now() + 1  // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Contacting Spotify."
           
        }
        when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Left on read.."
            
        }
        when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Double snapping..."
            
        }
        when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Finishing up.."
            
        }
        when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            dialog.dismiss(animated: false, completion: nil)
            self.refreshAll()
        }
        
    }
    func presentDialog() {
        let dialog = AZDialogViewController(title: "Spotify not playing", message: "You can search spotify or just start playing music.")
   
        dialog.titleColor = .black
        
        //set the message color
        dialog.messageColor = .black
        
        //set the dialog background color
        dialog.alertBackgroundColor = .white
        
        //set the gesture dismiss direction
        dialog.dismissDirection = .bottom
        
        //allow dismiss by touching the background
        dialog.dismissWithOutsideTouch = false
        
        //show seperator under the title
        dialog.showSeparator = false
        
        //set the seperator color
        dialog.separatorColor = UIColor.blue
        
        //enable/disable drag
        dialog.allowDragGesture = false
        
        //enable rubber (bounce) effect
        dialog.rubberEnabled = true
        
        //set dialog image
        //dialog.image = UIImage(named: "1024.png")
        
        //enable/disable backgroud blur
        dialog.blurBackground = true
        
        //set the background blur style
        dialog.blurEffectStyle = .dark
        
        // set the dialog offset (from center)
       // dialog.contentOffset = self.view.frame.height / 2.0 - dialog.estimatedHeight / 2.0 - 16.0
        dialog.addAction(AZDialogAction(title: "Search Spotify") { (dialog) -> (Void) in
            //add your actions here.
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "search") as! searchViewController
             dialog.dismiss(animated: false, completion: nil)
            self.present(vc, animated: true, completion: nil)
           
        })
        
       
        dialog.addAction(AZDialogAction(title: "Check Again") { (dialog) -> (Void) in
            //add your actions here.
          dialog.dismiss(animated: false, completion: nil)
          self.presentDialog2()
           // dialog.dismiss(animated: true, completion: nil)
           //  self.refreshAll()
        })
        self.present(dialog, animated: false, completion: nil)
    }
    func aboutDia() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        var versionDetails = "v.\(appVersion!)b.\(buildNumber!)"
            let dialog = AZDialogViewController(title: "Coverly (\(versionDetails))", message: "Thanks for using Coverly!")
            dialog.titleColor = .black
            
            //set the message color
            dialog.messageColor = .black
            
            //set the dialog background color
            dialog.alertBackgroundColor = .white
            
            //set the gesture dismiss direction
            dialog.dismissDirection = .bottom
            
            //allow dismiss by touching the background
            dialog.dismissWithOutsideTouch = true
            
            //show seperator under the title
            dialog.showSeparator = false
            
            //set the seperator color
            dialog.separatorColor = UIColor.blue
            
            //enable/disable drag
            dialog.allowDragGesture = true
            
            //enable rubber (bounce) effect
            dialog.rubberEnabled = true
            
            //set dialog image
            //dialog.image = UIImage(named: "1024.png")
            
            //enable/disable backgroud blur
            dialog.blurBackground = true
            
            //set the background blur style
            dialog.blurEffectStyle = .dark
            
            // set the dialog offset (from center)
            // dialog.contentOffset = self.view.frame.height / 2.0 - dialog.estimatedHeight / 2.0 - 16.0
            dialog.addAction(AZDialogAction(title: "About Coverly") { (dialog) -> (Void) in
                //add your actions here.
                
                dialog.dismiss(animated: false, completion: nil)
                 self.showSafariVC(for: "https://www.coverly.app/about")
                
            })
            dialog.addAction(AZDialogAction(title: "Terms Of Service") { (dialog) -> (Void) in
                //add your actions here.
                
                dialog.dismiss(animated: false, completion: nil)
                self.showSafariVC(for: "https://www.coverly.app/tos")
                
            })
            dialog.addAction(AZDialogAction(title: "Contact Support") { (dialog) -> (Void) in
                
                //add your actions here.
             
                dialog.dismiss(animated: false, completion: nil)
             
                self.sendEmail()
            })
            
            dialog.addAction(AZDialogAction(title: "Disconnect Spotify") { (dialog) -> (Void) in
                //add your actions here.
                
                dialog.dismiss(animated: false, completion: nil)
                self.disSpot()
            })
            self.present(dialog, animated: false, completion: nil)
        
    }
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            //Show an invalid URL error alert
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@coverly.app"])
            mail.setSubject("Coverly Support Request")
            mail.setMessageBody("<p>Type here</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            let dialog = AZDialogViewController(title: "Error", message: "iPhone is not able to send an email, setup in the Mail app first or contact support@coverly.app")
            dialog.show(in: self)
            print("Application is not able to send an email")
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    func disSpot() {
        let dialog = AZDialogViewController(title: "Disconnect Spotify", message: "Are you sure you want to sign out of Spotify account \(self.username)?")
        dialog.titleColor = .black
        
        //set the message color
        dialog.messageColor = .black
        
        //set the dialog background color
        dialog.alertBackgroundColor = .white
        
        //set the gesture dismiss direction
        dialog.dismissDirection = .bottom
        
        //allow dismiss by touching the background
        dialog.dismissWithOutsideTouch = true
        
        //show seperator under the title
        dialog.showSeparator = false
        
        //set the seperator color
        dialog.separatorColor = UIColor.blue
        
        //enable/disable drag
        dialog.allowDragGesture = true
        
        //enable rubber (bounce) effect
        dialog.rubberEnabled = true
        
        //set dialog image
        //dialog.image = UIImage(named: "1024.png")
        
        //enable/disable backgroud blur
        dialog.blurBackground = true
        
        //set the background blur style
        dialog.blurEffectStyle = .dark
        
        // set the dialog offset (from center)
        // dialog.contentOffset = self.view.frame.height / 2.0 - dialog.estimatedHeight / 2.0 - 16.0
        dialog.addAction(AZDialogAction(title: "Disconnect") { (dialog) -> (Void) in
            //add your actions here.
            dialog.dismiss(animated: false, completion: {
                SpotifyLogin.shared.logout()
                self.showLogin()
            })
            
        })
        
        dialog.addAction(AZDialogAction(title: "Cancel") { (dialog) -> (Void) in
            //add your actions here.
            
            dialog.dismiss(animated: true, completion: nil)
            
        })
        self.present(dialog, animated: false, completion: nil)
    }
    func fetchTrackRequest() {
    let string = "https://api.spotify.com/v1/me/player/currently-playing"
        var url = NSURL(string: string)
    let request = NSMutableURLRequest(url: url! as URL)
    
    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization") //**
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //request.addValue("application/json", forHTTPHeaderField: "")
    let session = URLSession.shared
    
    do {
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
    guard let data = data, error == nil else {                                                 // check for fundamental networking error
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
        
        let alert = UIAlertController(title: "Error", message: "Fundamental networking error.", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        }
    return
    }
    
    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
 //alert not playing
        self.presentDialog()
    }
    
    
    
    do {
    
    let json = try JSON(data: data)
        
        
        if let id = json["item"]["album"]["images"].array {
    var stringURL = id[0]["url"].url
           // let stringURL = self.stringify(json: id[0]["url"])
           //self.urls = URL(string: stringURL!)
            self.downloadImage(from: stringURL!)
            self.imgURLpublic = stringURL!.absoluteString
          // print(stringURL)
          //self.getTempoOfID(id: id)
    
    }
       
  
      
        if let title = json["item"]["name"].string {
            self.songTitle = title
            DispatchQueue.main.async() {
            self.titleLbl.text = title

            
            }
            print("TITLE",self.songTitle)
            
            if let arts = json["item"]["artists"][0]["name"].string {
                 print("ARTIST",arts)
                self.artistName = arts
                if let name = json["item"]["album"]["external_urls"]["spotify"].string {
                    self.extUrl = "https://www.coverly.app/song?c=" + name + "&d=" + self.songTitle + "&e=" + self.artistName + "&f=" + self.imgURLpublic
                    
                    DispatchQueue.main.async() {
                    self.artistLbl.text = self.artistName
                    }
                    
                }
            }
           
        }
        
    
    }
    catch {
    
    }
    }
    task.resume()
    }
    }
    @IBAction func logout(_ sender: Any) {
        appDetails()
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(controller, animated: true, completion: nil)
    }
    @IBOutlet weak var lbl: UILabel!
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
     func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
 
   
    @IBOutlet weak var iamgeView: UIImageView!
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.iamgeView.image = UIImage(data: data)
                
                self.customImage = UIImage(data: data)!
                self.activity.isHidden = true
                self.activity.stopAnimating()
                var cgGradColor = self.customImage?.averageColor?.cgColor
                let myColor = UIColor(cgColor: cgGradColor!)
                
                let myColorComponents = myColor.components
                print(myColorComponents.red)
                self.red = Int(myColorComponents.red * 256)
                // 0.5
                print(myColorComponents.green)
                self.green = Int(myColorComponents.green * 256)
                // 1.0
                print(myColorComponents.blue)
                self.blue = Int(myColorComponents.blue * 256)
                // 0.25
                self.extUrl = self.extUrl + "&r=" + String(self.red)
                self.extUrl = self.extUrl + "&g=" + String(self.green)
                self.extUrl = self.extUrl + "&b=" + String(self.blue)
                print(myColorComponents.alpha) // 0.5

                self.gradientLayer.colors = [ UIColor.black.cgColor, cgGradColor]
                print("Done setting image")
                self.stickerView.isHidden = false
                self.create.titleLabel!.text = "Share"
                self.create.isHidden = false
                self.snaplogo.isHidden = false
                self.create.isEnabled = true
               //self.spotBtn.isHidden = false
                self.artistLbl.isHidden = false
                self.tapNotif.isHidden = false
                self.titleLbl.isHidden = false
                
                
            }
            
        }
    }
    
    @IBAction func snapcoverpress(_ sender: Any) {
        appDetails()
    }
    func appDetails() {
        aboutDia()
        
    }
func downloadImageSearch(from url: URL) {
    print("Download Started")
    imgURLpublic = url.absoluteString
    getData(from: url) { data, response, error in
        guard let data = data, error == nil else { return }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        print("Download Finished")
        DispatchQueue.main.async() {
            self.iamgeView.image = UIImage(data: data)
            
            self.customImage = UIImage(data: data)!
            self.gradientLayer.colors = [ UIColor.black.cgColor, self.customImage?.averageColor?.cgColor]
            self.activity.isHidden = true
            self.activity.stopAnimating()
            self.view.backgroundColor = UIColor.clear
           
            print("Done setting image")
            self.stickerView.isHidden = false
            self.create.isHidden = false
            self.create.titleLabel!.text = "Share"
            self.snaplogo.isHidden = false
            self.create.isEnabled = true
            self.artistLbl.isHidden = false
            self.tapNotif.isHidden = false
            self.titleLbl.isHidden = false
           // self.spotBtn.isHidden = false
            if self.interstitial.isReady && adsAllowed && adAble{
                self.interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
           // self.view.backgroundColor = self.customImage?.averageColor
            
            
            //self.activity.isHidden = true
            //self.activity.stopAnimating()
        }
        
    }
}


    @IBOutlet weak var activity: NVActivityIndicatorView!
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
               
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
extension UIImage {
    
    var averageColor: UIColor? {
        guard let inputImage = self.ciImage ?? CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: inputImage.extent)])
            else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [CIContextOption.workingColorSpace : kCFNull])
        let outputImageRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: outputImageRect, format: CIFormat.RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3] / 255))
    }
}
class Colors {
    var gl:CAGradientLayer!
    
    init(colorToGrad: UIColor) {
        let colorBottom = colorToGrad.cgColor
        let colorTop = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
extension UIViewController {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
