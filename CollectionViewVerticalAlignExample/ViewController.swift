//
//  ViewController.swift
//  CollectionViewVerticalAlignExample
//
//  Created by 박준현 on 2022/08/06.
//

import UIKit

class ViewController: UIViewController {

    var dataSources: [BaseCellViewModel] = [
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 50)),
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 100), bgColor: .blue),
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 50)),
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 50)),
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 100), bgColor: .blue),
        BaseCellViewModel(title: "1", size: CGSize(width: 100, height: 50))
    ]
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let layout = TSCollectionViewVerticalAlignLayout(verticalAlign: .top)
        collectionView.collectionViewLayout = layout
        collectionView.register(BaseCell.self, forCellWithReuseIdentifier: "BaseCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }

}
extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseCell", for: indexPath) as! BaseCell
        cell.setViewModel(dataSources[indexPath.row])
        cell.isHidden = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSources[indexPath.row].size
        
    }


}

class BaseCellViewModel {
    var bgColor: UIColor?
    var title: String
    var size: CGSize
    init(title: String, size: CGSize, bgColor: UIColor? = .red) {
        self.title = title
        self.size = size
        self.bgColor = bgColor
    }
}

class BaseCell: UICollectionViewCell {
    
    var cellView: BaseTitleCellView?
    
    func setViewModel(_ viewModel: BaseCellViewModel) {
        if let cellView = cellView {
            cellView.setViewModel(viewModel)
        } else {
            let cellView = BaseTitleCellView()
            cellView.setViewModel(viewModel)
            self.cellView = cellView
            self.contentView.addSubview(cellView)
            cellView.bindToSuperView()
        }
    }
    
    
}

class BaseTitleCellView: UIView {
    var label: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel()
        label.textColor = .white
        
        label.font = .systemFont(ofSize: 14)
        self.addSubview(label)
        label.bindToSuperView()
        self.label = label
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setViewModel(_ viewModel: BaseCellViewModel) {
        self.backgroundColor = viewModel.bgColor
        label?.text = viewModel.title
        label?.sizeToFit()
        sizeToFit()
    }
}

extension UIView {
    
    func bindToSuperView() {
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                superview.topAnchor.constraint(equalTo: self.topAnchor),
                superview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                superview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                superview.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
        }
    }
}
