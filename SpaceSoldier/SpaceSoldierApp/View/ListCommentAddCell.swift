import UIKit
import kintone_ios_sdk

protocol AddCommentCellDelegate {
    func handleCommentCancel()
    func handleCommentPost(_ addCell: ListCommentAddCell)
}

class ListCommentAddCell: UITableViewCell {
    
    @IBOutlet weak var mentionLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    var mentionList: [CommentMention]?
    var delegate: AddCommentCellDelegate?
    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //
        // Configure the view for the selected state
    }
    
    @IBAction func postCommentHandler(_ sender: Any) {
        delegate?.handleCommentPost(self)
    }
    
    
    @IBAction func cancelCommentHandler(_ sender: Any) {
        delegate?.handleCommentCancel()
    }
}
