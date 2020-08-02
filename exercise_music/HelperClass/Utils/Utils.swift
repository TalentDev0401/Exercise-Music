//
//  Utils.swift
//  Allo Boulangerie
//
//  Created by Adite Technologies on 04/04/16.
//  Copyright © 2016 Adite Technologies. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import Alamofire
import Realm
import REDownloadTasksQueue

enum CharacterSetType: String
{
    case Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
    case Numeric = "0123456789"
    case AlphaNumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_., "
}
class Utils: NSObject
{
    
    class func getTimeStamp() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    class func shadowEffectBtn(btn: UIButton) {
        btn.layer.cornerRadius = btn.bounds.size.height/2
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.shadowPath = UIBezierPath(rect: btn.bounds).cgPath
        btn.layer.shadowRadius = 18
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowOpacity = 0.8
    }
    
    // - get label's height regarding text
    class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
    class func Show(_ message:String = "Please wait",controller: UIViewController){
        
        let state:Bool =  Reachability.isConnectedToNetwork()
        if state == true
        {
            var load : MBProgressHUD = MBProgressHUD()
            
            load = MBProgressHUD.showAdded(to: UIApplication.shared.windows[0], animated: true)
            load.mode = MBProgressHUDMode.indeterminate
            load.labelText = message;
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            controller.view.addSubview(load)
        }
    }
    class func HideHud(controller: UIViewController){
        MBProgressHUD.hide(for: controller.view, animated: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    class func HideAllHud(){
        DispatchQueue.main.async {
            MBProgressHUD.hideAllHUDs(for: UIApplication.shared.windows[0], animated: true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    class func showAlert(_ message: String?, withTitle title: String?, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        controller.present(alert, animated: true)
    }
    
    @available(iOS 13.0, *)
    class func setviewBorder(_ view: Any, color:UInt32, opacity:Float)
    {
        let bottomBorder = CALayer()
        let borderWidth: CGFloat = 1
        bottomBorder.frame = CGRect(x: CGFloat(0), y: CGFloat((view as AnyObject).frame.size.height - borderWidth), width: CGFloat((view as AnyObject).frame.size.width), height: CGFloat(1))
     
        bottomBorder.borderColor = self.uiColorString(hStr: "0xDCDCDC").cgColor
        //uicolorFromHex(rgbValue: color).cgColor
        bottomBorder.borderWidth = 1.0;
        (view as AnyObject).layer.addSublayer(bottomBorder)
        (view as AnyObject).layoutIfNeeded()
    }
    
    class func addAttributes(text:String,range:NSRange,fontName:String,fontSize:CGFloat, color:UIColor) -> NSMutableAttributedString
    {
        let myMutableString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font:UIFont(name: fontName, size: fontSize)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return myMutableString
    }
    class func showAlert(_ title: String, message: String, controller: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:
            { action in
                
                Utils.removeUserInfoObject()
        }
        ))
        controller.present(alert, animated: true, completion: nil)
    }
    class func showToastMessage(_ message: String, controller: UIViewController)
    {
        var toast: MBProgressHUD = MBProgressHUD()
        toast = MBProgressHUD.showAdded(to: controller.view, animated: true)
        toast.labelText = message
        toast.mode = .text
        toast.yOffset = (Float(controller.view.frame.size.height) / 2) - 50
        toast.sizeToFit()
        toast.removeFromSuperViewOnHide = true
        toast.hide(true, afterDelay: 3)
    }
    class func setUserInfoObject(_ object: Any)
    {
        if object != nil
        {
            let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
            userDefault.set(encodedObject, forKey: "jukebox")
            userDefault.synchronize()
        }
    }
    class func urlToString(str:String) -> URL
    {
        let url = URL(string:str)
        print("URL === \(url!)")
        return url!
    }
    class func getUserInfoObject() -> Any?
    {
        let encodedObject: Data? = userDefault.object(forKey: "jukebox") as! Data?
        //defaults.object(forKey: "jukebox") as! Data?
        if encodedObject == nil
        {
            return nil
        }
        else
        {
            let object = NSKeyedUnarchiver.unarchiveObject(with: encodedObject!)
            //print(object)
            return object as Any
        }
    }
    class func removeUserInfoObject() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "jukebox")
        defaults.synchronize()
    }
    
