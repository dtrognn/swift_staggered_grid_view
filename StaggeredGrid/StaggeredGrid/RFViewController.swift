//
//  RFViewController.swift
//  StaggeredGrid
//
//  Created by dtrognn on 21/11/24.
//

import UIKit
import SnapKit

class RFViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RFQuiltLayoutDelegate {
    private var collectionView: UICollectionView!

    var widgets = [
        WidgetItem(title: "widget 1", w: 8, h: 4),
        WidgetItem(title: "widget 2", w: 4, h: 4),
        WidgetItem(title: "widget 3", w: 4, h: 2),
        WidgetItem(title: "widget 4", w: 2, h: 2),
        WidgetItem(title: "widget 5", w: 2, h: 2),
        WidgetItem(title: "widget 6", w: 4, h: 1),
        WidgetItem(title: "widget 7", w: 4, h: 1),
        WidgetItem(title: "widget 8", w: 2, h: 4),
        WidgetItem(title: "widget 9", w: 4, h: 4),
        WidgetItem(title: "widget 10", w: 2, h: 4),
    ]

    private let numberOfItem: CGFloat = UIDevice().userInterfaceIdiom == .phone ? 8 : 16
    private let spacing: CGFloat = 8

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    private func getMinimumWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width - 3 * spacing
        return screenWidth / numberOfItem
    }

    private func setupCollectionView() {
        // Initialize layout
        let layout = RFQuiltLayout()
        layout.delegate = self

        // Initialize collection view with custom layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = .white

        // Add to view hierarchy and set constraints
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview()
        }

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        if let layout = collectionView.collectionViewLayout as? RFQuiltLayout {
            layout.direction = .vertical
            layout.blockPixels = CGSize(width: getMinimumWidth(), height: getMinimumWidth())
        }

        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }

    // MARK: - UICollectionView Delegate & DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return widgets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = widgets[indexPath.row].color
        cell.layer.cornerRadius = 8

        var label = cell.viewWithTag(5) as? UILabel
        if label == nil {
            label = UILabel(frame: CGRect(x: 10, y: 7, width: 100, height: 20))
            label?.font = .systemFont(ofSize: 12, weight: .regular)
            label?.tag = 5
            label?.textColor = .white
            label?.backgroundColor = .clear
            cell.addSubview(label!)
        }
        label?.text = widgets[indexPath.row].title

        return cell
    }

    // MARK: - RFQuiltLayoutDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, blockSizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row >= widgets.count {
            print("Asking for index paths of non-existent cells! \(indexPath.row) from \(widgets.count) cells")
        }

        let width = CGFloat(widgets[indexPath.row].w)
        let height = CGFloat(widgets[indexPath.row].h)

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemAt indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
}

extension RFViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = widgets[indexPath.item]
        let itemProvider = NSItemProvider(object: "\(item)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            destinationIndexPath = IndexPath(item: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
        }

        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }

    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else { return }

        collectionView.performBatchUpdates({
            let movedItem = widgets[sourceIndexPath.item]
            widgets.remove(at: sourceIndexPath.item)
            widgets.insert(movedItem, at: destinationIndexPath.item)

            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        }, completion: { _ in
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        })
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
