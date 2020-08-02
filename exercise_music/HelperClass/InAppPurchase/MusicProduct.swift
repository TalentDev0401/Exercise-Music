//
//  MusicProduct.swift
//  exercise_music
//
//  Created by Billiard ball on 08.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

public struct MusicProduct {
    
    public static let monthlySub = "com.mark.exercisemusic.comm.studios.LLC"
//    public static let yearlySub = "com.razeware.poohWisdom.yearlySub"
    public static let store = IAPManager(productIDs: MusicProduct.productIDs)
    private static let productIDs: Set<ProductID> = [MusicProduct.monthlySub]
    
}

public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
