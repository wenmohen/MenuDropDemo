//
//  ViewController.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    
    var foods = ["菜式","菜式咖色的接口看奥斯卡大咖斯柯达啊速度快萨克","菜式2","菜式3","菜式4","菜式5"]
    var areas = ["全部地区","地区1","地区2"]
    var arr1 = [[String: Any]]()
    var arr2 = [String]()
    var arr3 = [String]()

    var menuArr = [String]()
    var selectedDate1Index = 0
    var selectedDate1Index2 = 0
    var selectedDate2Index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let menu = NMenuDropView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 40))
        self.view.addSubview(menu)
        arr1 = [["title":"餐厅","data":foods],["title":"地标","data":areas]]
        arr2 = areas
        arr3 = ["商圈1","商圈1"]
        menuArr = ["菜式","地区"]
        menu.delegate = self
        menu.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ViewController: NMenuDropViewDelegate, NMenuDropViewDataSource {
    
    func currentLeftSelectedRow(column: NSInteger) -> NSInteger {
        switch column {
        case 0:
            return selectedDate1Index
        case 1:
            return selectedDate2Index
        default:
            return 0
        }
    }
    
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
                return datas[indexPath.row]
            }
        case 1:
            return arr2[indexPath.row]
        default:
            return ""
        }
        
        
    }
    
    func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath) {
        switch indexPath.column {
        case 0:
            if indexPath.leftOrRight == 0 {
                selectedDate1Index = indexPath.row
            }else {
                guard let _ = arr1[indexPath.leftRow]["data"] as? [String] else {
                    return
                }
            }
        case 1:
            selectedDate2Index = indexPath.row
        default:
            break
        }
    }
    
}
