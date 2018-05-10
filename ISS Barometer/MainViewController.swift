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
    @IBOutlet weak var yAxisLabel: UILabel!
    @IBOutlet weak var deltaTimestamp: UILabel!
    @IBOutlet weak var currentTimestamp: UILabel!
    @IBOutlet weak var dpdtDisplay: UILabel!
    @IBOutlet weak var dtdpDisplay: UILabel!
    @IBOutlet weak var dpdtToTimestamp: UILabel!
    @IBOutlet weak var dpdtFromTimestamp: UILabel!
    @IBOutlet weak var pressureDisplayUnit: UILabel!
    @IBOutlet weak var deltaPressureDisplayUnit: UILabel!
    @IBOutlet weak var dpdtDisplayUnit: UILabel!
    @IBOutlet weak var dtdpDisplayUnit: UILabel!
    @IBOutlet weak var deltaResetButton: UIButton!
    @IBOutlet weak var dpdtResetButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var tResButton: UIButton!
    @IBOutlet weak var tResDisplay: UILabel!
    
    
    var barometer = Barometer()
    var screenIsLocked = false
    var deltaResetWasPressed = false
    var dpdtResetWasPressed = false
    
    var currentPressure = 0.0
    var tResTimer: Timer!
    var tResTotal = 0.0
    
    lazy var chartViewController = childViewControllers[0] as! ChartViewController
    lazy var settings: Settings = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.settings
    }()

    @IBAction func deltaResetPressed(_ sender: Any) {
        barometer.updateInitialDeltaReading()
        deltaResetWasPressed = true
    }
    
    @IBAction func dpdtResetPressed(_ sender: Any) {
        dpdtDisplay.text = String(format:"%.\(settings.sigFigs)f", barometer.getDpdt())
        dtdpDisplay.text = String(format:"%.\(settings.sigFigs)f", barometer.getDtdp())
        let startDate = Date(timeIntervalSince1970: barometer.getDtdpStartTime())
        let endDate = Date(timeIntervalSince1970: barometer.getDtdpEndTime())
        dpdtFromTimestamp.text =  DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .medium)
        dpdtToTimestamp.text = DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .medium)
        barometer.clearPressureReadings()
    }
    
    @IBAction func screenLockPressed(_ sender: Any) {
        screenIsLocked = !screenIsLocked
        lockButton.setTitle(screenIsLocked ? "Unlock" : "Lock", for: .normal)
        settingsButton.isEnabled = !screenIsLocked
        dpdtResetButton.isEnabled = !screenIsLocked
        deltaResetButton.isEnabled = !screenIsLocked
        chartView.isUserInteractionEnabled = !screenIsLocked
    }
    
    @IBAction func tResButtonPressed(_ sender: Any) {
        let pressure = barometer.unit2kPa(pres: currentPressure)
        let rate = barometer.getDpdt()
        updateTRes(start: pressure, rate: rate)
    }
    
    func handleDeltaReset(_ date: Date) {
        if deltaResetWasPressed || barometer.firstReading {
            deltaTimestamp.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
            deltaResetWasPressed = false
        }
    }
    
    func updateTRes(start: Double, rate: Double){
        if rate < 0 {
            let buffer = settings.pressureBuffer // In kPa
            tResTotal = -((start - buffer) / rate)
            if tResTimer != nil {
                tResTimer.invalidate()
            }
            startTResTimer()
            print(tResTotal, " seconds")
        }
    }
    
    func secToString(seconds: Double) -> String {
        let intSec = Int(seconds)
        let hours = Int(intSec / 3600)
        let mins = Int((intSec % 3600) / 60)
        let secs = Int((intSec % 3600) % 60)
        let ms = Int(seconds.truncatingRemainder(dividingBy: 1.0) * 60.0)
        return String(format: "%02d:%02d:%02d:%02d", hours, mins, secs, ms)
    }
    
    func startTResTimer() {
        tResTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTResTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTResTimer(){
        tResDisplay.text =  secToString(seconds: tResTotal)
        tResTotal -= 0.1
        if tResTotal < 0.01 {
            endTResTimer()
        }
    }
    
    func endTResTimer(){
        tResTimer.invalidate()
    }
    
    func updateUI(pressure:Double, deltaPressure:Double, time:Double) {
        let date = Date(timeIntervalSince1970: time)
        currentPressure = pressure
        pressureDisplay.text = String(format:"%.\(settings.sigFigs)f", pressure)
        deltaPressureDisplay.text = String(format:"%.\(settings.sigFigs)f", deltaPressure)
        currentTimestamp.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
        handleDeltaReset(date)
        chartViewController.updateChart(pressureReading: pressure, time: time)
    }
    
    func adjustAxisLabels() {
        yAxisLabel.text = "Pressure (\(settings.units))"
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        yAxisLabel.sizeToFit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barometer.settings = self.settings
        barometer.startBarometerUpdates(updateFunc: updateUI)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setDisplayUnits() {
        pressureDisplayUnit.text = String(settings.units)
        dtdpDisplayUnit.text = "Sec/" + String(settings.units)
        dpdtDisplayUnit.text = String(settings.units) + "/Sec"
        deltaPressureDisplayUnit.text = String(settings.units)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDisplayUnits()
        adjustAxisLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsSegue" {
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.chartVC = self.chartViewController
        } else if segue.identifier == "ChartSegue" {
            let chartVC = segue.destination as! ChartViewController
            chartVC.barometer = barometer
        }
    }
}

