//
//  NMenuDropView.swift
//  MenuDropDemo
//
//  Created by ning on 2018/8/10.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

@objc protocol NMenuDropViewDataSource {
    
    //func menu(menu: NMenuDropView, numberOfRowsInColumn column: NSInteger, leftOrRight: NSInteger, leftRow: NSInteger)
}

@objc protocol NMenuDropViewDelegate {
    func  memu(_ memu: NMenuDropView, numberOfRowsInSection section: Int) -> Int
    func  memu(_ memu: NMenuDropView, titleForRowAt indexPath: NIndexPath) -> String
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
    var listArr: [String] = []
    var isHasRight = false
    var delegate: NMenuDropViewDelegate? {
        didSet {
            setupTableView()
        }
    }
    var menuTitleNormalColor = UIColor.black
    var menuTitleSelectedColor = UIColor.red
    var verticalLineColor = UIColor.lightGray
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
        for (i,item) in menuTitleArr.enumerated() {
            let button = UIButton(type: .custom)
            button.frame = CGRect.init(x: CGFloat(i) * buttonWidth, y: 0, width: buttonWidth - 1, height: titleView.frame.height)
            button.setTitle(item, for: .normal)
            button.setTitleColor(menuTitleNormalColor, for: .normal)
            button.setTitleColor(menuTitleSelectedColor, for: .selected)
            titleView.addSubview(button)
            if i != 0 {
                let verticalLineView = UIView()
                verticalLineView.frame = CGRect(x: CGFloat(i) * buttonWidth - 1, y: 5, width: 1, height: titleView.frame.height - 10)
                verticalLineView.backgroundColor = verticalLineColor
                titleView.addSubview(verticalLineView)
            }
        }
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        backgroundView.frame = CGRect.init(x: frame.origin.x, y: frame.origin.y + titleView.frame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
    }
    
   private func setupTableView() {
        self.superview?.addSubview(backgroundView)
        leftTableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: leftTableView.rowHeight * CGFloat(listArr.count))
        leftTableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: listArr.count > 5 ? leftTableView.rowHeight * 5 : leftTableView.rowHeight * CGFloat(listArr.count))
        backgroundView.addSubview(leftTableView)
    }
}

extension NMenuDropView {
    func reloadData() {
         leftTableView.reloadData()
         rightTableView.reloadData()
    }
}
extension NMenuDropView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.delegate?.memu(self, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.delegate?.memu(self, titleForRowAt: NIndexPath.init(column: currentSelectedIndex, leftOrRight: -1, leftRow: -1, row: indexPath.row))
        cell.textLabel?.textColor = menuTitleNormalColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let _ = self.delegate?.memu?(self, didSelectRowAt: NIndexPath.init(column: currentSelectedIndex, leftOrRight: -1, leftRow: -1, row: indexPath.row))else {
            return
        }
    }
    
    static func indexPath(_ col: NSInteger, _ leftOrRight: NSInteger,_ leftRow: NSInteger, _ row: NSInteger) -> NIndexPath {
        return NIndexPath.init(column: col, leftOrRight: leftOrRight, leftRow: leftRow, row: row)
    }
}
