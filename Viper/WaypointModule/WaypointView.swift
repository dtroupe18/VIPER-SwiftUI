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
import CoreLocation
import MapKit

struct WaypointView: View {
  @EnvironmentObject var model: DataModel
  @Environment(\.presentationMode) var mode

  @ObservedObject var presenter: WaypointViewPresenter

  init(presenter: WaypointViewPresenter) {
    self.presenter = presenter
  }

  func applySuggestion() {
    presenter.didTapUseThis()
    mode.wrappedValue.dismiss()
  }

  var body: some View {
    return
      VStack{
        VStack {
          TextField("Type an Address", text: $presenter.query)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          HStack {
            Text(presenter.info)
            Spacer()
            Button(action: applySuggestion) {
              Text("Use this")
            }.disabled(!presenter.isValid)
          }

        }.padding([.horizontal])
        MapView(center: presenter.location)
      }.navigationBarTitle(Text(""), displayMode: .inline)
  }
}

#if DEBUG
struct WaypointView_Previews: PreviewProvider {
  static var previews: some View {
    let model = DataModel.sample
    let waypoint = model.trips[0].waypoints[0]
    let provider = RealMapDataProvider()

    return
      Group {
        NavigationView {
          WaypointView(presenter: WaypointViewPresenter(waypoint: waypoint, interactor: WaypointViewInteractor(waypoint: waypoint, mapInfoProvider: provider)))
            .environmentObject(model)
        }.previewDisplayName("Detail")
        NavigationView {
          WaypointView(presenter: WaypointViewPresenter(waypoint: Waypoint(), interactor: WaypointViewInteractor(waypoint:  Waypoint(), mapInfoProvider: provider)))
            .environmentObject(model)
            .previewDisplayName("New")
        }
    }
  }
}
#endif
