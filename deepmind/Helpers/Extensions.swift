//
//  Extensions.swift
//  deepmind
//
//  Created by mac88 on 2017. 7. 4..
//  Copyright © 2017년 mac88. All rights reserved.
//

import UIKit
import PagingMenuController
import SkyFloatingLabelTextField
import GameKit
import BouncyLayout

extension UIView
{
  func setHideKeyboard()
  {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(UIView.dismissKeyboard))
    
    addGestureRecognizer(tap)
  }
  
  func dismissKeyboard()
  {
    endEditing(true)
  }
}

extension UIViewController {
  func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
  }
}

extension UIWindow
{
  /// The reason why I declare `moveTo(VC)` in here(UIWindow extension) is that both of "LoginViewController" and "PlayerFieldsViewController" need this same functionality
  /// Set `_vc` to "Window(`self`)"'s rootViewController
  func moveTo(VC _vc: ViewController) {
    log.verbose("called")
    if self.isKeyWindow {
      if ( _vc == .PlayerRegister ) {
        self.rootViewController = getPlayerRegisterVC()
      } else if ( _vc == .MainFields ) {
        let fieldsVC = getMainFieldsVC()
        //야 대박 
        fieldsVC.automaticallyAdjustsScrollViewInsets = false
        let navigationViewController = UINavigationController(rootViewController: fieldsVC)
        self.rootViewController = navigationViewController
      }
    } else {
      log.error("This window is not keywindow")
    }
  }
  /// Make `PlayerFieldsViewController` with design options and Return
  func getPlayerRegisterVC() -> PlayerRegisterViewController {
    log.verbose("called")
    /// Design options of menu item that will be used in top menu of `PagingMenuController`, which is related with `MemberViewController`
    struct memberRegisterViewControllerMenuItem: MenuItemViewCustomizable {
      var horizontalMargin: CGFloat {
        return 110
      }
      var displayMode: MenuItemDisplayMode {
        let menuItemText = MenuItemText(
          text: "맴버",
          color: UIColor.flatBlack,
          selectedColor: UIColor.flatBlue,
          font: UIFont.systemFont(ofSize: 16),
          selectedFont: UIFont.systemFont(ofSize: 18)
        )
        return MenuItemDisplayMode.text(title: menuItemText)
      }
    }
    /// Design options of menu item that will be used in top menu of `PagingMenuController`, which is related with `JokerViewController`
    struct jokerRegisterViewControllerMenuItem: MenuItemViewCustomizable {
      var horizontalMargin: CGFloat {
        return 30
      }
      var displayMode: MenuItemDisplayMode {
        let menuItemText = MenuItemText(
          text: "조커",
          color: UIColor.flatBlack,
          selectedColor: UIColor.flatBlue,
          font: UIFont.systemFont(ofSize: 16),
          selectedFont: UIFont.systemFont(ofSize: 18)
        )
        return MenuItemDisplayMode.text(title: menuItemText)
      }
    }
    /// Collection of menu view option including menu item option
    struct MenuOptions: MenuViewCustomizable {
      var itemsOptions: [MenuItemViewCustomizable] {
        return [memberRegisterViewControllerMenuItem(), jokerRegisterViewControllerMenuItem()]
      }
      var displayMode: MenuDisplayMode {
        return MenuDisplayMode.segmentedControl
      }
      var menuPosition: MenuPosition {
        return .top
      }
      var height: CGFloat {
        return 80
      }
    }

    /// Last settings to make `PagingMenuController`
    struct PagingMenuOptions: PagingMenuControllerCustomizable {
      var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: [MemberRegisterViewController(), JokerRegisterViewController()])
      }
    }
    //이렇게 연결시켜줌으로써, PlayerFieldsViewController안에서 MemberVC or JokerVC를 편하게 참조 할 수있게 된다
    let playerRegisterVC : PlayerRegisterViewController = PlayerRegisterViewController(options: PagingMenuOptions())
    if let pgvController = playerRegisterVC.pagingViewController {
      playerRegisterVC.memberRegisterVC = (pgvController.controllers[0] as! MemberRegisterViewController)
      playerRegisterVC.jokerRegisterVC = (pgvController.controllers[1] as! JokerRegisterViewController)
    }
    
    log.verbose("여기서 moveTo가 끝나고, playerFieldsVC를 돌려줍니다")
    
    return playerRegisterVC
  }
  
  /// Make FieldsViewController with 5 main controllers and Return
  func getMainFieldsVC() -> MainFieldsTabBarController {
    let fieldsTBC = MainFieldsTabBarController()
    // mapVC setting
    let mapVC : MapViewController = MapViewController()
    mapVC.title = "지도"
    mapVC.tabBarItem.image = UIImage(named: "ic_map")
    // pointsVC setting
    let pointVC : PointViewController = PointViewController()
    pointVC.title = "포인트"
    pointVC.tabBarItem.image = UIImage(named: "ic_rank")
    // OutVC setting
    let outVC : OutViewController = OutViewController(collectionViewLayout: BouncyLayout())
    outVC.title = "활동제한"
    outVC.tabBarItem.image = UIImage(named: "ic_out")
    // postsVC setting
    let postVC : PostViewController = PostViewController()
    postVC.title = "업로드"
    postVC.tabBarItem.image = UIImage(named: "ic_upload")
    // timerVC setting
    let timerVC : TimerViewController = TimerViewController()
    timerVC.title = "타이머"
    timerVC.tabBarItem.image = UIImage(named: "ic_timer")
    // "TabBarController" setting
    if ( mSettings.sharedInstance.options.playerList! ) {
      fieldsTBC.setViewControllers([mapVC, pointVC, outVC, postVC, timerVC], animated: true)
    } else {
      fieldsTBC.setViewControllers([mapVC, pointVC, postVC, timerVC], animated: true)
    }
    
    fieldsTBC.tabBar.tintColor = UIColor.flatBlackDark
    //fieldsTBC.tabBar.backgroundColor = UIColor.flatWhite
    return fieldsTBC
  }
}

