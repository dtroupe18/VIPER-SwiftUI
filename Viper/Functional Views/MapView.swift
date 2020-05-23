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
import MapKit

struct MapView: UIViewRepresentable {
  var pins: [MKAnnotation] = []
  var routes: [MKRoute]?
  var center: CLLocationCoordinate2D?

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    view.removeAnnotations(view.annotations)
    view.removeOverlays(view.overlays)
    if let center = center {
      view.setRegion(MKCoordinateRegion(center: center, latitudinalMeters: 2000, longitudinalMeters: 2000), animated: true)
      view.addAnnotation( {
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        return annotation
        }())
    }
    if pins.count > 0 {
      view.addAnnotations(pins)
      view.showAnnotations(pins, animated: false)
    }
    if let routes = routes {
      routes.forEach { route in
        view.addOverlay(route.polyline, level: .aboveRoads)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
      self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }

      let lineRenderer = MKPolylineRenderer(polyline: polyline)
      lineRenderer.strokeColor = .blue
      lineRenderer.lineWidth = 3

      return lineRenderer
    }
  }
}

fileprivate class CoordinateWrapper: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D

  init(_ coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    let pins = DataModel.sample.trips[0].waypoints.map { waypoint -> MKPointAnnotation in
      let annotation = MKPointAnnotation()
      annotation.coordinate = waypoint.location
      return annotation
    }
    return Group {
      MapView(pins: pins, routes: nil, center: nil)
        .previewDisplayName("Pins")
      MapView(pins: [], routes: nil, center: CLLocationCoordinate2D.timesSquare)
        .previewDisplayName("Centered")
    }
  }
}
#endif
