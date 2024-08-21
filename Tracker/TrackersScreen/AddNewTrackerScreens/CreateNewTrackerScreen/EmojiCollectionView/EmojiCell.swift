import UIKit

final class EmojiCell: UICollectionViewCell {
    
    private var emojiLabel = UILabel()
    var emoji: String?
    
    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textAlignment = .center
        
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    private func updateSelectionAppearance() {
        if isSelected {
            contentView.backgroundColor = .blue
        } else {
            contentView.backgroundColor = .white
        }
    }
    
    func configure(with emoji: String) {
        self.emoji = emoji
        emojiLabel.text = emoji
    }
}
