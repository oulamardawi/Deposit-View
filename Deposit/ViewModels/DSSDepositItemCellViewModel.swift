//
//  DSSDepositItemCellViewModel.swift

//  Created by Oula Mardawi on 30/10/2022.


import Foundation

class DSSDepositItemCellViewModel {
    
    /// deposit Cell Details
    private (set) var salesDeposit: SalesDeposit
    /// array of amount view in one deposit
    var viewArray: [AmountView] = []
    /// bool to indicate if the cell details is shown
    var isDetailsShown: Bool = false
    /// index of current cell
    var cellIndex: Int
    ///Check if sale is enable to edit
    var isEditEnable: Bool = false
    
    let tagBase: Int
    let numberOfCells: Int
    
    var title: String {
        return "\(String.Localizable.DepositsViewTitle.string) #\(Int(self.salesDeposit.number ?? 1))"
    }
    
    init(salesDeposit: SalesDeposit, isDetailsShown: Bool, isEditEnable: Bool, cellIndex: Int, tagBase: Int, numberOfCells: Int) {
        self.salesDeposit = salesDeposit
        let currencyFormatter = USCurrencyFormatter(minimumFractionDigits: 0)
        self.isDetailsShown = isDetailsShown
        self.isEditEnable = isEditEnable
        self.cellIndex = cellIndex
        self.tagBase = tagBase
        self.numberOfCells = numberOfCells
        
        ///store totalDeposit to view array
        
        let totalDeposit = AmountView(title: String.Localizable.ItemTotalDeposit.string,
                                      amount: self.getAmount(doubleAmount: salesDeposit.amount),
                                      titleColor: UIColor.Assets.BlueCellTextColor.color,
                                      leadingConstraint: 16,
                                      type: CellType.TotalDeposit)
        viewArray.append(totalDeposit)
        
        ///store billCounterTitle to view array
        let billCounterTitle = AmountView(title: String.Localizable.ItemBillCounter.string,
                                          titleColor: UIColor.Assets.Black.color,
                                          leadingConstraint: 16,
                                          viewType: .titleView)
        viewArray.append(billCounterTitle)
        
        ///store oneDollarBill to view array
        let oneDollarBill = AmountView(title: ("\(currencyFormatter.string(from: 1) ?? "") \(String.Localizable.ItemBills.string)"),
                                       amount: self.getAmount(intAmount: salesDeposit.bill1),
                                       type: CellType.OneDollarBill)
        viewArray.append(oneDollarBill)
        
        ///store twoDollarsBill to view array
        let twoDollarsBill = AmountView(title: ("\(currencyFormatter.string(from: 2) ?? "") \(String.Localizable.ItemBills.string)"),
                                        amount: self.getAmount(intAmount: salesDeposit.bill2),
                                        type: CellType.TwoDollarsBill)
        viewArray.append(twoDollarsBill)
        
        ///store fiveDollarsBill to view array
        let fiveDollarsBill = AmountView(title: ("\(currencyFormatter.string(from: 5) ?? "") \(String.Localizable.ItemBills.string)"),
                                         amount: self.getAmount(intAmount: salesDeposit.bill5),
                                         type: CellType.FiveDollarsBill)
        viewArray.append(fiveDollarsBill)
        
        ///store tenDollarsBill to view array
        let tenDollarsBill = AmountView(title: ("\(currencyFormatter.string(from: 10) ?? "") \(String.Localizable.ItemBills.string)"),
                                        amount: self.getAmount(intAmount: salesDeposit.bill10),
                                        type: CellType.TenDollarsBill)
        viewArray.append(tenDollarsBill)
        
        ///store twentyDollarsBill to view array
        let twentyDollarsBill = AmountView(title: ("\(currencyFormatter.string(from: 20) ?? "") \(String.Localizable.ItemBills.string)"),
                                           amount: self.getAmount(intAmount: salesDeposit.bill20),
                                           type: CellType.TwentyDollarsBill)
        viewArray.append(twentyDollarsBill)
        
        ///store fiftyDollarsBill to view array
        let fiftyDollarsBill = AmountView(title:("\(currencyFormatter.string(from: 50) ?? "") \(String.Localizable.ItemBills.string)"),
                                          amount: self.getAmount(intAmount: salesDeposit.bill50),
                                          type: CellType.FiftyDollarsBill)
        viewArray.append(fiftyDollarsBill)
        
        ///store oneHundredDollarsBill to view array
        let oneHundredDollarsBill = AmountView(title:("\(currencyFormatter.string(from: 100) ?? "") \(String.Localizable.ItemBills.string)"),
                                               amount: self.getAmount(intAmount: salesDeposit.bill100),
                                               type: CellType.OneHundredDollarsBill)
        viewArray.append(oneHundredDollarsBill)
        
        ///store totalCash to view array
        let totalCash = AmountView(title: String.Localizable.ItemTotalCash.string,
                                   amount: self.getAmount(intAmount: salesDeposit.totalCashAmount),
                                   leadingConstraint: 24,
                                   viewType: .labelView,
                                   type: CellType.TotalCash)
        viewArray.append(totalCash)
        
        ///store totalCoin to view array
        let totalCoin = AmountView(title: String.Localizable.ItemTotalCoin.string,
                                   amount: self.getAmount(doubleAmount: salesDeposit.totalCoinAmount),
                                   leadingConstraint: 24,
                                   type: CellType.TotalCoin)
        viewArray.append(totalCoin)
        
        ///store totalCheck to view array
        let totalCheck = AmountView(title: String.Localizable.ItemTotalCheck.string,
                                    amount: self.getAmount(doubleAmount: salesDeposit.totalCheckAmount),
                                    leadingConstraint: 24,
                                    type: CellType.TotalCheck)
        viewArray.append(totalCheck)
        
    }
    
