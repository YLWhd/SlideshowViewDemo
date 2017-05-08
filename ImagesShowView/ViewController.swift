//
//  ViewController.swift
//  ImagesShowView
//
//  Created by 袁利伟 on 17/5/8.
//  Copyright © 2017年 ylifegroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private lazy var imagesShowView: SlideshowView = {
        let view = SlideshowView()
        view.isAnimationScroll = false
        view.delegate = self
        return view
    }()
    
    var images: [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imagesShowView)
        imagesShowView.frame = view.bounds
        var imageArray:[UIImage] = []
        
        for i in 5 ... 11 {
            let image = UIImage(named: "timg-\(i)")
            imageArray.append(image!)
        }
        imagesShowView.imageArray = imageArray
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: SlideshowViewDelegate {
    
    func slideshowViewDidClickImage(view: SlideshowView, imageIndex index: Int) {
        
        let vc = UIAlertController(title: "提示", message: "点击了\(index)图片", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        vc.addAction(ok)
        self.present(vc, animated: true, completion: nil)
        
        
    }

}