    // MARK: Get User POJO  
    
    class func isObjectNotNil(_ ob: AnyObject?) -> Bool {
        if ob == nil {
            return false
        }
        if (ob is NSNull) {
            return false
        }
        return true
    }
    class func uiColorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/255.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    class func uiColorString(hStr:String?)->UIColor{
        
        let hStr1 = "0x" + hStr!
        let rgbValue = UInt(String(hStr1.suffix(6)), radix: 16)
        let red = CGFloat((rgbValue! & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue! & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue! & 0xFF)/255.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    class func uiColorString(hStr:String?,alpha:Float)->UIColor{
        
        let hStr1 = "0x" + hStr!
        let rgbValue = UInt(String(hStr1.suffix(6)), radix: 16)
        let red = CGFloat((rgbValue! & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue! & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue! & 0xFF)/255.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    class func uiColorFromHex(rgbValue:UInt32,alpha:Float)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/255.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    class func milliSecondsToTimer(milliseconds:Int) -> String
    {
        var finalTimerString : String = ""
        var secondsString : String = ""
        
        let const:Int = 1000 * 60 * 60
        
        // Convert total duration into time
        let hours:Int = Int(milliseconds / const)
        var minutes:Int = Int((milliseconds % const) / (1000 * 60))
        let seconds:Int = Int((milliseconds % const) % (1000 * 60) / 1000)
        
        // Add hours if there
        
        if hours > 0
        {
            //            finalTimerString = "\(hours)" + "."
            minutes = minutes + hours * 60
        }
        if seconds < 10
        {
            secondsString = "0" + "\(seconds)"
        }
        else
        {
            secondsString = "" + "\(seconds)"
        }
        finalTimerString = finalTimerString + "\(minutes)" + "." + secondsString
        return finalTimerString
    }

    class func removeFileFromDirectory(obj:DownloadObj,controller:UIViewController,backView:UIView,completion: @escaping (_ sts: Bool) -> ()){
        
        let audioFileName = URL(string:obj.item_file_path!)
        let audioName = audioFileName?.lastPathComponent
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("/")
        documentsURL.appendPathComponent(obj.item_file_path!)
        let finalPath = documentsURL.deletingLastPathComponent()
        
        let directoryContents:[String] = try! FileManager.default.contentsOfDirectory(atPath: finalPath.path)
        
        if directoryContents.count > 0 {
            for path in directoryContents {
                if path == audioName
                {
                    let fullpath2 = finalPath.deletingLastPathComponent().path.appending("/").appending(obj.item_image_path!)
                    let fullPath = finalPath.path.appending("/" + path)
                    
                    if jukebox != nil
                        //&& kAppDelegate.isFromDownload
                    {
                        let item = JukeboxItem(URL: URL(string:fullPath)!)
                        item.localId = obj.item_id
                        jukebox.remove(item: item)
                    }
                    RealmUtils.sharedInstance.removeDownloadObject(itemId: obj.item_id!)
                    
                    guard (try? FileManager.default.removeItem(atPath: fullPath)) != nil else {
                        print("Could not delete audio file:")
                        break
                    }
                    
                    guard (try? FileManager.default.removeItem(atPath: fullpath2)) != nil else {
                        //removeItem(at: URL(string:fullpath2)!)) != nil else {
                        print("Could not delete img file:")
                        break
                    }
                    print("File deleted")
                    completion(true)
                }
            }
        }
    }
    class func generateRandomDigit() -> String
    {
        return String(arc4random_uniform(9999))
    }

    class func setAlomFireImage(_ url: String, imageView: UIImageView,AI:UIActivityIndicatorView?,rad:Int,imageSize:CGSize) {
        
        if url == "" {
            if let AI = AI {
                AI.stopAnimating();
            }
            return
        }
        
        let finalUrl = URL(string: url)
        let placeholderImage = UIImage(named: "no_image")!
        let CustomSize = imageSize
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: CustomSize,
            radius: CGFloat(rad)
        )
        imageView.af_setImage(
            withURL: finalUrl!,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.5),
            completion : { response in
                if response.result.value != nil
                {
                    
                }
                if let AI = AI {
                    AI.stopAnimating();
                    AI.isHidden = true
                }                
        }
        )
    }
    
}

func configureTableView(_ myTableView: UITableView)
{
    myTableView.tableFooterView = UIView()
    myTableView.rowHeight = UITableView.automaticDimension
    myTableView.estimatedRowHeight = 90
}
func reloadTableViewWithAnimation(myTableView: UITableView)
{
    let range = NSMakeRange(0, myTableView.numberOfSections)
    let sections = NSIndexSet(indexesIn: range)
    myTableView.reloadSections(sections as IndexSet, with: .automatic)
    // myTableView.endLoading()
}
func setSelectedValue(btn:RadioButton) -> String
{
    if kAppDelegate.fromWhereRepeate == "R"
    {
        for rb in btn.groupButtons {
            let rb1 = rb as! RadioButton
            if rb1.titleLabel?.text == kAppDelegate.radioTitle
            {
                rb1.setSelected(true)
            }
        }
        return ""
    }
    else
    {
        return kAppDelegate.textFieldRepeteValue
    }
}
func getSelectionValue(title:String) -> String
{
    var str = ""
    switch title {
    case "3 times":
        str = "3"
    case "5 times":
        str = "5"
    case "9 times":
        str = "9"
    case "11 times":
        str = "11"
    case "108 times":
        str = "108"
    default:
        str = ""
    }
    return str
}

extension UIView {
  func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 0.3) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: duration) {
        self.alpha = alpha
      }
    }
  }

  func fadeIn(_ duration: TimeInterval = 0.3) {
    fadeTo(1.0, duration: duration)
  }

  func fadeOut(_ duration: TimeInterval = 0.3) {
    fadeTo(0.0, duration: duration)
  }
}

