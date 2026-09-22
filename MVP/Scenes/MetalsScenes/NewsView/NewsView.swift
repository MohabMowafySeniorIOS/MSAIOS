//
//  NewsView.swift
//  CurrencyApp
//
//  Created by Mohab Mowafy on 03/04/2026.
//


//import Foundation
//var news_api_key = "ff229884078642488fb05db7928e127c"
//
//import SwiftUI
//
//class NewsVC: UIHostingController<NewsView> {
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder, rootView: NewsView())
//    }
//}
//struct NewsResponse: Codable {
//    let articles: [Article]
//}
//
//struct Article: Codable, Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String?
//    let urlToImage: String?
//    let url: String
//}
//import SwiftUI
//import Combine
//
//import Foundation
//import SwiftSoup
//
//struct NewsItem {
//    let title: String
//    let link: String
//    let image: String
//}
//
//struct NewsModel: Identifiable, Hashable {
//
//    let id = UUID()
//
//    
//    let title: String
//
//    let image: String
//
//    let link: String
//}
//enum AppLanguage {
//
//    case arabic
//
//    case english
//
//}
//class NewsViewModel: ObservableObject {
//    
//    @Published var articlesArr: [Article] = []
//    @Published var isLoading = false
////    func newsURL(for language: AppLanguage) -> [String] {
////
////        switch language {
////
////        case .arabic:
////
////            return [
////
////                "https://www.skynewsarabia.com/business",
////
////                "https://www.masrawy.com/news/news_economy",
////
////                "https://sa.investing.com/commodities/gold-news"
////
////            ]
////
////        case .english:
////
////            return [
////
////                "https://www.kitco.com/news/",
////
////                "https://www.reuters.com/markets/commodities/",
////
////                "https://www.investing.com/commodities/gold-news"
////
////            ]
////
////        }
////
////    }
////    func fetchNews(
////
////            language: AppLanguage
////
////        ) {
////            self.isLoading = true
////
////            let urls = newsURL(for: language)
////
////            var allNews: [NewsModel] = []
////
////            let group = DispatchGroup()
////
////            urls.forEach { urlString in
////
////                group.enter()
////
////                guard let url = URL(string: urlString) else {
////
////                    group.leave()
////
////                    return
////
////                }
////
////                URLSession.shared.dataTask(with: url) { data, _, _ in
////
////                    defer {
////
////                        group.leave()
////
////                    }
////
////                    guard let data else { return }
////
////                    do {
////
////                        let html = String(data: data, encoding: .utf8) ?? ""
////
////                        let doc = try SwiftSoup.parse(html)
////
////                        let articles = try doc.select("article")
////
////                        for item in articles.array() {
////
////                            let title = try item.select("h2,h3").text()
////
////                            let image = try item.select("img").attr("src")
////
////                            let link = try item.select("a").attr("href")
////
////                            if title.lowercased().contains("gold")
////
////                            || title.contains("ذهب")
////
////                            || title.lowercased().contains("silver")
////
////                            || title.contains("فضة") {
////
////                                let news = NewsModel(
////
////                                    title: title,
////
////                                    image: image,
////
////                                    link: link,
////
////                                    source: url.host ?? ""
////
////                                )
////
////                                allNews.append(news)
////
////                            }
////
////                        }
////
////                    } catch {
////
////                        print(error)
////
////                    }
////
////                }.resume()
////
////            }
////
////            group.notify(queue: .main) {
////                self.isLoading = false
////                self.articlesArr = allNews
////
////            }
////
////        }
////
////    }
//    
//    func fetchNews() {
//        let lang = L102Language.currentAppleLanguage()
//        guard let url = URL(string: "https://newsapi.org/v2/everything?q=gold&language=\(lang)&apiKey=\(news_api_key)") else { return }
//           print(url)
//         
//        isLoading = true
//        
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//            
//            guard let data = data else { return }
//            
//            let result = try? JSONDecoder().decode(NewsResponse.self, from: data)
//            
//            DispatchQueue.main.async {
//                self.articlesArr = result?.articles ?? []
//            }
//        }.resume()
//    }
//}
//
//struct NewsCardView: View {
//    let article: Article
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            
//            if let image = article.urlToImage,
//               let url = URL(string: image) {
//                
//                AsyncImage(url: url) { image in
//                    image.resizable()
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(height: 180)
//                .cornerRadius(12)
//            }
//            
//            Text(article.title )
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            Text(article.description ?? "" )
//                .font(.title2)
//                .foregroundColor(.white)
//        }
//        .onTapGesture {
//            if let url = URL(string: article.url ) {
//                UIApplication.shared.open(url)
//            }
//        }
//        .padding()
//        .background(Color.gray)
//        .cornerRadius(16)
//        .shadow(radius: 5)
//        
//    }
//}
//struct NewsView: View {
//    
//    @StateObject var vm = NewsViewModel()
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                
//            Color.unSelectedColor.ignoresSafeArea()
//                
//                if vm.isLoading {
//                    ProgressView()
//                        .tint(.yellow)
//                } else {
//                    ScrollView {
//                        LazyVStack(spacing: 16) {
//                            ForEach(vm.articlesArr) { article in
//                                NewsCardView(article: article)
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .navigationTitle("أخبار الذهب")
//        }
//        .onAppear {
//            vm.fetchNews()
//        }
//    }
//}
//
