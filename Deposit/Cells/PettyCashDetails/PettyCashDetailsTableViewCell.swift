//
//  PettyCashDetailsTableViewCell.swift
//
//  Created by Oula Mardawi on 03/10/2022.


import UIKit

protocol PettyCashDetailsTableViewCellDelegate: AnyObject {
    func pettyCashCellChanged(amount: String)
    func clickNext(tag: Int)
    func clickPrevious(tag: Int)
}

class PettyCashDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemsStackView: UIStackView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    var pettyCahViewModel: DSSPettyCashCellViewModel?
    weak var delegate: PettyCashDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureViewsUI()
    }
    
    private func configureViewsUI() {
        self.separatorHeightConstraint.constant = 1 / UIScreen.main.scale
    }
    
    /**
     configureCell
     - add petty cash amount
     */
    func configureCell(viewModel: DSSPettyCashCellViewModel) {
        self.pettyCahViewModel = viewModel
        var tag = 1
        for view in viewModel.viewArray {
            let amountView = DSSDepositeAmountView()
            amountView.delegate = self
            amountView.configureView(view: view, isEditEnable: viewModel.isEditEnable)
            if view.viewType == .inputView {
                amountView.tag =  tag
                tag += 1
            }
            self.itemsStackView.addArrangedSubview(amountView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeFromStack()
    }
    
    func removeFromStack() {
        self.itemsStackView.subviews.forEach({$0.removeFromSuperview()})
    }
}

extension PettyCashDetailsTableViewCell: DSSDepositeAmountViewDelegate {
    func clickNext(tag: Int) {
        self.delegate?.clickNext(tag: tag)
    }
    
    func clickPrevious(tag: Int) {
        self.delegate?.clickPrevious(tag: tag)
    }
    
    func didClickAtTextField(tag: Int) {}
    
    func amountTextFieldChanged(amountViewType: CellType, amount: String) {
        if let viewModel = self.pettyCahViewModel {
            viewModel.updatePettyCash(type: amountViewType, amount: Double(amount) ?? 0.00)
            self.delegate?.pettyCashCellChanged(amount: amount)
        }
    }
}
