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

/**
 This creates a presenter class that has reference to the interactor.

 Since it’s the presenter’s job to fill the view with data,
 you want to expose the list of trips from the data model.
 */
class TripListPresenter: ObservableObject {
  private let router = TripListRouter()
  private let interactor: TripListInteractor

  @Published var trips: [Trip] = []

  // This set is a place to store Combine subscriptions so their
  // lifetime is tied to the class’s. That way, any subscriptions
  // will stay active as long as the presenter is around.
  private var cancellables = Set<AnyCancellable>()

  init(interactor: TripListInteractor) {
    self.interactor = interactor

    // interactor.model.$trips creates a publisher that tracks changes
    // to the data model’s trips collection. Its values are assigned to
    // this class’s own trips collection, creating a link that keeps the
    // presenter’s trips updated when the data model changes.
    // Finally, this subscription is stored in cancellables so you can clean it up later.
    interactor.model.$trips
    .assign(to: \.trips, on: self)
    .store(in: &cancellables)
  }

  func makeAddNewButton() -> some View {
    Button(action: addNewTrip) {
      Image(systemName: "plus")
    }
  }

  // MARK: User Interactions

  func addNewTrip() {
    interactor.addNewTrip()
  }

  func deleteTrip(_ index: IndexSet) {
    interactor.deleteTrip(index)
  }

  // MARK: Navigation

  func linkBuilder<Content: View>(
    for trip: Trip,
    @ViewBuilder content: () -> Content
  ) -> some View {
    /*
     This creates a NavigationLink to a detail view the router provides.
     When you place it in a NavigationView, the link becomes a button
     that pushes the destination onto the navigation stack.

     The content block can be any arbitrary SwiftUI view.
     But in this case, the TripListView will provide a TripListCell.
     */
    NavigationLink(
      destination: router.makeDetailView(
        for: trip,
        model: interactor.model)) {
          content()
    }
  }
}

