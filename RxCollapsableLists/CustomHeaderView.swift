
import Foundation
import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {
    static let identifier: String = "\(CustomHeaderView.self)"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    var isCollapsed = false
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupViews()
        setupConstraints()
    }
    
    func configure(section: SectionOfCustomData) {
        
    }
    
    func setupViews() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        let titleLabelConstraints = [
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: 20)
        ]
        
        NSLayoutConstraint.activate(titleLabelConstraints)
    }
    
    func setupGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        self.addGestureRecognizer(gestureRecognizer)
        self.isUserInteractionEnabled = true
    }
}
