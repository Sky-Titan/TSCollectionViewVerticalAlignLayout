//
//  TSCollectionViewVerticalAlignLayout.swift
//  CollectionViewVerticalAlignExample
//
//  Created by 박준현 on 2022/08/06.
//

import UIKit

enum CollectionViewVerticalAlign {
    case top
    case center
    case bottom
}

class TSCollectionViewVerticalAlignLayout: UICollectionViewFlowLayout {
    private var sectors: [CGFloat: CollectionViewLayoutAttributeSector] = [:]
    
    required init(verticalAlign: CollectionViewVerticalAlign) {
        self.verticalAlign = verticalAlign
        super.init()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    var verticalAlign: CollectionViewVerticalAlign = .center {
        didSet {
            invalidateLayout()
        }
    }
        
    override func prepare() {
        super.prepare()
        refreshSectors()
    }
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard scrollDirection == .vertical else {
            return super.layoutAttributesForElements(in: rect)
        }
            
        var attributes: [UICollectionViewLayoutAttributes]?
        sectors.enumerated().forEach({
        let sector = $0.element.value
        if sector.rect.intersects(rect) {
                if attributes == nil {
                    attributes = []
                }
                attributes?.append(contentsOf: sector.attributes.compactMap({
                    if let kind = $0.representedElementKind {
                        return layoutAttributesForSupplementaryView(ofKind: kind, at: $0.indexPath)
                    }
                    return layoutAttributesForItem(at: $0.indexPath)
                }))
                
            }
        })
        
        return attributes
    }
        
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = super.layoutAttributesForItem(at: indexPath)
        
        guard scrollDirection == .vertical else {
            return attribute
        }
        
        guard let attribute = attribute else {
            return nil
        }
        
        let centerY = attribute.center.y
        
        if let sector = sectors[centerY] {
            switch verticalAlign {
            case .top:
                attribute.frame.origin.y = sector.minY
            case .bottom:
                attribute.frame.origin.y += sector.maxY - attribute.frame.maxY
            default:
                break
            }
        }
        
        return attribute
    }
    
    private func refreshSectors() {
        sectors = [:]
        let allLayoutAttributes = allLayoutAttributes()
        allLayoutAttributes.forEach({
            let centerY = $0.center.y
            if sectors[centerY] == nil {
                sectors[centerY] = CollectionViewLayoutAttributeSector(centerY: centerY)
            }
            sectors[centerY]?.attributes.append($0)
        })
    }
    
    private func allLayoutAttributes() -> [UICollectionViewLayoutAttributes] {
        var list: [UICollectionViewLayoutAttributes] = []
        
        for section in 0 ..< numberOfSection() {
            if let headerAttribute = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: section)) {
                list.append(headerAttribute)
            }
            for row in 0 ..< numberOfItems(section) {
                let indexPath: IndexPath = IndexPath(row: row, section: section)
                if let attribute = super.layoutAttributesForItem(at: indexPath) {
                    list.append(attribute)
                }
            }
            if let footerAttribute = super.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: numberOfItems(section), section: section)) {
                list.append(footerAttribute)
            }
        }
        return list
    }
    
    func numberOfSection() -> Int {
        if let collectionView = collectionView, let number = collectionView.dataSource?.numberOfSections?(in: collectionView) {
            return number
        }
        return 0
    }
    
    func numberOfItems(_ section: Int) -> Int {
        if let collectionView = collectionView, let number = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) {
            return number
        }
        return 0
    }
}

class CollectionViewLayoutAttributeSector {
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    let centerY: CGFloat
    
    var minX: CGFloat {
        return attributes.reduce(CGFloat.infinity, { result, attribute in
            min(result, attribute.frame.minX)
        })
    }
    var maxX: CGFloat {
        return attributes.reduce(CGFloat.zero, { result, attribute in
            max(result, attribute.frame.maxX)
        })
    }
    
    var minY: CGFloat {
        return attributes.reduce(CGFloat.infinity, { result, attribute in
            min(result, attribute.frame.minY)
        })
    }
    var maxY: CGFloat {
        return attributes.reduce(CGFloat.zero, { result, attribute in
            max(result, attribute.frame.maxY)
        })
    }
    var rect: CGRect {
        return CGRect(x: 0, y: minY, width: UIScreen.main.bounds.width, height: maxY - minY)
    }
    
    init(centerY: CGFloat) {
        self.centerY = centerY
    }
}
