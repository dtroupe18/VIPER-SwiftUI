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

import SwiftUI
import Combine

class TripDetailsPresenter: ObservableObject {
  private let interactor: TripDetailsInteractor
  private let router: TripDetailRouter

  private var cancellables = Set<AnyCancellable>()

  // These provide the hooks for the view to read and set the trip name.
  @Published var tripName: String = "No name"
  @Published var distanceLabel: String = "Calculating..."
  @Published var waypoints: [Waypoint] = []

  let setTripName: Binding<String>

  init(interactor: TripDetailsInteractor) {
    self.interactor = interactor
    self.router = TripDetailRouter(mapProvider: interactor.mapInfoProvider)

    // 1
    setTripName = Binding<String>(
      get: { interactor.tripName },
      set: { interactor.setTripName($0) }
    )

    // 2
    interactor.tripNamePublisher
      .assign(to: \.tripName, on: self)
      .store(in: &cancellables)

    /*
     This code:

     [1] Creates a binding to set the trip name. The TextField will use this in the
     view to be able to read and write from the value.

     [2] Assigns the trip name from the interactor’s publisher to the tripName property
     of the presenter. This keeps the value synchronized.

     Separating the trip name into properties like this allows you to synchronize
     the value without creating an infinite loop of updates.
     */

    interactor.$totalDistance
      .map { "Total Distance: " + MeasurementFormatter().string(from: $0) }
      .replaceNil(with: "Calculating...")
      .assign(to: \.distanceLabel, on: self)
      .store(in: &cancellables)

    interactor.$waypoints
      .assign(to: \.waypoints, on: self)
      .store(in: &cancellables)

  }

  func save() {
    interactor.save()
  }

  func makeMapView() -> some View {
     TripMapView(presenter: TripMapViewPresenter(interactor: interactor))
  }

  func addWaypoint() {
    interactor.addWaypoint()
  }

  func didMoveWaypoint(fromOffsets: IndexSet, toOffset: Int) {
    interactor.moveWaypoint(fromOffsets: fromOffsets, toOffset: toOffset)
  }

  func didDeleteWaypoint(_ atOffsets: IndexSet) {
    interactor.deleteWaypoint(atOffsets: atOffsets)
  }

  func cell(for waypoint: Waypoint) -> some View {
    let destination = router.makeWaypointView(for: waypoint)
      .onDisappear(perform: interactor.updateWaypoints)
    return NavigationLink(destination: destination) {
      Text(waypoint.name)
    }
  }
}
