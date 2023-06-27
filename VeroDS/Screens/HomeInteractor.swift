//
//  HomeInteractor.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation

final class HomeInteractor: Interactorable {
    let entities = HomeEntities()
    var presenter: HomeInteractorOutputs?
    
}
extension HomeInteractor: HomeInteractorInputs {
    
     func processData(data: Data, success: @escaping (() -> Void?)) {
         do {
             let decoder = JSONDecoder()
             HomeEntities.responseAPI = try decoder.decode([HomeEntities.Response].self, from: data)
             success()
         } catch {
             print("Error parsing JSON: \(error.localizedDescription)")
         }
     }
    
    func getDatas() {
        Api().getAPIData(accessToken: entities.accessToken, savedDataURL: entities.localDataURL!) {(result: Result<[HomeEntities.Response], Error>) in
            switch result {
            case .success(let success):
                self.presenter?.onSuccessSearch(data: success)
            case .failure(let failure):
                self.presenter?.onErrorSearch(error: failure.localizedDescription)
            }
        }
    }
    
    func getLocalDataURL(success: @escaping (() -> Void?)) {
        entities.localDataURL = Api().getLocalDataURL()
        success()
    }
    
    func getAccessToken(success: @escaping (() -> Void?)) {
        AccessToken().loginAPI { [weak self] accessToken  in
            self?.entities.accessToken = accessToken
            success()
        }
    }
    
}
