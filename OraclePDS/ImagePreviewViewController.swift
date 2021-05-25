//
//  ImagePreviewViewController.swift
//  OraclePDS
//
//  Created by Arun CP on 25/05/21.
//

import UIKit

class ImagePreviewController: UIViewController {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    public var image = UIImage()
    
    override func viewDidLoad() {
        self.imageView.image = image
    }
    
    
    
    
    @IBAction func btnActionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
