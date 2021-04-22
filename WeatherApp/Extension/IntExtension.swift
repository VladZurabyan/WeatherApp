//
//  IntExtension.swift
//  WeatherApp
//
//  Created by Admin on 4/21/21.
//

import UIKit

extension Int {
    func incrementWeekDays(by num: Int) -> Int {
        let incrementedVal = self + num
        let mod = incrementedVal % 7
        
        return mod
    }
}
