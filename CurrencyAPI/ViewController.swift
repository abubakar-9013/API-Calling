//
//  ViewController.swift
//  CurrencyAPI
//
//  Created by Muhammad Abubakar on 07/12/2020.
//

import UIKit
import Alamofire

struct Currency: Codable {
    
    struct allCurrencies :Codable {
        var currencyName:[Double]
    }
        
    var source:String
    var rates:[String:Double]
    
}

struct CurrencyConverter : Codable{
    
    var result:Double
    var text:String
}


struct SupportedCountries : Codable {
    
    var name: String?
    var countries:[Country]?
    var symbol:String
}
    
    struct Country: Codable {
        var name: String
        var flag: String
}


enum Currencies: String, Codable {
    case USD
    case PKR
    case INR
    case GBP
    case AED
}



class ViewController: UIViewController {
    
    let baseEndPoint = "https://v1.nocodeapi.com/abubakar/cx/VglZehMhtgsgxNoF"

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getCurrencyJSON(sourceCurrency: .USD )
//         getData(sourceCurrency: .USD) { (currencyData) in
//            for (currencyName, exchangeRate) in currencyData.rates {
//                print("CurrencyName: \(currencyName), CurrencyRate: \(exchangeRate)")
//
//            }
//        }
        
//        currencyConverter(amount: 5, fromCurreny: .USD, toCurrency: .PKR) { (data) in
//            print(data.text)
//        }
    
        supportedCountries { (countries) in
            print(countries)
        }
    }
    
    
    
    func getCurrencyJSON(sourceCurrency: Currencies) {
        
        let finalEndpoint = baseEndPoint + "/rates?source=\(sourceCurrency)"
        print(finalEndpoint)
        if let url = URL(string: "\(finalEndpoint)") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    print("Error is \(error)")
                }
                
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let result = try jsonDecoder.decode(Currency.self, from: data)
                        
                        for (key,value) in result.rates {
                            print("Key: \(key), Value: \(value)")
                        }
                    }
                    catch {
                        print("Error Occured \(error)")
                    }
                    
                }
            }.resume()
        }
        else {
            print("Invalid URL")
        }
    }
    
    
    
    func getData(sourceCurrency:Currencies, completion: @escaping(Currency) ->()) {
        
        let finalEndpoint = baseEndPoint + "/rates"
        let url = URL(string: "\(finalEndpoint)")!
        let params:[String:Currencies] = ["source": .USD, "target" : .PKR]
        
        
        let request = AF.request(url, method: .get, parameters: params)
        request.responseDecodable(of: Currency.self) { (response) in
            guard let result = response.value
            else {
                    print("Error is \(String(describing: response.error!.errorDescription))")
                    return
            }
            completion(result)
         }
     }
    
    
    
    func currencyConverter(amount:Double, fromCurreny:Currencies, toCurrency:Currencies, completion: @escaping (CurrencyConverter) ->()) {
        
        let baseEndpointForCurrency = baseEndPoint + "/rates/convert"
        let url = URL(string: "\(baseEndpointForCurrency)")!
        let params:[String:Any] = ["amount":amount, "from": "\(fromCurreny)", "to": "\(toCurrency)"]
        
        let request = AF.request(url, method: .get, parameters: params)
        request.responseDecodable(of: CurrencyConverter.self) { (response) in
        
            guard let result = response.value else {
                print("Error \(response.error.debugDescription)")
                return
            }
            
            completion(result)
        }
    }
    
    
    func supportedCountries(completion: @escaping([String: SupportedCountries]) -> ()) {
        let finalEndPoint = baseEndPoint + "/symbols"
        let url = URL(string: "\(finalEndPoint)")!
        
        let request = AF.request(url, method: .get)
        request.responseDecodable(of: [String: SupportedCountries].self) { (response) in
            
            guard let result = response.value else {
                print("Error : ", response.error.debugDescription)
                return
            }
          
            completion(result)
        }
    }
}

