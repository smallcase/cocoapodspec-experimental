//
//  OtherBrokerCustomCell.swift
//  SCGateway
//
//  Created by Dip on 08/06/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

class OtherBrokerCustomCell: UITableViewCell {
     var title: String? {
          didSet {
              titleLabel.text = title
          }
      }
      var imageUrl: URL? {
          didSet {
              guard let imageUrl = imageUrl else { return }
              iconImageView.load(url: imageUrl)
          }
      }
    
  var txtColor: UIColor? {
        didSet {
            titleLabel.textColor = txtColor
        }
    }
      
      
      
      //MARK:- UI Components
      fileprivate let containerView: UIView = {
          let view = UIView()
          view.backgroundColor = UIColor.white
          view.translatesAutoresizingMaskIntoConstraints = false
          return view
      }()
      
    
      
      fileprivate let iconImageView: UIImageView = {
          let imgView = UIImageView()
          imgView.translatesAutoresizingMaskIntoConstraints = false
          return imgView
      }()
      
      fileprivate let titleLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont(name: "GraphikApp-Regular", size: 14 )
          label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ScgatewayColor.TextColor.normal
        label.tintColor = ScgatewayColor.TextColor.normal
          
          return label
      }()
    
    public let cellContainerSaperator : UIView = {
         let view = UIView()
         view.backgroundColor = ScgatewayColor.seperatorColor
         view.translatesAutoresizingMaskIntoConstraints = false
         view.layer.masksToBounds = true
         return view
     }()
      
      
      //MARK:- Setup
      
      func setupViews() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(cellContainerSaperator)
      }
      
      func setupLayouts() {
          //ContainerView
          containerView.fillSuperview()
        iconImageView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: 13, leftConstant: 9, bottomConstant: 13, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        titleLabel.anchor(containerView.topAnchor, left: iconImageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 1, rightConstant: 9, widthConstant: self.bounds.width - 38, heightConstant: self.bounds.height - 10)
        
        cellContainerSaperator.anchor(nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.bounds.width, heightConstant: 1)
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
