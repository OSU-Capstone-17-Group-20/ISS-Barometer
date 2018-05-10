//
//  Barometer.swift
//  ISS Barometer
//
//  Created by Daniel Kato on 12/15/17.
//  Copyright © 2017 ISSBarometer. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class Barometer {
    lazy var altimeter :CMAltimeter = CMAltimeter()
    var initialDeltaReading: Double?
    var pressureReadings = [(Double, Double)]()
    lazy var settings: Settings = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.settings
    }()
    var firstReading = true

    // REMOVE BEFORE DEPLOY <--
    var debugData:Double? = 100.0
    // -->
    
    func calcDeltaSum(_ dType: String) -> Double {
        var sum = 0.0
        if pressureReadings.count <= 1 {
            return 0
        }
        for idx in 1..<pressureReadings.count {
            let dp = pressureReadings[idx].0 - pressureReadings[idx-1].0
            let dt = pressureReadings[idx].1 - pressureReadings[idx-1].1
            sum += (dType == "dpdt" ? dp/dt : dt/dp)
        }
        return sum / Double(pressureReadings.count - 1)
    }
    
    func getDpdt() -> Double {
        return calcDeltaSum("dpdt")
    }
    
    func getDtdp() -> Double {
        return calcDeltaSum("dtdp")
    }
    
    func getDtdpStartTime() -> Double {
         return self.pressureReadings.first?.1 ?? Date().timeIntervalSince1970
    }
    
    func getDtdpEndTime() -> Double {
        return self.pressureReadings.last?.1 ?? Date().timeIntervalSince1970
    }
    
    func clearPressureReadings(){
        self.pressureReadings = [(Double, Double)]()
    }
    
    func updateInitialDeltaReading() {
        initialDeltaReading = nil
    }
    
    func kPa2units(kPa:Double) -> Double {
        switch settings.units {
            case "mmHg":
                return kPa * 7.50061683
            case "psi":
                return kPa / 6.89475729
            case "kPa":
                return kPa
            case "atm":
                return kPa / 101.325
            default:
                return kPa * 7.50061683
        }
    }
    
    func unit2kPa(pres:Double) -> Double {
        switch settings.units {
        case "mmHg":
            return pres / 7.50061683
        case "psi":
            return pres * 6.89475729
        case "kPa":
            return pres
        case "atm":
            return pres * 101.325
        default:
            return pres
        }
    }
    
    func startDisplayingPressureData(updateFunc:@escaping (Double, Double, Double) -> ()) {
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: {
            data, error in
            let kPa = data?.pressure.doubleValue
            let pressure = self.kPa2units(kPa: kPa!)
            let time = Date().timeIntervalSince1970
            if self.initialDeltaReading == nil {
                self.initialDeltaReading = pressure
            }
            self.pressureReadings.append((pressure, time))
            let deltaPressure = pressure - self.initialDeltaReading!
            updateFunc(pressure, deltaPressure, time)
            self.firstReading = false
        })
    }
    
    // REMOVE BEFORE DEPLOY
    func startDisplayingDebugData(updateFunc:@escaping (Double, Double, Double) -> ()) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            let time = Date().timeIntervalSince1970
            if (arc4random() % 2 == 0 || self.debugData! < 1){
                self.debugData = self.debugData! + drand48()
            } else {
                self.debugData = self.debugData! - drand48()
            }
            if self.initialDeltaReading == nil {
                self.initialDeltaReading = self.debugData!
            }
            let pressure = self.kPa2units(kPa: self.debugData!)
            self.pressureReadings.append((pressure, time))
            let deltaDebug = (self.debugData! - self.initialDeltaReading!)
            updateFunc(pressure, deltaDebug, time)
            self.firstReading = false
        }
    }
    
    func startBarometerUpdates(updateFunc:@escaping (Double, Double, Double) -> ()) {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            startDisplayingPressureData(updateFunc: updateFunc)
        } else {
            startDisplayingDebugData(updateFunc: updateFunc)
        }
    }
}
