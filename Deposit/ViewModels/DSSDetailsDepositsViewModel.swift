//
//  DSSDetailsDepositsViewModel.swift
//
//  Created by Oula Mardawi on 02/10/2022.

import Foundation

class DSSDetailsDepositsViewModel {
    let sections: [DSSDepositSectionType] = [.totalDeposit, .pettyCash, .deposits]
    
    /// Display Error msg
    var onShowError: ((_ msg: String) -> Void)?
    
    /// Call when data is set
    var onDataFetched: (() -> Void)?
    
    private var depositsCellDetailsDisplay: [Int: Bool] = [:]
    
    private (set) var dssOperationDetailsModel: DSSOperationDetailsModel
    private (set) var isAPIFailed: Bool = false
    private (set) var isUpdated: Bool = false
    private let maxDepositsNumber = 5
    
    /// Date of deposit
    private var date: String {
        return dssOperationDetailsModel.entity?.date ?? ""
    }
    
    /// Check if sale is enable to edit
    var isEditEnable: Bool {
        return !(self.dssOperationDetailsModel.entity?.isStepsComplete ?? false || self.dssOperationDetailsModel.entity?.isApproved ?? false)
    }

    var isPettyCashEnabled: Bool {
        return self.dssOperationDetailsModel.entity?.isPettyCashEnabled ?? false
    }
    
    private var dailySalesSummaryId: String {
        return self.dssOperationDetailsModel.entity?.id ?? ""
    }
    
    private var locationId: String {
        return self.dssOperationDetailsModel.entity?.location?.id ?? ""
    }

    var entity: DSSOperationDetailsEntity? {
        return self.dssOperationDetailsModel.entity
    }
    
    /// return number of deposit includes empty ones
    var depositCount: Int {
        var lastDepositCount = 1
        if self.getDSSDetailsDepositsSalesCount() > 1 {
            lastDepositCount = self.dssOperationDetailsModel.entity?.salesDeposits?[self.getDSSDetailsDepositsSalesCount() - 1].number ?? 0
        }
        return lastDepositCount
    }
    
    var isFooterButtonEnable: Bool {
        return self.depositCount != self.maxDepositsNumber && self.isEditEnable
    }

    init(dssOperationDetailsModel: DSSOperationDetailsModel) {
        self.dssOperationDetailsModel = dssOperationDetailsModel
    }
    
    func getData() {
        self.isAPIFailed = false
        self.putDSSOperationDetails()
    }
    
    func getPettyCashTextFieldCount() -> Int {
        return self.entity?.isPettyCashEnabled ?? false ? 3 : 1
    }
    
    func isLastTextField(tag: Int) -> Bool {
        let pettyCashTextFieldCount = self.getPettyCashTextFieldCount()
        let depositsCount = self.getDSSDetailsDepositsSalesCount()
        
        let textFieldCount = pettyCashTextFieldCount + (depositsCount * 10)
        return tag == textFieldCount
    }
    
    func isFirstTextField(tag: Int) -> Bool {
        return tag == 1
    }

    func isTextFieldAtDeposit(tag: Int) -> Bool {
        return tag > self.getPettyCashTextFieldCount()
    }
    
    func showDepositDetails(forTextFieldWithTag tag: Int, completion: @escaping (_ showDetails: Bool, _ depositIndex: Int) -> ()) {
        guard isTextFieldAtDeposit(tag: tag) else { return }
        
        let pettyCashTextFieldCount = self.getPettyCashTextFieldCount()
        
        let textFieldAtDepsitIndex = (tag - pettyCashTextFieldCount) - 1
        let depositIndex: Int = textFieldAtDepsitIndex / 10
        
        if self.depositsCellDetailsDisplay[depositIndex] != true {
            completion(true, depositIndex)
        } else {
            completion(false, depositIndex)
        }
    }
}

extension DSSDetailsDepositsViewModel {
    func getViewControllerNavigationTitle() -> String {
        return "\(String.Localizable.DepositViewTitle.string) - \(self.getDepositFormattedDate())"
    }
    
