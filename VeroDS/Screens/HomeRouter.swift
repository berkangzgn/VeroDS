//
//  HomeRouter.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import UIKit

final class HomeRoute:Routerable  {
    internal weak var view: Viewable!


    let navigationController: UINavigationController

    var viewController: HomeViewController

    init(view: HomeViewController,viewable: Viewable) {
        self.viewController = view
        navigationController = UINavigationController(rootViewController: view)
        self.view = viewable
    }

}
