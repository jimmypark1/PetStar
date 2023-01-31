//
//  MGPaginationHelper.swift
//  PetStarGram
//
//  Created by Junsung Park on 2018. 7. 24..
//  Copyright © 2018년 Junsung Park. All rights reserved.
//

import UIKit

protocol MGKeyed {
    var key: String? { get set }
}

class MGPaginationHelper<T: MGKeyed> {
    enum MGPaginationState {
        case initial
        case ready
        case loading
        case end
    }
    
    // MARK: - Properties
   
    let pageSize: UInt
    let serviceMethod: (UInt, String?, @escaping (([T]) -> Void)) -> Void
    var state: MGPaginationState = .initial
    var lastObjectKey: String?
    // MARK: - Init
  
    init(pageSize: UInt = 2, serviceMethod: @escaping (UInt, String?, @escaping (([T]) -> Void)) -> Void) {
        self.pageSize = pageSize
        self.serviceMethod = serviceMethod
    }
    
    func paginate(completion: @escaping ([T]) -> Void) {
        // 2
        switch state {
        // 3
        case .initial:
            lastObjectKey = nil
            fallthrough
        // 4
        case .ready:
            state = .loading
            serviceMethod(pageSize, lastObjectKey) { [unowned self] (objects: [T]) in
                // 5
                defer {
                // 6
                if let lastObjectKey = objects.last?.key {
                self.lastObjectKey = lastObjectKey
                }
                // 7
                self.state = objects.count < Int(self.pageSize) ? .end : .ready
                }
                // 8
                guard let _ = self.lastObjectKey else {
                return completion(objects)
                }
                // 9
                let newObjects = Array(objects.dropFirst())
                completion(newObjects)
                }
        // 10
        case .loading, .end:
            return
        }
    }
    func reloadData(completion: @escaping ([T]) -> Void) {
        state = .initial
            paginate(completion: completion)
    }
}
