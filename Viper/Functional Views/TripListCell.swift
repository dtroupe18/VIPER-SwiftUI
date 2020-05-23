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

struct TripListCell: View {
  let imageProvider: ImageDataProvider = PixabayImageDataProvider() // this could be injected in the future
  @ObservedObject var trip: Trip

  @State private var images: [UIImage] = []
  @State private var cancellable: AnyCancellable?

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottomLeading) {
        SplitImage(images: self.images)
          .frame(width: geometry.size.width, height: geometry.size.height)
        BlurView()
          .frame(width: geometry.size.width, height: 42)
        Text(self.trip.name)
          .font(.system(size: 32))
          .fontWeight(.bold)
          .foregroundColor(.white)
          .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
      }
      .cornerRadius(12)
    }.onAppear() {
      self.cancellable = self.imageProvider.getEndImages(for: self.trip).assign(to: \.images, on: self)
    }
  }
}

#if DEBUG
struct TripListCell_Previews: PreviewProvider {
  static var previews: some View {
    let model = DataModel.sample
    let trip = model.trips[0]
    return TripListCell(trip: trip)
      .frame(height: 160)
      .environmentObject(model)
  }
}
#endif

struct BlurView: UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(blurView, at: 0)
    NSLayoutConstraint.activate([
      blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
      blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])
    return view
  }

  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {
  }
}
