//
//  DevRepository.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation

class DevRepository: Repository {
    var router: Router<DeveloperAPI>
    
    init(router: Router = Router()) {
        self.router = router
    }
    
    func get(_ id: Int) -> Developer? {
        return nil
    }
    
    func getListPage(_ page: Int) -> [Developer] {
        
    }
}
    
    
    
    
    
    
}
