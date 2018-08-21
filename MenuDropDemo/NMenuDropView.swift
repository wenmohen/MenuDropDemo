//
//  NMenuDropView.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

@objc protocol NMenuDropViewDataSource {
    
    /// 表视图总行数
    ///
    /// - Parameters:
    ///   - memu: 菜单
    ///   - column: 菜单中第n个标题
    ///   - leftOrRight: 0为左表视图，1为右表视图
    ///   - leftRow: 左表视图选中的行数
    /// - Returns: 对应的列表总行数
    func  memu(_ memu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger,leftRow: NSInteger) -> NSInteger
    
    /// 标题
    ///
    /// - Parameters:
    ///   - memu: 菜单
    ///   - column: 菜单中第n个标题
    /// - Returns: 标题
    func  memu(_ memu: NMenuDropView, titleForColumn column: NSInteger) -> String
    
    /// 表视图列表内容
    ///
    /// - Parameters:
    ///   - memu: 菜单
    ///   - indexPath: 所在行列
    /// - Returns: 标题
    func  memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String
    
    /// 表视图，左边表视图显示比例
    ///
    /// - Parameter column: column
    /// - Returns: 比例
    func widthRatioOfLeftColumn(column: NSInteger) -> CGFloat
    
    /// 是否需要显示右表视图
    ///
    /// - Parameter column:
    /// - Returns: 是否显示
    func haveRightTableViewInColumn(column: NSInteger) -> Bool
    
    /// 选中左边表视图行
    ///
    /// - Parameter column: 第n个标题
    /// - Returns: 第n行
    func currentLeftSelectedRow(column: NSInteger) -> NSInteger
    
    /// 总共几个标题，默认1
    ///
    /// - Parameter memu: 菜单
    /// - Returns: 菜单数量
    @objc optional func numberOfColumn(_ memu: NMenuDropView) -> NSInteger
}

@objc protocol NMenuDropViewDelegate {
    
    /// 列表选中
    ///
    /// - Parameters:
    ///   - memu: 菜单
    ///   - indexPath: 所在行列
    @objc optional func memu(_ memu: NMenuDropView, didSelectRowAt indexPath: NIndexPath)
}

class NIndexPath: NSObject {
    var column: NSInteger = 0
    var leftOrRight: NSInteger = 0
    var leftRow: NSInteger = 0
    var row: NSInteger = 0
    
    init(column: NSInteger,leftOrRight: NSInteger,leftRow: NSInteger,row: NSInteger) {
        self.column = column
        self.leftOrRight = leftOrRight
        self.leftRow = leftRow
        self.row = row
    }
}

class NMenuDropView: UIView {
    //代理
    var delegate: NMenuDropViewDelegate?
    var dataSource: NMenuDropViewDataSource? {
        didSet {
            setupDataSource()
        }
    }
    //选中的菜单，默认选中第一个，起始值为0
    var currentMenuSelectedIndex: NSInteger = 0
    //未选中字体颜色
    var menuTitleNormalColor = UIColor.black
    //选中字体颜色
    var menuTitleSelectedColor = UIColor.red
    //每个菜单标题的竖直分割线
    var verticalLineColor = UIColor.lightGray
    //左表视图选中行数，默认选择第一行，起始值为0
    var leftSelectedRow: NSInteger = 0
    //弹窗高最大行数
    private var maxLineNum: Int = 8
    //菜单标题个数
    private var numOfMenu = 1
    //箭头
    private var indicators: [UIImageView] = []
    //标题
    private var titleLabels: [UILabel] = []
    //每个菜单标题按钮
    private var menuButtons: [UIButton] = []
    //弹窗是否显示
    private var isShow = false
    typealias Complete = () -> Void
    //左表视图
    private var leftTableView = UITableView()
    //右表视图
    private var rightTableView = UITableView()
    //表视图背景View
    private let backgroundView = UIView()
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NMenuDropView {
    func setupView() {
        backgroundView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        backgroundView.frame = CGRect.init(x: frame.origin.x, y: frame.origin.y + self.frame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didBackgroundViewTap))
        backgroundView.addGestureRecognizer(tapGesture)
        
        leftTableView = UITableView.init(frame: CGRect.init(x: 0, y: self.frame.origin.y, width: 0, height: 0), style: UITableViewStyle.plain)
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.rowHeight = 44
        leftTableView.tableHeaderView = UIView()
        leftTableView.tableFooterView = UIView()
        
        rightTableView = UITableView.init(frame: CGRect.init(x: self.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: 0, height: 0), style: UITableViewStyle.plain)
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.rowHeight = 44
        rightTableView.tableHeaderView = UIView()
        rightTableView.tableFooterView = UIView()
    }
    