extension Array {
  mutating func fill(With _with: Element, Count _count: Int) {
    for _ in 0..<_count {
      self.append(_with)
    }
  }
  func shuffled(using source: GKRandomSource) -> [Element] {
    return (self as NSArray).shuffled(using: source) as! [Element]
  }
  func shuffled() -> [Element] {
    return (self as NSArray).shuffled() as! [Element]
  }

}

extension SkyFloatingLabelTextField {
  func validate(Name _name: String, Limit _limit: Int){
    let length = _name.lengthOfBytes(using: String.Encoding.utf8)
    if(length%3 == 0){
      if(length/3 > _limit){
        self.errorMessage = "5글자 제한"
      }else{
        self.errorMessage = nil
      }
    }else{
      self.errorMessage = "영문/특수문자는 불가능합니다."
    }
  }
}

extension UICollectionView {
  func hasSelectedItem()->Bool {
    if let selectedItems = self.indexPathsForSelectedItems {
      if ( selectedItems.count > 0 ) {
        return true
      }
    }
    return false
  }
  func getSelectedItemIndexPath()->IndexPath? {
    if ( self.hasSelectedItem() ) {
      return self.indexPathsForSelectedItems![0]
    } else {
      return nil
    }
  }
  func getSelectedItem() -> UICollectionViewCell? {
    if let selectedItemIndexPath = getSelectedItemIndexPath() {
      if let selectedItem = self.cellForItem(at: selectedItemIndexPath) {
        return selectedItem
      }
    }
    return nil
  }
}

extension UIImageView {
  func getOwner() -> PostViewController.ImageViewOwner {
    switch self.tag {
    case 1:
      return .picture
    case 2:
      return .video
    case 3:
      return .post
    default:
      break
    }
    
    return .post
  }
  func set(Owner _owner: PostViewController.ImageViewOwner) {
    self.tag = _owner.rawValue
  }
}