    func getDSSDetailsDepositsSalesModel() -> [SalesDeposit] {
        return self.dssOperationDetailsModel.entity?.salesDeposits ?? []
    }
    
    func getDSSDetailsDepositsSalesCount() -> Int {
        let sales = self.dssOperationDetailsModel.entity?.salesDeposits ?? []
        return (sales.count != 0) ? sales.count : 1
    }
    
    func getMetricsViews() -> [DSSMetricView] {
        let depositViewModel = DSSDepositCellViewModel(totalDepositAmount: self.entity?.totalDepositAmount, toPettyCashAmount: self.entity?.toPettyCashAmount, cashPaymentAmount: self.entity?.cashPaymentAmount, paidOutTotal: self.entity?.paidOutTotal, paidInTotal: self.entity?.paidInTotal, unpaidCashTipsAmount: self.entity?.unpaidCashTipsAmount, fromPettyCashAmount: self.entity?.fromPettyCashAmount, isPayTipsWithPayrollEnabled: self.entity?.isPayTipsWithPayrollEnabled, nonCashTips: self.entity?.nonCashTips)
        
        let metrics = depositViewModel.metrics ?? []
        let metricViews: [DSSMetricView] = metrics.map {
            let metricView = DSSMetricView()
            metricView.metricImageView.image = $0.image
            metricView.metricTitle.text = $0.title
            metricView.metricDetail.text = $0.detail
            return metricView
        }
        return metricViews
    }
    
    func toggleCellDetailsShown(index: Int) {
        let value = self.depositsCellDetailsDisplay[index]
        self.depositsCellDetailsDisplay[index] = value == true ? false : true
    }
    
    /**
     Check if last deposits is added at the end of deposits list
     */
    func addNewDeposit() {
        let newDepositNumber = self.depositCount + 1
        if newDepositNumber <= self.maxDepositsNumber {
            self.prepareNewDeposit(newDepositNumber: newDepositNumber)
        }
    }
    
    func prepareNewDeposit(newDepositNumber: Int) {
        let newDepositSales = self.initNewDeposit(newDepositNumber: newDepositNumber)
        self.toggleCellDetailsShown(index: newDepositNumber - 1)
        self.dssOperationDetailsModel.entity?.salesDeposits?.append(newDepositSales)
        self.onDataFetched?()
    }
    
    func initNewDeposit(newDepositNumber: Int) -> SalesDeposit {
        var newDepositSales = SalesDeposit()
        newDepositSales.number = newDepositNumber
        newDepositSales.locationID = self.locationId
        newDepositSales.dailySalesSummaryID = self.dailySalesSummaryId
        return newDepositSales
    }
    
    /**
     Add deposits at specific index
     - parameter index: index which represent the number of missed deposit
     */
    func addEmptyDeposit(index: Int) {
        let newDepositSales = self.initNewDeposit(newDepositNumber: index)
        self.dssOperationDetailsModel.entity?.salesDeposits?.insert(newDepositSales, at: index - 1)
        self.onDataFetched?()
    }
    
    /**
     Calculate total deposit amount of all updated deposits
     */
    func calculateTotalDepositAmount() {
        var totalDepositAmount: Double = 0
        for index in 0..<(self.dssOperationDetailsModel.entity?.salesDeposits?.count ?? 0) {
            totalDepositAmount = totalDepositAmount + (self.dssOperationDetailsModel.entity?.salesDeposits?[index].amount ?? 0)
        }
        let toPettyCashAmount = isPettyCashEnabled ? self.dssOperationDetailsModel.entity?.toPettyCashAmount ?? 0.0 : 0.0
        self.dssOperationDetailsModel.entity?.totalDepositAmount = totalDepositAmount -  toPettyCashAmount
    }
    
