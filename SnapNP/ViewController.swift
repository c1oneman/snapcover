//
//  ViewController.swift
//  SnapNP
//
//  Created by Clay Loneman on 6/7/19.
//  Copyright © 2019 Clay Loneman. All rights reserved.
//
import SwiftyJSON
import UIKit
import SCSDKCreativeKit
import SpotifyLogin
var globalID = ""
var key = ""
class ViewController: UIViewController {
    @IBOutlet weak var stickerView: UIView!
    
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var create: UIButton!
    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var spotBtn: UIButton!
    @IBOutlet weak var styleBtn: UIButton!
    var snapAPI = SCSDKSnapAPI()
    var isBlackTheme = true
    var username = ""
    var extUrl = ""
    
    var artistName = ""
    var songTitle = ""
    var customImage = UIImage(named:"img.png")
    var urls = URL(string: "")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
        
        
       stickerView.dropShadow()
        snapCoverlbl.textColor = UIColor.black
        activity.isHidden = false
        activity.startAnimating()
      create.isHidden = true
        create.isEnabled = false
        //spotBtn.isHidden = true
        
        create.layer.cornerRadius = create.frame.height/2
        create.layer.borderWidth = 1
        create.layer.borderColor = UIColor.clear.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAllNotif), name: UIApplication.willEnterForegroundNotification, object: nil)
        snapAPI = SCSDKSnapAPI()
        iamgeView.isHidden = false
        }
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        fetchFromID(idS: globalID)
    }
    @IBAction func searchAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "search") as! searchViewController
        self.present(vc, animated: true, completion: nil)
    
        
       
    }
    func refreshAll() {
         activity.startAnimating()
        activity.isHidden = false
         stickerView.isHidden = true
         create.isHidden = true
        spotBtn.isHidden = false
        create.isEnabled = false
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
        self.demoSendSticker()
    }
    func demoSendSticker() {
        /* Sticker to be used in the Snap */
        
        let renderer = UIGraphicsImageRenderer(size: stickerView.bounds.size)
        
        let image = renderer.image { ctx in
            stickerView.drawHierarchy(in: stickerView.bounds, afterScreenUpdates: true)
        }
        
        //let stickerImage = image/* Prepare a sticker image */
        let sticker = SCSDKSnapSticker(stickerImage: image)
        /* Alternatively, use a URL instead */
        // let sticker = SCSDKSnapSticker(stickerUrl: stickerImageUrl, isAnimated: false)
        
        /* Modeling a Snap using SCSDKNoSnapContent */
        let snap = SCSDKNoSnapContent()
        snap.sticker = sticker /* Optional */
        /* Optional */
        snap.caption = songTitle + "\n" + artistName
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
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
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
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
                //self!.fetchTrackRequest()
                
                print(token!)
            }
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
                    
                    if let name = json["external_urls"]["spotify"].string {
                        self.extUrl = name
                        
                        
                    }
                    if let title = json["name"].string {
                        self.songTitle = title
                        if let leftIdx = title.index(of: "("),
                            let rightIdx = title.index(of: ")")
                        {
                            let sansParens = String(title.prefix(upTo: leftIdx) + title.suffix(from: title.index(after: rightIdx)))
                            self.songTitle = sansParens.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        print(self.songTitle)
                        let replaced = self.songTitle.replacingOccurrences(of: " ", with: "-")
                        if let arts = json["artists"][0]["name"].string {
                            self.artistName = arts.lowercased()
                            let replaced2 = self.artistName.replacingOccurrences(of: " ", with: "-")
                            
                            
                            var testURL = "https://songwhip.com/song/\(replaced2.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))/\(replaced.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))"
                            print("TEST \(testURL)")
                            guard let myURL = URL(string: testURL) else {
                                print("Error: \(testURL) doesn't seem to be a valid URL")
                                return
                            }
                            
                            do {
                                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                                print("HTML : \(myHTMLString)")
                                
                                self.extUrl = testURL
                                
                            } catch let error {
                                print("Error: \(error)")
                                testURL = "https://songwhip.com/album/\(replaced2.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))/\(replaced.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))"
                                print("TEST \(testURL)")
                                guard let myURL = URL(string: testURL) else {
                                    print("Error: \(testURL) doesn't seem to be a valid URL")
                                    return
                                }
                                
                                do {
                                    let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                                    print("HTML : \(myHTMLString)")
                                    self.extUrl = testURL
                                   
                                } catch let error {
                                    print("Error: \(error)")
                                    testURL = self.extUrl
                                    self.extUrl = testURL
                                    
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
        
        let alert = UIAlertController(title: "Oh dear.", message: "Fundamental networking error.", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        }
    return
    }
    
    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        // check for http errors
    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
    //print("response = \(String(describing: response))")
    let alert = UIAlertController(title: "Nothing playing.", message: "You can search Spotify with the button above.", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    do {
    
    let json = try JSON(data: data)
  
    
        if let id = json["item"]["album"]["images"].array {
    var stringURL = id[0]["url"].url
           // let stringURL = self.stringify(json: id[0]["url"])
            //self.urls = URL(string: stringURL!)
            self.downloadImage(from: stringURL!)
          
          // print(stringURL)
    //self.getTempoOfID(id: id)
    
    }
       
    if let name = json["item"]["album"]["external_urls"]["spotify"].string {
        self.extUrl = name
    
    
    }
        if let title = json["item"]["name"].string {
            self.songTitle = title
            if let leftIdx = title.index(of: "("),
                let rightIdx = title.index(of: ")")
            {
                let sansParens = String(title.prefix(upTo: leftIdx) + title.suffix(from: title.index(after: rightIdx)))
                self.songTitle = sansParens.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            print(self.songTitle)
            var replaced = self.songTitle.replacingOccurrences(of: " ", with: "-")
            if let arts = json["item"]["artists"][0]["name"].string {
                self.artistName = arts.lowercased()
                var replaced2 = self.artistName.replacingOccurrences(of: " ", with: "-")
             
              
             var testURL = "https://songwhip.com/song/\(replaced2.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))/\(replaced.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))"
                 print("TEST \(testURL)")
                guard let myURL = URL(string: testURL) else {
                    print("Error: \(testURL) doesn't seem to be a valid URL")
                    return
                }
                
                do {
                    let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                    print("HTML : \(myHTMLString)")
                    self.extUrl = testURL
                } catch let error {
                    print("Error: \(error)")
                testURL = "https://songwhip.com/album/\(replaced2.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))/\(replaced.lowercased().replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil))"
                    print("TEST \(testURL)")
                    guard let myURL = URL(string: testURL) else {
                        print("Error: \(testURL) doesn't seem to be a valid URL")
                        return
                    }
                    
                    do {
                        let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                        print("HTML : \(myHTMLString)")
                         self.extUrl = testURL
                        
                    } catch let error {
                        print("Error: \(error)")
                        testURL = self.extUrl
                         self.extUrl = testURL
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
        let dialogMessage = UIAlertController(title: "Disconnect Spotify", message: "Are you sure you want to sign out of Spotify account \(self.username)?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action) -> Void in
            
            SpotifyLogin.shared.logout()
            self.showLogin()
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
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
                self.gradientLayer.colors = [ UIColor.black.cgColor, self.customImage?.averageColor?.cgColor]
                print("Done setting image")
                self.stickerView.isHidden = false
                self.create.isHidden = false
                self.create.isEnabled = true
                self.spotBtn.isHidden = false
                //self.view.backgroundColor = self.customImage?.averageColor
                //self.activity.isHidden = true
                //self.activity.stopAnimating()
            }
            
        }
    }
    
    
func downloadImageSearch(from url: URL) {
    print("Download Started")
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
            self.create.isEnabled = true
            self.spotBtn.isHidden = false
           // self.view.backgroundColor = self.customImage?.averageColor
            DispatchQueue.main.async {
                self.demoSendSticker()
            }
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
