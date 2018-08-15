//
//  ViewController.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NMenuDropViewDelegate {
    
    var arr = ["菜式","地区","地区","地区","地区","地区","地区","地区","地区","地区"]
    func memu(_ memu: NMenuDropView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String {
       return arr[indexPath.row]
    }
    
    func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath) {
        print("哈哈哈哈或")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       let menu = NMenuDropView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 40))
        menu.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        self.view.addSubview(menu)
        menu.listArr = arr
        menu.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