    func setupDataSource() {
        if let num = self.dataSource?.numberOfColumn?(self) {
            numOfMenu = num
        }else {
            numOfMenu = 1
        }
        
        let buttonWidth: CGFloat = self.frame.size.width / CGFloat(numOfMenu)
        menuButtons = [UIButton]()
        indicators = [UIImageView]()
        titleLabels = [UILabel]()
        for i in 0..<numOfMenu {
            let button = UIButton(type: .custom)
            button.frame = CGRect.init(x: CGFloat(i) * buttonWidth, y: 0, width: buttonWidth - 1, height: self.frame.height)
            let titleString = dataSource?.memu(self, titleForColumn: i) ?? ""
            button.setTitle(titleString, for: .normal)
            button.setTitleColor(menuTitleNormalColor, for: .normal)
            button.tag = 100 + i
            self.addSubview(button)
            menuButtons.append(button)
            button.setImage(#imageLiteral(resourceName: "icon_arrow"), for: .normal)
            button.addTarget(self, action: #selector(didMenuViewTap), for: .touchUpInside)
            
            if i != 0 {
                let verticalLineView = UIView()
                verticalLineView.frame = CGRect(x: CGFloat(i) * buttonWidth - 1, y: 5, width: 1, height: self.frame.height - 10)
                verticalLineView.backgroundColor = verticalLineColor
                self.addSubview(verticalLineView)
            }
            indicators.append(button.imageView ?? UIImageView())
            titleLabels.append(button.titleLabel ?? UILabel())
        }
        
    }
}

extension NMenuDropView {
    
    @objc private func didMenuViewTap(button: UIButton) {
        currentMenuSelectedIndex = button.tag - 100
        let isHaveRight = dataSource?.haveRightTableViewInColumn(column: currentMenuSelectedIndex) ?? false
        let tempRightTableView = isHaveRight ? rightTableView : nil
        leftSelectedRow = dataSource?.currentLeftSelectedRow(column: currentMenuSelectedIndex) ?? 0
        
        if  isShow {
            animateIndicator(indicators[currentMenuSelectedIndex], titleLabels[currentMenuSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: false) {
                isShow = false
            }
        }else {
            //            leftSelectedRow = dataSource?.currentLeftSelectedRow(column: currentMenuSelectedIndex) ?? 0
            if isHaveRight {
                rightTableView.reloadData()
            }
            leftTableView.reloadData()
            let radio = self.dataSource?.widthRatioOfLeftColumn(column: currentMenuSelectedIndex) ?? 1
            leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
            if tempRightTableView != nil {
                rightTableView.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
            }
            animateIndicator(indicators[currentMenuSelectedIndex], titleLabels[currentMenuSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: true) {
                isShow = true
            }
        }
    }
    
    @objc private func didBackgroundViewTap(tap: UITapGestureRecognizer) {
        animateIndicator(indicators[currentMenuSelectedIndex], titleLabels[currentMenuSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: false) {
            isShow = false
        }
    }
}
extension NMenuDropView {
    fileprivate func animateIndicator(_ indicator: UIImageView,_ title: UILabel,_ backgroundView: UIView, _ leftTableView: UITableView,_ rightTableView: UITableView? = nil,andForward forward: Bool,complete: Complete) {
        animateIndicator(indicator, andForward: forward) {
            animateTitle(title, andIsShow: forward, complete: {
                animateBackgroundView(backgroundView, andIsShow: forward, complete: {
                    animateTableView(leftTableView, rightTableView, andIsShow: forward, complete: {})
                })
            })
        }
        complete()
    }
    
    fileprivate func animateTitle(_ title: UILabel, andIsShow isShow: Bool,complete: Complete) {
        let size = title.sizeThatFits(CGSize.init(width: self.frame.size.width / CGFloat(numOfMenu), height: self.frame.size.height))
        title.bounds = CGRect.init(x: 0, y: 0, width: size.width, height: self.frame.size.height)
        title.textColor = isShow == false ? menuTitleSelectedColor : menuTitleNormalColor
        title.text = "黑胡椒"
        title.isHidden = false
        complete()
    }
    fileprivate func animateIndicator(_ indicator: UIImageView, andForward forward: Bool,complete: Complete) {
        indicator.transform = forward ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform(rotationAngle: CGFloat(0))
        complete()
    }
    fileprivate func animateBackgroundView(_ view: UIView, andIsShow isShow: Bool,complete: Complete) {
        if isShow {//显示
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2) {
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.3)
            }
        }else {//隐藏
            UIView.animate(withDuration: 0.2, animations: {
                view.backgroundColor = UIColor.init(white: 0.0, alpha: 0)
            }) { (finished: Bool) in
                view.removeFromSuperview()
            }
        }
        complete()
    }
    fileprivate func animateTableView(_ leftTableView: UITableView,_ tempRightTableView: UITableView? = nil,andIsShow isShow: Bool, complete: Complete) {
        let radio = self.dataSource?.widthRatioOfLeftColumn(column: currentMenuSelectedIndex) ?? 1
        if isShow {//显示
            var leftTableViewHeight: CGFloat = 0
            var rightTableViewHeight: CGFloat = 0
            
            leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
            self.superview?.addSubview(leftTableView)
            leftTableViewHeight = leftTableView.numberOfRows(inSection: 0) > maxLineNum ? (CGFloat(maxLineNum) * leftTableView.rowHeight) : leftTableView.rowHeight * CGFloat(leftTableView.numberOfRows(inSection: 0))
            
            if  tempRightTableView != nil {
                tempRightTableView!.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
                self.superview?.addSubview(tempRightTableView!)
                rightTableViewHeight = tempRightTableView!.numberOfRows(inSection: 0) > maxLineNum ? (CGFloat(maxLineNum) * tempRightTableView!.rowHeight) : tempRightTableView!.rowHeight * CGFloat(tempRightTableView!.numberOfRows(inSection: 0))
            }
            
            let tableViewHeight: CGFloat = max(leftTableViewHeight, rightTableViewHeight)
            
            UIView.animate(withDuration: 0.2) {
                leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: tableViewHeight)
                
                if tempRightTableView != nil {
                    tempRightTableView!.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: tableViewHeight)
                }
            }
            
        }else {//隐藏
            UIView.animate(withDuration: 0.2, animations: {
                leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
                if tempRightTableView != nil {
                    tempRightTableView?.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
                }
            }) { (finished: Bool) in
                leftTableView.removeFromSuperview()
                if tempRightTableView != nil {
                    tempRightTableView?.removeFromSuperview()
                }
            }
        }
        complete()
    }
}
extension NMenuDropView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var leftOrRight: NSInteger = 0
        if tableView == rightTableView {
            leftOrRight = 1
        }
        return self.dataSource?.memu(self, numberOfRowsInColumn: currentMenuSelectedIndex, leftOrRight: leftOrRight, leftRow: leftSelectedRow) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        var leftOrRight: NSInteger = 0
        if tableView == rightTableView {
            leftOrRight = 1
        }
        cell.textLabel?.text = self.dataSource?.memu(self, titleForRowAt: NIndexPath.init(column: currentMenuSelectedIndex, leftOrRight: leftOrRight, leftRow:leftSelectedRow, row: indexPath.row))
        cell.textLabel?.textColor = menuTitleNormalColor
        
