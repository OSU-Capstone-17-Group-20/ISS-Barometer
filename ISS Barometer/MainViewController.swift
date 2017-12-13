//
//  ViewController.swift
//  Barometer Test
//
//  Created by Daniel Kato on 10/21/17.
//  Copyright © 2017 Daniel Kato. All rights reserved.
//

import UIKit
import CoreMotion
import Charts

class MainViewController: UIViewController {
    @IBOutlet weak var pressureDisplay: UILabel!
    @IBOutlet weak var deltaPressureDisplay: UILabel!
    @IBOutlet weak var chartView: UIView!

    lazy var altimeter :CMAltimeter = CMAltimeter()
    var mmHg:Double? = 0.0
    var prevMmHg:Double? = 0.0
    var deltaMmHg:Double? = 0.0
    var prevTime:NSDate? = NSDate()
    var time:NSDate? = NSDate()
    var significantDigits:Int = 4
    lazy var chartViewController: ChartViewController = {
        return childViewControllers[0] as! ChartViewController
    }()
    
    func kPa2mmHg(kPa:Double) -> Double {
        let atm:Double = kPa * 101.325
        let mmHg:Double = atm / 760.0
        return mmHg
    }
    
    func handlePressureReading(data:CMAltitudeData) {
        let kPa = data.pressure.doubleValue
        prevTime = time
        time = NSDate()
        prevMmHg = mmHg
        mmHg = kPa2mmHg(kPa: kPa)
        deltaMmHg = (mmHg! - prevMmHg!) / (time?.timeIntervalSince(prevTime! as Date))!
        
        // Set Pressure Readings
        let fString = "%.\(significantDigits)f mmHg"
        pressureDisplay.text = String(format:fString, (mmHg)!)
        deltaPressureDisplay.text = String(format:fString, (deltaMmHg)!)
        
        // Update Chart
        chartViewController.updateChart(pressureReading: mmHg!,
                                        time: time!.timeIntervalSince1970)
    }
    
    func startDisplayingPressureData() {
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main,
                                               withHandler: { data, error in
            self.handlePressureReading(data: data!)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CMAltimeter.isRelativeAltitudeAvailable() {
            startDisplayingPressureData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
