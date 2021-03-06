//
//  Settings.swift
//  ISS Barometer
//
//  Created by Daniel Kato on 12/29/17.
//  Copyright © 2017 ISSBarometer. All rights reserved.
//

import Foundation
import UIKit

class Settings: Codable {
    var units = "mmHg"
    var sigFigs = 3
    var orientation = "Up"
    var runningIntegrationInterval = 4
    var slidingScale = false
    var slidingScaleThreshold = 20
    var windowSize = 50
    var pressureBuffer = 58.66
}
