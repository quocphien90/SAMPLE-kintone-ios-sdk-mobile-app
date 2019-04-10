//  Copyright © 2018 Cybozu. All rights reserved.

import kintone_ios_sdk
import UIKit
import Promises

class ListCommentController: UIViewController, CommentCellDelegate, UITextViewDelegate {
    public var recordId: Int? = 0
    
    var displayComments = [Comment]()
    var connection = AppCommon.shared.getConnection()
    var appId = AppCommon.shared.getAppId()!
    var recordModule: Record?
    var defaultLimit: Int = 10
    var limit: Int = 0
    var offset: Int = 0
    var refreshControl: UIRefreshControl!
    var replyListHeight = CGFloat(1)
    var needDrawBorders = true
    
    let NEW_COMMENT_INIT_CONSTRAINT = 10
    private var justHidden = false
    var newCommentMentioner = [CommentMention]()
    var userTimeZone: String = AppCommon.shared.getUserTimezone()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentContentTextView: UITextView!
    @IBOutlet weak var mentionList: UIView!
    @IBOutlet weak var newCommentContainer: UIView!
    @IBOutlet weak var newCommentConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionLabel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordModule = Record(connection!)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.commentContentTextView.delegate = self
        
        // set corner radius for comment text view
        self.commentContentTextView.layer.borderWidth = 1
        self.commentContentTextView.layer.borderColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
        self.commentContentTextView.layer.masksToBounds = true
        self.commentContentTextView.layer.cornerRadius = 5
        //
        
        // add gesture recognizer when tapped around
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //
        
