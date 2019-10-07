//
//  ViewController.swift
//  PhotoJournal
//
//  Created by Sunni Tang on 10/2/19.
//  Copyright © 2019 Sunni Tang. All rights reserved.
//

import UIKit

class PhotoJournalViewController: UIViewController {

    // TODO: Connect Settings button to SettingsVC
    
    
    @IBOutlet weak var photoJournalCollectionView: UICollectionView!
    
    var photoJournal = [PhotoJournal]() {
        didSet {
            photoJournalCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPhotoJournal()
    }

    private func configureCollectionView() {
        photoJournalCollectionView.dataSource = self
    }
    
    private func loadPhotoJournal() {
        do {
            photoJournal = try PhotoPersistenceHelper.manager.getPhotoJournal()
        } catch {
            let alertVC = UIAlertController(title: "Error", message: "Could not load photo journal!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    

}

extension PhotoJournalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoJournal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoJournalCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoJournalCollectionViewCell
        let currentPhotoEntry = photoJournal[indexPath.row]
        
        cell.photoImageView.image = UIImage(data: currentPhotoEntry.photoData)
        cell.titleLabel.text = currentPhotoEntry.title
        cell.dateLabel.text = currentPhotoEntry.date
        
        cell.optionsButton.tag = indexPath.row
        cell.delegate = self
        
        return cell
    }

    
}

extension PhotoJournalViewController: PhotoCellDelegate {
    func showActionSheet(tag: Int) {
        let selectedPhoto = self.photoJournal[tag]
        
        let optionsMenu = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            do {
                try PhotoPersistenceHelper.manager.deletePhotoJournal(with: tag)
                self.loadPhotoJournal()
            } catch {
                let alertVC = UIAlertController(title: "Error", message: "Could not delete photo entry!", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            }
            
        }
        
        let editAction = UIAlertAction.init(title: "Edit", style: .default) { (action) in
            // add edit functionality using persistence
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editVC = storyboard.instantiateViewController(identifier: "editPhotoSB") as EditPhotoViewController
            self.navigationController?.pushViewController(editVC, animated: true)
            
            editVC.currentPhotoEntry = selectedPhoto
            editVC.currentTag = tag
    
        }
        
        let shareAction = UIAlertAction.init(title: "Share", style: .default) { (action) in
            // add share functionality using persistence
    
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        optionsMenu.addAction(deleteAction)
        optionsMenu.addAction(editAction)
        optionsMenu.addAction(shareAction)
        optionsMenu.addAction(cancelAction)
        
        present(optionsMenu, animated: true, completion: nil)
        
    }
}
