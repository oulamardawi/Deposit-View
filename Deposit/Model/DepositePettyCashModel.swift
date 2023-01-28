//
//  DepositePettyCashModel.swift
//
//  Created by Oula Mardawi on 05/10/2022.


import Foundation

struct AmountView {
    var title: String?
    var amount: String?
    var titleColor: UIColor = UIColor.Assets.TabNormalTitleColor.color
    var leadingConstraint: CGFloat = 32
    var font: UIFont = Font.robotoMedium(size: 14)
    var viewType: DSSDepositeAmountViewType = .inputView
    var type: CellType?
}

class Deposit: NSObject {
    var sectionType: DSSDepositSectionType?
    var sectionTitle: String?
    var cells: [Cell] = []
}

enum DSSDepositSectionType: Int {
    case totalDeposit = 0
    case pettyCash
    case deposits
}

class Cell: NSObject {
    var titleAmountView: [DSSDepositeAmountView]?
}

class PettyCashCell: Cell {}

class DepositDetailsCell: Cell {
    var title: String?
}

enum CellType: Int, CaseIterable {
    case TotalDeposit = 0
    case BillCounter
    case OneDollarBill
    case TwoDollarsBill
    case FiveDollarsBill
    case TenDollarsBill
    case TwentyDollarsBill
    case FiftyDollarsBill
    case OneHundredDollarsBill
    case TotalCash
    case TotalCoin
    case TotalCheck
    case CachIn
    case CashOut
    case UnpaidTibs
}
