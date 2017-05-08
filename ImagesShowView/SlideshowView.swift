//
//  SlideshowView.swift
//  PersonalDemo
//
//  Created by 袁利伟 on 16/12/22.
//  Copyright © 2016年 venusourceyuan. All rights reserved.
//

import UIKit

public enum PageControlAlignment : Int {
    
    case BottomLeft
    case BottomCenter
    case BottomRight

}

protocol SlideshowViewDelegate:NSObjectProtocol {
    
    func slideshowViewDidClickImage(view:SlideshowView,imageIndex index:Int)
    
}

class SlideshowView: UIView {
    
    weak var delegate:SlideshowViewDelegate?
    var pageControlAlignment:PageControlAlignment = .BottomCenter
    var picTimeInterval:TimeInterval = 0.5
    var isAnimationScroll: Bool = true
    
    var currentPageIndicatorTintColor:UIColor {
        get{
            return pageControl.currentPageIndicatorTintColor!
        }
        set{
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }
    var pageIndicatorTintColor:UIColor {
        get{
            return pageControl.pageIndicatorTintColor!
        }
        set{
            pageControl.pageIndicatorTintColor = newValue
        }
    }
    var imageArray:[UIImage] = [] {
        didSet{
            imageCount = imageArray.count
            setImageScrollviewWithImages(count: imageArray.count)
            for (index,imageView) in imageViews.enumerated() {
                if index == 0 {
                    imageView.image = imageArray.last
                }else{
                    imageView.image = imageArray[(index - 1) % imageArray.count]
                }
            }
        }
    }
    var adImageViews:[UIImageView] {
        get{
            return imageViews
        }
    }
    
    var adImageCount:Int {
        get{
            return imageCount
        }
        set{
            imageCount = newValue
        }
    }
    fileprivate var picTimer:Timer?
    private var imageViews:[UIImageView] = []
    fileprivate var imageCount:Int = 0
    
    fileprivate lazy var imageScrollview:UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.isPagingEnabled = true
//        scrollview.backgroundColor = UIColor.redColor()
        scrollview.delegate = self
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        return scrollview
    }()
    
