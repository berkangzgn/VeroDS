//
//  HomePresenter.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation
import UIKit
import Reachability
import AVFoundation

typealias HomePresenterDependencies = (
    interactor: HomeInteractor,
    router: HomeRoute
)

final class HomePresenter: Presenterable {
    
    var entites: HomeEntities
    var view: HomeViewInputs?
    let dependencies: HomePresenterDependencies
    
    init(view: HomeViewInputs,
         entites: HomeEntities,
         dependencies: HomePresenterDependencies) {
        self.view = view
        self.entites = entites
        self.dependencies = dependencies
    }
    
}
extension HomePresenter: HomeViewOutputs {
    func qrBtnClicked(controller: HomeViewController) {
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
        previewLayer.frame = controller.view.layer.bounds
        controller.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    
    func searchData(searchText: String) {
        guard !searchText.isEmpty && HomeEntities.responseAPI != nil else {
            return
        }
        entites.data?.removeAll()
       
        // Search of all value
        guard let datas = HomeEntities.responseAPI else {return}
        for response in datas {
            
            if response.BusinessUnitKey?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.businessUnit?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.colorCode?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.description?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.parentTaskID?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.preplanningBoardQuickSelect?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.task?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.title?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
                
            } else if response.workingTime?.range(of: searchText, options: .caseInsensitive) != nil {
                entites.data?.append(response)
            }
        }
        
        if entites.data?.isEmpty == true {
            entites.data = HomeEntities.responseAPI
        }
        
        view?.tableViewReload(tableViewDataSource: HomeTableViewDataSource(entities: entites))
    }
    
    func checkInternetConnection() {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable { // offline
            guard let url = entites.localDataURL else {return}
            
            if let savedData = try? Data(contentsOf: url) {
                dependencies.interactor.processData(data: savedData) {
                    self.entites.data = HomeEntities.responseAPI
                    self.view?.tableViewReload(tableViewDataSource: HomeTableViewDataSource(entities: self.entites))
                }
            }
            
        } else { // online
            dependencies.interactor.getAccessToken {
                self.dependencies.interactor.getLocalDataURL {
                    self.dependencies.interactor.getDatas()
                }
            }
        }
    }
    
    func viewDidLoad() {
        view?.indicatorView(animate: true)
        view?.configure()
        view?.configureSearchView()
        view?.configureTableView()
        view?.configureQrOperations()
        dependencies.interactor.getAccessToken {
            self.dependencies.interactor.getLocalDataURL {
                self.dependencies.interactor.getDatas()
            }
        }
    }
}

extension HomePresenter: HomeInteractorOutputs {
    func onSuccessSearch(data: [HomeEntities.Response]?) {
        guard let data = data else { return }
        entites.data = data
        HomeEntities.responseAPI = data
        view?.indicatorView(animate: false)
        view?.tableViewReload(tableViewDataSource: HomeTableViewDataSource(entities: entites))
    }
    
    func onErrorSearch(error: String) {
        print(error)
    }
    
}
