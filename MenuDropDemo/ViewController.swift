//
//  ViewController.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
  
    var foods = ["全部菜式","菜式1","菜式2","菜式3","菜式4","菜式5"]
    var areas = ["全部地区","地区1","地区2","地区3","地区4","地区5","地区6","地区7","地区8","地区9","地区10"]
    var arr1 = [[String: Any]]()
    var arr2 = [String]()
    var menuArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       let menu = NMenuDropView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 40))
        menu.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        self.view.addSubview(menu)
        arr1 = [["title":"菜式","data":foods],["title":"地区","data":areas]]
        arr2 = areas
        menuArr = ["菜品","地区"]
        menu.menuTitleArr = menuArr
        menu.delegate = self
        menu.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: NMenuDropViewDelegate, NMenuDropViewDataSource {
    func numberOfColumn(_ memu: NMenuDropView) -> NSInteger {
        return menuArr.count
    }
    func memu(_ memu: NMenuDropView, titleForColumn column: NSInteger) -> String {
        return menuArr[column]
    }
    
    func memu(_ memu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger, leftRow: NSInteger) -> NSInteger {
        switch column {
         case 0:
            if leftOrRight == 0 {
                return arr1.count
            }else {
                guard let datas = arr1[leftRow]["data"] as? [String] else {
                    return 0
                }
                return datas.count
            }
         case 1:
            return arr2.count
        default:
            return 0
        }
    }
    

    
    func widthRatioOfLeftColumn(column: NSInteger) -> CGFloat {
        switch column{
        case 0:
            return 1/3
        default:
            return 1
        }
    }
    
    func haveRightTableViewInColumn(column: NSInteger) -> Bool {
        switch column {
        case 0:
            return true
        default:
            return false
        }
    }

    func memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String {
        switch indexPath.column {
        case 0:
            if indexPath.leftOrRight == 0 {
                guard let title = arr1[indexPath.row]["title"] as? String else {
                    return ""
                }
                return title
            }else {
                guard let datas = arr1[indexPath.leftRow]["data"] as? [String] else {
                    return ""
                }
                print(datas)
                return datas[indexPath.row]
            }
        case 1:
            return arr2[indexPath.row]
        default:
            return ""
        }
       
        
    }
    
    func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath) {
        print("哈哈哈哈或")
        switch indexPath.column {
        case 0:
            if indexPath.leftOrRight == 0 {
                print(arr1[indexPath.row]["title"])
            }else {
                guard let datas = arr1[indexPath.leftRow]["data"] as? [String] else {
                    return
                }
                print(datas[indexPath.row])
            }
        case 1:
            print(arr2[indexPath.row])
        default:
            break
        }
    }
    
}
