//
//  searchViewController.swift
//  SnapNP
//
//  Created by Clay Loneman on 6/15/19.
//  Copyright © 2019 Clay Loneman. All rights reserved.
//
import SwiftyJSON
import UIKit
import Alamofire
struct post {
    //let mainImage : UIImage!
    let name : String!
     let art : String!
    let identif : String!
    
}

class searchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var posts = [post]()

    
    var searchURL = String()
    
    typealias JSONStandard = [String : AnyObject]
    @IBOutlet weak var searchTextEntry: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextEntry.delegate = self
        searchTextEntry.becomeFirstResponder()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag

        searchTextEntry.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("cLEAR")
            posts.removeAll()
            tableView.reloadData()
       
        return true
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HeadlineTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HeadlineTableViewCell") as! HeadlineTableViewCell
        cell.actionBtn.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        cell.actionBtn.tag = indexPath.row
        cell.actionBtn.layer.cornerRadius = cell.actionBtn.frame.height/2
        cell.actionBtn.layer.borderWidth = 1
        cell.actionBtn.layer.borderColor = UIColor.clear.cgColor
        cell.titleLbl.text = posts[indexPath.row].name
        cell.authLbl.text = posts[indexPath.row].art
        
        
        return cell
    }
    @objc func connected(sender: UIButton){
        let buttonTag = sender.tag
        print(buttonTag)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        globalID = posts[indexPath.row].identif
        NotificationCenter.default.post(name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.count >= 2 && textField.text!.count % 2 == 0{
            print(textField.text!)
            self.searchSpot(input: textField.text!)
        }
    }
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
             let json = try JSON(data: JSONData)
            
            if let name = json["tracks"]["items"][0]["artists"][0]["name"].string {
                print(name)
                
                
            }
            if let tracks = readableJSON["tracks"] as? JSONStandard{
               
             var artist = "nil"
                var id = "nil"
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count{
                        if let name = json["tracks"]["items"][i]["artists"][0]["name"].string {
                            print(name)
                            artist = name
                            
                        }
                        if let identi = json["tracks"]["items"][i]["id"].string {
                            print(identi)
                            id = identi
                            
                        }
                        let item = items[i]
                        //print(item)
                        
                        //print(artist)
                        let name = item["name"] as! String
                        //let previewURL = item["preview_url"] as! String
                       
                       
                                
                            
                                
                        posts.insert(post.init(name: name, art: artist, identif: id),at: 0)
                        
                                //print(posts)
                        tableView.beginUpdates()
                        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                      
                        
                        tableView.endUpdates()
                        
                        
                    }
                    
                    
                }
                
            }
        }
        catch{
            print(error)
        }
        
        
    }
    func callAlamo(url : String){
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(key)",
            "Accept": "application/json"
        ]
        Alamofire.request(url, headers: headers).responseJSON(completionHandler: {
            response in
            self.parseData(JSONData: response.data!)
            //print(response.description)
        })
    }
    
    func searchSpot(input: String) {
        let keywords = input
        let finalKeywords = keywords.replacingOccurrences(of: " ", with: "+")
        
        
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords)&type=track&limit=2"
        
        print(searchURL)
        
        callAlamo(url: searchURL)
    }
}

class HeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var spotID: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var authLbl: UILabel!
    
}

