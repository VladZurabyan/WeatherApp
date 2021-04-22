//
//  SelfConfiguringCell.swift
//  WeatherApp
//
//  Created by Admin on 4/21/21.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with item: ForecastTemperature)
}
