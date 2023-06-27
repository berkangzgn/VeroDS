//
//  HomeConfigurator.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation

final class HomeConfigurator {

    static let sharedInstance = HomeConfigurator()
    
    func configure(viewController: HomeViewController) {
        let interactor = HomeInteractor()
        let dependencies = HomePresenterDependencies(interactor: interactor, router: HomeRoute(view: viewController, viewable: viewController))
        let presenter = HomePresenter(view: viewController, entites: HomeEntities(), dependencies: dependencies)
        viewController.tableViewDataSource = HomeTableViewDataSource(entities: HomeEntities())
        viewController.presenter = presenter
        interactor.presenter = presenter
    }
}
