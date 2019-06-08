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
class ViewController: UIViewController {
    @IBOutlet weak var stickerView: UIView!
    @IBOutlet weak var create: UIButton!
    
    @IBOutlet weak var styleBtn: UIButton!
    var snapAPI = SCSDKSnapAPI()
    var isBlackTheme = true
    var username = ""
    var extUrl = ""
    var key = ""
    var artistName = ""
    var songTitle = ""
    var customImage = UIImage(named:"img.png")
    var urls = URL(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
      create.isHidden = true
        create.isEnabled = false
        create.layer.cornerRadius = create.frame.height/2
        create.layer.borderWidth = 1
        create.layer.borderColor = UIColor.black.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAllNotif), name: UIApplication.willEnterForegroundNotification, object: nil)
        snapAPI = SCSDKSnapAPI()
        iamgeView.isHidden = false
        }
  
    func refreshAll() {
         stickerView.isHidden = true
         create.isHidden = true
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
                self!.key = token!
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
                self!.key = token!
                self!.fetchTrackRequest()
                //self!.fetchTrackRequest()
                
                print(token!)
            }
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
    
    
    return
    }
    
    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
    //print("response = \(String(describing: response))")
    
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
                print("Done setting image")
                self.stickerView.isHidden = false
                self.create.isHidden = false
                self.create.isEnabled = true
            }
            
        }
    
    
}
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
