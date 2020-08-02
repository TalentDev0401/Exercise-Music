//
//  AppColor_AND_Font.swift
//  Audio Player
//
//  Created by Adite Technologies on 22/09/17.
//  Copyright © 2017 Adite Technologies. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift


let userDefault = UserDefaults.standard
var jukebox : Jukebox!
let kRealm = try! Realm()
var kDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

var AppURLLive = "https://itunes.apple.com/in"
let AppName = "Exercise Music"

let kMobileAdsConfigutationId = "ca-app-pub-3940256099942544~1458002511"
let kInterstitialId = "ca-app-pub-3940256099942544/4411468910"
let kBannerId = "ca-app-pub-3940256099942544/2934735716"
let kShareContent = "Hi,I am happy to share this awesome Devotional songs app with you, Download from here:"
//let FACEBOOK_SCHEME = "fb903723256364055"
let FACEBOOK_SCHEME_SHARE = "fbauth2:/"
let ReciverEmailID = "rgbcat@gmail.com"
let PhoneNumber = ""
let SiteURL = "http://www.goldenant.in"
let visitString = "Visit Us At"
let LaunchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil)
let Main = UIStoryboard(name: "Main", bundle: nil)

let UUID1: String = (UIDevice.current.identifierForVendor?.uuidString)!
let kAppDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let defaults = UserDefaults.standard

let _screenFrame    = UIScreen.main.bounds
let _screenSize     = _screenFrame.size
let _widthRatio     = _screenSize.width/320
let _heighRatio     = _screenSize.height/568

var bigOb:[String : Any] = Utils.getUserInfoObject() as! [String : Any]
var loginToken = bigOb["token"] as! String
let helperOb = HelerMethod()
let isDynamicColor = true

struct NotificationName {
    static let JukeBoxConfigured = "JukeBoxConfigured"
    static let PlaybackProgressChange = "PlaybackProgressChange"
    static let PlaybackStateChange = "PlaybackProgressChange"
    static let FavoriteStateChange = "FavoriteStateChange"
    static let PlaybackInfoChange = "PlaybackInfoChange"
    static let PlaybackEnded = "PlaybackEnded"
    static let PlaybackPaused = "PlaybackPaused"
    static let FavoriteInfoChanged = "FavoriteInfoChanged"
    static let Purchased = "Purchased"
    static let ProgressSong = "ProgressSong"
    static let ProgressSongCompleted = "ProgressSongCompleted"
    //static let PlaybackPaused= "PlaybackPaused"
}
struct USERINFO {
    static let username = "username"
    static let email = "email"
    static let password = "password"
    static let token = "token"
    static let extra_time = "extra_time"
    static let user_id = "user_id"
}
struct AppURL {
    
    //Base Url
    static let  API_BASE_URL = "http://178.128.39.216"
    
    //Api Name
    static let  API_POST_SIGNUP = "/api/v1/gcm_register"
    static let  API_POST_SIGNIN = "/api/v1/gcm_login"
    static let  API_POST_CATEGORY = "/api/v1/get_item"
    static let  API_POST_FAVORITES = "/api/v1/set_favorite"
    static let  API_POST_SESSION = "/api/v1/set_session"
    static let  API_POST_STATS = "/api/v1/get_duration"
    static let  API_POST_DELAY_TIME = "/api/v1/set_extra"
    static let  API_ABOUT_US = "/api/v1/get_about_us"
    static let  API_DELETE_USER = "/api/v1/gcm_delete"
    static let  API_UPDATE_PASSWORD = "/api/v1/update_user"
    static let  API_RESET_PASSWORD = "/api/v1/reset_password"
    static let  API_SUBSCRIPTION = "/api/v1/subscription"
    static let  API_COMPARE_DEVICE = "/api/v1/compare_device"
    static let  API_GCM_ID = "gcm_register"
    static let  API_UPDATE_SONG_STATUS = "/api/v1/update_song_status"
    static let  API_SEARCH_SONG = "search_song"
    
    //Whole url
    static let  API_POST_SIGNUP_URL = API_BASE_URL + API_POST_SIGNUP
    static let  API_POST_SIGNIN_URL = API_BASE_URL + API_POST_SIGNIN
    static let  API_POST_CATEGORY_URL = API_BASE_URL + API_POST_CATEGORY
    static let  API_POST_FAVORITES_URL = API_BASE_URL + API_POST_FAVORITES
    static let  API_POST_SESSION_URL = API_BASE_URL + API_POST_SESSION
    static let  API_POST_STATS_URL = API_BASE_URL + API_POST_STATS
    static let  API_POST_DELAY_TIME_URL = API_BASE_URL + API_POST_DELAY_TIME
    static let  API_ABOUT_US_URL = API_BASE_URL + API_ABOUT_US
    static let  API_DELETE_USER_URL = API_BASE_URL + API_DELETE_USER
    static let  API_UPDATE_PASSWORD_URL = API_BASE_URL + API_UPDATE_PASSWORD
    static let  API_RESET_PASSWORD_URL = API_BASE_URL + API_RESET_PASSWORD
    static let  API_SUBSCRIPTION_URL = API_BASE_URL + API_SUBSCRIPTION
    static let  API_COMPARE_DEVICE_URL = API_BASE_URL + API_COMPARE_DEVICE
    static let  API_GCM_ID_URL = API_BASE_URL + API_GCM_ID
    static let  API_POST_UPDATE_SONG_STATUS = API_BASE_URL + API_UPDATE_SONG_STATUS
    static let  API_POST_SEARCH_SONG = API_BASE_URL + API_SEARCH_SONG
}
struct AppParams {
    // string constants
    static let  CATEGORY_ID = "category_id"
    static let  CATEGORY_NAME = "category_name"
    static let  CATEGORY_IMAGE = "category_image"
    static let  item_id = "item_id"
    static let  item_name = "item_name"
    static let  item_description = "item_description"
    static let  item_file = "item_file"
    static let  item_image = "item_image"
    static let  download_name = "download_name"
    
