//
//  Mp3Cell.swift
//  exercise_music
//
//  Created by Billiard ball on 03.05.2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class Mp3Cell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var min_txt: UILabel!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songImg: UIImageView!
    @IBOutlet weak var lockImg: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var songName_constraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shadowRadius = 18
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowOpacity = 1.0
    }
}
