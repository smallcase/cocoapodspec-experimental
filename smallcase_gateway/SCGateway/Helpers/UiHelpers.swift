//
//  UiHelpers.swift
//  SCGateway
//
//  Created by Dip on 06/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation


func requiredHeight(width:CGFloat,labelText:String,font:UIFont,attributed:Bool, lineSpacing:CGFloat = 7) -> CGFloat {

    let label: UILabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.font = font
    if attributed {
       let paragraphStyle = NSMutableParagraphStyle()
        //line height size
        paragraphStyle.lineSpacing = lineSpacing
        let attrString = NSMutableAttributedString(string: labelText)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    } else
    {
        label.text = labelText
    }
    label.sizeToFit()
    return label.frame.height

}
