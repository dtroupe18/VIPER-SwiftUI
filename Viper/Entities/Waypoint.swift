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

import Combine
import CoreLocation
import MapKit

final class Waypoint {
  @Published var name: String
  @Published var location: CLLocationCoordinate2D
  var id: UUID

  init() {
    id = UUID()
    name = "Times Square"
    location = CLLocationCoordinate2D.timesSquare
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    location = try container.decode(CLLocationCoordinate2D.self, forKey: .location)
    id = try container.decode(UUID.self, forKey: .id)
  }

  func copy() -> Waypoint {
    let new = Waypoint()
    new.name = name
    new.location = location
    return new
  }
}

extension Waypoint: Equatable {
  static func == (lhs: Waypoint, rhs: Waypoint) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Waypoint: CustomStringConvertible {
  var description: String { name }
}

extension Waypoint: Codable {
  enum CodingKeys: CodingKey {
    case name
    case location
    case id
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(location, forKey: .location)
    try container.encode(id, forKey: .id)
  }
}

extension Waypoint: Identifiable {}

extension Waypoint {
  var mapItem: MKMapItem {
    return MKMapItem(placemark: MKPlacemark(coordinate: location))
  }
}

extension CLLocationCoordinate2D: Codable {
  public init(from decoder: Decoder) throws {
    let representation = try decoder.singleValueContainer().decode([String:CLLocationDegrees].self)
    self.init(latitude: representation["latitude"] ?? 0, longitude:  representation["longitude"] ?? 0)
  }

  public func encode(to encoder: Encoder) throws {
    let representation = ["latitude": self.latitude, "longitude": self.longitude]
    try representation.encode(to: encoder)
  }
}
