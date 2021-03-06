//
//  SettingsViewController.swift
//  ISS Barometer
//
//  Created by Daniel Kato on 12/29/17.
//  Copyright © 2017 ISSBarometer. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    var chartVC: ChartViewController!
    var barometer: Barometer!
    lazy var csv: Csv = Csv()
    lazy var settings: Settings = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.settings
    }()

    @IBOutlet weak var sigFigSlider: UISlider!
    @IBOutlet weak var sigFigValue: UILabel!
    @IBOutlet weak var unitPicker: UISegmentedControl!
    @IBOutlet weak var orientationPicker: UISegmentedControl!
    @IBOutlet weak var slidingScalePicker: UISwitch!
    @IBOutlet weak var runningWindowSlider: UISlider!
    @IBOutlet weak var runningWindowValue: UILabel!
    @IBOutlet weak var runningWindowOptions: UIView!
    @IBOutlet weak var runningWindowTable: UITableViewCell!
    @IBOutlet weak var shareSheet: UIBarButtonItem!
    @IBOutlet weak var integrationIntervalPicker: UISegmentedControl!
    
    @IBOutlet weak var minimumPressureUnit: UILabel!
    @IBOutlet weak var minimumPressureField: UITextField!
    @IBAction func shareSheetPressed(_ sender: Any) {
        let path = csv.createCsvFile(chartVC.dataEntries)
        let vc = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
        let popOver = vc.popoverPresentationController!
        popOver.sourceView = self.view
        popOver.barButtonItem = self.shareSheet
    }
    
    @IBAction func sliderMoved(_ sender: Any) {
        let roundedValue = lroundf(sigFigSlider.value)
        (sender as AnyObject).setValue(Float(roundedValue), animated: true)
        sigFigValue.text = String(roundedValue)
        settings.sigFigs = roundedValue
        barometer.updateInitialPressureReading = true
    }
    
    @IBAction func unitPicked(_ sender: Any) {
        let selectedIdx = unitPicker.selectedSegmentIndex
        let selectedUnit = unitPicker.titleForSegment(at: selectedIdx)
        let kpaOfField = Barometer().unit2kPa(pres: Double(minimumPressureField.text!)!)
        chartVC.convertDataPoints(unit: selectedUnit!)
        settings.units = selectedUnit!
        minimumPressureUnit.text = selectedUnit!
        minimumPressureField.text = String(format:"%.3f", Barometer().kPa2units(kPa: kpaOfField))
    }
    
    @IBAction func orientationPicked(_ sender: Any) {
        let selectedIdx = orientationPicker.selectedSegmentIndex
        let selectedOrientation = orientationPicker.titleForSegment(at: selectedIdx)
        settings.orientation = selectedOrientation!
        UIDevice.current.setValue(selectedIdx + 1, forKey: "orientation")
    }
    
    @IBAction func IntervalPicked(_ sender: Any) {
        let selectedIdx = integrationIntervalPicker.selectedSegmentIndex
        let selectedInterval = integrationIntervalPicker.titleForSegment(at: selectedIdx)
        settings.runningIntegrationInterval = Int(selectedInterval!)!
    }
    
    @IBAction func slidingScalePicked(_ sender: Any) {
        settings.slidingScale = slidingScalePicker.isOn
        initWindowSlider()
    }
    
    @IBAction func runningWindowSliderMoved(_ sender: Any) {
        let roundedValue = lroundf(runningWindowSlider.value)
        (sender as AnyObject).setValue(Float(roundedValue), animated: true)
        runningWindowValue.text = String(roundedValue*25)
        settings.windowSize = roundedValue*25
    }
    
    @IBAction func minimumPressureChanged(_ sender: Any) {
        if let pres = Double(minimumPressureField.text!) {
            settings.pressureBuffer = Barometer().unit2kPa(pres: pres)
        }
    }
    
    func initSlider() {
        sigFigValue.text = String(describing: settings.sigFigs)
        sigFigSlider.setValue(Float(settings.sigFigs), animated: true)
    }
    
    func initUnitPicker() {
        let unitPickerSegments = ["mmHg": 0, "psi": 1, "kPa": 2, "atm": 3]
        let segmentIdx = unitPickerSegments[settings.units]!
        unitPicker.selectedSegmentIndex = segmentIdx
    }
    
    func initOrientationPicker() {
        let orientationPickerSegments = ["Up": 0, "Down": 1, "Left": 2, "Right": 3]
        let segmentIdx = orientationPickerSegments[settings.orientation]!
        orientationPicker.selectedSegmentIndex = segmentIdx
    }

    func initIntegrationIntervalPicker() {
        let orientationPickerSegments = [1: 0, 2: 1, 4: 2, 6: 3, 8: 4, 10: 5]
        let segmentIdx = orientationPickerSegments[settings.runningIntegrationInterval]!
        integrationIntervalPicker.selectedSegmentIndex = segmentIdx
    }
    
    func initSlidingScalePicker() {
        slidingScalePicker.setOn((settings.slidingScale), animated: true)
    }
    
    func initWindowSlider() {
        if slidingScalePicker.isOn {
            runningWindowOptions.isHidden = false
            runningWindowTable.isHidden = false
        } else {
            runningWindowOptions.isHidden = true
            runningWindowTable.isHidden = true
        }
        runningWindowValue.text = String(describing: settings.windowSize)
        runningWindowSlider.setValue(Float(round(Double(settings.windowSize)/25.0)), animated: true)
    }
    
    func initMinPressure() {
        minimumPressureUnit.text = settings.units
        minimumPressureField.keyboardType = .numbersAndPunctuation
        minimumPressureField.text = String(format:"%.3f", Barometer().kPa2units(kPa: settings.pressureBuffer))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSlider()
        initUnitPicker()
        initOrientationPicker()
        initSlidingScalePicker()
        initWindowSlider()
        initIntegrationIntervalPicker()
        initMinPressure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


