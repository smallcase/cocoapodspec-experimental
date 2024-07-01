//
//  ContentSizedCollectionView.swift
//  SCGateway
//
//  Created by Shivani on 08/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


public final class ContentSizedCollectionView: UICollectionView {
    
    override public var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
