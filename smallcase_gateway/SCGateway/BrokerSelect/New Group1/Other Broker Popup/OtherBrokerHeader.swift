//
//  OtherBrokerHeader.swift
//  SCGateway
//
//  Created by Dip on 17/06/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation


class OtherBrokerHeader: UITableViewCell {
     var title: String? {
              didSet {
                  titleLabel.text = title
                  titleLabel.textColor = ScgatewayColor.TextColor.normal
                  titleLabel.tintColor = ScgatewayColor.TextColor.normal
              }
          }
          
          
          
          
          //MARK:- UI Components
          fileprivate let containerView: UIView = {
              let view = UIView()
              view.backgroundColor = UIColor.white
              view.translatesAutoresizingMaskIntoConstraints = false
              return view
          }()
          
        
          
       
          
          fileprivate let titleLabel: UILabel = {
              let label = UILabel()
              label.font = UIFont(name: "GraphikApp-Medium", size: 13 )
              label.translatesAutoresizingMaskIntoConstraints = false
              label.textColor = ScgatewayColor.TextColor.normal
              label.tintColor = ScgatewayColor.TextColor.normal
              return label
          }()
        
          
          
          //MARK:- Setup
          
          func setupViews() {
            addSubview(containerView)
           
            containerView.addSubview(titleLabel)
    
          }
          
          func setupLayouts() {
              //ContainerView
              containerView.fillSuperview()
            
            titleLabel.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 10, leftConstant: 9, bottomConstant: 0, rightConstant: 0, widthConstant: self.bounds.width - 38, heightConstant: self.bounds.height - 22)
            
          }
          
          //MARK:- Initialize
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            //Setup
            setupViews()
            setupLayouts()
        }
          
         
          
          required init?(coder aDecoder: NSCoder) {
              fatalError("init(coder:) has not been implemented")
          }
}
