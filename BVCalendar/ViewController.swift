//
//  ViewController.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 28..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendar: BVCalendar! {
        didSet {
            calendar.allowsRangeSelection = true
//            calendar.selectedDate = Calendar.current.date(byAdding: .month, value: 2, to: Date())
//            calendar.setSelectedRange(from: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
//                                      to: Calendar.current.date(byAdding: .day, value: 18, to: Date())!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }


    @IBAction func buttonpressed(_ sender: Any) {
        print(calendar.selectedDate)
//        print("\(calendar.rangeStartDate) - \(calendar.rangeEndDate)")
    }
}

