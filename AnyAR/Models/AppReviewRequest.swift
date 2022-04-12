//
//  AppReviewRequest.swift
//  AnyAR
//
//  Created by Jack Battle on 4/10/22.
//

import UIKit
import StoreKit

enum AppReviewRequest {
    static var threshhold = 3
    
    static func reviewIfNeeded() {
        if let scene =  UIApplication.shared.connectedScenes.first as? UIWindowScene {
            
            SKStoreReviewController.requestReview(in: scene)
            
        }
    }
}
