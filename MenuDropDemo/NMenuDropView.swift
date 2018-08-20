//
//  NMenuDropView.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

@objc protocol NMenuDropViewDataSource {
    func  memu(_ memu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger,leftRow: NSInteger) -> NSInteger
//    func  memu(_ memu: NMenuDropView, titleForColumn column: NSInteger) -> Int
//    func  memu(_ memu: NMenuDropView, numberOfRowsInSection section: Int) -> Int
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
    func haveRightTableViewInColumn(column: NSInteger) -> Bool}

@objc protocol NMenuDropViewDelegate {
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
    var currentSelectedIndex: NSInteger = 0
    var menuTitleArr = ["菜式","地区"]
    var listArr: [[String: Any]] = []
    //是否有两列（右边那列是否存在）
    var isHasRight = false
    var delegate: NMenuDropViewDelegate? {
        didSet {
            //            setupTableView()
        }
    }
    var dataSource: NMenuDropViewDataSource? {
        didSet {
            setupTableView()
        }
    }
    var menuTitleNormalColor = UIColor.black
    var menuTitleSelectedColor = UIColor.red
    var verticalLineColor = UIColor.lightGray
    var leftSelectedRow: NSInteger = 0
    //是否显示
    private var indicators: [UIImageView] = []
    private var titleLabels: [UILabel] = []
    private var menuButtons: [UIButton] = []
    private var isShow = false
    typealias Complete = () -> Void
    private lazy var leftTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: self.frame.origin.y, width: 0, height: 0), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.isUserInteractionEnabled = true
        return tableView
    }()
    private lazy var rightTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: self.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: 0, height: 0), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        return tableView
    }()
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
        let titleView = UIView()
        titleView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        titleView.backgroundColor = UIColor.lightText
        self.addSubview(titleView)
        let buttonWidth: CGFloat = titleView.frame.size.width / CGFloat(menuTitleArr.count)
        menuButtons = [UIButton]()
        indicators = [UIImageView]()
        titleLabels = [UILabel]()
        for (i,item) in menuTitleArr.enumerated() {
            let button = UIButton(type: .custom)
            button.frame = CGRect.init(x: CGFloat(i) * buttonWidth, y: 0, width: buttonWidth - 1, height: titleView.frame.height)
            button.setTitle(item, for: .normal)
            button.setTitleColor(menuTitleNormalColor, for: .normal)
            button.tag = 100 + i
            titleView.addSubview(button)
            menuButtons.append(button)
            button.setImage(#imageLiteral(resourceName: "icon_arrow"), for: .normal)
            button.addTarget(self, action: #selector(didMenuViewTap), for: .touchUpInside)
            
            if i != 0 {
                let verticalLineView = UIView()
                verticalLineView.frame = CGRect(x: CGFloat(i) * buttonWidth - 1, y: 5, width: 1, height: titleView.frame.height - 10)
                verticalLineView.backgroundColor = verticalLineColor
                titleView.addSubview(verticalLineView)
            }
            indicators.append(button.imageView ?? UIImageView())
            titleLabels.append(button.titleLabel ?? UILabel())
        }
        
        backgroundView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        backgroundView.frame = CGRect.init(x: frame.origin.x, y: frame.origin.y + titleView.frame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didBackgroundViewTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }
  
    fileprivate func setupTableView() {
        self.superview?.addSubview(backgroundView)
        leftTableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: 0)
        leftTableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: 0)
        backgroundView.addSubview(leftTableView)
        backgroundView.addSubview(rightTableView)
    }
}

extension NMenuDropView {
    func reloadData() {
        leftTableView.reloadData()
        rightTableView.reloadData()
    }
}

extension NMenuDropView {
    
    @objc private func didMenuViewTap(button: UIButton) {
        currentSelectedIndex = button.tag - 100
        let isHaveRight = dataSource?.haveRightTableViewInColumn(column: currentSelectedIndex) ?? false
        let tempRightTableView = isHaveRight ? rightTableView : nil
        if  isShow {
            animateIndicator(indicators[currentSelectedIndex], titleLabels[currentSelectedIndex], backgroundView, leftTableView, tempRightTableView, andForward: false) {
                isShow = false
            }
        }else {
            leftTableView.reloadData()
            tempRightTableView?.reloadData()
            let radio = self.dataSource?.widthRatioOfLeftColumn(column: currentSelectedIndex) ?? 1
            leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
            if tempRightTableView != nil {
                tempRightTableView?.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
            }
            animateIndicator(indicators[currentSelectedIndex], titleLabels[currentSelectedIndex], backgroundView, leftTableView, tempRightTableView, andForward: true) {
                isShow = true
            }
        }
    }
    
