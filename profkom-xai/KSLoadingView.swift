//
//  KSLoadView.swift
//  profkom-xai
//
//  Created by KY1VSTAR on 28.09.16.
//  Copyright © 2016 KY1VSTAR. All rights reserved.
//

import UIKit

class KSLoadingView: UIView {

    private var errorLabel: UILabel!
    private var refreshButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    private var activityIndicatorLabel: UILabel!
    var reloadButtonClicked: (() -> ())?
    
    init() {
        super.init(frame: CGRect.zero)
        errorLabel = UILabel()
        errorLabel.textColor = .lightGray
        errorLabel.textAlignment = .center
        errorLabel.text = "Ошибка при загрузке данных"
        errorLabel.isHidden = true
        errorLabel.sizeToFit()
        addSubview(errorLabel)
        
        let viewWidth = errorLabel.frame.width
        let viewHeight = errorLabel.frame.height + 25
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth))
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewHeight))
        
        refreshButton = UIButton(type: .system)
        refreshButton.frame = CGRect(x: (viewWidth - 70) / 2, y: errorLabel.frame.height, width: 70, height: 25)
        refreshButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        refreshButton.setTitle("Обновить", for: UIControlState())
        refreshButton.isHidden = true
        addSubview(refreshButton)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        let activityIndicatorX = (viewWidth - activityIndicator.frame.width - 91) / 2
        let activityIndicatorY = (viewHeight - activityIndicator.frame.size.height) / 2
        activityIndicator.frame.origin = CGPoint(x: activityIndicatorX, y: activityIndicatorY)
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicatorLabel = UILabel(frame: CGRect(x: activityIndicatorX + activityIndicator.frame.size.width + 8, y: activityIndicatorY, width: 84, height: activityIndicator.frame.height))
        activityIndicatorLabel.font = .systemFont(ofSize: 16)
        activityIndicatorLabel.text = "Загрузка..."
        addSubview(activityIndicatorLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func reload() {
        reloadButtonClicked?()
    }
    
    func hide() {
        errorLabel.isHidden = true
        refreshButton.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicatorLabel.isHidden = true
    }
    
    func showError() {
        errorLabel.isHidden = false
        refreshButton.isHidden = false
        //activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicatorLabel.isHidden = true
    }
    
    func showLoading() {
        errorLabel.isHidden = true
        refreshButton.isHidden = true
        //activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicatorLabel.isHidden = false
    }
    
    var isErrorHidden: Bool {
        return errorLabel.isHidden
    }

}
