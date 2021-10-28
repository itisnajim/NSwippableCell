//
//  ViewController.swift
//  NSwippableCell
//
//  Created by itisnajim on 02/21/2021.
//  Copyright (c) 2021 itisnajim. All rights reserved.
//

import UIKit

import NSwippableCell

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let cellsCount = 16;
    let cellHeight: CGFloat = 96;
    var cellsCanClose: [IndexPath : Bool] = [:];
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var cellNumberTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(NSwippableCell.self, forCellWithReuseIdentifier: "cell");
        stepper.minimumValue = 1;
        stepper.maximumValue = Double(cellsCount);
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellsCount;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "cell";
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? NSwippableCell;
        let canClose = canCloseWhenOtherOpened(indexPath: indexPath);
        cell?.hideLeftRevealViewIfOtherOpened = canClose;
        cell?.hideRightRevealViewIfOtherOpened = canClose;
        let tag = indexPath.row + 200;
        cell?.tag = tag;
        if((cell?.contentView.viewWithTag(101)) != nil){
            (cell?.contentView.viewWithTag(101) as? UILabel)?.text = "Cell #"+String(indexPath.row+1);
            let b = cell?.contentView.viewWithTag(199)?.subviews.filter{($0 as? UIButton != nil)}.first as? UIButton;
            b?.tag = tag;
            b?.setTitle("close when other opened? "+String(canClose), for: .normal);
        }else{
            cell?.contentView.addSubview(getContentView(for: indexPath, cell: cell!))
        }
        
        cell?.contentView.tag = 100;
        cell?.rightRevealView = getRevealView(text: "RIGHT");
        cell?.leftRevealView = getRevealView(text: "LEFT");
        cell?.didRevealLeftView = { (visible: Bool) in
            self.showToast(message: "didRevealLeftView \nvisible="+String(visible))
        }
        cell?.didRevealRightView = { (visible: Bool) in
            self.showToast(message: "didRevealRightView \nvisible="+String(visible))
        }
        cell?.backgroundColor = .white;
        return cell!;
    }
    
    func getRevealView(text: String) -> UIView {
        let l = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: cellHeight)));
        l.text = text;
        l.textAlignment = .center;
        l.isUserInteractionEnabled = true;
        l.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.revealViewAction(sender:))));
        return l;
    }
    
    @objc func revealViewAction(sender: Any) {
        if let sender = sender as? UILabel {
            let alert = UIAlertController(title: "Alert", message: "The view containing the text "+(sender.text ?? "")+" was clicked", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func getContentView(for indexPath: IndexPath, cell: NSwippableCell) -> UIView {
        let v = UIView();
        v.tag = 199;
        v.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: cellHeight)
        let l = UILabel(frame: CGRect(x: 8, y: 0, width: 100, height: cellHeight));
        l.tag = 101;
        l.text = "Cell Number #"+String(indexPath.row+1);
        l.font = l.font.withSize(12)
        let b = UIButton(frame: CGRect(x: collectionView.frame.width-108, y: 8, width: 100, height: cellHeight - 16))
        b.tag = cell.tag;
        b.titleLabel?.numberOfLines = 0;
        b.titleLabel?.lineBreakMode = .byWordWrapping;
        b.titleLabel?.textAlignment = .center;
        b.setTitle("close when other opened? "+String(cell.hideRightRevealViewIfOtherOpened), for: .normal);
        b.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnMarkClose(sender:))));
        b.titleLabel?.font = b.titleLabel?.font.withSize(12)
        b.tintColor = .white;
        b.backgroundColor = UIColor.systemBlue;
        v.addSubview(b);
        v.addSubview(l);
        v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1);
        return v;
    }
    
    @objc func btnMarkClose(sender: UITapGestureRecognizer) {
        if let sender = sender.view as? UIButton, let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag-200, section: 0)) as? NSwippableCell {
            let indexPath = IndexPath(row: sender.tag-200, section: 0);
            let canClose = canCloseWhenOtherOpened(indexPath: indexPath);
            cell.hideRightRevealViewIfOtherOpened = !canClose;
            cell.hideLeftRevealViewIfOtherOpened = !canClose;
            setCanCloseWhenOtherOpened(canClose: !canClose, at: indexPath)
            sender.setTitle("close when other opened? "+String(!canClose), for: .normal);
        }
    }
    
    func canCloseWhenOtherOpened(indexPath: IndexPath) -> Bool{
        let canCloseResults = cellsCanClose.filter { indexPath.row == $0.key.row };
        var canClose = true;
        if(!canCloseResults.isEmpty){
            canClose = cellsCanClose[canCloseResults.first!.key] ?? true;
        }
        return canClose;
    }
    
    func setCanCloseWhenOtherOpened(canClose: Bool, at indexPath: IndexPath){
        let canCloseResults = cellsCanClose.filter { indexPath.row == $0.key.row };
        if(!canCloseResults.isEmpty){
            cellsCanClose[canCloseResults.first!.key] = canClose;
        }else{
            cellsCanClose[indexPath] = canClose;
        }
    }
    
    
    @IBAction func closeAllCellsAction(_ sender: Any) {
        collectionView.visibleCells.forEach({ (cell) in
            if let cell = cell as? NSwippableCell {
                cell.closeRevealedView(){
                    if let indexPath = self.collectionView.indexPath(for: cell){
                        self.showToast(message: "Cell at "+indexPath.description+" was closed")
                    }
                };
            }
        })
    }
    
    @IBAction func stepperAction(_ sender: Any) {
        cellNumberTextField.text = String(Int(stepper.value));
    }
    
    @IBAction func leftBtnAction(_ sender: Any) {
        swipeCell(at: IndexPath(row: Int(stepper.value-1), section: 0), to: .left)
    }
    @IBAction func rightBtnAction(_ sender: Any) {
        swipeCell(at: IndexPath(row: Int(stepper.value-1), section: 0), to: .right)
    }
    
    func swipeCell(at indexPath: IndexPath, to direction: UISwipeGestureRecognizer.Direction){
        print("swipeCell", indexPath, cellsCanClose.map{[$0.key.row : $0.value]});
        guard let cell = collectionView.cellForItem(at: indexPath) as? NSwippableCell else {
            return
        }
        cell.doSwipe(gestureDirection: direction);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController {

    func showToast(message : String, duration: TimeInterval = 3) {

        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
               toastContainer.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -75)
        self.view.addConstraints([c1, c2, c3])

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration - 0.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
}

