//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by WangQi on 16/8/10.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import UIKit
import Twitter


class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            images = tweets.reduce([], combine: +)
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, media: $0) }
                }.reduce([], combine: +)
//            images = tweets.flatMap({ $0 })
//                .map { tweet in
//                    tweet.media.map { TweetMedia(tweet: tweet, media: $0) }
//                }.flatMap({ $0 })
        }
    }
    
    private var images = [TweetMedia]()
    
    struct TweetMedia: CustomStringConvertible {
        var tweet: Twitter.Tweet
        var media: Twitter.MediaItem
        
        var description: String { return "\(tweet): \(media)" }
    }
    
    // MARK: - Cache
    
    private var cache = NSCache()

    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: -lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupLayout()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(
            target: self,
            action: #selector(ImageCollectionViewController.changeScale(_:))
            ))
        //installsStandardGestureForInteractiveMovement = true
    }
   
    func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()

    }
    
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
//            }

 
    // MARK: - Navigation
    
//    @IBAction private func toRootViewController(sender: UIBarButtonItem) {
//        navigationController?.popToRootViewControllerAnimated(true)
//    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.SegueIdentifier {
            if let ttvc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell {
                    ttvc.tweets = [[images[collectionView!.indexPathForCell(cell)!.row].tweet]]
                    //ttvc.tweets = [[tweetMedia.tweet]]
                }
            }
        }
    }
    

    // MARK: UICollectionViewDataSource
    
    private struct Storyboard {
        static let CellReuseIdentifier = "ImageCell"
        static let CellArea: CGFloat = 4000
        static let SegueIdentifier = "ShowRelatedTweet"
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.cache = cache
        cell.imageURL = images[indexPath.row].media.url
    
        return cell
    }
//
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        let width = min(sqrt(ratio * Storyboard.CellArea) * scale, collectionView.bounds.size.width)
        let height = width / ratio
        
        return CGSize(width: width, height: height)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}