    /**
     Add deposits that are exist and empty in web but doesn't exist in API
     */
    func addMissedDeposits() {
        if let salesDeposits = self.dssOperationDetailsModel.entity?.salesDeposits {
            let lastDepositNumber = Int(salesDeposits.last?.number ?? 1)
            
            for index in 1...lastDepositNumber {
                if !salesDeposits.contains(where: {$0.number == index}) {
                    addEmptyDeposit(index: index)
                }
            }
        }
    }
    
    /**
     Update sales deposit in entity
     - parameter index: represents the index of changed sales  deposit cell
     - parameter salesDeposit: represents the new sales deposit
     */
    func updateEntityData(newSaleDeposits: SalesDeposit, index: Int)  {
        if (index < self.dssOperationDetailsModel.entity?.salesDeposits?.count ?? 0) {
            if (newSaleDeposits.amount == 0 || newSaleDeposits.amount == nil) {
                self.dssOperationDetailsModel.entity?.salesDeposits?.remove(at: index)
            } else {
                self.dssOperationDetailsModel.entity?.salesDeposits?[index] = newSaleDeposits
            }
            self.calculateTotalDepositAmount()
            self.isUpdated = true
        }
    }
    
    /**
     Update unpaid cash tips amount in entity
     - parameter unpaidCashTipsAmount: represents the new unpaidCashTipsAmount
     */
    func updateUnpaidCashTips(amount: Double)  {
        self.dssOperationDetailsModel.entity?.unpaidCashTipsAmount = amount
        self.isUpdated = true
    }
    
    func getDepositItemCellViewModel(row: Int) -> DSSDepositItemCellViewModel? {
        let deposits = self.getDSSDetailsDepositsSalesModel()
        guard row >= 0 &&
              row < deposits.count
        else { return nil }
        
        let salesDeposit = deposits[row]
        let isEditEnable =  self.isEditEnable
        let isDetailsShown = self.depositsCellDetailsDisplay[row] ?? false
        let tagBase = self.getPettyCashTextFieldCount()
        let numberOfCells = self.getNumberOfCells(sectionType: .deposits)
        let cellViewModel = DSSDepositItemCellViewModel(salesDeposit: salesDeposit, isDetailsShown: isDetailsShown, isEditEnable: isEditEnable, cellIndex: row, tagBase: tagBase, numberOfCells: numberOfCells)
        return cellViewModel
    }
}

// MARK: - Table view methods
extension DSSDetailsDepositsViewModel {
    func getNumberOfCells(sectionType: DSSDepositSectionType) -> Int {
        switch sectionType {
        case .totalDeposit, .pettyCash:
            return 1
        case .deposits:
            return getDSSDetailsDepositsSalesCount()
        }
    }
    
    func getDepositFormattedDate() -> String {
        return self.date.toDate(format: .MMMd) ?? ""
    }
}

// MARK: - Call API's
extension DSSDetailsDepositsViewModel {
    func putDSSOperationDetails() {
        guard self.dssOperationDetailsModel.entity?.isDepositComplete == false else {
            self.retrieveOperationDetails()
            return
        }
        
        self.dssOperationDetailsModel.entity?.isDepositComplete = true
        DSSAPI.putOperationDetails(detailsModel: self.dssOperationDetailsModel, completionHandler: { [weak self] result in
            switch result {
            case .success:
                self?.retrieveOperationDetails()
                
            case .failure(let errorMsg):
                self?.isAPIFailed = true
                self?.onShowError?(errorMsg)
                
            case .cancelled:
                self?.onShowError?("")
            }
        })
    }
    
    private func retrieveOperationDetails() {
        DSSAPI.retrieveOperationDetails(id: self.dailySalesSummaryId) { [weak self] (dssOperationDetails , response) in
            switch response {
            case .success:
                if let dssOperationDetails {
                    self?.dssOperationDetailsModel = dssOperationDetails
                    self?.addMissedDeposits()
                    self?.onDataFetched?()
                }
                
            case .failure(let msg):
                self?.isAPIFailed = true
                self?.onShowError?(msg)
                
            case .cancelled:
                self?.onShowError?("")
            }
        }
    }
}
