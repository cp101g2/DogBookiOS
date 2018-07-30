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
    
    let friendListVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbFriendList")
    let searchVC = UIStoryboard(name: "FriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "sbSearch")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        friendView.addSubview(friendListVC.view)
        
        switchPageControl.selectedSegmentIndex = 0
        switchPageControl.isHidden = false
        //        friendListView.addSubview(friendListVC.view)
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
    
    @IBAction func selectValueChanged(_ sender: UISegmentedControl) {
        
        switch switchPageControl.selectedSegmentIndex {
        case 0:
            friendView.addSubview(friendListVC.view)
        case 1:
            friendView.addSubview(searchVC.view)
//        case 2:
//            friendView.addSubview(pairVC.view)
        default:
            friendView.addSubview(friendListVC.view)
        }
        
    }
    
}