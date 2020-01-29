//
//  BVCalendarHeader.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 27..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

final class BVCalendarHeader: UICollectionReusableView {
    
    var date: Date! {
        didSet {
            label.text = dateFormatter.string(from: date)
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.layer.borderColor = UIColor.green.cgColor
        return label
    }()
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMMM"
        dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return dateFormatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.layer.cornerRadius = frame.width / 2
    }
    
}