        setRefreshControlAttr()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        // add bottom border for mention list
        mentionListHeightConstraint.constant = self.replyListHeight
        mentionList.layoutIfNeeded()
        if(needDrawBorders) {
            self.mentionList.addBorder(toSide: .Bottom, withColor: UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor, andThickness: 1, offsetX: 100)
            self.needDrawBorders = false
        }
        //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.refreshComments()
            self.tableView.tableFooterView = UIView()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(refreshControl.isRefreshing) {
            handleRefreshTable()
        }
    }
   
    func setRefreshControlAttr() {
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
    }
    @objc func handleRefreshTable() {
        self.refreshComments()
        self.refreshControl.endRefreshing()
        let detailController = parent as! RecordDetailController
        detailController.rightMostButton.isEnabled = true
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if self.justHidden==false, let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let keyboardFrameY = keyboardFrame!.height
            newCommentConstraint.constant = keyboardFrameY + 2
            self.commentContentTextView.becomeFirstResponder()
            self.view.layoutIfNeeded()
        }
        else {
            self.justHidden = false
        }
    }
    
    @objc func hideKeyboard() {
        if(self.commentContentTextView.isFirstResponder) {
            self.justHidden = true
            self.view.endEditing(true)
            self.newCommentConstraint.constant = CGFloat(self.NEW_COMMENT_INIT_CONSTRAINT)
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.isScrollEnabled = true
        self.adjustTextViewHeight(textView)
    }
    
    func adjustTextViewHeight(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let difference = newSize.height - 32 //new line
        self.containerHeightConstraint?.constant = 37 + difference //new line
        self.view.layoutIfNeeded()
    }
    
    func refreshComments() {
        getListComments(self.offset, self.defaultLimit)
        .then{ listComments in
           self.displayComments = listComments
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.catch { error in
            if type(of: error) is KintoneAPIException.Type
            {
                self.alert(message: (error as! KintoneAPIException).toString()!)
            } else {
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func commentPostHandler(_ sender: Any) {
        handleCommentPost()
    }
    
    func handleCommentPost(){
        hideKeyboard()
        let spinner = UIViewController.displaySpinner(onView: (self.parent?.view)!)
        let recordModule = Record(self.connection!)
        let commentContent = CommentContent()
        let commentText = self.commentContentTextView.text!
        commentContent.setText(commentText)
        if(self.newCommentMentioner.count > 0 ) {
            commentContent.setMentions(self.newCommentMentioner)
        }
     
        recordModule.addComment(self.appId, self.recordId!, commentContent)
            .then{_ in
                DispatchQueue.main.async {
                    self.commentContentTextView.text = ""
                    self.resetMentionList()
                    self.adjustTextViewHeight(self.commentContentTextView)
                    self.refreshComments()
                }
            }.catch{error in
                if type(of: error) is KintoneAPIException.Type {
                    self.alert(message: (error as! KintoneAPIException).toString()!)
                } else {
                    self.alert(message: error.localizedDescription)
                }
            }.always {
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: spinner)
                }
            }
        
    }
    
    func resetMentionList() {
        self.newCommentMentioner = [CommentMention]()
        self.replyListHeight = 1
        self.view.layoutSubviews()
        self.mentionLabel.setTitle("", for: .normal)
        self.mentionLabel.sizeToFit()
        self.view.layoutIfNeeded()
    }
    
    func handleReply(_ cell: ListCommentViewCell) {
        self.commentContentTextView.becomeFirstResponder()
        let currentReplyComment = cell.cellData
        let creator = currentReplyComment!.getCreator()!
        let mentionEntry: CommentMention = CommentMention()
        mentionEntry.setCode(creator.code!)
        mentionEntry.setType(MemberSelectEntityType.USER.rawValue)
        self.newCommentMentioner = [mentionEntry]
        self.replyListHeight = 22
        self.view.layoutSubviews()
        self.mentionLabel.setTitle("@\(creator.code!)", for: .normal)
        self.mentionLabel.sizeToFit()
    }
    
    func handleCommentDelete(_ cell: ListCommentViewCell) {
        let alert = UIAlertController(title: NSLocalizedString("delete-confirm-message", comment: ""), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete-confirm-ok", comment: ""), style: .default, handler: { action in
            let spinner = UIViewController.displaySpinner(onView: (self.parent?.view)!)
            self.hideKeyboard()
            
            let commentId = cell.cellData!.getId()!
            let recordModule = Record(self.connection!)
            recordModule.deleteComment(self.appId, self.recordId!, commentId).then{
                self.refreshComments()
                UIViewController.removeSpinner(spinner: spinner)
            }.catch { error in
                if type(of: error) is KintoneAPIException.Type
                {
                    self.alert(message: (error as! KintoneAPIException).toString()!)
                } else {
                    self.alert(message: error.localizedDescription)
                }
                UIViewController.removeSpinner(spinner: spinner)
            }
       }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete-confirm-cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true)
        self.hideKeyboard()
    }
    
    @IBAction func deleteMention(_ sender: Any) {
        resetMentionList()
        self.view.layoutSubviews()
        self.mentionLabel.setTitle("", for: .normal)
        self.mentionLabel.sizeToFit()
    }
    
}

extension ListCommentController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(displayComments.count > 0) {
            tableView.backgroundView = nil
            return displayComments.count        }
        else {
            UIViewController.EmptyMessage(message: "no-comments".localized, icon: "icon-message-100", tableView: tableView)
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(displayComments.count > 0) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section > 0) {
            return 20
        } else {
            return 0
        }
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section > 0) {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! ListCommentViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none;
        cell.delegate = self
        cell.indexPath = indexPath
        cell.cellData = displayComments[indexPath.section]
        let userCode = UserDefaults.standard.string(forKey: KintoneConstants.USERNAME_KEY)
        if(userCode == displayComments[indexPath.section].getCreator()!.code!) {
            cell.deleteButton.isHidden = false
        }
        else {
            cell.deleteButton.isHidden = true
        }
        return getCommentViewCellData(cell: cell, commentEntry: displayComments[indexPath.section], index: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(displayComments[indexPath.section].getId() == -1) {
            let addCell = cell as! ListCommentAddCell
            addCell.commentTextView.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let addCell = cell as? ListCommentAddCell {
            addCell.resignFirstResponder()
            addCell.mentionList = nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func getLimit(_ newLimit: Int) -> Int {
        var limit = newLimit
        if newLimit > (displayComments.count) {
            limit = (displayComments.count)
        }
        return limit
    }
    
    func getCommentViewCellData(cell: ListCommentViewCell, commentEntry: Comment, index: Int) -> ListCommentViewCell {
        let cellData = cell
        let createdDate = commentEntry.getCreatedAt()
        cellData.createdDateTimeTextLabel.text = createdDate!.formatToString(dateFormat: "MMM dd, yyyy HH:mm" , timezone: userTimeZone)
        cellData.creatorTextLabel.text = commentEntry.getCreator()?.name
        cellData.commentIdTextLabel.text = "\(commentEntry.getId()!):"
        let mentionList =  commentEntry.getMentions()!
        var mentionText: String = ""
        if mentionList.count > 0 {
            for mention in mentionList {
                mentionText = "\(mentionText) @\(mention.getCode()!)"
            }
        }
        let commentText = commentEntry.getText()
        if(mentionText.count > 0) {
            cellData.commentTextView.text = "\(mentionText) \n \(commentText!)"
        }
        else {
            cellData.commentTextView.text = "\(commentText!)"
        }
        return cellData
    }
    
    func getListComments(_ offset: Int, _ limit: Int) -> Promise<[Comment]> {
        return Promise{ fulfill, reject in
            self.recordModule!.getComments(self.appId, self.recordId!, "desc", offset, limit)
            .then{ commentResponse in
                fulfill(commentResponse.getComments()!)
            }.catch{ error in
                reject(error)
            }
        }
    }
    
}