    fileprivate lazy var pageControl:UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPage = 0
//        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageScrollview)
        self.addSubview(pageControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setImageScrollviewWithImages(count:Int) {
        imageCount = count
        guard count != imageViews.count else {
            return
        }
        clearImageViews()
        for index in 0 ..< count + 2 {
            let imageView = UIImageView()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.didClickImage(tap:)))
            imageView.addGestureRecognizer(tap)
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageScrollview.addSubview(imageView)
            imageViews.append(imageView)
        }
        setNeedsLayout()
    }
    var imageScrollviewEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero {
        
        didSet{

        }
        
    }
    
    
    
    //MARK: - 布局视图
    override func layoutSubviews() {
        super.layoutSubviews()

        let x = imageScrollviewEdgeInsets.left
        let y = imageScrollviewEdgeInsets.top
        let width = bounds.width - (imageScrollviewEdgeInsets.left + imageScrollviewEdgeInsets.right)
        let height = bounds.height - (imageScrollviewEdgeInsets.top + imageScrollviewEdgeInsets.bottom)
        imageScrollview.frame = CGRect(x: x, y: y, width: width, height: height)
        layoutScrollviewWithImages()
        layoutPageControl(count: imageCount)
        
    }
    
    private func layoutScrollviewWithImages() {
        
        let width = imageScrollview.bounds.width
        let height = imageScrollview.bounds.height
        var x:CGFloat = 0
        for (index,imageView) in imageViews.enumerated() {
            x = CGFloat(index) * width
            imageView.frame = CGRect(x: x, y: 0, width: width, height: height)
            
        }
        imageScrollview.contentSize = CGSize(width: width * CGFloat(imageViews.count), height: height)
        imageScrollview.contentOffset = CGPoint(x: width, y: 0)
        
    }
    
    private func layoutPageControl(count:Int) {
        pageControl.numberOfPages = count
        let pageControlSize = pageControl.size(forNumberOfPages: count)
        var pageControlX:CGFloat = 0
        var pageControlY:CGFloat = 0
        let space:CGFloat = 10
        switch pageControlAlignment {
        case .BottomLeft:
            pageControlX = 0
            pageControlY = self.bounds.height - pageControlSize.height
        case .BottomRight:
            pageControlX = self.bounds.width - space - pageControlSize.width
            pageControlY = self.bounds.height - pageControlSize.height
        default:
            pageControlX = (self.bounds.width - pageControlSize.width) * 0.5
            pageControlY = self.bounds.height - pageControlSize.height
        }
        pageControl.frame = CGRect(x: pageControlX, y: pageControlY, width: pageControlSize.width, height: pageControlSize.height)
        
        
    }
    
    private func clearImageViews() {
        for view in imageScrollview.subviews {
            view.removeFromSuperview()
        }
        imageViews = []
    }
    
    //MARK: - 布局视图
    func didClickImage(tap:UITapGestureRecognizer) {
        
        let view = tap.view as! UIImageView
        var index = view.tag
        if index == 0 {
            index = imageCount - 1
        }else if index == imageCount + 1 {
            index = 0
        }else{
            index -= 1
        }
        self.delegate?.slideshowViewDidClickImage(view: self, imageIndex: index)
        
    }
    


    func starTime() {
        
        guard isAnimationScroll else {
            return
        }
        
        if let picTimer = picTimer {
            if picTimer.isValid {
                stopTime()
            }
        }
        guard imageCount > 0 else {
            return
        }
        let timer = Timer(timeInterval: picTimeInterval, target: self, selector: #selector(self.changeScrollViewContentOffset), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        self.picTimer = timer
    }
    
    func stopTime() {
        guard let picTimer = picTimer else { return  }
        picTimer.invalidate()
        self.picTimer = nil
    }
    
    
    func changeScrollViewContentOffset() {
        
        var currentOffset = imageScrollview.contentOffset
        currentOffset.x += imageScrollview.bounds.width
        
        if (currentOffset.x > imageScrollview.bounds.size.width * CGFloat(imageCount + 1)) {
            currentOffset.x = imageScrollview.bounds.size.width
            self.imageScrollview.contentOffset = currentOffset;
            currentOffset.x += imageScrollview.bounds.size.width
        }
        
        if (currentOffset.x == 0) {
            currentOffset.x = imageScrollview.frame.size.width * CGFloat(imageCount - 1)
            imageScrollview.contentOffset = currentOffset
            currentOffset.x += imageScrollview.bounds.size.width
        }
        
        let page = currentOffset.x / imageScrollview.bounds.size.width
        var curPage = Int(page)
        if (curPage == 1) {
            curPage = 0
        }else if (curPage == imageCount + 1) {
            curPage = 0
        }else{
            curPage -= 1
        }
        imageScrollview.setContentOffset(currentOffset, animated: true)
        pageControl.currentPage = curPage % imageCount
        
    }


    


}

extension SlideshowView:UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        stopTime()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if isAnimationScroll {
            picTimer = Timer(timeInterval: picTimeInterval, target: self, selector: #selector(SlideshowView.starTime), userInfo: nil, repeats: false)
            RunLoop.main.add(picTimer!, forMode: RunLoopMode.commonModes)
        }
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset
        
        let curPage = currentOffset.x / imageScrollview.bounds.width
        var index = Int(curPage)
        if index == 0 {
            index = imageCount - 1
            imageScrollview.contentOffset = CGPoint(x: imageScrollview.bounds.width * CGFloat(imageCount), y: 0)
        }else if index == imageCount + 1 {
            index = 0
            imageScrollview.contentOffset = CGPoint(x: imageScrollview.bounds.width, y: 0)
        }else {
            index -= 1
        }
        pageControl.currentPage = index % imageCount
        
    }
    
    

}


