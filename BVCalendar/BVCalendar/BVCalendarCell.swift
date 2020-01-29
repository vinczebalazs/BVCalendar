//
//  BVCalendarCell.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 27..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

final class BVCalendarCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .white : .black
            label.backgroundColor = isSelected ? .systemBlue : .white
        }
    }
    override var isUserInteractionEnabled: Bool {
        didSet {
            label.textColor = isUserInteractionEnabled ? (isSelected ? .white : .black) : . gray
        }
    }
    var containsCurrentDate = false {
        didSet {
            label.layer.borderWidth = (containsCurrentDate && !isSelected) ? 1 : 0
        }
    }
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