extension Bool {
    
    init?(string: String) {
        switch string {
        case "True", "true", "yes", "1":
            self = true
        case "False", "false", "no", "0":
            self = false
        default:
            return nil
        }
    }
}
// Mark: Print Font Name
func PrintFontName()
{
    let fontFamilyNames = UIFont.familyNames
    for familyName in fontFamilyNames {
        print("------------------------------")
        print("Font Family Name = [\(familyName)]")
        let names = UIFont.fontNames(forFamilyName: familyName)
        print("Font Names = [\(names)]")
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

//MARK: Custom Designable UIButton 
@IBDesignable
class CustomUIButton: UIButton {
    
    @IBInspectable  var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable  var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable  var cornerRadius: CGFloat = 0.0  {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0)  {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable  var shadowRadius: CGFloat = 5.0{
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable  var shadowOpacity: CGFloat = 0.5{
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
}
@IBDesignable
class CustomView: UIView {
    
    //    @IBInspectable var shadowColor: UIColor? = UIColor.black
    //    @IBInspectable var shadowOpacity: Float = 0.5
    
    @IBInspectable  var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable  var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable  var cornerRadius: CGFloat = 0.0  {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0)  {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable  var shadowRadius: CGFloat = 5.0{
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable  var shadowOpacity: CGFloat = 0.5{
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
}

//MARK: Custom Designable UITextField 
@IBDesignable
class CustomUItxtField: UITextField {
    
    @IBInspectable  var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable  var borderWidth: CGFloat = 0.0  {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable  var cornerRadius: CGFloat = 0.0  {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

//MARK: Custom Designable UIButton 
@IBDesignable
class CustomUIImageView: UIImageView {
    
    @IBInspectable  var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable  var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable  var cornerRadius: CGFloat = 0.0  {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0)  {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable  var shadowRadius: CGFloat = 5.0{
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    @IBInspectable  var shadowOpacity: CGFloat = 0.5{
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
}
extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}

