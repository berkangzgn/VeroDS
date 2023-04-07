//
//  ViewController.swift
//  VeroDS
//
//  Created by Berkan Gezgin on 6.04.2023.
//

import UIKit
import Reachability
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var qrBtn: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchV: UIView!
    @IBOutlet weak var resultTV: UITableView!
    
    private var accessToken = ""
    private var responseList: [Response]?
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let refreshControl = UIRefreshControl()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    /// Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkInternetConnection()
        
        self.resultTV.delegate = self
        self.resultTV.dataSource = self
        
        // Search view border and radius
        searchV.layer.borderColor = UIColor.separator.cgColor
        searchV.layer.borderWidth = 2.0
        searchV.layer.cornerRadius = 10
        
        searchTF.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        searchTF.returnKeyType = .search
        searchTF.keyboardType = .webSearch
        searchTF.delegate = self
        
        // Activity indicator opreations
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // Close keyboard anywhere
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // Pull-to-refresh created
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        resultTV.addSubview(refreshControl)
        
        // QR code operations
        captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    @IBAction func qrBtnClicked(_ sender: Any) {
        let session = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    /// pull-to-refresh operations
    @objc func refresh(_ sender: UIRefreshControl) {
        checkInternetConnection()
        
        sender.endRefreshing()
    }
    
    /// Textfield operations
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTF.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchData()
    }
    
    /// Search data with searchKey in responseList
    private func searchData() {
        guard !searchTF.text!.isEmpty && Response.responseAPI != nil else {
            return
        }
        
        responseList?.removeAll()
        
        // Search of all value
        for response in Response.responseAPI! {
            
            if response.BusinessUnitKey?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.businessUnit?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.colorCode?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.description?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.parentTaskID?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.preplanningBoardQuickSelect?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.task?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.title?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
                
            } else if response.workingTime?.range(of: searchTF.text!, options: .caseInsensitive) != nil {
                responseList?.append(response)
            }
        }
        
        if responseList?.isEmpty == true {
            responseList = Response.responseAPI
        }
        
        resultTV.reloadData()
    }
    
    /// API Login operations
    private func loginAPI() {
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

        self.activityIndicator.startAnimating()
        
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
                                
                                self.accessToken = accessToken
                                self.getAPIData()
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
    
    /// Get data after login operatiıons
    private func getAPIData() {
        guard let url = URL(string: "https://api.baubuddy.de/dev/index.php/v1/tasks/select") else {
            self.activityIndicator.stopAnimating()
            print("Invalid URL")
            return
        }

        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.activityIndicator.stopAnimating()
            return
        }
        
        let dataFileURL = documentsDirectoryURL.appendingPathComponent("data.json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if let error = error { // If offline
                if let savedData = try? Data(contentsOf: self.getLocalDataURL()) {
                    // If data saved, read here
                    self.processData(data: savedData)
                }
                
                print("Error fetching data: \(error.localizedDescription)")
                
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)

                do {
                    let responseService = try JSONDecoder().decode([Response].self, from: data)

                    // Verileri depola
                    do {
                        let data = try JSONEncoder().encode(responseService)
                        try data.write(to: dataFileURL)
                    } catch {
                        print("Error writing data: \(error.localizedDescription)")
                    }

                    if let savedData = try? Data(contentsOf: self.getLocalDataURL()) {
                        // If data saved, read here
                        self.processData(data: savedData)
                        
                        DispatchQueue.main.async {
                            self.resultTV.reloadData()
                        }
                        
                    }
                    
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    private func getLocalDataURL() -> URL {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataFileURL = documentDirectoryURL.appendingPathComponent("data.json")
        return dataFileURL
    }

    /// Read data from local
    private func processData(data: Data) {
        do {
            let decoder = JSONDecoder()
            Response.responseAPI = try decoder.decode([Response].self, from: data)
            responseList = Response.responseAPI
            
            DispatchQueue.main.async {
                self.resultTV.reloadData()
            }
            
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }
    
    /// Internet status check
    private func checkInternetConnection() {
        let reachability = try! Reachability()        
        if reachability.connection == .unavailable {  // offline
            if let savedData = try? Data(contentsOf: getLocalDataURL()) {
                processData(data: savedData)
            }
            
        } else { // online
            loginAPI()
        }
    }
    
    /// AVCaptureMetadataOutputObjectsDelegate func
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            searchTF.text = stringValue
        }

        dismiss(animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTV.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultTableViewCell

        var resultText: String?
        let currentResult = responseList![indexPath.row]
        
        if currentResult.title != nil { resultText = "\(String(describing: currentResult.title!))\n" }
        if currentResult.task != nil { resultText = "\(String(describing: currentResult.task!))\n" }
        if currentResult.description != nil { resultText = "\(String(describing: currentResult.description!))" }
        
        cell.textV.text = "\(resultText!)"
        cell.selectionStyle  = .none
        
        //TODO: cell background ayarlanacak
        
        return cell
    }
    
}

struct Response: Codable {
    static var responseAPI: [Response]?
    
    let BusinessUnitKey: String?
    let businessUnit: String?
    let colorCode: String?
    let description: String?
//    let isAvailableInTimeTrackingKioskMode: Int?
    let parentTaskID: String?
    let preplanningBoardQuickSelect: String?
//    let sort: Int?
    let task: String?
    let title: String?
    let wageType: String?
    let workingTime: String?
}

/*
 1+ "https://api.baubuddy.de/index.php/login" URL'sine bir POST isteği göndererek API'ye oturum açılacak. Bu, kullanıcının kimlik doğrulaması için gerekli.
 2+ API'den verileri çekmek için "https://api.baubuddy.de/dev/index.php/v1/tasks/select" URL'sine bir GET isteği gönderilecek.
 3+ Alınan verileri uygun bir veri yapısında saklanılacak.
 4+ Verileri liste olarak görüntülemek için bir UITableView oluşturulacak.
 5+ Verileri UITableView'e yüklenilecek ve hücrelerde gerekli özellikleri görüntülenecek.
 6+ Arama işlevselliği için bir arama çubuğu oluşturulacak ve arama kriterlerine göre verileri filtrelenecek.
 7? QR kod tarayıcısını kullanarak arama kriterlerini değiştirmek için bir seçenek eklenecek.
 8- Verileri yenilemek için bir pull-to-refresh işlevselliği eklenilecek.
 */
