//
//  FriendPageSwitchViewController.swift
//  DogBook
//
//  Created by Apple on 2018/7/24.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class FriendPageSwitchViewController: UIViewController {
    
    @IBOutlet weak var switchPageControl: UISegmentedControl!
    @IBOutlet weak var friendView: UIView!
    
    let friendListVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbFriendList") as! FriendListViewController
    let searchVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbSearch")
    let pairVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbPair")
    let addListVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbAddList")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendListVC.myNavigation = self.navigationController
        friendView.addSubview(friendListVC.view)
        
        switchPageControl.selectedSegmentIndex = 0
        switchPageControl.isHidden = false
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func test(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "FriendStoryboard", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "sbPair") as! PairViewController
        navigationController?.pushViewController(destination, animated: true)
    }
    
    
    
    @IBAction func selectValueChanged(_ sender: UISegmentedControl) {
        
        switch switchPageControl.selectedSegmentIndex {
        case 0:
            friendListVC.myNavigation = self.navigationController
            self.friendView.addSubview(friendListVC.view)
            
        case 1:
       
            friendView.addSubview(searchVC.view)
            
        case 2:
           
            friendView.addSubview(pairVC.view)
            
        case 3:
          
            friendView.addSubview(addListVC.view)
            
        default:

            friendView.addSubview(friendListVC.view)
            
        }        
    }
    
}
