//
//  DSSPettyCashCellViewModel.swift

//  Created by Oula Mardawi on 01/11/2022.


import Foundation

class DSSPettyCashCellViewModel {
    ///Check if sale is enable to edit
    var isEditEnable: Bool = false
    var viewArray: [AmountView] = []
    
    init(entity: DSSOperationDetailsEntity, isEditEnable: Bool ) {
        self.isEditEnable = isEditEnable
        let pattyCashTitleView = AmountView(title: String.Localizable.PettyCashViewTitle.string,
                                            titleColor: UIColor.Assets.BlackCellTextColor.color,
                                            leadingConstraint: 16,
                                            font: Font.robotoMedium(size: 16),
                                            viewType: .titleView)
        viewArray.append(pattyCashTitleView)
        
        if entity.isPettyCashEnabled ?? false {
            let cashInView = AmountView(title: String.Localizable.ItemTitleCashIn.string,
                                        amount: "\(entity.toPettyCashAmount ?? 0)",
                                        titleColor: UIColor.Assets.TabNormalTitleColor.color,
                                        leadingConstraint: 24,
                                        type: CellType.CachIn)
            
            let cashOutView = AmountView(title: String.Localizable.ItemTitleCashOut.string,
                                         amount: "\(entity.fromPettyCashAmount ?? 0)",
                                         titleColor: UIColor.Assets.TabNormalTitleColor.color,
                                         leadingConstraint: 24,
                                         type: CellType.CashOut)
            
            viewArray.append(cashInView)
            viewArray.append(cashOutView)
        }
        let unpaidCashView = AmountView(title: String.Localizable.ItemTitleUnpaidCashTips.string,
                                        amount: "\(entity.unpaidCashTipsAmount ?? 0)",
                                        titleColor: UIColor.Assets.BlackCellTextColor.color,
                                        leadingConstraint: 16,
                                        type: CellType.UnpaidTibs)
        viewArray.append(unpaidCashView)
    }
    
    func updatePettyCash(type: CellType, amount: Double) {
        for index in 0..<viewArray.count {
            if let viewType = viewArray[index].type, viewType == type {
                viewArray[index].amount = "\(amount)"
                break
            }
        }
    }
}
