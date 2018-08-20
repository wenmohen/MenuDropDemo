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

   
    var arr = [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       let menu = NMenuDropView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 40))
        menu.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        self.view.addSubview(menu)
        arr = [["title":"菜式","data":foods],["title":"地区"],["data":areas]]
        menu.listArr = arr
        menu.delegate = self
        menu.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: NMenuDropViewDelegate, NMenuDropViewDataSource {
    func memu(_ memu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger, leftRow: NSInteger) -> NSInteger {
        if leftOrRight == 0 {
            return arr.count
        }else {
            guard let datas = arr[leftRow]["data"] as? [String] else {
                return 0
            }
            return datas.count
        }
    }
    

    
    func widthRatioOfLeftColumn(column: NSInteger) -> CGFloat {
        return 1
    }
    
    func haveRightTableViewInColumn(column: NSInteger) -> Bool {
        return false
    }

    func memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String {
        if indexPath.leftOrRight == 0 {
            guard let title = arr[indexPath.row]["title"] as? String else {
                 return ""
            }
            return title
        }else {
            guard let datas = arr[indexPath.row]["data"] as? [String] else {
                return ""
            }
            return datas[indexPath.row]
        }
        
    }
    
    func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath) {
        print("哈哈哈哈或")
    }
    
}
