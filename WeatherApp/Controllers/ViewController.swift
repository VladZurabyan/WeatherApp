//
//  ViewController.swift
//  WeatherApp
//
//  Created by Admin on 4/21/21.
//

import UIKit
import CoreLocation

class ViewController: UITabBarController, UITabBarControllerDelegate{
    
    
    let networkManager = WeatherNetworkManager()
    
    let currentLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...Location"
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        
        label.font = UIFont.systemFont(ofSize: 38, weight: .heavy)
        return label
    }()
    
    let currentTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "28 March 2020"
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }()
    
    let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "°C"
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        return label
    }()
    
    let tempDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    let tempSymbol: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "cloud.fill")
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .gray
        return img
    }()
    let infoButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(systemName: "info.circle"), for: .normal)
        v.contentVerticalAlignment = .fill
        v.contentHorizontalAlignment = .fill
        v.imageView?.contentMode = .scaleAspectFit
        v.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(handleInfo), for: .touchUpInside)
        return v
    }()
    let refreshButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        v.contentVerticalAlignment = .fill
        v.contentHorizontalAlignment = .fill
        v.imageView?.contentMode = .scaleAspectFit
        v.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        return v
    }()
    
    
    let userDefaults = UserDefaults()
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation?
    var stackView : UIStackView!
    var latitude : CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiddleButton()
        
        if let valueName = userDefaults.value(forKey: "name") as? String {
            currentLocation.text = valueName
        }
        if let valueTime = userDefaults.value(forKey: "time") as? String {
            currentTime.text = valueTime
        }
        if let valueTemp = userDefaults.value(forKey: "temp") as? String {
            currentTemperatureLabel.text = valueTemp
        }
        if let valueTempDesc = userDefaults.value(forKey: "tempDesc") as? String {
            tempDescription.text = valueTempDesc
        }
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupViews()
        layoutViews()
        handleRefresh()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupMiddleButton() {
        let middleButton = UIButton(frame: CGRect(x: (self.view.bounds.width / 2) - 35, y: -25, width: 80, height: 80))
        
        middleButton.setBackgroundImage(UIImage(named: "ic_middle"), for: .normal)
        middleButton.layer.shadowColor = UIColor.black.cgColor
        middleButton.layer.shadowOpacity = 0.1
        middleButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        self.tabBar.addSubview(middleButton)
        middleButton.addTarget(self, action: #selector(handleAddPlaceButton), for: .touchUpInside)
        
        self.view.layoutIfNeeded()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        let location = locations[0].coordinate
        latitude = location.latitude
        longitude = location.longitude
        print("Long", longitude.description)
        print("Lat", latitude.description)
        loadDataUsingCoordinates(lat: latitude.description, lon: longitude.description)
    }
    
    
    
    
    func loadData(city: String) {
        networkManager.fetchCurrentWeather(city: city) { (weather) in
            print("Current Temperature", weather.main.temp.kelvinToCeliusConverter())
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" //yyyy
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                self.tempSymbol.loadImageFromURL(url: "http://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
                self.userDefaults.setValue("\(weather.name ?? "") , \(weather.sys.country ?? "")", forKey: "name")
                self.userDefaults.setValue("\(self.currentTime.text ?? "")", forKey: "time")
                self.userDefaults.setValue("\(self.currentTemperatureLabel.text ?? "")", forKey: "temp")
                self.userDefaults.setValue("\(self.tempDescription.text ?? "")", forKey: "tempDesc")
            }
        }
    }
    
    func loadDataUsingCoordinates(lat: String, lon: String) {
        networkManager.fetchCurrentLocationWeather(lat: lat, lon: lon) { (weather) in
            print("Current Temperature", weather.main.temp.kelvinToCeliusConverter())
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" //yyyy
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? ""), \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                
                self.tempSymbol.loadImageFromURL(url: "http://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
                
            }
        }
    }
    
    func setupViews() {
        view.addSubview(currentLocation)
        view.addSubview(currentTemperatureLabel)
        view.addSubview(tempSymbol)
        view.addSubview(tempDescription)
        view.addSubview(currentTime)
        view.addSubview(infoButton)
        view.addSubview(refreshButton)
    }
    
    func layoutViews() {
        
        currentLocation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        currentLocation.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18).isActive = true
        currentLocation.heightAnchor.constraint(equalToConstant: 150).isActive = true
        currentLocation.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor).isActive = true
        
        currentTime.topAnchor.constraint(equalTo: currentLocation.bottomAnchor, constant: 4).isActive = true
        currentTime.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        currentTime.heightAnchor.constraint(equalToConstant: 10).isActive = true
        currentTime.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        
        currentTemperatureLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        currentTemperatureLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        currentTemperatureLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        currentTemperatureLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        tempSymbol.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor).isActive = true
        tempSymbol.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        tempSymbol.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tempSymbol.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        tempDescription.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: 12.5).isActive = true
        tempDescription.leadingAnchor.constraint(equalTo: tempSymbol.trailingAnchor, constant: 8).isActive = true
        tempDescription.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tempDescription.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    //MARK: - Handlers
    @objc func handleAddPlaceButton() {
        let alertController = UIAlertController(title: "Add City", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "City Name(please write in english)"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            print("City Name: \(String(describing: firstTextField.text))")
            guard let cityname = firstTextField.text else { return }
            self.loadData(city: cityname)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
            print("Cancel")
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleRefresh() {
        let city = UserDefaults.standard.string(forKey: "SelectedCity") ?? ""
        loadData(city: city)
    }
    
    @objc func handleInfo() {
        let alertController = UIAlertController(title: "Information", message: "Application Developer Vlad Zurabyan, Telegram: @VladZurabyan", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            let alertController = UIAlertController(title: "Error", message: "You do not have access to your location", preferredStyle: .alert)
            let alertActionOne = UIAlertAction(title: "Enable Geolocation", style: .default) { (_) in
                if let bundleId = Bundle.main.bundleIdentifier,
                   let url = URL(string: "App-prefs:Privacy&path=LOCATION/\(bundleId)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            }
            let alertActionTwo = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(alertActionOne)
            alertController.addAction(alertActionTwo)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}


