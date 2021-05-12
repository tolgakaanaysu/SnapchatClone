import UIKit
import ImageSlideshow

class SnapVC: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    
    var selectSnap: Snap?
    var inputArray = [KingfisherSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
      
        
        if let snap = selectSnap {
            timeLabel.text = "Time Left: \(snap.timeLeft)"
            
            for imageURL in snap.imageUrlArray {
                inputArray.append(KingfisherSource(urlString: imageURL)!)
                
            }
            
            let imageSlide = ImageSlideshow(frame: CGRect(x: self.view.frame.width * 0.5 - (self.view.frame.width * 0.45) , y: 0, width: self.view.frame.width * 0.9, height: self.view.frame.height * 0.8))
                        
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = .black
            pageIndicator.pageIndicatorTintColor = .lightGray
            imageSlide.pageIndicator = pageIndicator
            
            imageSlide.backgroundColor = .white
            imageSlide.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlide.setImageInputs(inputArray)
            self.view.addSubview(imageSlide)
            self.view.bringSubviewToFront(timeLabel)
            
        }
        
        
    }

}
