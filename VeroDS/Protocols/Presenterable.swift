//
//  Presenterable.swift
//  VeroDS
//
//  Created by Murat Çiçek on 27.06.2023.
//

import Foundation

protocol Presenterable {
    //    associatedtype V: Viewable
    //    associatedtype I: Interactorable
    //    associatedtype R: Routerable
    //    associatedtype E: PresenterEntities
    //    var dependencies: (view: V, router: R, interactor: I, entities: E) { get }

    associatedtype I: Interactorable
    associatedtype R: Routerable
    var dependencies: (interactor: I, router: R) { get }
}
