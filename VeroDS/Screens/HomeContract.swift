//
//  HomeContract.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation
import AVFoundation
import UIKit

protocol HomeViewInputs: AnyObject {
    func configure()
    func tableViewReload(tableViewDataSource: TableViewDataSource)
    func configureSearchView()
    func configureTableView()
    func configureQrOperations()
    func indicatorView(animate: Bool)
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
}
protocol HomeViewOutputs: AnyObject {
    func viewDidLoad()
    func checkInternetConnection()
    func searchData(searchText: String)
    func qrBtnClicked(controller: HomeViewController)
    
}
protocol HomeInteractorOutputs: AnyObject {
    func onSuccessSearch(data: [HomeEntities.Response]?)
    func onErrorSearch(error: String)
}
protocol HomeInteractorInputs: AnyObject {
    func getAccessToken(success: @escaping (() -> Void?))
    func getLocalDataURL(success: @escaping (() -> Void? ))
    func getDatas()
    func processData(data: Data, success: @escaping (() -> Void?))
}
