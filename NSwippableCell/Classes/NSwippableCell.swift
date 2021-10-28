//
//  NSwippableCell.swift
//  NSwippableCell
//
//  Created by itisnajim on 02/21/2021.
//  Copyright (c) 2021 itisnajim. All rights reserved.
//

import UIKit

open class NSwippableCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    public enum VisiblityState : String {
        case none = "NONE"
        case leftView = "LEFTVIEW"
        case rightView = "RIGHTVIEW"
    }

    public var visiblityState: VisiblityState = .none;
    
    public var rightRevealView: UIView? {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    public var leftRevealView: UIView? {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    public var hideRightRevealViewIfOtherOpened: Bool = true;
    public var hideLeftRevealViewIfOtherOpened: Bool = true;
    
    
    public var didRevealLeftView : ((Bool)-> Void)? = nil;
    public var didRevealRightView : ((Bool)-> Void)? = nil;
    
    
    private var _contentSnapshotView: UIView? = nil
    
    private func contentSnapshotView() -> UIView? {
        if _contentSnapshotView == nil {
            _contentSnapshotView = self.snapshotView()
            _contentSnapshotView?.backgroundColor = .clear
        }
        return _contentSnapshotView
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        if let _contentSnapshotView = _contentSnapshotView{
            self.contentView.addConstraints([NSLayoutConstraint.init(item: _contentSnapshotView, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 1, constant: 0), NSLayoutConstraint.init(item: _contentSnapshotView, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 1, constant: 0)])
            self.contentView.addConstraint(NSLayoutConstraint(item: _contentSnapshotView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0))
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
    }
    
    open override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self._contentSnapshotView?.removeFromSuperview()
        self._contentSnapshotView = nil
        self.leftRevealView?.removeFromSuperview()
        self.rightRevealView?.removeFromSuperview()
        self.leftRevealView = nil
        self.rightRevealView = nil
        self.visiblityState = .none
    }
    
    func setupView(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) -> Void {
        guard rightRevealView != nil || leftRevealView != nil else {
            return
        }
        let direction = gesture.direction;
        doSwipe(gestureDirection: direction);
    }
    
    public func doSwipe(gestureDirection: UISwipeGestureRecognizer.Direction){
        let revealView : UIView = ((gestureDirection == .left) ? rightRevealView ?? leftRevealView : leftRevealView ?? rightRevealView)!;
        revealView.isHidden = true
        self.contentView.addSubview(revealView)
        self.contentView.sendSubviewToBack(revealView)
        if(self._contentSnapshotView == nil){
            self.contentView.addSubview(self.contentSnapshotView()!)
            self.contentView.bringSubviewToFront(self._contentSnapshotView!)
        }
        if(self.visiblityState != .none){
            self.contentView.subviews.forEach { (view) in
                if(view != self._contentSnapshotView && view != self.rightRevealView && view != self.leftRevealView){
                    view.isHidden = true;
                }
            }
            if((gestureDirection == .right && self.visiblityState == .leftView) || (gestureDirection == .left && self.visiblityState == .rightView)){
                revealView.isHidden = false;
            }else{
                self.setRevealView(to: .none, animated: true, byUserInteraction: true);
            }
        }else{
            self.setRevealView(to: gestureDirection == .left ? .rightView : .leftView, animated: true, byUserInteraction: true);
            
        }
    }
    
    public func closeRevealedView(completion: (() -> Void)? = nil) {
        if(self.visiblityState != .none){
            self.setRevealView(to: .none, animated: true, completion: completion);
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard rightRevealView != nil || leftRevealView != nil else {
            return
        }
        if(leftRevealView != nil){
            let size = leftRevealView!.frame.size;
            leftRevealView?.frame = CGRect()
            leftRevealView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
            leftRevealView?.frame.size = size;
        }
        if(rightRevealView != nil){
            let size = rightRevealView!.frame.size;
            rightRevealView?.frame = CGRect()
            rightRevealView?.frame.origin = CGPoint(x: self.frame.width - size.width, y: 0.0)
            rightRevealView?.frame.size = size;
        }
        if(self._contentSnapshotView == nil){
            self.contentView.subviews.forEach { (view) in
                view.isHidden = false;
            }
        }
    }
    
    public func setRevealView(to state: VisiblityState, animated: Bool, byUserInteraction: Bool = false, completion: (() -> Void)? = nil) {
        if(state == .none && self.visiblityState != .none){
            if let _contentSnapshotView = self._contentSnapshotView, !_contentSnapshotView.center.equalTo(contentView.center){
                UIView.animate(withDuration: animated ? 0.1 : 0.0, delay: 0.0, options: .curveEaseOut, animations: {
                    _contentSnapshotView.center = CGPoint(x: self.frame.width / 2, y: _contentSnapshotView.center.y)
                }) { finished in
                    UIView.animate(withDuration: animated ? 0.1 : 0.0, delay: 0.0, options: .curveLinear, animations: {
                        _contentSnapshotView.center = CGPoint(x: self.visiblityState == .leftView ? self.center.x + 2.0 : self.center.x - 2.0, y: _contentSnapshotView.center.y)
                    }) { finished in
                        UIView.animate(withDuration: animated ? 0.1 : 0.0, delay: 0.0, options: .curveLinear, animations: {
                            _contentSnapshotView.center = CGPoint(x: self.frame.width / 2, y: _contentSnapshotView.center.y)
                        }) { finished in
                            
                            if byUserInteraction {
                                self.visiblityState == .leftView ? self.didRevealLeftView?(false) : self.didRevealRightView?(false)
                            }
                            self._contentSnapshotView?.removeFromSuperview()
                            self._contentSnapshotView = nil
                            self.rightRevealView?.removeFromSuperview()
                            self.leftRevealView?.removeFromSuperview()
                            
                            self.contentView.subviews.forEach({ (view) in
                                if(view != self._contentSnapshotView && view != self.rightRevealView && view != self.leftRevealView){
                                    view.isHidden = false;
                                }
                            })
                            self.visiblityState = .none
                            completion?()
                        }
                    }
                }
            }else{
                completion?()
            }
        }else if state != .none {
            guard rightRevealView != nil || leftRevealView != nil else {
                return
            }
            if(state == .leftView && leftRevealView != nil){
                leftRevealView?.isHidden = false;
                self.contentView.addSubview(leftRevealView!)
                self.contentView.sendSubviewToBack(leftRevealView!)
                startAnimation(state: state, duration: animated ? 0.1 : 0.0, completion: completion);
            }else if(state == .rightView && rightRevealView != nil){
                rightRevealView?.isHidden = false;
                self.contentView.addSubview(rightRevealView!)
                self.contentView.sendSubviewToBack(rightRevealView!)
                startAnimation(state: state, duration: animated ? 0.1 : 0.0, completion: completion);
            }else{
                completion?()
            }
        }
    }
    
    private func startAnimation(state: VisiblityState, duration: TimeInterval = 0.1, completion: (() -> Void)? = nil){
        
        if(self._contentSnapshotView == nil){
            self.contentView.addSubview(self.contentSnapshotView()!)
            self.contentView.bringSubviewToFront(self._contentSnapshotView!)
        }
        self._contentSnapshotView?.isHidden = false
        
        self.contentView.subviews.forEach { (view) in
            if(view != self._contentSnapshotView && view != self.rightRevealView && view != self.leftRevealView){
                view.isHidden = true;
            }
        }
        
        self.contentView.layoutIfNeeded()
        self._contentSnapshotView!.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut,
        animations: {
            let center = CGPoint(x: state == .leftView ? self.frame.width / 2 + self.leftRevealView!.frame.width : self.frame.width / 2 - self.rightRevealView!.frame.width, y: self._contentSnapshotView!.center.y)
            self._contentSnapshotView!.center = center
            self._contentSnapshotView!.layoutIfNeeded()
            self.contentView.layoutIfNeeded()
        }, completion: { (completed) in
            if(completed){
                if let superCollectionView = self.superCollectionView(){
                    superCollectionView.visibleCells.forEach({ (cell) in
                        if let cell = cell as? NSwippableCell, cell != self {
                            if (cell.hideRightRevealViewIfOtherOpened && cell.visiblityState == .rightView) || (cell.hideLeftRevealViewIfOtherOpened && cell.visiblityState == .leftView) {
                                cell.setRevealView(to: .none, animated: true)
                            }
                        }
                    })
                }
                
                state == .leftView ? self.didRevealLeftView?(true) : self.didRevealRightView?(true)
                self.visiblityState = state
                completion?()
            }
        })
    }
    
    private func superCollectionView() -> UICollectionView? {
        var superview: UIView? = self.superview
        
        while superview != nil {
            if (superview is UICollectionView) {
                return superview as? UICollectionView
            }
            
            superview = superview?.superview
        }
        
        return nil
    }
    
}

extension UIView {
    public func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }

    public func snapshotView() -> UIView? {
        if let snapshotImage = snapshotImage() {
            return UIImageView(image: snapshotImage)
        } else {
            return nil
        }
    }
}
