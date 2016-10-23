//
//  ProductSearchViewController.swift
//  VendingDemo
//
//  Created by Cristina Escalante on 10/22/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import Moya
import CoreLocation
import MapKit

let CellIdentifier = "SearchCell"
let images = [#imageLiteral(resourceName: "Vending-1"), #imageLiteral(resourceName: "Vending-2"), #imageLiteral(resourceName: "Vending-3"), #imageLiteral(resourceName: "Vending-4")]
let regionRadius: CLLocationDistance = 1000

enum SegueIdentifiers {
    static let pairingSegue = "pairingSegue"
}


class ProductSearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pairingButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var nearbyMachines = [Machine]() {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            for machine in nearbyMachines {
                let machineAnnotation = MachineAnnotation(machine: machine)
                mapView.addAnnotation(machineAnnotation)
            }
        }
    }
    
    var selectedMachine: Machine! {
        didSet {
            collectionView.reloadData()
        }
    }

    var nearbyMachineRequest: Cancellable?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchNearbyMachines(query: String = "", force: Bool = false) {
        guard let currentLocation = currentLocation else {
            return
        }

        if let request = nearbyMachineRequest, request.cancelled {
            if force {
                request.cancel()
            } else {
                return
            }
        }

        let latitude = Float(currentLocation.coordinate.latitude)
        let longitude = Float(currentLocation.coordinate.longitude)

        nearbyMachineRequest = UnattendedRetailProvider.request(.nearbyMachines(latitude: Float(latitude), longitude: Float(longitude), query: query)) { [unowned self] result in
            switch result {
            case let .success(response):
                do {
                    print(response)
                    self.nearbyMachines = try response.mapArray(type: Machine.self)
                } catch {
                    self.showAlert(title: "Nearby machines", message: "Unable to fetch from server")
                }
            case let .failure(error):
                switch error {
                case .underlying(let nsError):
                    self.showAlert(title: "Nearby machines", message: nsError.localizedDescription)
                    break
                default:
                    guard let error = error as? CustomStringConvertible else {
                        return
                    }
                    self.showAlert(title: "Nearby machines", message: error.description)
                }
            }
        }
    }
    
    func refresh() {
//        if Settings.sharedInstance.useMobileLocation {
            locationManager.requestLocation()
//        } else {
//            locationManager(locationManager, didUpdateLocations: [Settings.sharedInstance.stubbedLocation])
//        }
    }

    func showAlert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        present(vc, animated: true, completion: nil)
    }
}

// MARK: - Core location methods
extension ProductSearchViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            refresh()
        case .denied, .restricted:
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
            showAlert(title: "Location Error!", message: "Location permission is required to find nearby machines. Go to 'Settings -> \(appName) -> Location' and select 'While Using the App'")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        currentLocation = location
        centerMapOnLocation(location: currentLocation!)
        fetchNearbyMachines()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Location manager failed with error: \(error)")
        showAlert(title: "Location Error!", message: "Cannot determine your location. Please try again.")
//        hideLoadingView()
    }
}


// MARK: - MapKit Helpers
extension ProductSearchViewController {
    func centerMapOnLocation(location: CLLocation) {
        guard let mapView = mapView else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.centerMapOnLocation(location: location)
            }
            return
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
}

// MARK: - MapKit Data Source
extension ProductSearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let machineAnnotation = view.annotation as? MachineAnnotation else { return }
        selectedMachine = machineAnnotation.machine
    }
}


// MARK: - IBActions
extension ProductSearchViewController {
    @IBAction private func readyPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: SegueIdentifiers.pairingSegue, sender: self)
    }
}


// MARK: - Life Cycle
extension ProductSearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case SegueIdentifiers.pairingSegue:
            guard let pairingViewController = segue.destination as? PairingViewController else { return }
            guard let machineAnnotation = mapView.selectedAnnotations.first as? MachineAnnotation else { return }
            guard let machine = machineAnnotation.machine else { return }
            pairingViewController.machine = machine
        default:
            return
        }
    }
}


// MARK: - CollectionView Data Source
extension ProductSearchViewController: UICollectionViewDataSource {
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedMachine = selectedMachine else { return 0 }
        return selectedMachine.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        // Configure the cell
        let product = selectedMachine.products[indexPath.row] as Product!
        cell.configureCell(product: product)
        return cell
    }

}


// MARK: - CollectionView Delegate
extension ProductSearchViewController: UICollectionViewDelegate {
    
}


// MARK: - Search Bar Delegate
extension ProductSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text?.characters.count == 0 {
            fetchNearbyMachines()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text else {
            fetchNearbyMachines()
            return
        }
        fetchNearbyMachines(query: query)
    }
}

// MARK: - Cell
class VendingCell: UITableViewCell {
    @IBOutlet weak var machineImageView: UIImageView!
    @IBOutlet weak var machineNameLabel: UILabel!
    @IBOutlet weak var machineDistanceLabel: UILabel!
    @IBOutlet weak var machineAddressLabel: UILabel!
    
    func configureCell(machine: Machine, image: UIImage) {
        machineNameLabel.text = machine.name
        machineDistanceLabel.text = machine.formatDistance()
        machineAddressLabel.text = machine.address
        machineImageView.image = image
    }
}

