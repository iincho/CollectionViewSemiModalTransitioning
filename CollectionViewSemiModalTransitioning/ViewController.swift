//
//  ViewController.swift
//  CollectionViewSemiModalTransitioning
//
//  Created by Yoichi on 2019/02/12.
//  Copyright © 2019 Yoichi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataList: [ViewData] = []
    private let customTransition = OverCurrentTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        generateDataList()
    }
    
    func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: UICollectionViewCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
    }
    
    func generateDataList() {
        dataList = [
            ViewData(color: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1), title: "Strawberry"),
            ViewData(color: #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1), title: "Banana"),
            ViewData(color: #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1), title: "SeaFoam"),
            ViewData(color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), title: "Maraschino"),
            ViewData(color: #colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1), title: "Honeydew"),
            ViewData(color: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), title: "Aqua"),
            ViewData(color: #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1), title: "Magenta"),
            ViewData(color: #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), title: "Tangerine"),
            ViewData(color: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), title: "Turquoise"),
            ViewData(color: #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1), title: "Lavender"),
            ViewData(color: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1), title: "Salmon"),
            ViewData(color: #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1), title: "Flora"),
        ]
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = dataList[indexPath.row].color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = view.bounds.width / 2 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = CollectionSemiModalViewController.make(dataList: dataList, selectedIndex: indexPath.row)
        let nv = UINavigationController(rootViewController: vc)
        customTransition.interactor = vc.interactor
        nv.transitioningDelegate = customTransition
        nv.modalPresentationStyle = .custom
        present(nv, animated: true, completion: nil)
    }
}

struct ViewData {
    let color: UIColor
    let title: String
}
