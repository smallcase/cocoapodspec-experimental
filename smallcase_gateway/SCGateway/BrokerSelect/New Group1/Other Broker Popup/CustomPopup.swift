//
//  CustomPopup.swift
//  SCGateway
//
//  Created by Dip on 04/06/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

protocol  CustomPopupDelegate: AnyObject {
    func upcomingBrokerSelected(broker:UpcomingBroker)
    func moreBrokerSelected(broker:BrokerConfig)
    func popVisibility(visibility:Bool)
}

protocol  KeyboardAppearDelegate: AnyObject {
    func keyboardAppeared(height:CGFloat)
    func keyboardDisapeared()
    
}





class CustomPopup : UIView , UITableViewDelegate, UITableViewDataSource,KeyboardAppearDelegate{
    
    
    
    //internal var searchList: [Any]? = nil
    
    internal var selectedUpcomingBroker:UpcomingBroker? = nil
    
    weak var delegate: CustomPopupDelegate?
    
    internal var currenty:CGFloat = CGFloat(0)
    
    
    func getBrokerCount() -> Int {
        var count = 0
       if (SessionManager.moreBrokers.count != 0) {
        count = count + SessionManager.moreBrokers.count + 1
        }
        return count
    }
    
    func getHeight() -> CGFloat {
        var height = 52.0 + (CGFloat((getBrokerCount() - 1)) * 46.0) + 20.0
        if height > 200 {
            height = 200.0
        }
        return height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getBrokerCount()
//        if searchList != nil {
//            return (searchList?.count ?? 0) + 1
//        } else
//        {
//            return count
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            var currentProduct: Any? = nil
//            if searchList != nil {
//                currentProduct = searchList![indexPath.row - 1]
//            } else
//            {
                if SessionManager.moreBrokers.count != 0 {
                    if indexPath.row <= SessionManager.moreBrokers.count  {
                        currentProduct = SessionManager.moreBrokers[indexPath.row - 1]
                    } else if (indexPath.row > SessionManager.moreBrokers.count + 1 )
                    {
                        currentProduct = SessionManager.tweetConfig[indexPath.row - (SessionManager.moreBrokers.count + 2) ]
                    }
                } else {
                    currentProduct = SessionManager.tweetConfig[indexPath.row - 1]
                }
           // }
            
            if  currentProduct != nil{
                if (currentProduct as? BrokerConfig) != nil {
                    delegate?.moreBrokerSelected(broker: currentProduct as! BrokerConfig)
                    self.dismiss(animated: false)
                } else if(currentProduct as? UpcomingBroker) != nil
                {
                    delegate?.upcomingBrokerSelected(broker: currentProduct as! UpcomingBroker)
                    self.dismiss(animated: false)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // if searchList == nil {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "otherBrokerHeader", for: indexPath as IndexPath) as! OtherBrokerHeader
                if (SessionManager.moreBrokers.count != 0)
                {
                    cell.title = "More partner brokers"
                } else
                {
                     cell.title = "Other Brokers"
                }
                return cell
            }
//            } else if (Config.moreBrokers.count != 0 && indexPath.row == (Config.moreBrokers.count+1)) {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "otherBrokerHeader", for: indexPath as IndexPath) as! OtherBrokerHeader
//                cell.title = "Other Brokers"
//                return cell
//            }
                else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "myCustomCell", for: indexPath as IndexPath) as! OtherBrokerCustomCell
                if (SessionManager.moreBrokers.count != 0 && indexPath.row <= SessionManager.moreBrokers.count) {
                        cell.title = SessionManager.moreBrokers[indexPath.row - 1].brokerDisplayName
                    cell.imageUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\(SessionManager.moreBrokers[indexPath.row - 1].broker).png")
                        
                } else {
                    if (SessionManager.moreBrokers.count == 0) {
                        let tweetBroker = SessionManager.tweetConfig[indexPath.row - 1]
                        cell.title = tweetBroker.brokerDisplayName
                                       cell.imageUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\(tweetBroker.broker).png")
                        if tweetBroker.broker == selectedUpcomingBroker?.broker {
                                                   cell.txtColor = ScgatewayColor.linkBlue
                                               } else
                        {
                            cell.txtColor = ScgatewayColor.TextColor.normal
                        }
                    } else
                    {
                        let tweetBroker = SessionManager.tweetConfig[indexPath.row - (SessionManager.moreBrokers.count + 2)]
                        cell.title = tweetBroker.brokerDisplayName
                        cell.imageUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\(tweetBroker.broker).png")
                        if tweetBroker.broker == selectedUpcomingBroker?.broker {
                            cell.txtColor = ScgatewayColor.linkBlue
                        } else{
                            cell.txtColor = ScgatewayColor.TextColor.normal
                        }
                    }
                   
                    
                }
                if indexPath.row == getBrokerCount() - 1 {
                    cell.cellContainerSaperator.isHidden = true
                }
                return cell
            }
//        } else
//        {
//          if indexPath.row == 0 {
//                         let cell = tableView.dequeueReusableCell(withIdentifier: "otherBrokerHeader", for: indexPath as IndexPath) as! OtherBrokerHeader
//            if (searchList?.count == 0)
//                {
//                    cell.title = "No Brokers found"
//                } else
//                {
//                    cell.title = "Results"
//                }
//                         return cell
//                } else {
//                        let currentObj = searchList?[indexPath.row - 1]
//                         let cell = tableView.dequeueReusableCell(withIdentifier: "myCustomCell", for: indexPath as IndexPath) as! OtherBrokerCustomCell
//            if (currentObj as? BrokerConfig) != nil {
//                cell.title = (currentObj as! BrokerConfig).brokerDisplayName
//                cell.imageUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\((currentObj as! BrokerConfig).broker).png")
//            }
//
//            if (currentObj as? UpcomingBroker) != nil {
//                cell.title = (currentObj as! UpcomingBroker).brokerDisplayName
//                cell.imageUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\((currentObj as! UpcomingBroker).broker).png")
//            }
//                         return cell
//        }
//        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 52.0
        } else{
           return 46.0
        }
        
    }
    
    
    
    
    
    var backgroundView = UIView()
   // var dialogView = UIView()
    
    
    
    convenience init(width:CGFloat,x:CGFloat,y:CGFloat) {
        self.init(frame: UIScreen.main.bounds)
        initialize(width: width, x: x, y: y)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    internal let dialogView: UIView = {
       let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.0
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
//   fileprivate let searchIcon : UIImageView = {
//        let imgView = UIImageView()
//        imgView.contentMode = .center
//        imgView.translatesAutoresizingMaskIntoConstraints = false
//        imgView.image = images[ImageConstants.searchIcon]!!
//        return imgView
//    }()
    
    
   
//    fileprivate let closeButton : UIButton = {
//        let button = UIButton(type: .custom)
//        button.setImage( images[ImageConstants.closeIcon]!!, for: .normal)
//        button.addTarget(self, action: #selector(tapListener(button:)), for: .touchUpInside)
//        button.alpha = 0
//        return button
//    }()
//
//    fileprivate let searchViewContainer : UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.masksToBounds = true
//        return view
//    }()
//
//    fileprivate let searchContainerSaperator : UIView = {
//        let view = UIView()
//        view.backgroundColor = Color.seperatorColor
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.masksToBounds = true
//        return view
//    }()
//
//    fileprivate let searchTextField : UITextField = {
//        let view = UITextField()
//        view.textColor = Color.TextColor.normal
//        view.attributedPlaceholder = NSAttributedString(string: "Search Brokers",
//                                                        attributes: [NSAttributedString.Key.foregroundColor: Color.TextColor.light])
//        return view
//    }()
//
    fileprivate let uiTableView : UITableView = {
       let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private func setUpTableView(){
        uiTableView.register(OtherBrokerCustomCell.self, forCellReuseIdentifier: "myCustomCell")
        uiTableView.register(OtherBrokerHeader.self, forCellReuseIdentifier: "otherBrokerHeader")
        uiTableView.dataSource = self
        uiTableView.delegate = self
    }
    
    
    private func addConstraints(width:CGFloat){
//        searchViewContainer.anchor(dialogView.topAnchor, left: dialogView.leftAnchor, bottom: nil, right: dialogView.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: 7, widthConstant: width, heightConstant: 45)
//         searchIcon.anchor(searchViewContainer.topAnchor, left: searchViewContainer.leftAnchor, bottom: searchViewContainer.bottomAnchor, right: nil, topConstant: 0, leftConstant: 9, bottomConstant: 1, rightConstant: 0, widthConstant: 18, heightConstant: 18)
//         closeButton.anchor(searchViewContainer.topAnchor, left: nil, bottom: searchViewContainer.bottomAnchor, right: searchViewContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 1, rightConstant: 9, widthConstant: 18, heightConstant: 18)
//         searchTextField.anchor(searchViewContainer.topAnchor, left: searchIcon.rightAnchor, bottom: searchViewContainer.bottomAnchor, right: closeButton.leftAnchor, topConstant: 0, leftConstant: 9, bottomConstant: 1, rightConstant: 0, widthConstant: width - 68, heightConstant: 44)
//        searchContainerSaperator.anchor(searchTextField.bottomAnchor, left: searchViewContainer.leftAnchor  , bottom: searchViewContainer.bottomAnchor, right: searchViewContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width-14, heightConstant: 1)
//
        uiTableView.anchor(dialogView.topAnchor, left: dialogView.leftAnchor, bottom: dialogView.bottomAnchor, right: dialogView.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: 7, widthConstant: width, heightConstant: getHeight())
        
    }
    
    
    func initialize(width:CGFloat,x:CGFloat,y:CGFloat){
        //customize dialogview
        
        dialogView.frame = CGRect(x: x, y: y, width: width, height: getHeight())
        dialogView.layer.shadowPath = UIBezierPath(roundedRect: dialogView.bounds, cornerRadius: 4).cgPath
        backgroundView.frame = frame
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
//        searchTextField.addTarget(self, action: #selector(onTextChange(_:)), for: .editingChanged)
//        searchTextField.addTarget(self, action: #selector(onEditBegin(_:)), for: .editingDidBegin)
//        searchTextField.addTarget(self, action: #selector(onEditEnd(_:)), for: .editingDidEnd)
//        dialogView.addSubview(searchViewContainer)
//        searchViewContainer.addSubview(searchIcon)
//        searchViewContainer.addSubview(closeButton)
//        searchViewContainer.addSubview(searchTextField)
//        searchViewContainer.addSubview(searchContainerSaperator)
        dialogView.addSubview(uiTableView)
        addConstraints(width: width)
        addSubview(dialogView)
        setUpTableView()
        //animateCloseButton(visible: false)
    }
    
//    @objc private func onEditBegin(_ textField: UITextField) {
//        searchContainerSaperator.backgroundColor = Color.linkBlue
//    }
//
//    @objc private func onEditEnd(_ textField: UITextField) {
//        searchContainerSaperator.backgroundColor = Color.seperatorColor
//    }
//
//
//    @objc private func onTextChange(_ textField : UITextField){
//        let text = textField.text
//        if text==nil || text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
//            searchList = nil
//            animateCloseButton(visible: false)
//        } else
//        {
//            animateCloseButton(visible: true)
//            searchList = []
//            for upcomingBrokers in Config.tweetConfig
//            {
//                if upcomingBrokers.brokerDisplayName.localizedLowercase.contains(text!.localizedLowercase) {
//                    searchList?.append(upcomingBrokers)
//                }
//            }
//
//            for moreBrokers in Config.moreBrokers
//            {
//                if (moreBrokers.brokerDisplayName!.localizedLowercase.contains(text!.localizedLowercase)) {
//                    searchList?.append(moreBrokers)
//                }
//            }
//
//        }
//
//        uiTableView.reloadData()
//    }
    
    func keyboardAppeared(height: CGFloat) {
        
        if self.dialogView.frame.origin.y == currenty {
            self.dialogView.frame.origin.y -= height
        }
    }
    
    func keyboardDisapeared() {
        if self.dialogView.frame.origin.y != currenty {
                   self.dialogView.frame.origin.y = currenty
               }
    }
    
//    private func animateCloseButton(visible:Bool){
//        UIView.animate(withDuration: 0.1) {
//            self.closeButton.alpha = visible ? 1 : 0
//        }
//    }
//
//    @objc private func tapListener(button:UIButton) {
//        print("fgiuhgukdf")
//        self.searchTextField.text = ""
//        searchList = nil
//        animateCloseButton(visible: false)
//        uiTableView.reloadData()
//
//    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: false)
    }
    
}

extension CustomPopup{
    
    func show(animated:Bool,x:CGFloat,y:CGFloat,width:CGFloat,selectedUpcomingBroker:UpcomingBroker?){
        delegate?.popVisibility(visibility: true)
        self.selectedUpcomingBroker = selectedUpcomingBroker
            self.dialogView.center = CGPoint(x: x + width/2, y: (y - self.dialogView.frame.height/2) + 15)
        UIApplication.shared.keyWindow?.addSubview(self)
        self.dialogView.alpha = 0.4
        UIView.animate(withDuration: 0.2, delay: 0,options: .curveEaseOut, animations: {
               self.dialogView.alpha = 1
        })
        UIView.animate(withDuration: 0.33, delay: 0,options: .curveEaseOut, animations: {
              self.dialogView.center = CGPoint(x: x + width/2, y: y - self.dialogView.frame.height/2)
            self.currenty = self.dialogView.frame.origin.y
        })
        }
        
        func dismiss(animated:Bool){
            delegate?.popVisibility(visibility: false)
                self.removeFromSuperview()
            
            
        }
    

}


