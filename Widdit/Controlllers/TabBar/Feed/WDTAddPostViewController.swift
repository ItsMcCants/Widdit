//
//  WDTAddPostViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import ALCameraViewController
import UITextView_Placeholder

class WDTAddPostViewController: UIViewController, UITextViewDelegate {

    var m_strPlaceholder: String?
    var m_objPost: PFObject?
    
    @IBOutlet weak var m_btnPost: UIBarButtonItem!
    @IBOutlet weak var m_txtDescription: UITextView!
    @IBOutlet weak var m_lblLength: UILabel!
    @IBOutlet weak var m_imgPost: UIImageView!
    @IBOutlet weak var m_btnImageDelete: UIButton!
    @IBOutlet weak var m_lblSliderValue: UILabel!
    @IBOutlet weak var m_viewSliderContainer: UIView!
    
    let slider = WDTCircleSlider()
    
    var geoPoint: PFGeoPoint?
    var isPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let strPlaceholder = m_strPlaceholder {
            m_txtDescription.placeholder = strPlaceholder
        }
        
        if let objPost = m_objPost {
            m_txtDescription.text = objPost["postText"] as? String ?? ""
            
            let photo = objPost["photoUrl"] as? String ?? ""
            if photo.characters.count > 0 {
                m_imgPost.kf.setImage(with: URL(string: photo))
                m_btnImageDelete.isHidden = false
                isPhoto = true
            }
        }
        
        m_lblLength.text = "\(m_txtDescription.text.characters.count) / \(Constants.Integer.MAX_POST_LENGTH)"
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
        
        //Initialize CircleSlider
        m_viewSliderContainer.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        slider.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
        
        postGuard()
    }

    func valueChanged(sender: WDTCircleSlider) {
        slider.roundControll()
        
        var s = ""
        if Int(sender.value) == 1 {
            s = ""
        } else {
            s = "s"
        }
        
        if slider.circle == .Hours {
            m_lblSliderValue.text = "Lasts for \(Int(sender.value)) hour" + s
        } else {
            m_lblSliderValue.text = "Lasts for \(Int(sender.value)) day" + s
        }
        
        postGuard()
    }
    
    func postGuard() {
        m_btnPost.isEnabled = m_txtDescription.text.characters.count > 0 && slider.value > 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnPost(_ sender: Any) {
        view.endEditing(true)
        
        showHud()
        
        var tasksCount = 1
        
        func removeTask() {
            tasksCount -= 1
            if tasksCount <= 0 {
                self.hideHud()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        if m_objPost == nil {
            m_objPost = PFObject(className: "posts")
        }
        
        m_objPost?["postText"] = m_txtDescription.text
        m_objPost?["user"] = PFUser.current()
        
        if let geoPoint = self.geoPoint {
            m_objPost?["geoPoint"] = geoPoint
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks.last
                        
                        if let city = placemark?.locality {
                            self.m_objPost?["city"] = city
                        }
                        
                        if let country = placemark?.isoCountryCode {
                            self.m_objPost?["country"] = country
                        }
                    }
                }
            })
        }
        
        if slider.circle == .Days {
            m_objPost?["hoursexpired"] = Date().addHours(Double(slider.value) * 24)
        } else {
            m_objPost?["hoursexpired"] = Date().addHours(Double(slider.value))
        }
        
        if isPhoto {
            tasksCount += 1
            
            let photoData = UIImageJPEGRepresentation(m_imgPost.image!, 0.5)
            let photoFile = PFFile(name: "postPhoto.jpg", data: photoData!)
            photoFile?.saveInBackground(block: { (success, error) in
                self.m_objPost?["photoUrl"] = photoFile?.url
                self.m_objPost?.saveInBackground(block: { (success, error) in
                    removeTask()
                })
            })
        } else {
            m_objPost?["photoUrl"] = ""
        }
        
        var tags = [String]()
        let nsstring = m_txtDescription.text as NSString
        let matches = WDTTextParser.getElements(from: m_txtDescription.text, with: WDTTextParser.hashtagPattern)
        for match in matches where match.range.length > 2 {
            let tag = nsstring.substring(with: match.range)
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
            
            tags.append(tag.substring(from: 1))
        }
        
        m_objPost?["hashtags"] = tags

        m_objPost?.saveInBackground(block: { (success, error) in
            if error == nil {
                self.addNewCategories() {
                    removeTask()
                }
            } else {
                removeTask()
            }
        })
    }
    
    func addNewCategories(completion: @escaping () -> Void) {
        let categories = m_objPost?["hashtags"] as! [String]
        
        var tasksCount = categories.count
        
        func removeTask() {
            tasksCount -= 1
            if tasksCount <= 0 {
                completion()
            }
        }
        
        if categories.count == 0 {
            removeTask()
        }
        
        for category in categories {
            let categoriesQuery = PFQuery(className: "categories")
            categoriesQuery.whereKey("title", equalTo: category)
            categoriesQuery.getFirstObjectInBackground(block: { (objCategory, error) in
                if objCategory == nil {
                    let newCategory = PFObject(className: "categories")
                    newCategory["title"] = category
                    newCategory.saveInBackground(block: { (success, error) in
                        removeTask()
                    })
                } else {
                    removeTask()
                }
            })
        }
    }
    
    @IBAction func onClickBtnImageDelete(_ sender: Any) {
        m_btnImageDelete.isHidden = true
        m_imgPost.image = UIImage(named: "post_image_placeholder")
        isPhoto = false
    }
    
    @IBAction func onTapPostImage(_ sender: Any) {
        let cameraVC = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { (image, asset) in
            if let image = image {
                self.m_imgPost.image = image
                self.m_btnImageDelete.isHidden = false
                self.isPhoto = true
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        present(cameraVC, animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        postGuard()
        
        if newLength > Constants.Integer.MAX_POST_LENGTH {
            return false
        } else {
            m_lblLength.text = "\(newLength) / \(Constants.Integer.MAX_POST_LENGTH)"
            return true
        }
    }
    
}
