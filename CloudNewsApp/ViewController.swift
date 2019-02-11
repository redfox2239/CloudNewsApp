//
//  ViewController.swift
//  CloudNewsApp
//
//  Created by REO HARADA on 2019/02/12.
//  Copyright © 2019年 reo harada. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var newsTableView: UITableView!
    var newsData: [NCMBObject] = []
    var imgCache: [String:Data] = [String:Data]()
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        
        let xib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        self.newsTableView.register(xib, forCellReuseIdentifier: "newsCell")
        
        self.refreshControl.addTarget(self, action: "reloadData", for: UIControl.Event.valueChanged)
        self.newsTableView.addSubview(self.refreshControl)
        
        NCMB.setApplicationKey("fb2e810af40e559d06478eea30924a2523293dd4a42bc61c70fad96e1b14e118", clientKey: "105886742ada1f577b54f5f25ca7664569b8f348bac6cfded691842072eacfed")
        let query = NCMBQuery(className: "news")
        query?.order(byDescending: "createDate")
        query?.limit = 50
        self.newsData = try! query?.findObjects() as! [NCMBObject]
        self.newsTableView.reloadData()
    }
    
    @objc func reloadData() {
        NCMB.setApplicationKey("fb2e810af40e559d06478eea30924a2523293dd4a42bc61c70fad96e1b14e118", clientKey: "105886742ada1f577b54f5f25ca7664569b8f348bac6cfded691842072eacfed")
        let query = NCMBQuery(className: "news")
        query?.order(byDescending: "createDate")
        query?.limit = 50
        self.newsData = try! query?.findObjects() as! [NCMBObject]
        self.newsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.newsTableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        cell.newsLabel.text = (self.newsData[indexPath.row].object(forKey: "title") as! String)
        let src = self.newsData[indexPath.row].object(forKey: "src") as! String
        let imgURL = URL(string: src)
        cell.newsImageView.image = nil
        if self.imgCache[src] != nil {
            cell.newsImageView.image = UIImage(data: self.imgCache[src]!)
        }
        else {
            DispatchQueue.global().async {
                let imgData = try! Data(contentsOf: imgURL!)
                self.imgCache[src] = imgData
                DispatchQueue.main.async {
                    cell.newsImageView.image = UIImage(data: imgData)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height / 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let href = self.newsData[indexPath.row].object(forKey: "href") as! String
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        next.urlStr = href
        self.show(next, sender: nil)
    }


}

