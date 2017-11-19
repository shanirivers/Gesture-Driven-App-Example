//
//  TableViewCell.swift
//  GestureDrivenTest
//
//  Created by Shani on 11/15/17.
//  Copyright © 2017 Shani Rivers. All rights reserved.
//  REFERENCE: https://www.raywenderlich.com/77974/making-a-gesture-driven-to-do-list-app-like-clear-in-swift-part-1

import UIKit
import QuartzCore

// Need a protocol to let the vc know that something happened, state change
// This code defines a protocol with a required method that indicates an item has been deleted.
protocol TableViewCellDelegate
{
     //indicates that the given item has been deleted
    func toDoItemDeleted(todoItem: ToDoItem)
}


class TableViewCell: UITableViewCell
{
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, completeOnDragRelease = false
    var tickLabel: UILabel?, crossLabel: UILabel?
    
    // strike through text properties
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    
    // The following properties are going to be used in the protocol above (both are optional, bc their values will be set in the ViewController.swift file):
    // the object that acts as delegate for this cell
    var delegate: TableViewCellDelegate?
    
    //The item that this cell renders
    var toDoItem: ToDoItem?
    {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.isHidden = !label.strikeThrough
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        // *** ORDER HERE IS SUPER IMPORTANT!!!! ****
        // MARK: Strike Through Label
        // create label that renders the to-do item text
        label = StrikeThroughText(frame: CGRect.null)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        
        // MARK: Super Init
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        // MARK: Add label subview
        addSubview(label)
        
        // and remove default gray highlight for selected cells
        selectionStyle = .none
        
        // and add a layer that renders green background for complete items
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor.green.cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0)
        
        //tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel?.text = "\u{2713}"
        tickLabel?.textAlignment = .right
        addSubview(tickLabel!)
        
        crossLabel = createCueLabel()
        crossLabel?.text = "\u{2717}"
        tickLabel?.textAlignment = .left
        addSubview(crossLabel!)
        
        // MARK: Add pan geture recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    override func layoutSubviews() {
        super.layoutSubviews()
        //ensure gradient layer occupies full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width, height: bounds.size.height)
        
        // add checkmark and cross out
        tickLabel?.frame = CGRect(x: -40, y: 0,
                                 width: 40, height: bounds.size.height)
        crossLabel?.frame = CGRect(x: bounds.size.width + 20, y: 0,
                                  width: 40, height: bounds.size.height)
    }

    // utility method for creating contextual cues
    func createCueLabel() -> UILabel
    {
        let label = UILabel(frame: CGRect.null)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 32.0)
        label.backgroundColor = UIColor.clear
        
        return label
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer)
    {
        if recognizer.state == .began
        {
            originalCenter = center
        }
        
        if recognizer.state == .changed
        {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            
            completeOnDragRelease = frame.origin.x > -frame.size.width / 2.0
            
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel?.alpha = cueAlpha
            crossLabel?.alpha = cueAlpha
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel?.textColor = completeOnDragRelease ? UIColor.green : UIColor.white
            crossLabel?.textColor = deleteOnDragRelease ? UIColor.red : UIColor.white
        }
        
        if recognizer.state == .ended
        {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease
            {
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
            
            // implement this if statement if the protocol is already defined:
            if deleteOnDragRelease
            {
                if delegate != nil && toDoItem != nil
                {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemDeleted(todoItem: toDoItem!)
                }
            } else if completeOnDragRelease {
                if toDoItem != nil
                {
                    toDoItem!.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.isHidden = false
                UIView.animate(withDuration: 0.2, animations: { self.frame = originalFrame })
            } else {
                UIView.animate(withDuration: 0.2, animations: { self.frame = originalFrame })
            }
            
            
        }
    }
    
    // Add Gesture delegate, allows cancelling of recognition of gesture before it has begun.
    // failure to implement renders scrolling inoperable
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        {
            let translation = panGestureRecognizer.translation(in: superview!)
            
            if fabs(translation.x) > fabs(translation.y)
            {
                return true
            }
            return false
        }
        return false
    }
}

















