//
//  DSSDetailsDepositsViewController.swift
//  Created by Oula Mardawi on 02/10/2022.


import UIKit

protocol DSSDetailsDepositsViewControllerDelegate: AnyObject {
    func didReturnFromDetailsDepositsView(operationDetailsModel: DSSOperationDetailsModel, isUpdated: Bool)
    func didDSSOpreationDetailsChanged(details: DSSOperationDetailsModel?)
}

class DSSDetailsDepositsViewController: UIViewController, NavigationBar {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerButtonsView: FooterButtonsView!
    
    private var refreshControl: RefreshControlManager? = nil
    private var isKeyboardVisible: Bool = false
    
    weak var delegate: DSSDetailsDepositsViewControllerDelegate?
    var viewModel: DSSDetailsDepositsViewModel
    
    init(viewModel: DSSDetailsDepositsViewModel) {
        self.viewModel = viewModel
        let nibName = String(describing: type(of: self))
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.bindViewModel()
        self.viewModel.toggleCellDetailsShown(index: 0)
        self.viewModel.putDSSOperationDetails()
        self.adjustTableViewPosition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.delegate?.didReturnFromDetailsDepositsView(operationDetailsModel: self.viewModel.dssOperationDetailsModel, isUpdated: self.viewModel.isUpdated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.tableView.alpha == 0 && self.footerButtonsView.alpha == 0 && !(self.viewModel.isAPIFailed )  {
            self.view.addLoadingWithAnimation(frame: self.view.frame)
        }
    }
    
    /**
     Configure all views
     */
    private func configureViews() {
        self.configureNavigationBar()
        self.refreshControl = self.getRefreshControlManager(tableView: self.tableView, selector: #selector(reloadData))
        self.configureTableView()
        self.hideContentViews()
        self.configureTapGesture()
    }
    
    /**
     Configure navigation bar
     */
    private func configureNavigationBar() {
        self.title = self.viewModel.getViewControllerNavigationTitle()
        
        let cameraImage = UIImage.Assets.cameraUploadIcon.image.withRenderingMode(.alwaysTemplate)
        let cameraButton = UIBarButtonItem(image: cameraImage,
                                           style: .plain,
                                           target: self,
                                           action: #selector(self.didClickAddAttachmentButton))
        cameraButton.tintColor = UIColor.Assets.Black.color
        self.navigationItem.rightBarButtonItem = cameraButton
        
        self.addNavigationBarBackArrowButtonWithoutStack(backButtonAction: #selector(self.backButtonClicked), target: self)
    }
    
    @objc func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Configure table view
     - register table cells
     */
    private func configureTableView() {
        self.tableView.alpha = 0
        self.tableView.keyboardDismissMode = .onDrag
        
        // register cells
        self.tableView.register(DetailsMetricSummaryViewCell.nib, forCellReuseIdentifier: DetailsMetricSummaryViewCell.cellId)
        self.tableView.register(PettyCashDetailsTableViewCell.nib, forCellReuseIdentifier: PettyCashDetailsTableViewCell.cellId)
        self.tableView.register(DepositItemDetailsTableViewCell.nib, forCellReuseIdentifier: DepositItemDetailsTableViewCell.cellId)
    }
    
    /**
     Configure footer button view
     */
    private func configureFooterButtonsView() {
        footerButtonsView.configureView(mainButtonTitle: String.Localizable.NewDepositButtonTitle.string, isMainButtonEnable: self.viewModel.isFooterButtonEnable)
        footerButtonsView.delegate = self
    }
    
    private func hideContentViews() {
        self.tableView.alpha = 0
        self.footerButtonsView.alpha = 0
    }
    
    private func showContentViews() {
        self.tableView.alpha = 1
        self.footerButtonsView.alpha = 1
    }
    
    /**
     Configure tap gesture
     - dismss keyboard when user pressed anywhere in view
     */
    func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    /**
     Bind view model and implement methods
     */
    private func bindViewModel() {
        self.viewModel.onDataFetched = { [weak self] in
            self?.view.removeNetworkErrorView()
            self?.stopLoadingAnimations()
            self?.view.removeLoading()
            self?.tableView.reloadData()
            if self?.tableView.alpha == 0 && self?.footerButtonsView.alpha == 0 {
                UIView.animate(withDuration: 0.25) {
                    self?.showContentViews()
                }
            }
            self?.configureFooterButtonsView()
        }
        
        self.viewModel.onShowError = { [weak self] errorMsg in
            guard let self = self else {return}
            self.stopLoadingAnimations()
            self.view.addNetworkErrorView(title: errorMsg , delegate: self)
        }
    }
    
    /**
     Scroll table view to the opened deposit
     - Parameter row: the row of  the opened deposit
     */
    func scrollToDeposit(at row: Int, animated: Bool = true) {
        guard self.isKeyboardVisible == false else { return }
        DispatchQueue.main.async {
            let depositSctionIndex = self.viewModel.sections.firstIndex(of: .deposits) ?? 0
            let indexPath = IndexPath(row: row, section: depositSctionIndex)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
    /**
     Adjust table view position when moving between textfieldsby keyboard arrows
     */
    private func adjustTableViewPosition() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /**
     Remove observer
     */
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /**
     Reload data when the table view is refreshed
     */
    @objc func reloadData() {
        self.viewModel.getData()
    }
    
    private func showLoadingWithBackground() {
        let backgroundColor = UIColor(white: 1, alpha: 0.9)
        self.view.addLoadingWithAnimation(frame: self.view.frame, backgroundColor: backgroundColor)
    }
    
    /**
     Stop the loading animation when data is fetched
     */
    private func stopLoadingAnimations() {
        self.view.removeLoading()
        self.refreshControl?.endRefreshing()
    }
    
    func refreshMetricView() {
        let indexPath = IndexPath(row: DSSDepositSectionType.totalDeposit.rawValue, section: DSSDepositSectionType.totalDeposit.rawValue)
        if tableView.cellForRow(at: indexPath) != nil {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func moveToTextField(tag: Int) {
        self.viewModel.showDepositDetails(forTextFieldWithTag: tag) { refreshCell, depositIndex in
            if refreshCell {
                let depositCell = self.getDepositCell(at: depositIndex)
                depositCell?.showDetailsView()
            }
        }
        
        if (tag > 0) {
            let view = self.view.viewWithTag(tag) as? DSSDepositeAmountView
            view?.amountTextField.becomeFirstResponder()
        }
    }
    
    func getDepositCell(at index: Int) -> DepositItemDetailsTableViewCell? {
        let indexPath: IndexPath = IndexPath(row: index, section: DSSDepositSectionType.deposits.rawValue)
        return self.tableView.cellForRow(at: indexPath) as? DepositItemDetailsTableViewCell
    }
    
    /**
     did Click Add Attachment Button
     - handle when the right navigation button is clicked to add new attachment
     */
    @objc func didClickAddAttachmentButton() {}
    
    /**
     Calls this function when the tap is recognized
     */
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

//MARK: - Footer buttons view delegate
extension DSSDetailsDepositsViewController: FooterButtonsViewDelegate {
    func didClickedMainButton() {
        self.viewModel.addNewDeposit()
        let index = self.viewModel.depositCount - 1
        self.scrollToDeposit(at: index)
    }
}

// MARK: - Admin Navigation Controller Configurable Extension
extension DSSDetailsDepositsViewController: AdminNavigationControllerConfigurable {
    var isPanelItemAdded: Bool {
        return false
    }
}

// MARK: - Deposit item details table view cell delegate
extension DSSDetailsDepositsViewController: DepositItemDetailsTableViewCellDelegate {
    func didClickAtTextField(tag: Int) {
        guard self.tableView.contentInset.top == 0 else { return }
        self.tableView.contentInset.top = 100
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
    
    func depositItemCellChanged(saleDeposits: SalesDeposit, index: Int) {
        self.viewModel.updateEntityData(newSaleDeposits: saleDeposits, index: index)
        self.refreshMetricView()
    }
    
    func toggleCellDetailsShown(index: Int) {
        self.viewModel.toggleCellDetailsShown(index: index)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.scrollToDeposit(at: index)
    }
}

// MARK: - Petty cash details Table view cell delegate
extension DSSDetailsDepositsViewController: PettyCashDetailsTableViewCellDelegate {
    func clickNext(tag: Int) {
        guard self.viewModel.isLastTextField(tag: tag) == false else {
            self.view.endEditing(true)
            return
        }
        
        self.moveToTextField(tag: tag + 1)
    }
    
    func clickPrevious(tag: Int) {
        guard self.viewModel.isFirstTextField(tag: tag) == false else {
            self.view.endEditing(true)
            return
        }
        
        self.moveToTextField(tag: tag - 1)
    }
        
    func pettyCashCellChanged(amount: String) {
        self.viewModel.updateUnpaidCashTips(amount: Double(amount) ?? 0)
        self.refreshMetricView()
    }
}

// MARK: - Network Error View Delegate
extension DSSDetailsDepositsViewController: NetworkErrorViewDelegate {
    func networkErrorTryAgainButtonClicked() {
        self.hideContentViews()
        self.view.addLoadingWithAnimation(frame: self.view.frame)
        self.view.removeNetworkErrorView()
        self.viewModel.getData()
    }
}

// MARK: - Arrows Adjustment Keyboard Bar Method
extension DSSDetailsDepositsViewController {
    @objc func keyboardWillShow(notification: Notification) {
        self.isKeyboardVisible = true
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        self.tableView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.isKeyboardVisible = false
        self.tableView.contentInset = .zero
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
}
