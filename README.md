## NewsReaderApp

A simple, fast iOS app to browse the latest headlines, search topics you care about, and save favorites for later reading — with light/dark mode and offline support.

### Table of Contents
- [Key Features](#key-features)
- [Requirements](#requirements)
- [How to Use (End User)](#how-to-use-end-user)
- [Data & Privacy](#data--privacy)
- [Setup (Developers)](#setup-developers)
- [Architecture Overview (MVVM)](#architecture-overview-mvvm)
- [Project Structure (Highlights)](#project-structure-highlights)
- [API Details](#api-details)
- [Using URLSession (Built-in Networking)](#using-urlsession-built-in-networking)
  - [Basic GET Request + JSON Decoding](#basic-get-request--json-decoding)
  - [Building URLs Safely with URLComponents (recommended)](#building-urls-safely-with-urlcomponents-recommended)
  - [Image Loading with URLSession (simple approach)](#image-loading-with-urlsession-simple-approach)
- [Optional Libraries: SDWebImage, Kingfisher, Alamofire](#optional-libraries-sdwebimage-kingfisher-alamofire)
  - [SDWebImage](#sdwebimage-image-loading--caching)
  - [Kingfisher](#kingfisher-image-loading--processors)
  - [Alamofire](#alamofire-networking-abstraction)
  - [Choosing between SDWebImage vs. Kingfisher](#choosing-between-sdwebimage-vs-kingfisher)
  - [Minimal Code Changes Summary](#minimal-code-changes-summary)
- [Support](#support)

### Key Features
- **Top headlines**: Browse the latest news (US by default).
- **Search**: Find articles by title.
- **Bookmarks**: Save and manage favorite articles.
- **Offline reading (cached list)**: If you go offline, the app shows the most recently loaded articles from local cache.
- **Themes**: Choose System, Light, or Dark appearance from the top-right button.
- **Pull to refresh**: Swipe down to fetch the latest news.

### Requirements
- **iOS**: 13.0 or later (uses SceneDelegate and SF Symbols)
- **Xcode**: 15 or later recommended
- **Network**: Internet connectivity for fetching news (the app gracefully handles offline mode)
- **API Key**: A free API key from the NewsAPI service

### How to Use (End User)
- **Tabs**: 
  - News: Explore the latest headlines and use the search bar to filter or find specific topics.
  - Bookmarks: View and manage your saved articles.
- **Bookmarking**: Tap the bookmark icon on any article to save/remove it.
- **Theme**: Tap the circle half-filled icon in the navigation bar to switch between System, Light, or Dark.

### Data & Privacy
- **Content source**: Articles are retrieved from the NewsAPI service.
- **Local data**: Bookmarks and a cached list of articles are stored locally on your device using Core Data.
- **Personal data**: The app does not require login and does not collect personal information.
- **Network**: Images are loaded directly from the article sources.

### Setup (Developers)
1. **Clone and open**: Open the project in Xcode.
2. **Get an API key**: Create a free key at the NewsAPI website: [Get a NewsAPI key](https://newsapi.org/).
3. **Add the key to the app**:
   - Update the API key in both of these places in code (current project defines it in two spots):
     - `Utils/Constants.swift` → `Constants.API.apiKey`
     - `Services/APIManager.swift` → `private let apiKey`
   - Tip: For maintainability, you can refactor `APIManager` to read from `Constants.API.apiKey` so there is a single source of truth.
4. **Run**: Select an iOS device or simulator (iOS 13+) and Run.

### Architecture Overview (MVVM)
- **UI (Views/Controllers)**:
  - `Views/Controller/ArticlesVC.swift`: Shows the articles list, search, bookmarking, and theme action.
  - `Views/Controller/BookmarksVC.swift`: Shows saved bookmarks and lets you remove them (swipe to delete).
  - `Views/CustomCells/ArticleTableViewCell.swift`: Displays title, author, image, and bookmark control.
  - `Views/Storyboards/Base.lproj/Main.storyboard`: Storyboard containing `ArticlesVC` and `BookmarksVC` (identified by storyboard IDs "ArticlesVC" and "BookmarksVC").
- **ViewModels**:
  - `ViewModels/ArticlesViewModel.swift`: Fetches/searches articles, filters results, coordinates cache, and reports loading/error states via `ArticlesViewModelDelegate`.
  - `ViewModels/BookmarksViewModel.swift`: Loads and manages bookmarked articles via `BookmarksViewModelDelegate`.
- **Services**:
  - `Services/APIManager.swift`: Networking to NewsAPI (`/top-headlines` for US, `/everything` for search). Handles connectivity checks and JSON decoding.
  - `Services/CacheManager.swift`: Abstraction over Core Data for caching and bookmarks.
- **Persistence (Core Data)**:
  - `Models/CoreData/CoreDataManager.swift`: Core Data stack and CRUD for `Article` entities (save, fetch cached, toggle bookmark, fetch bookmarks).
  - `Models/CoreData/ArticleEntity+*.swift`: Managed object model properties.
- **Models**:
  - `Models/Article.swift`: Codable `Article` model and `NewsResponse` (as returned by NewsAPI).
- **Theming**:
  - `Utils/ThemeManager.swift`: Persists theme selection in `UserDefaults` and broadcasts updates via `NotificationCenter`. Applied in `SceneDelegate`.
  - `Utils/Extensions.swift`: Provides a reusable theme picker sheet (`System`, `Light`, `Dark`) and common UI helpers.
- **App lifecycle**:
  - `AppDelegate.swift` and `SceneDelegate.swift`: Scene setup and tab bar with two tabs (News and Bookmarks). Theme is applied to the app window and re-applied on changes.

### Project Structure (Highlights)
- `Models/`: Data models and Core Data entities
- `Services/`: Networking and caching layers
- `ViewModels/`: Screen logic (MVVM)
- `Views/`: Storyboard scenes, view controllers, and custom cells
- `Utils/`: Constants, theme manager, and UI extensions

### API Details
- **Base URL**: `https://newsapi.org/v2`
- **Endpoints used**:
  - Top headlines: `/top-headlines?country=us&apiKey=...`
  - Search: `/everything?q={query}&apiKey=...&sortBy=publishedAt`
- **Notes**:
  - The app currently fetches US headlines by default.
  - Errors are surfaced to the user with friendly alerts.

### Using URLSession (Built-in Networking)
`URLSession` is Apple’s native networking library. It requires no extra dependencies and is already used in this project for both API calls and image loading.

- **Where it’s used here**:
  - `Services/APIManager.swift`: Fetches JSON from NewsAPI and decodes to `NewsResponse`.
  - `Views/CustomCells/ArticleTableViewCell.swift` and `Utils/Extensions.swift`: Loads images from article URLs.

#### Basic GET Request + JSON Decoding
Copy-paste pattern used by this app to fetch and decode results:
```swift
func performRequest(urlString: String, completion: @escaping (Result<[Article], Error>) -> Void) {
    guard let url = URL(string: urlString) else {
        return completion(.failure(NetworkError.invalidURL))
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            return DispatchQueue.main.async { completion(.failure(error)) }
        }
        guard let data = data else {
            return DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
        }
        do {
            let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            DispatchQueue.main.async { completion(.success(newsResponse.articles)) }
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }.resume()
}
```

#### Building URLs Safely with URLComponents (recommended)
Avoid manual string concatenation for query parameters:
```swift
var components = URLComponents(string: "https://newsapi.org/v2/everything")!
components.queryItems = [
    URLQueryItem(name: "q", value: query),
    URLQueryItem(name: "apiKey", value: apiKey),
    URLQueryItem(name: "sortBy", value: "publishedAt")
]
let url = components.url!
```
Then pass `url.absoluteString` to the method above.

#### Image Loading with URLSession (simple approach)
Used in this app as a lightweight alternative to libraries:
```swift
imageView.image = UIImage(systemName: "photo")
if let url = URL(string: urlString) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async { imageView.image = image }
        }
    }.resume()
}
```

### Optional Libraries: SDWebImage, Kingfisher, Alamofire
These popular libraries can make image loading and networking more efficient and easier to maintain. Below are simple, drop-in guides for this project.

#### SDWebImage (Image loading + caching)
- **Install (SPM)**: Xcode → File → Add Packages… → use `https://github.com/SDWebImage/SDWebImage.git`
- **Import**: `import SDWebImage`
- **Use in `ArticleTableViewCell`** (replace the simple URLSession image loading):
```swift
// In ArticleTableViewCell.configure(...)
articleImageView.sd_setImage(
    with: URL(string: article.urlToImage ?? ""),
    placeholderImage: UIImage(systemName: "photo"),
    options: [.retryFailed, .continueInBackground]
)
```
- **Notes**:
  - SDWebImage handles memory/disk caching automatically.
  - You can cancel image loads in `prepareForReuse()` with `articleImageView.sd_cancelCurrentImageLoad()` if needed.

#### Kingfisher (Image loading + processors)
- **Install (SPM)**: Xcode → File → Add Packages… → use `https://github.com/onevcat/Kingfisher.git`
- **Import**: `import Kingfisher`
- **Use in `ArticleTableViewCell`**:
```swift
// In ArticleTableViewCell.configure(...)
articleImageView.kf.setImage(
    with: URL(string: article.urlToImage ?? ""),
    placeholder: UIImage(systemName: "photo"),
    options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage
    ]
)
```
- **Notes**:
  - Kingfisher provides powerful processors (resize, round corners, downsampling) and caching strategies.
  - Cancel in `prepareForReuse()` with `articleImageView.kf.cancelDownloadTask()` if needed.

#### Alamofire (Networking abstraction)
- **Install (SPM)**: Xcode → File → Add Packages… → use `https://github.com/Alamofire/Alamofire.git`
- **Import**: `import Alamofire`
- **Use in `APIManager`** (replace `URLSession` logic):
```swift
// Example: fetchTopHeadlines using Alamofire
func fetchTopHeadlines(completion: @escaping (Result<[Article], Error>) -> Void) {
    guard isConnected else { return completion(.failure(NetworkError.noConnection)) }
    let urlString = "\(baseURL)/top-headlines?country=us&apiKey=\(apiKey)"

    AF.request(urlString)
        .validate()
        .responseDecodable(of: NewsResponse.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let news):
                DispatchQueue.main.async { completion(.success(news.articles)) }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
}

// Example: searchArticles using Alamofire
func searchArticles(query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
    guard isConnected else { return completion(.failure(NetworkError.noConnection)) }
    let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "\(baseURL)/everything?q=\(encoded)&apiKey=\(apiKey)&sortBy=publishedAt"

    AF.request(urlString)
        .validate()
        .responseDecodable(of: NewsResponse.self) { response in
            switch response.result {
            case .success(let news):
                DispatchQueue.main.async { completion(.success(news.articles)) }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
}
```
- **Notes**:
  - `responseDecodable` simplifies JSON parsing; you can customize `JSONDecoder` strategies if needed.
  - Keep `NWPathMonitor` connectivity checks; Alamofire also offers `NetworkReachabilityManager` as an alternative.

#### Choosing between SDWebImage vs. Kingfisher
- **Both** provide excellent async loading and caching.
- **SDWebImage**: Very mature ecosystem, simple API, wide community adoption.
- **Kingfisher**: Rich image processors and transitions out of the box.
- For this app, either is a safe choice. If you need built-in processors/animations, lean Kingfisher; if you want minimal, lean SDWebImage.

#### Minimal Code Changes Summary
- If adopting SDWebImage/Kingfisher:
  - Remove the custom image loading in `ArticleTableViewCell` (or simply stop calling it) and set the image with the library API inside `configure(with:isBookmarked:)`.
- If adopting Alamofire:
  - Replace the `URLSession` request in `APIManager.performRequest(...)` with Alamofire calls as shown (or keep the signature and internals but switch implementation).

### Support
If you run into issues:
- Ensure your API key is valid and not rate-limited by NewsAPI.
- Check your internet connection. The app will fall back to cached articles if offline.
- Review console logs in Xcode for error details during development.
