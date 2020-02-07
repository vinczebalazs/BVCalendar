//
//  BVCalendarCell.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 27..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

final class BVCalendarCell: UICollectionViewCell {
    
    struct RangeIndicatorType: OptionSet {
        let rawValue: Int

        static let start = RangeIndicatorType(rawValue: 1 << 0)
        static let middle = RangeIndicatorType(rawValue: 1 << 1)
        static let end = RangeIndicatorType(rawValue: 1 << 2)
        static let rowStart = RangeIndicatorType(rawValue: 1 << 3)
        static let rowEnd = RangeIndicatorType(rawValue: 1 << 4)
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .white : .black
            label.backgroundColor = isSelected ? selectionColor : .white
            label.layer.borderWidth = (containsCurrentDate && !isSelected) ? 1 : 0
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
    var rangeIndicator: RangeIndicatorType = [] {
        didSet {
            styleForRangeIndication()
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
    private let selectionColor = UIColor.systemBlue
    private let backgroundMaskLayer = CAShapeLayer()
    
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
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        rangeIndicator = []
        layer.mask = nil
        layer.cornerRadius = 0
    }
    
    private func styleForRangeIndication() {
        backgroundColor = selectionColor.withAlphaComponent(0.5)
        layer.mask = backgroundMaskLayer
        label.backgroundColor = isSelected ? selectionColor : .clear
                                
        var cornersToRound: UIRectCorner = []
        var radius = frame.width / 2
        
        if rangeIndicator.isEmpty {
            backgroundColor = nil
        } else if rangeIndicator.contains(.start) {
            cornersToRound = [.topLeft, .bottomLeft]
        } else if rangeIndicator.contains(.end) {
            cornersToRound = [.topRight, .bottomRight]
        } else if rangeIndicator == .rowStart {
            radius = 6
            cornersToRound = [.topLeft, .bottomLeft]
        } else if rangeIndicator == .rowEnd {
            radius = 6
            cornersToRound = [.topRight, .bottomRight]
        }
        
        backgroundMaskLayer.path = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: cornersToRound,
                                                cornerRadii: CGSize(width: radius, height: 0.0)).cgPath
    }
        
}