    static let  GCM_ID = "gcm_id"
    static let  DEVICE_ID = "device_id"
    static let  FLAG = "flag"
}
struct ControllerTitle
{
    static var Home = "Categories"
    static var Favorite = "Favorites"
    static var Download = "Downloads"
    static var Notification = "Notifications"
    static var Share = "Share"
    static var Feedback = "Feedback"
    static var About = "About Us"
    static var Search = "Search Song"
}
struct MenuTitle
{
    static var Home = "HOME"
    static var Favorite = "FAVORITES"
    static var Download = "DOWNLOADS"
    static var Notification = "NOTIFICATIONS"
    static var Share = "INVITE/SHARE"
    static var Rate = "RATE US"
    static var Feedback = "FEEDBACK"
    static var About = "ABOUT US"
}
struct NoData
{
    static var Home = "No any category found!"
    static var Favorite = "No any favorites found!"
    static var Download = "No any downloads found!"
    static var Notification = "No any notifications found!"
    static var Search = "No song found!"
}
struct FeedBackPlaceholder
{
    static var Name = "Name"
    static var MobileNum = "Mobile Number"
    static var Description = "Description"
}
struct ShareBtnTitle
{
    static var fb = "Share On Facebook"
    static var email = "Share On Email"
    static var wp = "Share On Whatsapp"
    static var submit = "Submit"
}
struct SearchPlaceholder
{
    static var Name = "Search Song"
}
struct colorAboutText {
     static var color = "0xF45011"
     static var background = "#1e5159"
     static var sliderHandle = "0x2A7EA3"
     static var sliderFilled = "0xF45011"
}

struct Alerts {
    static var RemoveSong = "Do you want to remove this Song?"
    static var NoInternet = "Please check your Internet connection"
}
struct Directory
{
    static var AudioFiles = "AudioFiles"
    static var ImageFiles = "ImageFiles"
    static var CategoryImages = "CategoryImages"
}
struct ToastMsg
{
    static var songRemoved = "Song removed Successfully"
    static var notRemove = "You can not remove current song"
    static var radioSelect = "Please Select Value"
    static var NotUnfavorite = "You can not unfavorite current song"
    static var EnterValue = "Please Enter Values"
    static var DownlodedSuccess = "Downloded Successfully"
    static var MailCanceled = "Mail cancelled"
    static var MailSaved = "Mail saved"
    static var MailSent = "Mail sent"
    static var MailFailure = "Mail sent failure:"
}
struct Color
{
    //======================= NAVIGATION =======================
    static var secondaryAppColor = Utils.uiColorFromHex(rgbValue: 0xffffff)
    //custom navigation tint color
    static var customnavigationSignUpTintColor = UIColor.darkGray
    //custom navigation background color
    static var customNavigationBackgroundColor =  Utils.uiColorFromHex(rgbValue: 0xFFFFFF)
    
    //transparent navigation tint color
    static var navigationSignUpTintColor = Color.secondaryAppColor
}
    
//MARK: DateFormet
struct DateFormet {
    static let DemoDateFormat                   =   "yyyy-MM-dd hh:mm:ss"
    static let ServerDateFormet                 =   "yyyy-MM-dd HH:mm:ss"
    static let NormalDateFormet                 =   "yyyy-MM-dd"
    static let DatePickerDateFormet             =   "yyyy-MM-dd HH:mm:ss Z"
    static let DeliverybyDateFormet             =   "hh:mm a"
}

//MARK: Segue
struct Segue
{
    static let HomeSegue                        =   "homeSegue"
    static let SubCategorySegue                 =   "subCategorySegue"
    static let DetailSegue                      =   "detailSegue"
    static let DownloadSegue                    =   "downloadSegue"
    static let AboutSegue                       =   "aboutSegue"
    static let ShareSegue                       =   "shareSegue"
    static let FeedbackSegue                    =   "feedbackSegue"
    static let FavoriteSegue                    =   "favoriteSegue"
    static let NotifSegue                       =   "notifSegue"
    static let SearchSegue                      =   "searchSegue"
    static let ProgressSegue                    =   "progressSegue"
}

// MARK: - Welcome message
struct WelcomeMessage {
    static let dayMessage = "Good afternoon🌤"
    static let morningMessage = "Good morning🌸"
    static let eveningMessage = "Good evening🌒"
    static let nightMessage = "Have a good night😴"
    static let sleeplessMessage = "Sleepless night?🌑"
}