    /**
     Get amount as string based on amount data type either double or integer
     */
    func getAmount(doubleAmount: Double? = nil, intAmount: Int? = nil) -> String {
        var newAmount = ""
        if let amount = doubleAmount {
            newAmount = "\(amount)"
        }
        if let amount = intAmount {
            newAmount = "\(amount)"
        }
        return "\(newAmount)"
    }
    
    /**
     Prepare new entity based on sales deposit changes
     - parameter textFieldType: represents the type of changed textFilednumber
     - parameter amount: represents the new amount
     */
    func updateAmountView(cellType: CellType, amount: String) {
        switch cellType {
        case .TotalDeposit:
            self.setValueOfView(type: .TotalCoin, amount: "\(amount)")
            self.setValueOfView(type: cellType, amount: "\(amount)")
            
        case .OneDollarBill, .TwoDollarsBill, .FiveDollarsBill, .TenDollarsBill, .TwentyDollarsBill, .FiftyDollarsBill, .OneHundredDollarsBill:
            if amount.last == "." { break }
            self.setValueOfView(type: cellType, amount: amount)
            
        case .TotalCoin, .TotalCheck:
            self.setValueOfView(type: cellType, amount: amount)
            if amount.last == "." { return }
            
        default:
            break
        }
        
        if cellType != .TotalDeposit {
            self.calculateTotalCash()
            self.calculateTotalDeposit()
        }
        self.updateEntityData(views: self.viewArray)
    }
    
    func calculateTotalCash() {
        var totalCash = self.getDoubleValueOfView(type: .OneDollarBill) * 1 + self.getDoubleValueOfView(type: .TwoDollarsBill) * 2 + self.getDoubleValueOfView(type: .FiveDollarsBill) * 5
        totalCash += self.getDoubleValueOfView(type: .TenDollarsBill) * 10
        totalCash += self.getDoubleValueOfView(type: .TwentyDollarsBill) * 20
        totalCash += self.getDoubleValueOfView(type: .FiftyDollarsBill) * 50
        totalCash += self.getDoubleValueOfView(type: .OneHundredDollarsBill) * 100
        self.setValueOfView(type: .TotalCash, amount: "\(Int(totalCash))")
    }
    
    func calculateTotalDeposit() {
        var totalDeposit: Double
        totalDeposit = self.getDoubleValueOfView(type: .TotalCash) + self.getDoubleValueOfView(type: .TotalCoin) + self.getDoubleValueOfView(type: .TotalCheck)
        self.setValueOfView(type: .TotalDeposit, amount: "\(totalDeposit)")
    }
    
    /** Getter
     - get amount from view with specific type
     */
    func getValueOfView(type: CellType) -> String {
        var value: String = "0"
        if (type.rawValue < self.viewArray.count) {
            value = self.viewArray[type.rawValue].amount ?? "0"
        }
        return value
    }
    
    /** Getter
     - get double amount from view with specific type
     */
    func getDoubleValueOfView(type: CellType) -> Double {
        var value: Double = 0
        if (type.rawValue < self.viewArray.count) {
            value = Double(self.viewArray[type.rawValue].amount ?? "0") ?? 0.0
        }
        return value
    }
    
    /** Setter
     - set amount in view with specific type
     */
    func setValueOfView(type: CellType, amount: String) {
        var roundedAmount = amount
        if roundedAmount.contains(".") && roundedAmount.last != "." && roundedAmount.count > 4 {
            let doubleAmount = Double(amount) ?? 0.0
            roundedAmount = doubleAmount.roundedString(decimalPlaces: 2, isDecimalForced: true)
        }
        if (type.rawValue < self.viewArray.count) {
            self.viewArray[type.rawValue].amount = roundedAmount
        }
    }
    
    /**
     Update sales deposit then return new sales deposit
     - parameter views: represents the view with new data to store in new sales deposit
     */
    func updateEntityData(views: [AmountView]) {
        for type in CellType.allCases {
            if (type.rawValue < views.count) {
                let amount = Double(views[type.rawValue].amount ?? "") ?? 0.0
                switch type {
                case .TotalDeposit:
                    self.salesDeposit.amount = amount
                case .BillCounter:
                    break
                case .OneDollarBill:
                    self.salesDeposit.bill1 = Int(amount)
                case .TwoDollarsBill:
                    self.salesDeposit.bill2 = Int(amount)
                case .FiveDollarsBill:
                    self.salesDeposit.bill5 = Int(amount)
                case .TenDollarsBill:
                    self.salesDeposit.bill10 = Int(amount)
                case .TwentyDollarsBill:
                    self.salesDeposit.bill20 = Int(amount)
                case .FiftyDollarsBill:
                    self.salesDeposit.bill50 = Int(amount)
                case .OneHundredDollarsBill:
                    self.salesDeposit.bill100 = Int(amount)
                case .TotalCoin:
                    self.salesDeposit.totalCoinAmount = amount
                case .TotalCash:
                    self.salesDeposit.totalCashAmount = Int(amount)
                case .TotalCheck:
                    self.salesDeposit.totalCheckAmount = amount
                default:
                    break
                }
            }
        }
    }
}
