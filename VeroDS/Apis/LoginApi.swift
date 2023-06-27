//
//  LoginApi.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation

final class AccessToken {
    func loginAPI(success: @escaping ((String) -> Void?)) {
    let headers = [
      "Authorization": "Basic QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz",
      "Content-Type": "application/json"
    ]

    let parameters = [
      "username": "365",
      "password": "1"
    ] as [String : Any]

    let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

    let request = NSMutableURLRequest(url: NSURL(string: "https://api.baubuddy.de/index.php/login")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.httpBody = postData as Data

    
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
        if let error = error {
            print(error)
        } else if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            if statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let oauth = json["oauth"] as? [String: Any], let accessToken = oauth["access_token"] as? String {
                            print("Access Token: \(accessToken)")
                            success(accessToken)
                        }
                    }
                } catch {
                    print(error)
                }
            } else {
                print("Status Code: \(statusCode)")
            }
        }
    }

    dataTask.resume()
}

}

