//
//  ViewController.swift
//  CoverlyApp
//
//  Created by Clayton on 11/18/19.
//  Copyright © 2019 Clayton Software. All rights reserved.
//

import UIKit
import SpotifyLogin
import SCSDKCreativeKit
import Alamofire
import SwiftyJSON
import AZDialogView
import SafariServices
import MessageUI
import UIImageColors
var globalID = ""
var key = ""

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    

    @IBOutlet var titleText: UILabel!
    @IBOutlet var subtitle: UIButton!
    
    
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var main: UIButton!
    @IBOutlet weak var snapchatBtnImage: UIImageView!
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var albumArtContainer: UIView!
    @IBOutlet weak var albumArtImage: UIImageView!
   
    @IBOutlet var swipeUPLBL: UILabel!
    @IBOutlet var notSharable: [UIView]!
    
    var snapAPI = SCSDKSnapAPI()
    var imgURLpublic = ""
    var username = ""
    var extUrl = ""
    var artistName = ""
    var songTitle = ""
    var customImage = UIImage(named:"img.png")
    var urls = URL(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        readyButton.isEnabled = false
        buttonUIAdjust()
        self.animateOut(animateView: self.albumArtContainer)
        self.swipeUPLBL.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNote(_:)), name: Notification.Name(rawValue: "loginRefresh"), object: nil)
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @objc func refreshNote(_ notification: Notification) {
        self.refreshAll()
        
    }
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
                       self!.fetchTrackRequest()
                       
                       print(token!)
                   }
               }
    }
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        fetchFromID(idS: globalID)
    }
    func fetchFromID(idS: String) {
         let string = "https://api.spotify.com/v1/tracks/\(idS)"
         let url = NSURL(string: string)
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
                         let stringURL = id[0]["url"].url
                         self.downloadImageSearch(from: stringURL!)
    
                         
                     }
                     
                     
                     if let title = json["name"].string {
                         self.songTitle = title
                         
                          
                     }
                         print(self.songTitle)
                         //let replaced = self.songTitle.replacingOccurrences(of: " ", with: "-")
                         if let arts = json["artists"][0]["name"].string {
                             self.artistName = arts
                             if let name = json["external_urls"]["spotify"].string {
                                let nameEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                 self.extUrl = "https://www.coverly.app/song?s=" + nameEncoded + "&t=" + self.songTitle + "&a=" + self.artistName + "&f=" + self.imgURLpublic
                             }
                             
                             
                             
                         }
                         
                     }
                     
                     
                 
                 catch {
                     
                 }
             }
             task.resume()
           
         }
     
    
     }
    func downloadImageSearch(from url: URL) {
        print("Download Started")
        imgURLpublic = url.absoluteString
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.albumArtImage.image = UIImage(data: data)
                   
                   self.customImage = UIImage(data: data)!
                   self.animateIn(animateView: self.albumArtContainer)
                   self.readyButton.isEnabled = true
                

                   print("Done setting image")
               
            }
            
        }
    }

    func showLogin() {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let controller = storyboard.instantiateViewController(withIdentifier: "login")
          controller.modalPresentationStyle = .fullScreen
          self.present(controller, animated: true, completion: nil)
      }
    func demoSendSticker() {
        let alert = UIAlertController(title: nil, message: "Preparing..", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
          /* Sticker to be used in the Snap */
        swipeUPLBL.isHidden = false
          albumArtContainer.layer.shadowOpacity = 0.0
          print("send photo")
        var colorMain = self.view.backgroundColor
        
          if #available(iOS 10.0, *) {
            let colors = customImage!.getColors()
            titleText.text = songTitle.replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
            subtitle.setTitle(artistName, for: .normal)
            titleText.textColor = colors?.primary
            subtitle.setTitleColor(colors?.primary, for: .normal)
            view.backgroundColor = colors?.background
            swipeUPLBL.textColor = colors?.secondary
            for view in notSharable {
              view.isHidden = true
            }
                    //\\(.*\\)
                  //  detailLabel.textColor = colors.detail
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let size = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
                             let renderer = UIGraphicsImageRenderer(size: size)
                             let image = renderer.pngData { ctx in
                                self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
                             }
                let useImage = UIImage(data: image)!
                           let photo = SCSDKSnapPhoto(image: useImage)
                           
                           let photoContent = SCSDKPhotoSnapContent(snapPhoto: photo)
                self.albumArtContainer.layer.shadowOpacity = 1.0
                for view in self.notSharable {
                             view.isHidden = false
                           }
                self.view.backgroundColor = colorMain
                self.titleText.textColor = UIColor.white
                self.titleText.text = "Coverly.app"
                self.subtitle.setTitle("snap what you listen to", for: .normal)
                alert.dismiss(animated: false, completion: nil)
                self.subtitle.setTitleColor(UIColor.white, for: .normal)
                self.swipeUPLBL.isHidden = true
                //photoContent.caption = self.songTitle + "\n" + self.artistName
                print(self.extUrl)
                self.extUrl = self.extUrl.replacingOccurrences(of: " ", with: "%20")
                photoContent.attachmentUrl = self.extUrl
                self.view.isUserInteractionEnabled = false
                self.snapAPI.startSending(photoContent) { [weak self] (error: Error?) in
                               self?.view.isUserInteractionEnabled = true
                               
                               // Handle response
                           }
            }
             
           
            
          } else {
            print("FAIL")
          }
          
         
          
      }
    @IBAction func mainSubmitBtn(_ sender: Any) {
        demoSendSticker()
    }
    func fetchTrackRequest() {
        animateOut(animateView: albumArtContainer)
       let string = "https://api.spotify.com/v1/me/player/currently-playing"
           let url = NSURL(string: string)
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
            DispatchQueue.main.async() {
                self.presentDialog()

                          
                          }
       }
       
       
       
       do {
       
       let json = try JSON(data: data)
           
           
           if let id = json["item"]["album"]["images"].array {
               let stringURL = id[0]["url"].url ?? URL(string: "nil")
              // let stringURL = self.stringify(json: id[0]["url"])
              //self.urls = URL(string: stringURL!)
           
               self.downloadImage(from: stringURL!)
               self.imgURLpublic = stringURL!.absoluteString
            
             // print(stringURL)
             //self.getTempoOfID(id: id)
       
       }
          
     
         
           if let title = json["item"]["name"].string {
               self.songTitle = title
              
               print("TITLE",self.songTitle)
               
               if let arts = json["item"]["artists"][0]["name"].string {
                    print("ARTIST",arts)
                   self.artistName = arts
                   if let name = json["item"]["album"]["external_urls"]["spotify"].string {
                    let nameEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                       self.extUrl = "https://www.coverly.app/song?s=" + nameEncoded + "&t=" + self.songTitle + "&a=" + self.artistName + "&f=" + self.imgURLpublic
                    
                       
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
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    @IBAction func helpDiaButton(_ sender: Any) {
        aboutDia()
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
          print("Download Started")
          getData(from: url) { data, response, error in
              guard let data = data, error == nil else { return }
              print(response?.suggestedFilename ?? url.lastPathComponent)
              print("Download Finished")
              DispatchQueue.main.async() {
                  self.albumArtImage.image = UIImage(data: data)
                  
                  self.customImage = UIImage(data: data)!
                  self.animateIn(animateView: self.albumArtContainer)
                  self.readyButton.isEnabled = true
               

                  print("Done setting image")
             
                  
                  
              }
              
          }
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
                let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                notificationFeedbackGenerator.prepare()
                notificationFeedbackGenerator.notificationOccurred(.success)
                   self.showLogin()
               })
               
           })
           
           dialog.addAction(AZDialogAction(title: "Cancel") { (dialog) -> (Void) in
               //add your actions here.
               
               dialog.dismiss(animated: true, completion: nil)
               
           })
           self.present(dialog, animated: false, completion: nil)
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
             
           dialog.dismiss(animated: false, completion: nil)
           self.animateRefreshDialog()
           
         })
         DispatchQueue.main.async {
             //Do UI Code here.
             //Call Google maps methods.
             self.present(dialog, animated: false, completion: nil)
             }
         }
    func animateRefreshDialog() {
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
        dialog.allowDragGesture = true
        dialog.dismissWithOutsideTouch = true
        dialog.show(in: self)
        
        var when = DispatchTime.now() + 0.5  // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Contacting Spotify."
           
        }
        when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Left on read.."
            
        }
        when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Double snapping..."
            
        }
        when = DispatchTime.now() + 2.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            dialog.message = "Finishing up.."
            self.fetchTrackRequest()
            
        }
        when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            dialog.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func buttonUIAdjust() {
        // Refresh Button
        refreshBtn.layer.cornerRadius = readyButton.bounds.size.height/2.4
        refreshBtn.clipsToBounds = true
        
        // Search Button
        
        searchBtn.layer.cornerRadius = searchBtn.bounds.size.height/2.0
        searchBtn.clipsToBounds = true
        
        // Ready / Snap Button
        readyButton.layer.cornerRadius = readyButton.bounds.size.height/2.0
        readyButton.clipsToBounds = true
        readyButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        readyButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        readyButton.layer.shadowOpacity = 1.0
        readyButton.layer.shadowRadius = 0.0
        readyButton.layer.masksToBounds = false
        
        // Main Album cover view
        albumArtImage.layer.cornerRadius = 15
        albumArtImage.clipsToBounds = true
        
        
        albumArtContainer.layer.cornerRadius = 15
        albumArtContainer.clipsToBounds = true
        albumArtContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        albumArtContainer.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        albumArtContainer.layer.shadowOpacity = 1.0
        albumArtContainer.layer.shadowRadius = 0.0
        albumArtContainer.layer.masksToBounds = false
        
        
    }
    // Refresh All
    
    func refreshAll() {
           print("RefreshAll Commanded")
          self.readyButton.isEnabled = false
           SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
               
               if error != nil || token == nil {
                   print("Error Auth; Launching Spotify signin")
                   self!.showLogin()
               }
               else {
                   print("Successful login")
                   let usernameRec = SpotifyLogin.shared.username
                   self!.username = usernameRec!
                   key = token!
                   self!.fetchTrackRequest()
                   print(token!)
               }
           }
       }
    // IBOutlets
    @IBAction func refreshTouchUp(_ sender: Any) {
         fetchTrackRequest()
    }
    @IBAction func refreshTouchDown(_ sender: Any) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
          let originalTransform = self.refreshBtn.transform
           let scaledTransform = originalTransform.scaledBy(x: 0.9, y: 0.9)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: 0.0)
           UIView.animate(withDuration: 0.1, animations: {
               self.refreshBtn.transform = scaledAndTranslatedTransform
           }, completion: { _ in
             self.refreshBtn.transform = originalTransform
           })
    }
    @IBAction func searchTouchUp(_ sender: Any) {
    }
    @IBAction func searchTouchDown(_ sender: Any) {
       let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
       notificationFeedbackGenerator.prepare()
       notificationFeedbackGenerator.notificationOccurred(.success)
         let originalTransform = self.searchBtn.transform
          let scaledTransform = originalTransform.scaledBy(x: 0.9, y: 0.9)
       let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: 0.0)
          UIView.animate(withDuration: 0.1, animations: {
              self.searchBtn.transform = scaledAndTranslatedTransform
          }, completion: { _ in
            self.searchBtn.transform = originalTransform
          })
    }
    
    @IBAction func readyTouchDown(_ sender: Any) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.success)
        var originalTransform = self.snapchatBtnImage.transform
           var scaledTransform = originalTransform.scaledBy(x: 0.8, y: 0.8)
        var scaledAndTranslatedTransform = scaledTransform.translatedBy(x: -8.0, y: -2.0)
           UIView.animate(withDuration: 0.1, animations: {
               self.snapchatBtnImage.transform = scaledAndTranslatedTransform
           }, completion: { _ in
             self.snapchatBtnImage.transform = originalTransform
           })
           originalTransform = self.main.transform
            scaledTransform = originalTransform.scaledBy(x: 0.9, y: 0.9)
         scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: -2.0)
           UIView.animate(withDuration: 0.1, animations: {
               self.main.transform = scaledAndTranslatedTransform
           }, completion: { _ in
             self.main.transform = originalTransform
           })
    }
    
    func aboutDia() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionDetails = "v.\(appVersion!)b.\(buildNumber!)"
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
            dialog.addAction(AZDialogAction(title: "About Coverly 💁🏼‍♂️") { (dialog) -> (Void) in
                //add your actions here.
                
                dialog.dismiss(animated: false, completion: nil)
                 self.showSafariVC(for: "https://www.coverly.app/")
                
            })
            dialog.addAction(AZDialogAction(title: "Terms Of Service") { (dialog) -> (Void) in
       
                
                dialog.dismiss(animated: false, completion: nil)
                self.showSafariVC(for: "https://www.coverly.app/tos")
                
            })
            dialog.addAction(AZDialogAction(title: "Contact Support") { (dialog) -> (Void) in
                
       
             
                dialog.dismiss(animated: false, completion: nil)
             
                self.sendEmail()
            })
            
            dialog.addAction(AZDialogAction(title: "Spotify 🔌") { (dialog) -> (Void) in
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
             mail.setMessageBody("<p>Type here</p><br>v.\(appVersion!)b.\(buildNumber!)", isHTML: true)
             present(mail, animated: true)
         } else {
             let dialog = AZDialogViewController(title: "Error", message: "iPhone is not able to send an email, setup in the Mail app first or contact support@coverly.app")
             dialog.show(in: self)
             print("Application is not able to send an email")
         }
     }
    //Animations
    func animateIn(animateView: UIView) {
        animateView.alpha = 1.0
                UIView.animate(withDuration:0.4,
                               delay: 0.0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.5,
                               options: .curveEaseIn,
                animations: {
                      animateView.center.x = self.view.frame.width / 2
                       }, completion: {
                       //Code to run after animating
                           (value: Bool) in
                   })
     }
    func animateOut(animateView: UIView) {
        animateView.alpha = 0.0
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                              usingSpringWithDamping: 0.5,
                              initialSpringVelocity: 0.5,
                              options: .curveEaseIn,
               animations: {
                
                animateView.center.x = self.view.frame.width + animateView.frame.width
                
                      }, completion: {
                          _ in
                        //self.animateIn(animateView: animateView)
                  })
    }
}

