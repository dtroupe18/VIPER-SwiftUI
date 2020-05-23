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
import MapKit
import CoreLocation

protocol MapDataProvider {
  func getLocation(for address:String) -> AnyPublisher<CLPlacemark, Error>
  func directions(for waypoints:[Waypoint]) -> AnyPublisher<[MKRoute], Error>
  func totalDistance(for trip: [Waypoint]) -> AnyPublisher<Double, Never>
}

enum CustomErrors: String, Error {
  case unknown
  case noData
}

class RealMapDataProvider: MapDataProvider {
  let geocoder = CLGeocoder()

  func getLocation(for address:String) -> AnyPublisher<CLPlacemark, Error> {
    let subject = PassthroughSubject< CLPlacemark, Error>()

    geocoder.geocodeAddressString(address) { placemarks, error in
      if let placemark = placemarks?.first {
        subject.send(placemark)
        subject.send(completion: .finished)
      } else if let error = error {
        subject.send(completion: .failure(error))
      } else {
        subject.send(completion: .failure(CustomErrors.unknown))
      }
    }

    return subject
      .eraseToAnyPublisher()
  }

  func directions(for waypoints:[Waypoint]) -> AnyPublisher<[MKRoute], Error> {
    guard waypoints.count > 1 else {
      return Empty<[MKRoute], Error>().eraseToAnyPublisher()
    }

    var routePublishers: [AnyPublisher<[MKRoute], Error>] = []

    (0 ..< waypoints.count - 1).forEach { index in
      let start = waypoints[index]
      let end = waypoints[index + 1]

      let request = MKDirections.Request()
      request.transportType = .automobile
      request.source = start.mapItem
      request.destination = end.mapItem

      let directions = MKDirections(request: request)
      routePublishers.append(directions.calculate())
    }

    let allPublisher = Publishers.Sequence<[AnyPublisher<[MKRoute], Error>], Error>(sequence: routePublishers)
    return allPublisher.flatMap { $0 }
      .collect()
      .map { $0.compactMap { $0.first }} // get just the first route and make a list
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    }

  func totalDistance(for trip: [Waypoint]) -> AnyPublisher<Double, Never> {
    return directions(for: trip)
      .replaceError(with: [])
      .map { routes in
        routes.map { route in
          route.distance
        }.reduce(0, +)
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension MKDirections {
  func calculate() -> AnyPublisher<[MKRoute], Error> {
    let subject = PassthroughSubject<[MKRoute], Error>()
    calculate { response, error in
      if let routes = response?.routes {
        subject.send(routes)
        subject.send(completion: .finished)
      } else if let error = error {
        subject.send(completion: .failure(error))
      } else {
        subject.send(completion: .finished)
      }
    }
    return subject.eraseToAnyPublisher()
  }
}

extension CLLocationCoordinate2D {
  static var timesSquare: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: 40.757, longitude: -73.986)}
}
