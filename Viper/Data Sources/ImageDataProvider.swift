/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Combine

protocol ImageDataProvider {
  func getEndImages(for trip: Trip) -> AnyPublisher<[UIImage], Never>
}

private struct PixabayResponse: Codable {
  struct Image: Codable {
    let largeImageURL: String
    let user: String
  }

  let hits: [Image]
}

//Get an API Key here: https://pixabay.com/accounts/register/
class PixabayImageDataProvider: ImageDataProvider {
  let apiKey = "<#Enter your API key here#>"

  private func searchURL(query: String) -> URL {
    var components = URLComponents(string: "https://pixabay.com/api")!
    components.queryItems = [
      URLQueryItem(name: "key", value: apiKey),
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "image_type", value: "photo")
    ]
    return components.url!
  }

  private func imageForQuery(query: String) -> AnyPublisher<UIImage, Never> {
    URLSession.shared.dataTaskPublisher(for: searchURL(query: query))
    .map { $0.data }
    .decode(type: PixabayResponse.self, decoder: JSONDecoder())
      .tryMap { response -> URL in
        guard
          let urlString = response.hits.first?.largeImageURL,
          let url = URL(string: urlString)
          else {
            throw CustomErrors.noData
        }
          return url
    }.catch { _ in Empty<URL, URLError>() }
      .flatMap { URLSession.shared.dataTaskPublisher(for: $0) }
      .map { $0.data }
      .tryMap { imageData in
        guard let image = UIImage(data: imageData) else { throw CustomErrors.noData }
        return image
    }.catch { _ in Empty<UIImage, Never>()}
    .eraseToAnyPublisher()
  }

  func getEndImages(for trip: Trip) -> AnyPublisher<[UIImage], Never> {
    if trip.waypoints.count == 0 {
      return Empty<[UIImage], Never>()
        .eraseToAnyPublisher()
    }
    if trip.waypoints.count == 1 {
      return imageForQuery(query: trip.waypoints[0].name)
        .map { [$0] }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    let start = imageForQuery(query: trip.waypoints[0].name)
    let end = imageForQuery(query: trip.waypoints.last!.name)

    return Publishers.Merge(start, end)
      .collect()
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
