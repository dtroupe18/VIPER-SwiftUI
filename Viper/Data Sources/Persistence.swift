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

import Foundation
import Combine

fileprivate struct Envelope: Codable {
  let trips: [Trip]
}

/// This class can be refactored to save/load over a network instead of a local file
class Persistence {
  var localFile: URL {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("trips.json")
    print("In case you need to delete the database: \(fileURL)")
    return fileURL
  }
  
  var defaultFile: URL {
    return Bundle.main.url(forResource: "default", withExtension: "json")!
  }

  private func clear() {
    try? FileManager.default.removeItem(at: localFile)
  }

  func load() -> AnyPublisher<[Trip], Never>  {
    if FileManager.default.fileExists(atPath: localFile.standardizedFileURL.path) {
      return Future<[Trip], Never> { promise in
        self.load(self.localFile) { trips in
          DispatchQueue.main.async {
            promise(.success(trips))
          }
        }
      }.eraseToAnyPublisher()
    } else {
      return loadDefault()
    }
  }

  func save(trips: [Trip]) {
    let envelope = Envelope(trips: trips)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(envelope)
    try! data.write(to: localFile)
  }

  private func loadSynchronously(_ file: URL) -> [Trip] {
    do {
      let data = try Data(contentsOf: file)
      let envelope = try JSONDecoder().decode(Envelope.self, from: data)
      return envelope.trips
    } catch {
      clear()
      return loadSynchronously(defaultFile)
    }
  }

  private func load(_ file: URL, completion: @escaping ([Trip]) -> Void) {
    DispatchQueue.global(qos: .background).async {
      let trips = self.loadSynchronously(file)
      completion(trips)
    }
  }

  func loadDefault(synchronous: Bool = false) -> AnyPublisher<[Trip], Never> {
    if synchronous {
      return Just<[Trip]>(loadSynchronously(defaultFile)).eraseToAnyPublisher()
    }
    return Future<[Trip], Never> { promise in
      self.load(self.defaultFile) { trips in
        DispatchQueue.main.async {
          promise(.success(trips))
        }
      }
    }.eraseToAnyPublisher()
  }
}
