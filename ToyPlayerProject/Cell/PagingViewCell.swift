//
//  PagingViewCell.swift
//  ToyPlayerProject
//
//  Created by Admin iMBC on 1/23/24.
//

import Foundation
import UIKit

protocol PagingViewCellProtocol{
    func cellSelected(indexPath: IndexPath)
    func refreshCell()
}

enum Dimension {
    static let tabHeight: CGFloat = 65
    static let bannerRatio: CGFloat = 107/374
    static let contentHeight: CGFloat = 168
    static let contentSpacing: CGFloat = 14
}

class PagingViewCell: UICollectionViewCell{
    
    var delegate: PagingViewCellProtocol?
    
    var refreshControl : UIRefreshControl = {
       var refresh = UIRefreshControl()
        return refresh
    }()
    
    private var channelData : [ChannelInfo] = [] {
        didSet{
            DispatchQueue.main.async{
                self.videoCollectionView.reloadData()
            }
        }
    }
    static let identifier = "PagingViewCell"
    
    var videoCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
    
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsSelection = true
        cv.allowsMultipleSelection = false
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = true
        cv.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            cv.automaticallyAdjustsScrollIndicatorInsets = false
        }
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        videoCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseId)
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        if #available(iOS 10.0, *){
            videoCollectionView.refreshControl = refreshControl
        } else{
            videoCollectionView.addSubview(refreshControl)
        }
        videoCollectionView.refreshControl?.addTarget(self, action: #selector(refreshView), for: .valueChanged)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMyview(data: [ChannelInfo]){
        self.channelData = data
    }
    
    @objc
    private func refreshView(){
        DispatchQueue.main.async {
            self.delegate?.refreshCell()
            self.videoCollectionView.refreshControl?.endRefreshing()
        }
    }
    

    

}
extension PagingViewCell{
    private func setupLayout(){
        contentView.addSubview(videoCollectionView)
        videoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([videoCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     videoCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     videoCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     videoCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])

    }
}

extension PagingViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseId, for: indexPath) as! VideoCell
        let items = channelData[indexPath.item]
        if let title = items.title, let typetitle = items.typeTitle, let image = items.onAirImage{
            cell.configure(title: typetitle, sub: title, imagelink: image )
        }
        
        if PagingView.selectedIndex == PagingView.currentTab && PagingView.selectedscode == items.scheduleCode{
            cell.setSelected(true)
            videoCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20 - 20 - 14)/2
        return CGSize(width: width, height: Dimension.contentHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Dimension.contentSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cellSelected(indexPath: indexPath)
    }
}