    @objc private func didBackgroundViewTap(tap: UITapGestureRecognizer) {
        animateIndicator(indicators[currentSelectedIndex], titleLabels[currentSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: false) {
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
        let size = title.sizeThatFits(CGSize.init(width: self.frame.size.width / CGFloat(menuTitleArr.count), height: self.frame.size.height))
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
    fileprivate func animateTableView(_ leftTableView: UITableView,_ rightTableView: UITableView? = nil,andIsShow isShow: Bool, complete: Complete) {
        let radio = self.dataSource?.widthRatioOfLeftColumn(column: currentSelectedIndex) ?? 1
        if isShow {//显示
            var leftTableViewHeight: CGFloat = 0
            var rightTableViewHeight: CGFloat = 0
            
            leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
            self.superview?.addSubview(leftTableView)
            leftTableViewHeight = leftTableView.numberOfRows(inSection: 0) > 5 ? (5 * leftTableView.rowHeight) : leftTableView.rowHeight * CGFloat(leftTableView.numberOfRows(inSection: 0))
            
            if let tempRightTableView = rightTableView {
                tempRightTableView.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
                self.superview?.addSubview(tempRightTableView)
                rightTableViewHeight = tempRightTableView.numberOfRows(inSection: 0) > 5 ? (5 * tempRightTableView.rowHeight) : tempRightTableView.rowHeight * CGFloat(tempRightTableView.numberOfRows(inSection: 0))
            }
            
            let tableViewHeight: CGFloat = max(leftTableViewHeight, rightTableViewHeight)
            
            UIView.animate(withDuration: 0.2) {
                leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: tableViewHeight)
                
                if rightTableView != nil {
                    rightTableView?.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: tableViewHeight)
                }
            }
            
        }else {//隐藏
            UIView.animate(withDuration: 0.2, animations: {
                leftTableView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * radio, height: 0)
                if rightTableView != nil {
                    rightTableView?.frame = CGRect.init(x: self.frame.origin.x + leftTableView.frame.size.width, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width * (1 - radio), height: 0)
                }
            }) { (finished: Bool) in
                leftTableView.removeFromSuperview()
                if rightTableView != nil {
                    rightTableView?.removeFromSuperview()
                }
            }
        }
        complete()
    }
}
extension NMenuDropView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var leftOrRight: NSInteger = 0
//        if rightTableView == tableView {
//            leftOrRight = 1
//        }
        return self.dataSource?.memu(self, numberOfRowsInColumn: currentSelectedIndex, leftOrRight: leftOrRight, leftRow: leftSelectedRow) ?? 0
//        return self.dataSource?.memu(self, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        var leftOrRight: NSInteger = 0
        if rightTableView == tableView {
            leftOrRight = 1
        }
        cell.textLabel?.text = self.dataSource?.memu(self, titleForRowAt: NIndexPath.init(column: currentSelectedIndex, leftOrRight: leftOrRight, leftRow:leftSelectedRow, row: indexPath.row))
        cell.textLabel?.textColor = menuTitleNormalColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let _ = self.delegate?.memu?(self, didSelectRowAt: NIndexPath.init(column: currentSelectedIndex, leftOrRight: -1, leftRow: -1, row: indexPath.row))else {
            return
        }
        var leftOrRight: NSInteger = 0
        if rightTableView == tableView {
            leftOrRight = 1
        }else {
            leftOrRight = 0
            leftSelectedRow = indexPath.row
        }
        confiMenuWithSelectRow(indexPath.row, leftOrRight)
    }
    
    static func indexPath(_ col: NSInteger, _ leftOrRight: NSInteger,_ leftRow: NSInteger, _ row: NSInteger) -> NIndexPath {
        return NIndexPath.init(column: col, leftOrRight: leftOrRight, leftRow: leftRow, row: row)
    }
}

extension NMenuDropView {
   fileprivate func confiMenuWithSelectRow(_ row: NSInteger ,_ leftOrRight: NSInteger) {
        let menuButton = menuButtons[currentSelectedIndex]
        let titleString = dataSource?.memu(self, titleForRowAt: NIndexPath.init(column: currentSelectedIndex, leftOrRight: leftOrRight, leftRow: leftSelectedRow, row: row))
        menuButton.setTitle(titleString, for: .normal)
        animateIndicator(indicators[currentSelectedIndex], titleLabels[currentSelectedIndex], backgroundView, leftTableView, rightTableView, andForward: false) {
            isShow = false
        }
    }
}
