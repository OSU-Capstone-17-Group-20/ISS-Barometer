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
    @IBOutlet weak var debugDataToggle: UISwitch!
    
    lazy var altimeter :CMAltimeter = CMAltimeter()
    var mmHg:Double? = 0.0
    var prevMmHg:Double? = 0.0
    var deltaMmHg:Double? = 0.0
    var prevTime:Double? = 0.0
    var time:Double? = 0.0
    var significantDigits:Int = 4
    var prevDebugData:Double? = 760.00
    var debugData:Double? = 0.0
    var deltaDebug:Double? = 0.0
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
        time = data.timestamp
        prevMmHg = mmHg
        mmHg = kPa2mmHg(kPa: kPa)
        deltaMmHg = (mmHg! - prevMmHg!) / (time! - prevTime!)
        
        // Set Pressure Readings
        let fString = "%.\(significantDigits)f mmHg"
        pressureDisplay.text = String(format:fString, (mmHg)!)
        deltaPressureDisplay.text = String(format:fString, (deltaMmHg)!)
        
        // Update Chart
        chartViewController.updateChart(pressureReading: mmHg!,
                                        time: time!)
    }
    
    func startDisplayingPressureData() {
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main,
                                               withHandler: { data, error in
            self.handlePressureReading(data: data!)
        })
    }
    
    //Debug Function to populate graph with random data, when barometer is unavalailable
    func startDisplayingDebugData() {
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.displayDebugData), userInfo: nil, repeats: true)
        //(timeInterval: 1, target: self, selector: #selector(MainViewController.displayDebugData), userInfo: nil, repeats: true)
        
    }
    
    @objc func displayDebugData() {
        print("hello")
        prevTime = time
        time = NSDate()
        debugData = debugData! - drand48()
        deltaDebug = (debugData! - prevDebugData!) / (time?.timeIntervalSince(prevTime! as Date))!
        prevDebugData = debugData!
        let fString = "%.\(significantDigits)f mmHg"
        pressureDisplay.text = String(format:fString, (debugData)!)
        deltaPressureDisplay.text = String(format:fString, (deltaDebug)!)
        chartViewController.updateChart(pressureReading: debugData!,
                                        time: time!.timeIntervalSince1970)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if CMAltimeter.isRelativeAltitudeAvailable() {
            startDisplayingPressureData()
        } else {
            startDisplayingDebugData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

