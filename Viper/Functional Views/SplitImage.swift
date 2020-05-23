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

struct SplitImage: View {
  var images: [UIImage]

  func defaultImageView() -> some View {
    Image("no_waypoints")
      .resizable()
      .aspectRatio(contentMode: .fill)
  }

  func image(for uiImage: UIImage) -> some View {
    return Image(uiImage: uiImage)
      .resizable()
      .aspectRatio(contentMode: .fill)
  }

  func oneImageView() -> some View {
    image(for: images[0])
  }

  func twoImagesView() -> some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        self.image(for: self.images[0])
          .frame(width: geometry.size.width)
          .clipShape(TopTriangle(offset: 4))
        self.image(for: self.images[1])
          .frame(width: geometry.size.width)
          .clipShape(BottomTriangle(offset: 4))
      }
    }
  }

  var body: some View {
    if images.count == 0 {
      return AnyView(defaultImageView())
    }
    if images.count == 1 {
      return AnyView(oneImageView())
    }
    return AnyView(twoImagesView())
  }
}

struct TopTriangle: Shape {
  var offset: CGFloat = 2
  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - offset))
    path.closeSubpath()
    return path
  }
}

struct BottomTriangle: Shape {
  var offset: CGFloat = 2

  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + offset))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

#if DEBUG
struct SplitImage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SplitImage(images: [])
        .frame(height: 200)
      SplitImage(images: [UIImage(named: "waypoint.0")!])
        .frame(height: 100)
      SplitImage(images: [UIImage(named: "waypoint.1")!])
        .frame(height: 100)
      SplitImage(images: [UIImage(named: "waypoint.0")!, UIImage(named: "waypoint.1")!])
        .frame(height: 100)
    }
  }
}
#endif