        let isHaveRight = self.dataSource?.haveRightTableViewInColumn(column: currentMenuSelectedIndex) ?? false
        leftTableView.backgroundColor = isHaveRight ? UIColor.groupTableViewBackground : UIColor.white
        cell.backgroundColor = UIColor.white
        if indexPath.row == leftSelectedRow && leftOrRight == 0 && isHaveRight == false{
            cell.textLabel?.textColor = menuTitleSelectedColor
        }else if tableView == leftTableView && leftOrRight == 0 && isHaveRight == true {
            cell.textLabel?.textColor =  indexPath.row == leftSelectedRow ? menuTitleNormalColor : menuTitleNormalColor.withAlphaComponent(0.5)
            cell.backgroundColor = indexPath.row == leftSelectedRow ? .white : .clear
        }else if tableView == rightTableView && leftOrRight == 1 {
            cell.textLabel?.textColor = cell.textLabel?.text == menuButtons[currentMenuSelectedIndex].currentTitle ? menuTitleSelectedColor : menuTitleNormalColor
        }else {
            cell.textLabel?.textColor = menuTitleNormalColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var leftOrRight: NSInteger = 0
        if tableView == rightTableView  {
            leftOrRight = 1
        }else {
            leftOrRight = 0
            leftSelectedRow = indexPath.row
        }
        guard let _ = self.delegate?.memu?(self, didSelectRowAt: NIndexPath.init(column: currentMenuSelectedIndex, leftOrRight: leftOrRight, leftRow: leftSelectedRow, row: indexPath.row)) else {
            return
        }
        let isHaveRight = self.dataSource?.haveRightTableViewInColumn(column: currentMenuSelectedIndex) ?? false
        if isHaveRight == true && leftOrRight == 0 {
        }else {
            confiMenuWithSelectRow(indexPath.row, leftOrRight)
        }
        
        if leftOrRight == 0 && isHaveRight {
            leftTableView.reloadData()
            rightTableView.reloadData()
        }
    }
    
    static func indexPath(_ col: NSInteger, _ leftOrRight: NSInteger,_ leftRow: NSInteger, _ row: NSInteger) -> NIndexPath {
        return NIndexPath.init(column: col, leftOrRight: leftOrRight, leftRow: leftRow, row: row)
    }
}

extension NMenuDropView {
    fileprivate func confiMenuWithSelectRow(_ row: NSInteger ,_ leftOrRight: NSInteger) {
        let menuButton = menuButtons[currentMenuSelectedIndex]
        let titleString = dataSource?.memu(self, titleForRowAt: NIndexPath.init(column: currentMenuSelectedIndex, leftOrRight: leftOrRight, leftRow: leftSelectedRow, row: row))
        menuButton.setTitle(titleString, for: .normal)
        animateIndicator(indicators[currentMenuSelectedIndex], titleLabels[currentMenuSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: false) {
            isShow = false
        }
    }
}
