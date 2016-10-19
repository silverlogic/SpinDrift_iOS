//
//  ReceiptViewController.swift
//  VendingDemo
//
//  Created by Muhammad Azeem on 9/27/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit

class ReceiptViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var machineName: String = "" {
        didSet {
            configureView()
        }
    }
    
    var quantity: Int = 0 {
        didSet {
            configureView()
        }
    }
    
    var amount: String = "SGD XX.XX" {
        didSet {
            configureView()
        }
    }
    
    var cardMaskedPan: String = "****" {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)]
        self.view.backgroundColor = UIColor.squash
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    override func viewDidLayoutSubviews() {
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    // MARK: - Private methods
    func configureView() {
        self.navigationItem.title = NSLocalizedString("Receipt", comment: "")
        self.tableView?.reloadData()
    }
    
    // MARK: - Private methods
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view
extension ReceiptViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 92
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")!
        
        let contentView = header.contentView
        let topBorder = UIView()
        let titleLabel = UILabel()
        let detailLabel = UILabel()
        
        header.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        
        header.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup top border
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.backgroundColor = UIColor.white
        
        let border = CAShapeLayer();
        border.strokeColor = UIColor.textGray.cgColor
        border.fillColor = nil;
        border.lineDashPattern = [5, 5];
        topBorder.layer.addSublayer(border)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: topBorder.bounds.midY))
        path.addLine(to: CGPoint(x: contentView.bounds.width, y: topBorder.bounds.midY))
        border.path = path.cgPath
        border.frame = topBorder.bounds
        
        contentView.addSubview(topBorder)
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.textGray
        contentView.addSubview(titleLabel)
        
        // Setup detail label
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textAlignment = .right
        contentView.addSubview(detailLabel)
        
        var viewBindingsDict = [String: UIView]()
        viewBindingsDict["topBorder"] = topBorder
        viewBindingsDict["titleLabel"] = titleLabel
        viewBindingsDict["detailLabel"] = detailLabel
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[topBorder]-|", options: [], metrics: nil, views: viewBindingsDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topBorder(4)][titleLabel]|", options: [], metrics: nil, views: viewBindingsDict))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel][detailLabel]-16-|", options: [.alignAllCenterY, .alignAllTop, .alignAllBottom], metrics: nil, views: viewBindingsDict))
        
        contentView.setNeedsLayout()
        
        switch section {
        case 1:
            titleLabel.text = "Order Summary".uppercased()
        case 2:
            titleLabel.text = "Tax".uppercased()
        case 3:
            titleLabel.text = "Total".uppercased()
            detailLabel.text = amount
        default:
            break
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, indexPath.row == 0 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            titleCell.machineNameLabel.text = machineName
            titleCell.amountLabel.text = amount
            titleCell.dateLabel.text = dateFormatter.string(from: Date())
            return titleCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
        
        switch indexPath.section {
        case 1:
            cell.textLabel?.text = "Product Name"
            
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "x\(quantity)", attributes: [NSForegroundColorAttributeName: UIColor.textGray]))
            text.append(NSAttributedString(string: "  \(amount)"))
            
            cell.detailTextLabel?.attributedText = text
        case 2:
            cell.textLabel?.text = "0% Sale Tax"
            cell.detailTextLabel?.text = "USD 0.00"
        case 3:
            cell.textLabel?.text = "Payment card used"
            cell.detailTextLabel?.text = cardMaskedPan
        default:
            break
        }
        
        return cell
    }
}

// MARK: - Cells
class TitleCell : UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var machineNameLabel: UILabel!
}

private class HeaderView : UITableViewHeaderFooterView {
    var topBorder = UIView()
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    
    var alreadyAdded: Bool = false
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.white
        
        // Setup top border
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.backgroundColor = UIColor.white
        
        let border = CAShapeLayer();
        border.strokeColor = UIColor.textGray.cgColor
        border.fillColor = nil;
        border.lineDashPattern = [5, 5];
        topBorder.layer.addSublayer(border)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: topBorder.bounds.midY))
        path.addLine(to: CGPoint(x: topBorder.bounds.width, y: topBorder.bounds.midY))
        border.path = path.cgPath
        border.frame = topBorder.bounds
        
        self.contentView.addSubview(topBorder)
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.textGray
        self.contentView.addSubview(titleLabel)
        
        // Setup detail label
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textAlignment = .right
        self.contentView.addSubview(detailLabel)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if alreadyAdded {
            return
        }
        
        var viewBindingsDict = [String: UIView]()
        viewBindingsDict["topBorder"] = topBorder
        viewBindingsDict["titleLabel"] = titleLabel
        viewBindingsDict["detailLabel"] = detailLabel
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[topBorder]", options: [], metrics: nil, views: viewBindingsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topBorder(4)]-[titleLabel]|", options: [], metrics: nil, views: viewBindingsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel][detailLabel]-|", options: [.alignAllCenterY, .alignAllTop, .alignAllBottom], metrics: nil, views: viewBindingsDict))
        
        alreadyAdded = true
    }
}
