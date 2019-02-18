//
//  HomePictureCell.swift
//  TrueInstagramApp
//
//  Created by Nazir on 30/12/2017.
//  Copyright © 2017 Nazir. All rights reserved.
//

import UIKit

class HomePictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picCell: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        
        picCell.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
}
