//
//  DetailViewController.swift
//  UISearchBarDemo
//
//  Created by vivo on 4/3/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var candyImageView: UIImageView!
    
    var candy: Candy? {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    
    func configureView() {
        if let candy = candy,
           let detailDescriptionLabel = detailDescriptionLabel,
           let candyImageView = candyImageView {
            detailDescriptionLabel.text = candy.name
            candyImageView.image = UIImage(named: candy.name)
            title = candy.category.rawValue
        }
    }

}
