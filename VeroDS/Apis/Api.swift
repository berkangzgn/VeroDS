//
//  Api.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation
final class Api {
    func getAPIData<T: Codable>(accessToken: String, savedDataURL: URL, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "https://api.baubuddy.de/dev/index.php/v1/tasks/select") else {
           
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
           
            completion(.failure(NSError(domain: "Failed to access documents directory", code: 0, userInfo: nil)))
            return
        }
        
        let dataFileURL = documentsDirectoryURL.appendingPathComponent("data.json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {  (data, response, error) in

            
            if let error = error { // If offline
                if let savedData = try? Data(contentsOf: savedDataURL) {
                    // If data saved, read here
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: savedData)
                        completion(.success(decodedData))
                    } catch {
                        print("Error parsing saved data: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                
                do {
                    let responseService = try JSONDecoder().decode(T.self, from: data)
                    
                    // Verileri depola
                    do {
                        let encodedData = try JSONEncoder().encode(responseService)
                        try encodedData.write(to: dataFileURL)
                    } catch {
                        print("Error writing data: \(error.localizedDescription)")
                    }
                    
                    if let savedData = try? Data(contentsOf: savedDataURL) {
                        // If data saved, read here
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: savedData)
                            completion(.success(decodedData))
                            
                        } catch {
                            print("Error parsing saved data: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                    
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    func getLocalDataURL() -> URL {
       let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       let dataFileURL = documentDirectoryURL.appendingPathComponent("data.json")
       return dataFileURL
    }
}


