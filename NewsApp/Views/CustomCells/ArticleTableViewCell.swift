//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Yograj on 19/08/25.
//

import UIKit

/// A custom UITableViewCell for displaying a news article with title, author, image, and bookmark button.
class ArticleTableViewCell: UITableViewCell {
    
    /// Cell reuse identifier
    static let identifier = "ArticleTableViewCell"
    
    /// UI elements connected from storyboard/nib
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    /// Holds the current article displayed in the cell
    var article: Article?
    
    /// Closure callback triggered when bookmark button is tapped
    var onBookmarkTapped: ((Article) -> Void)?
    
    /// Called when cell is loaded from nib/storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    /// Prepares the cell for reuse by resetting its state
    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.image = nil
        article = nil
    }
    
    /// Configures initial UI setup for labels, image, and bookmark button
    private func setupUI() {
        articleImageView.layer.cornerRadius = 8
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 3
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        
        bookmarkButton.tintColor = .systemYellow
    }
    
    /// Configures the cell with an `Article` object and bookmark state
    /// - Parameters:
    ///   - article: The article to display
    ///   - isBookmarked: Whether the article is already bookmarked
    func configure(with article: Article, isBookmarked: Bool) {
        self.article = article
        
        titleLabel.text = article.title
        authorLabel.text = article.author ?? "Unknown Author"
        
        updateBookmarkButton(isBookmarked: isBookmarked)
        loadImage(from: article.urlToImage)
    }
    
    /// Loads an image from a given URL string and sets it to `articleImageView`
    /// - Parameter urlString: Image URL in string format
    private func loadImage(from urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            // Show placeholder image if no image is available
            articleImageView.image = UIImage(systemName: "photo")
            return
        }
        
        // Simple image loading (In production, use libraries like SDWebImage or Kingfisher for caching)
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.articleImageView.image = image
            }
        }.resume()
    }
    
    /// Formats ISO8601 date string to a more readable format
    /// - Parameter dateString: ISO8601 formatted string
    /// - Returns: Human-readable date string
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    
    /// Updates the bookmark button icon based on bookmark status
    /// - Parameter isBookmarked: Boolean indicating bookmark state
    private func updateBookmarkButton(isBookmarked: Bool) {
        let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    /// Action handler for bookmark button tap
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        guard let article = article else { return }
        onBookmarkTapped?(article) // Notify callback
    }
}

