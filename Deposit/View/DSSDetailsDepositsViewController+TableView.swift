//
//  DSSDetailsDepositsViewController+TableView.swift

//  Created by Oula Mardawi on 02/10/2022.

import Foundation

extension DSSDetailsDepositsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sections.count
    }
    
    //MARK: - Return number of table view cells in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.viewModel.sections[section]
        return self.viewModel.getNumberOfCells(sectionType: section)
    }
    
    //MARK: - Configure table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = self.viewModel.sections[indexPath.section]
        var cellToReturn: UITableViewCell?
        
        switch section {
        case .totalDeposit:
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailsMetricSummaryViewCell.cellId) as? DetailsMetricSummaryViewCell
            let metricsViews = self.viewModel.getMetricsViews()

            cell?.configureCell(title: String.Localizable.DepositMetricViewTitle.string, metricViews: metricsViews)
            cellToReturn = cell
            
        case .pettyCash:
            let cell = tableView.dequeueReusableCell(withIdentifier: PettyCashDetailsTableViewCell.cellId) as? PettyCashDetailsTableViewCell
            cell?.delegate = self
            
            if let entity = self.viewModel.entity {
                let isEditEnable = self.viewModel.isEditEnable
                let cellViewModel = DSSPettyCashCellViewModel(entity: entity, isEditEnable: isEditEnable)
                cell?.configureCell(viewModel: cellViewModel)
            }
            cellToReturn = cell
            
        case .deposits:
            let cell = tableView.dequeueReusableCell(withIdentifier: DepositItemDetailsTableViewCell.cellId) as? DepositItemDetailsTableViewCell
            cell?.delegate = self
            
            if let cellViewModel = self.viewModel.getDepositItemCellViewModel(row: indexPath.row) {
                cell?.configureCell(viewModel: cellViewModel)
            }
            cellToReturn = cell
        }
        return cellToReturn ?? UITableViewCell()
    }
}
