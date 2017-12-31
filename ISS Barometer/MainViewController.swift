//
//  ViewController.swift
//  Barometer Test
//
//  Created by Daniel Kato on 10/21/17.
//  Copyright © 2017 Daniel Kato. All rights reserved.
//

import UIKit
import Charts

class MainViewController: UIViewController {
    @IBOutlet weak var pressureDisplay: UILabel!
    @IBOutlet weak var deltaPressureDisplay: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var deltaTimestamp: UILabel!
    @IBOutlet weak var currentTimestamp: UILabel!
    
    lazy var settings: Settings = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.settings
    }()
    
    var barometer = Barometer()
    lazy var chartViewController = childViewControllers[0] as! ChartViewController

    @IBAction func resetPressed(_ sender: Any) {
        barometer.updateInitialReading()
    }
    
    func updateUI(mmHg:Double, deltaMmHg:Double, time:Double, resetWasPressed:Bool) {
        // Set Pressure Readings
        let fString = "%.\(settings.sigFigs)f \(settings.units)"
        pressureDisplay.text = String(format:fString, mmHg)
        deltaPressureDisplay.text = String(format:fString, deltaMmHg)
        let date = Date(timeIntervalSince1970: time)
        currentTimestamp.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
        if resetWasPressed {
            deltaTimestamp.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
        }

        // Update Chart
        chartViewController.updateChart(pressureReading: mmHg, time: time)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barometer.settings = self.settings
        barometer.startBarometerUpdates(updateFunc: updateUI)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called before sequeing to the settings view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsSegue" {
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.settings = self.settings
        } else if segue.identifier == "ChartSegue" {
            let chartVC = segue.destination as! ChartViewController
            chartVC.settings = self.settings
        }
    }
}

