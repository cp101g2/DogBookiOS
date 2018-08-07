//
//  AddEventViewController.swift
//  DogBook
//
//  Created by 李一正 on 2018/8/6.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController {
    
    let communicator = Communicator()
    let formatter = DateFormatter()
    
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventLocationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventOverViewTextField: UITextField!
    
    var myDogId = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        formatter.dateFormat = "yyyy-MM-dd"
    }

    @IBAction func showDatePicker(_ sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = NSDate() as Date
        datePicker.addTarget(self, action: #selector(show(datePicker:)), for: .valueChanged)
        eventDateTextField.inputView = datePicker
    }
    
    
    @IBAction func createEventButtonPressed(_ sender: UIBarButtonItem) {
        if myDogId == -1 {
            return
        }

        let name = eventNameTextField.text
        let location = eventLocationTextField.text
        
        
        let date = eventDateTextField.text!
//        print(date)
        
        let overview = eventOverViewTextField.text

        let event = Event(eventId: nil, type: nil, title: name, overview: overview, location: location, date: date)

        sendEvent(event: event)
    }
    
    @objc
    func show(datePicker:UIDatePicker){
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        eventDateTextField.text = dateFormater.string(from: datePicker.date)
    }
    
    func sendEvent(event:Event){
        
        var data = [String:Any]()
        data["status"] = ADD_EVENT
        data["dogId"] = myDogId
        
        guard let uploadData = try? JSONEncoder().encode(event) else {
            return
        }
        
        // 將要送出的 data 轉為 jsonString
        let jsonString = String(data: uploadData, encoding: .utf8)
        
        data["event"] = jsonString
        
        communicator.doPost(url: CalendarServlet, data: data) { (result) in
            guard let result = result else {
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: result, options: []) as! [String:Int] else {
                return
            }
            
            if output["result"] == 1 {
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }

}
