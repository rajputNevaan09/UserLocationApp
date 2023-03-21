//
//  MyRideVC.swift
//  UserLocationApp
//
//  Created by Bhagwan Rajput on 21/03/23.
//

import UIKit

class MyRideVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblMyRides: UITableView!
    
    let coreDM =  CoreDataManager()
    var rides: [Ride] = [Ride]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        rides =  coreDM.getAllRide()
        if (rides.count > 0) {
            tblMyRides.reloadData()
        }
        print("my rides data is::",rides)
        tblMyRides.delegate = self
        tblMyRides.dataSource = self
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if rides.count > 0 {
            let cell: MyRideCellTableViewCell = self.tblMyRides.dequeueReusableCell(withIdentifier: "myRideCellTableViewCell") as! MyRideCellTableViewCell
            let item = rides[indexPath.row]
            cell.lblNumOfRide.text! = "Ride \(indexPath.row + 1)"
            let formattedDate = "\(String(describing: item.date!))"
            let actualDate = dateFormatter(dateString: formattedDate)
            
            cell.lblDateRide.text! = "\(actualDate)"
            cell.lblDistance.text! = "\(item.distance) Meters"
            let sec = Double(round(1000 * item.duration) / 1000)
            cell.lblTimeTaken.text! = "\(sec) Seconds"
            return cell
        } else {
            return UIView() as! UITableViewCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    func dateFormatter (dateString:String) -> String {
        let dateFormatter = DateFormatter()
        
        // Set the input format of the date string
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        if let date = dateFormatter.date(from: dateString) {
            // Set the desired output format of the date
            dateFormatter.dateFormat = "hh:mm a 'on' MMMM dd, yyyy"
            let formattedDate = dateFormatter.string(from: date)
            print(formattedDate) // Output: "21 March 2023, 01:05:39 PM UTC"
            return formattedDate
        } else {
            print("Invalid date string")
            return dateString
        }
        
    }
}
