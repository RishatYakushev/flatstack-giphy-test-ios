//
//  GifController.swift
//  flatstack-giphy-test-ios
//
//  Created by Ришат Якушев on 13/12/2018.
//  Copyright © 2018 Flatstack. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import Kingfisher

protocol GifControllerDelegate: class {
    func didSelect(_ gifImage: URL)
}

class GifController: UIViewController {
    
    private enum Constants {
        
        // MARK: - Nested Properties
        
        static let apiKey = "du2y6LUT34jWgMybXmV1PHr7zuvtC0gC"
        
        static let reuseId = "GifCell"
        
        static let textfieldPlaceholder = "Поиск в GIPHY"
    }
    
    // MARK: - Instance Properties

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextfield: UITextField!

    
    // MARK: - Instance Properties
    
    var localCache: [String: Data] = [:]
    private var gifs: [String] = []
    private var gifsCcapture: [String] = []
    
    weak var delegate: GifControllerDelegate?
    
    // MARK: - Instance Methods

    private func configureUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constants.reuseId, bundle: nil), forCellWithReuseIdentifier: Constants.reuseId)
        searchTextfield.attributedPlaceholder = NSAttributedString(
            string: Constants.textfieldPlaceholder, attributes: [.foregroundColor: UIColor.white]
        )
        
        searchTextfield.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        closeButton.addTarget(self, action: #selector(closeButtonPushed), for: .touchUpInside)
    }
    
    @objc private func closeButtonPushed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func valueChanged() {
        let searchQuery = searchTextfield.text ?? ""
        if searchQuery.isEmpty {
            gifs = gifsCcapture
            self.collectionView.reloadData()
        }
        else {
            searchForStickers(searchQuery)
        }
    }
    
    private func loadData() {
        GiphyCore.shared.trending(.sticker, offset: 0, limit: 40, rating: .nsfw)
        { [unowned self] (gifList, error) in
            let gifsSource = gifList?.data?.map{
                "https://media.giphy.com/media/\($0.id)/giphy.gif" } ?? []
            self.gifsCcapture = gifsSource
            self.gifs = self.gifsCcapture
            DispatchQueue.main.async {
                //TODO ---  ActivityIndicator.dismiss(in: self.view)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func searchForStickers(_ searchString: String) {
        GiphyCore.shared.search(searchString, media: .sticker, offset: 0, limit: 40, rating: .nsfw, lang: .english) { [unowned self] (gifList, error) in
            let gifsSource = gifList?.data?.map{
                "https://media.giphy.com/media/\($0.id)/giphy.gif"
                } ?? []
            self.gifs = gifsSource
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GiphyCore.configure(apiKey: Constants.apiKey)
        self.loadData()
        self.configureUI()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension GifController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Instance Methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseId, for: indexPath) as! GifCell
        let gif = gifs[indexPath.row]
        cell.gif = gif
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3 - 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextfield.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = URL(string: gifs[indexPath.row]) else { return }
        delegate?.didSelect(url)
        dismiss(animated: true, completion: nil)
    }
}

