//
//  WeatherManager.swift
//  Clima App
//
//  Created by Konstantin on 13.04.2022.
//

import Foundation
import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=37e6684bdee56dd6a3bc4d7c802e2218&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitide: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitide)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create a URL
        
        guard let url = URL(string: urlString) else { return }
        
        // 2. Create a URLSession
        
        let session = URLSession(configuration: .default)
        
        // 3. Give the session a task
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil {
                delegate?.didFailWithError(error: error!)
                return
            }
            
            guard let safeData = data else { return }
            guard let weather = parseJSON(safeData) else { return }
            delegate?.didUpdateWeather(self, weather: weather)
        }
        
        // 4. Start the task
        
        task.resume()
        
    }
    
    func parseJSON(_ wearheData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
        let decodedData = try decoder.decode(WeatherData.self, from: wearheData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
    
}
