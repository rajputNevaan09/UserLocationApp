//
//  ContentView.swift
//  UserLocationApp
//
//  Created by Bhagwan Rajput on 21/03/23.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocationUI

struct ContentView: View {
    
    @State var isPaused = false
    @State var isStopped = false
    
    @State var isTimerRunning = false
    @State var distanceCovered = 0.0
    @State var elapsedTime = 0.0
    @State var lastStartTime: Date?
    @State private var showingAlert = false
    
    
    
    
    let coreDM: CoreDataManager
    @State private var rides: [Ride] = [Ride]()
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                VStack {
                    NavigationLink(destination: MyRideRepresentable()){
                        Text("My Ride")
                    }.padding(.bottom)
                }
                HStack {
                    Text("Distance Covered: \(Constant.totalDistance, specifier: "%.2f") meters").font(.system(size: 10))
                    Text("Elapsed Time: \(elapsedTime, specifier: "%.2f") seconds").font(.system(size: 10))
                }
                MapView(isPaused: $isPaused, isStopped: $isStopped)
                    .frame(height: UIScreen.main.bounds.height - 200 )
                HStack {
                    Button(action: {
                        // Start the map view
                        isPaused = false
                        isStopped = false
                        startTimer()
                    }, label: {
                        Text("Start")
                    })
                    
                    Button(action: {
                        // Pause the map view
                        isPaused = true
                    }, label: {
                        Text("Pause")
                    })
                    Button(action: {
                        // Stop the map view
                        showingAlert = true
                        isPaused = true
                        isStopped = true
                        guard let lastStartTime = lastStartTime else { return }
                        coreDM.saveRide(date: lastStartTime, distance: Constant.totalDistance, duration: elapsedTime)
                        stopTimer()
                    }, label: {
                        Text("Stop")
                    }).alert("Your ride has been saved.", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
                
            }.onAppear(perform: {
                rides = coreDM.getAllRide()
            })
        }
    }
    
    func startTimer() {
        lastStartTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let lastStartTime = lastStartTime else { return }
            elapsedTime = Date().timeIntervalSince(lastStartTime)
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard lastStartTime != nil else { return }
            distanceCovered += 1.0
        }
    }
    
    func stopTimer() {
        lastStartTime = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(coreDM: CoreDataManager())
    }
}

struct MapView: UIViewRepresentable {
    
    @StateObject var locationManager = LocationManager()
    @Binding var isPaused: Bool
    @Binding var isStopped: Bool
    
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        guard let location = locationManager.location else { return }
        
        // Plot current location on map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
        // Plot polyline of user's previous locations
        let previousLocations = locationManager.previousLocations
        var coordinates = previousLocations.map { $0.coordinate }
        coordinates.append(location.coordinate)
        
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        if isPaused {
            mapView.showsUserLocation = false
        } else {
            mapView.showsUserLocation = true
        }
        
        if isStopped {
            mapView.showsTraffic = false
        } else {
            mapView.showsTraffic = true
        }
        
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator()
    }
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    var previousLocations: [CLLocation] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.location = location
        previousLocations.append(location)
        
        locations.forEach { location in
            // Do something with each location, like calculating the distance from a reference location
            let prevLoc = previousLocations.last
            let referenceLocation = CLLocation(latitude: prevLoc?.coordinate.latitude ?? 0.0, longitude: prevLoc?.coordinate.longitude ?? 0.0)
            Constant.totalDistance = location.distance(from: referenceLocation)
            print("Distance from reference location to \(location.coordinate) is \(Constant.totalDistance) meters")
        }
        
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            renderer.lineDashPattern = [0, 10]
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct MyRideRepresentable : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "myRideVC") as! MyRideVC
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
