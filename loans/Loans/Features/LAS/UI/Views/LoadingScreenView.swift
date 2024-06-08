//
//  LoadingScreenView.swift
//  Loans
//
//  Created by Ankit Deshmukh on 05/05/23.
//

import Foundation
import UIKit

class LoadingScreenView: UIView {
    
    let loadingScreenXib = "LoadingScreenView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loaderGif: UIImageView!
    @IBOutlet weak var redirectingText: UILabel!
    @IBOutlet weak var redirectionDescriptionText: UILabel!
    
    //MARK: Variables
    internal var viewModel: LASViewModelProtocol? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.init(for: ScLoan.self).loadNibNamed(loadingScreenXib, owner: self, options: nil)
        
        contentView.layer.cornerRadius = 8
        loaderGif.image = UIImage.gif(name: "gateway-loader")
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func updateUi() {
        if let lenderInfo = viewModel?.getLenderInfo(),
           let lenderConfig = getLenderConfig(for: lenderInfo.lenderName) {
//            redirectingText.text = "Redirecting to \(lenderConfig.displayName ?? "Bajaj finserv")"
            
            var descriptionText = "for loan application"
            var titleText = "Redirecting for loan application"
            
            switch lenderInfo.intent.lowercased() {
            case "payment":
                titleText = lenderConfig.loaderTitleText?.payment ?? ""
                descriptionText = lenderConfig.loaderDescriptionText?.payment ?? ""
                break
            default:
                titleText = lenderConfig.loaderTitleText?.loan_application ?? "Redirecting for loan application"
                descriptionText = lenderConfig.loaderDescriptionText?.loan_application ?? ""
            }
            
            redirectingText.text = titleText
            
            redirectionDescriptionText.attributedText = getAttributedString(for: descriptionText, withLineHeight: 1.31)
            redirectionDescriptionText.textAlignment = NSTextAlignment.center
        }
    }
    
    private func getLenderConfig(for lender: String) -> LenderConfigs? {
        guard let lenderConfigs = SessionManager.lenderConfig else {
            return nil
        }
        
        for config in lenderConfigs {
            if let configLender = config.lender, configLender == lender {
                return config
            }
        }
        
        return nil
    }
    
    private func getAttributedString(for text: String, withLineHeight lineSpacing: CGFloat) -> NSAttributedString? {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        //attributed string
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        return attrString
    }
}
