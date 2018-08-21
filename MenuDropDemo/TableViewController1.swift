//
//  TableViewController1.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/21.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class TableViewController1: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewConstraintTop: NSLayoutConstraint!
    
    let menuHeaderSectionView = NMenuDropView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
    
    var foods = [String]()
    var areas = [[String: Any]]()
    var menuTitles = [String]()
    
    var foodLeftSelectedIndex = 0
    var areaLeftSelectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}
extension TableViewController1 {
    func setupTableView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableViewConstraintTop.constant = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250  + UIApplication.shared.statusBarFrame.height)
    }
    
    func setupMenuView() {
        menuTitles = ["菜式","地区"]
        foods = ["菜式","菜式1","菜式2","菜式3","菜式4","菜式5","菜式6","菜式7","菜式8","菜式9","菜式10"]
        areas = [["title":"地区","data":["地区","地区1","地区2","地区3","地区4","地区5"]],["title":"地标","data":["地标"]]]
        menuHeaderSectionView.frame.origin = CGPoint.init(x: 0, y: headerView.frame.maxY)
        menuHeaderSectionView.menuTitleSelectedColor = UIColor.red
        menuHeaderSectionView.delegate = self
        menuHeaderSectionView.dataSource = self
        menuHeaderSectionView.didMenuTapClosure = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.tableView.scrollToRow(at: [0,0], at: .top, animated: true)
            strongSelf.menuHeaderSectionView.frame.origin = CGPoint(x:0,y:64)
        }
        view.addSubview(menuHeaderSectionView)
    }
}

// MARK: - Delegate, Datasource of tableview
extension TableViewController1: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerSectionView = UIView()
        headerSectionView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        return headerSectionView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "celll")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
// MARK: - UIScrollViewDelegate
extension TableViewController1: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(tableView.contentOffset.y)
        updateMenuSectionView()
    }
    
    func updateMenuSectionView() {
        let y = tableView.contentOffset.y
        let maxHeight = headerView.frame.maxY - 64
        if y > maxHeight {
            menuHeaderSectionView.frame.origin = CGPoint(x:0,y:64)
        }else {
            menuHeaderSectionView.frame.origin = CGPoint(x:0,y:headerView.frame.maxY - y)
        }
    }
}

extension TableViewController1: NMenuDropViewDelegate, NMenuDropViewDataSource {
    
    func currentLeftSelectedRow(column: NSInteger) -> NSInteger {
        switch column {
        case 0:
            return foodLeftSelectedIndex
        case 1:
            return areaLeftSelectedIndex
        default:
            return 0
        }
    }
    
    func numberOfColumn(_ memu: NMenuDropView) -> NSInteger {
        return menuTitles.count
    }
    func memu(_ memu: NMenuDropView, titleForColumn column: NSInteger) -> String {
        return menuTitles[column]
    }
    
    func memu(_ memu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger, leftRow: NSInteger) -> NSInteger {
        switch column {
        case 0:
            return foods.count
        case 1:
            if leftOrRight == 0 {
                return areas.count
            }else {
                guard let datas = areas[leftRow]["data"] as? [String] else {
                    return 0
                }
                return datas.count
            }
            
        default:
            return 0
        }
    }
    
    
    
    func widthRatioOfLeftColumn(column: NSInteger) -> CGFloat {
        switch column{
        case 1:
            return 1/3
        default:
            return 1
        }
    }
    
    func haveRightTableViewInColumn(column: NSInteger) -> Bool {
        switch column {
        case 1:
            return true
        default:
            return false
        }
    }
    
    func memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String {
        switch indexPath.column {
        case 0:
            return foods[indexPath.row]
        case 1:
            if indexPath.leftOrRight == 0 {
                guard let title = areas[indexPath.row]["title"] as? String else {
                    return ""
                }
                return title
            }else {
                guard let datas = areas[indexPath.leftRow]["data"] as? [String] else {
                    return ""
                }
                return datas[indexPath.row]
            }
        default:
            return ""
        }
    }
    
    func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath) {
        switch indexPath.column {
        case 0:
            foodLeftSelectedIndex = indexPath.row
        case 1:
            if indexPath.leftOrRight == 0 {
                areaLeftSelectedIndex = indexPath.row
            }else {
                guard let _ = areas[indexPath.leftRow]["data"] as? [String] else {
                    return
                }
            }
        default:
            break
        }
    }
}
