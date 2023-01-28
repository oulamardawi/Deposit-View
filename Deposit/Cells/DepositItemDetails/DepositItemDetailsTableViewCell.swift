//
//  DepositItemDetailsTableViewCell.swift
//
//  Created by Oula Mardawi on 02/10/2022.

import UIKit

protocol DepositItemDetailsTableViewCellDelegate: AnyObject {
    func toggleCellDetailsShown(index: Int)
    func depositItemCellChanged(saleDeposits: SalesDeposit, index: Int)
    func clickNext(tag: Int)
    func clickPrevious(tag: Int)
    func didClickAtTextField(tag: Int)
}

class DepositItemDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var mainCellTitleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var depositsStackView: UIStackView!
    @IBOutlet weak var stackSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackSeparator: UIView!
    @IBOutlet weak var detailsContainerView: UIView!
    
    var cellViewModel: DSSDepositItemCellViewModel?
    weak var delegate: DepositItemDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureViewsUI()
    }
    
    /**
     configureViewsUI
     - set the seperator height depending to the screen scale
     */
    private func configureViewsUI() {
        self.stackSeparatorHeightConstraint.constant = 1 / UIScreen.main.scale
    }
    
    /**
     configureCell
     - clear deposits stack view contents
     - set the sale deposit
     */
    func configureCell(viewModel: DSSDepositItemCellViewModel) {
        self.cellViewModel = viewModel
        self.configureStackView()
        self.mainCellTitleLabel.text = viewModel.title
        
        var tag = (viewModel.cellIndex * 10) + viewModel.tagBase + 1
        for view in viewModel.viewArray {
            let amountView = DSSDepositeAmountView()
            amountView.delegate = self
            amountView.configureView(view: view, isEditEnable: viewModel.isEditEnable)
            
            if view.viewType == .inputView {
                amountView.tag = tag
                tag += 1
            }
            
            self.depositsStackView.addArrangedSubview(amountView)
        }
        self.configureDetailsView()
    }
    
    
    func configureStackView() {
        self.depositsStackView.subviews.forEach({$0.removeFromSuperview()})
        self.stackSeparator.isHidden = (cellViewModel?.cellIndex ?? 0) + 1 == cellViewModel?.numberOfCells
    }
    
    func showDetailsView() {
        self.showDetailView()
        self.cellViewModel?.isDetailsShown = true
        self.delegate?.toggleCellDetailsShown(index: self.cellViewModel?.cellIndex ?? 0)
    }
    
    /**
     Configure Details View
     - trasnform arraow image view based on isDetailsShown value
     */
    private func configureDetailsView() {
        self.detailsContainerView.isHidden = !(self.cellViewModel?.isDetailsShown ?? false)
        self.arrowImageView.transform = self.cellViewModel?.isDetailsShown ?? false ? CGAffineTransform(rotationAngle: .pi * -0.999) : CGAffineTransform.identity
    }
    
    /**
     show detail view
     - show the details with anmitaion when needed
     */
    private func showDetailView() {
        guard self.cellViewModel?.isDetailsShown == false else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi * -0.999)
            self.detailsContainerView.isHidden = false
            self.layoutIfNeeded()
        }
    }
    
    /**
     hide detail view
     - Hide the datail view with animation when needed
     */
    private func hideDetailView() {
        guard self.cellViewModel?.isDetailsShown == true else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = CGAffineTransform.identity
            self.detailsContainerView.isHidden = true
            self.layoutIfNeeded()
        }
        
        for view in self.depositsStackView.subviews {
            let depositAmountView = view as? DSSDepositeAmountView
            depositAmountView?.amountTextField.endEditing(true)
        }
    }
    
    /**
     update sub views in stack view
     - update the amounts in changed views
     */
    func updateSubViewsInStackView() {
        for index in 0..<self.depositsStackView.subviews.count {
            if let customView = self.depositsStackView.subviews[index] as? DSSDepositeAmountView, let type = customView.type {
                let amount = self.cellViewModel?.getValueOfView(type: type) ?? "0"
                customView.setValue(amount: amount)
            }
        }
    }
    
    /**
     main Button Clicked
     - Handle when the main button (Cell) is clicked to either show or hide its details
     */
    @IBAction func mainButtonClicked(_ sender: Any) {
        if self.cellViewModel?.isDetailsShown == true {
            self.hideDetailView()
        } else {
            self.showDetailView()
        }
        self.cellViewModel?.isDetailsShown.toggle()
        self.delegate?.toggleCellDetailsShown(index: self.cellViewModel?.cellIndex ?? 0)
    }
}

extension DepositItemDetailsTableViewCell: DSSDepositeAmountViewDelegate {
    func didClickAtTextField(tag: Int) {
        self.delegate?.didClickAtTextField(tag: tag)
    }
    
    func clickNext(tag: Int) {
        self.delegate?.clickNext(tag: tag)
    }
    
    func clickPrevious(tag: Int) {
        self.delegate?.clickPrevious(tag: tag)
    }
    
    func amountTextFieldChanged(amountViewType: CellType, amount: String) {
        self.cellViewModel?.updateAmountView(cellType: amountViewType, amount: amount)

        guard let deposit = self.cellViewModel?.salesDeposit,
              let cellIndex = self.cellViewModel?.cellIndex
        else { return }
                
        self.updateSubViewsInStackView()
        self.delegate?.depositItemCellChanged(saleDeposits: deposit, index: cellIndex)
    }
}
