//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Milton Moura on 07/11/15.
//  Copyright © 2015 mgcm. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreImage

class ViewController: UIViewController {
    static let rxSwiftLogo = "https://raw.githubusercontent.com/ReactiveX/RxSwift/rxswift-2.0/assets/Rx_Logo_M.png"
    static let swiftLogo = "https://developer.apple.com/assets/elements/icons/256x256/swift_2x.png"

    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var compositeImage: UIImageView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = combineLatest(slider1.rx_value, slider2.rx_value) {
                $0 + $1
            }.map {
                "Sum of slider values is \($0)"
            }.bindTo(label.rx_text)
            .addDisposableTo(self.disposeBag)

        let _ = loadButton.rx_tap.subscribeNext { [weak self] in
            self?.loadImages()
        }.addDisposableTo(self.disposeBag)
    }

    func loadImages() {
        let rxSwiftLogo = NSURLRequest(URL: NSURL(string: ViewController.rxSwiftLogo)!)
        let swiftLogo = NSURLRequest(URL: NSURL(string: ViewController.swiftLogo)!)

        let image1 = NSURLSession.sharedSession().rx_data(rxSwiftLogo)
            .map {
                UIImage(data: $0)
            }.catchErrorJustReturn(nil)

        let image2 = NSURLSession.sharedSession().rx_data(swiftLogo)
            .map {
                UIImage(data: $0)
            }.catchErrorJustReturn(nil)

        image1
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { [weak self] (image) -> Void in
                self?.leftImage.image = image
            }.addDisposableTo(disposeBag)

        image2
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { [weak self] (image) -> Void in
                self?.rightImage.image = image
            }.addDisposableTo(disposeBag)

        zip(image1, image2) { img1, img2  in
            return self.composeImages(img1!, img2: img2!)
        }.observeOn(MainScheduler.sharedInstance)
        .bindTo(compositeImage.rx_imageAnimated(kCATransitionFade))
        .addDisposableTo(disposeBag)

    }

    func composeImages(img1: UIImage, img2: UIImage) -> UIImage? {
        if let filter = CIFilter(name: "CISourceOverCompositing") {
            filter.setDefaults()
            filter.setValue(CIImage(CGImage: img1.CGImage!), forKey: "inputImage")
            filter.setValue(CIImage(CGImage: img2.CGImage!), forKey: "inputBackgroundImage")
            return UIImage(CIImage: filter.outputImage!)
        } else {
            return nil
        }
    }
}
    
