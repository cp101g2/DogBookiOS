//
//  EventViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/6.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    @IBOutlet weak var eventTableView: UITableView!
    
    let communicator = Communicator()
    let formatter = DateFormatter()
    
    var events = [Event]()
    var myDogId = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        
        formatter.dateFormat = "yyyyMMdd"
        eventDatePicker.locale = Locale(identifier: "zh_TW")
        eventDatePicker.date = Date()
        eventDatePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
    }
    
    @IBAction func addEventButtonPressed(_ sender: UIBarButtonItem) {
        
        let nextVC = UIStoryboard(name: "MyDogStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AddEvent") as! AddEventViewController
        nextVC.myDogId = myDogId
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    // MARK :- when datepicker valueChanged
    @objc
    func changeDate(datePicker:UIDatePicker){
        print(formatter.string(from: datePicker.date))
        let date = formatter.string(from: datePicker.date)
        getEvents(date:date)
    }
    
    // MARK :- get remote data
    func getEvents(date:String){
        var data = [String:Any]()
        data["status"] = GET_EVENTS
        data["dogId"] = myDogId
        data["date"] = Int(date)
        
        communicator.doPost(url: CalendarServlet, data: data) { (result) in
            
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONDecoder().decode([Event].self, from: result) else {
                return
            }
            
            self.events = output
            self.eventTableView.reloadData()
        }
    }
    
}
extension EventViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        let event = events[indexPath.row]
        cell.eventNameLabel.text = event.title
        cell.eventDescriptionLabel.text = event.overview
        cell.eventDateLabel.text = event.date!
    
        return cell
    }
    
    
}
