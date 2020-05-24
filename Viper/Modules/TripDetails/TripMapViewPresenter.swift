/// Copyright (c) 2020 Dave Troupe
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

import MapKit
import Combine

/*
 Here, the map presenter exposes two arrays to hold annotations and routes. In init(interactor:),
 you map the waypoints from the interactor to MKPointAnnotation objects so that they can be
 displayed as pins on the map. You then copy the directions to the routes array.
 */
class TripMapViewPresenter: ObservableObject {
  @Published var pins: [MKAnnotation] = []
  @Published var routes: [MKRoute] = []

  let interactor: TripDetailsInteractor
  private var cancellables = Set<AnyCancellable>()

  init(interactor: TripDetailsInteractor) {
    self.interactor = interactor

    interactor.$waypoints
      .map {
        $0.map {
          let annotation = MKPointAnnotation()
          annotation.coordinate = $0.location
          return annotation
        }
    }
    .assign(to: \.pins, on: self)
    .store(in: &cancellables)

    interactor.$directions
      .assign(to: \.routes, on: self)
      .store(in: &cancellables)
  }
}

