//
//  testMNILocationWeatherData.swift
//  phoenix-reader
//
//  Created by Scott Ferwerda on 3/28/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

import XCTest

class testMNILocationWeatherData: XCTestCase {
    lazy var testDataController: MNIDataController = MNIDataController(databaseName: "phoenix_reader_unit_tests.sqlite")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func paveDatastore() {
        let moc = testDataController.workerObjectContext()
        let fetchRequest = NSFetchRequest(entityName: "MNILocationWeatherData")
        fetchRequest.includesPropertyValues = false;
        var fetchedManagedObjects: [NSManagedObject]
        do {
            fetchedManagedObjects = try moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        for aManagedObject in fetchedManagedObjects {
            moc.deleteObject(aManagedObject)
        }
        fetchedManagedObjects.removeAll(keepCapacity: false)
        
        testDataController.persistWorkerMOCChanges(moc, synchronous: true, withCompletion:nil)
    }
    
    func getTestDataFromBundlePath(bundlePath: String, bundleType: String) -> [String : AnyObject]? {
        // load up the test JSON
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let filepath = bundle.pathForResource(bundlePath, ofType:bundleType)
            else {
                fatalError("Cannot find sample data in bundle")
        }
        
        guard let contentOfSampleFile = NSData(contentsOfFile: filepath)
            else {
                fatalError("Cannot read sample data file from bundle")
        }
        
        let jsonDict: [String : AnyObject]?
        // construct dictionary from sample JSON data
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(contentOfSampleFile, options: NSJSONReadingOptions.MutableContainers) as? [String : AnyObject]
        }
        catch {
            fatalError("Cannot parse sample JSON data into dictionary")
        }
        
        return jsonDict
    }
    
    // Test using core data manager. Inject database name.
    // Test ingesting JSON and making a Mantle model from it.
    func test010MakeModel() {
        guard let jsonDict = self.getTestDataFromBundlePath("testing-weather-data-raleigh", bundleType: "json")
            else {
                fatalError("Cannot load testing data as dictionary")
        }
        
        guard let datasetModel = MIWeatherDatasetForLocation(accuweatherDictionary: jsonDict)
            else {
                fatalError("Unable to construct model from sample data")
        }
        
        // check results
        XCTAssertEqual(datasetModel.locationKey, "329823", "unexpected location key")
        XCTAssertEqual(datasetModel.locationTitle, "Raleigh", "unexpected location title")
        XCTAssertEqual(datasetModel.locationTimeZoneCode, "EDT", "unexpected location timezone")
        XCTAssertEqual(datasetModel.currentConditions?.observationDateEpochTime, 1459344300, "unexpected observation date")
        guard let modelDate = datasetModel.currentConditions?.observationDate
            else {
                fatalError("missing observation NSDate")
        }
        let checkCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let checkDateComp = NSDateComponents()
        checkDateComp.year = 2016
        checkDateComp.month = 3
        checkDateComp.day = 30
        checkDateComp.timeZone = NSTimeZone(abbreviation: "EDT")
        checkDateComp.hour = 9
        checkDateComp.minute = 25
        checkDateComp.second = 0
        let checkDate = checkCalendar?.dateFromComponents(checkDateComp)
        XCTAssertEqual(checkDate!.compare(modelDate), NSComparisonResult.OrderedSame, "unexpected NSDate observation date")
        XCTAssertEqual(datasetModel.currentConditions?.observationDateISO8601, "2016-03-30T09:25:00-04:00", "unexpected ISO8601 observation date")
        XCTAssertEqual(datasetModel.currentConditions?.temperature.value, 51.0, "unexpected temperature value")
        XCTAssertEqual(datasetModel.currentConditions?.temperature.unit, "F", "unexpected temperature unit")
        XCTAssertEqual(datasetModel.dailyForecasts?.count, 10, "unexpected daily forecast count")
        XCTAssertEqual(datasetModel.hourlyForecasts?.count, 12, "unexpected hourly forecast count")
        
    }
    
    func test020MakeModelFromBadJSON() {
        guard let jsonDict = self.getTestDataFromBundlePath("testing-weather-data-BAD-raleigh", bundleType: "json")
            else {
                fatalError("Cannot load testing data as dictionary")
        }
        
        guard let datasetModel = MIWeatherDatasetForLocation(accuweatherDictionary: jsonDict)
            else {
                fatalError("Unable to construct model from sample data")
        }
        
        // check results
        XCTAssertEqual(datasetModel.locationKey, "329823", "unexpected location key")
        XCTAssertEqual(datasetModel.locationTitle, "Raleigh", "unexpected location title")
        XCTAssertEqual(datasetModel.locationTimeZoneCode, "EDT", "unexpected location timezone")
        XCTAssertEqual(datasetModel.currentConditions?.observationDateEpochTime, 1459344300, "unexpected observation date")
        guard let modelDate = datasetModel.currentConditions?.observationDate
            else {
                fatalError("missing observation NSDate")
        }
        let checkCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let checkDateComp = NSDateComponents()
        checkDateComp.year = 2016
        checkDateComp.month = 3
        checkDateComp.day = 30
        checkDateComp.timeZone = NSTimeZone(abbreviation: "EDT")
        checkDateComp.hour = 9
        checkDateComp.minute = 25
        checkDateComp.second = 0
        let checkDate = checkCalendar?.dateFromComponents(checkDateComp)
        XCTAssertEqual(checkDate!.compare(modelDate), NSComparisonResult.OrderedSame, "unexpected NSDate observation date")
        XCTAssertEqual(datasetModel.currentConditions?.observationDateISO8601, "2016-03-30T09:25:00-04:00", "unexpected ISO8601 observation date")
        XCTAssertEqual(datasetModel.currentConditions?.temperature.value, 51.0, "unexpected temperature value")
        XCTAssertEqual(datasetModel.currentConditions?.temperature.unit, "F", "unexpected temperature unit")
        XCTAssertEqual(datasetModel.dailyForecasts?.count, 10, "unexpected daily forecast count")
        XCTAssertEqual(datasetModel.hourlyForecasts?.count, 12, "unexpected hourly forecast count")
    }
    
    func test030Create() {
        
        self.paveDatastore()
        
        let moc = testDataController.workerObjectContext()
        let entityName = MNILocationWeatherData.entityName()
        
        for locationName in ["raleigh", "fresno", "kansascity"] {
            let jsonFilename = "testing-weather-data-\(locationName)"
            
            guard let jsonDict = self.getTestDataFromBundlePath(jsonFilename, bundleType: "json")
                else {
                    fatalError("Cannot load testing data as dictionary")
            }
            
            let newEntity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as! MNILocationWeatherData
            let modeled = newEntity.setMniWeatherDatasetForLocationFromDictionary(jsonDict, updateDerivedAttributes: true)
            XCTAssertTrue(modeled, "sample json data for location \(locationName) could not be modeled")
        }
        
        testDataController.persistWorkerMOCChanges(moc, synchronous: true, withCompletion: nil)
        
    }
    
    func test040Read() {
        
        let moc = testDataController.workerObjectContext()
        let entityName = MNILocationWeatherData.entityName()
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedWeatherDatasets: [MNILocationWeatherData]
        do {
            fetchedWeatherDatasets = try moc.executeFetchRequest(fetchRequest) as! [MNILocationWeatherData]
            XCTAssertEqual(fetchedWeatherDatasets.count, 3, "unexpected number of fetched weather datasets")
        }
        catch {
            fatalError("fetch of weather datasets failed")
        }
 
        let matchDict: [String: String] = [ "Raleigh": "329823", "Fresno": "327144", "Kansas City": "329441" ]

        for (aLocationName, aLocationID) in matchDict {
            let filteredFetchRequest = NSFetchRequest(entityName: entityName)
            filteredFetchRequest.predicate = NSPredicate(format: "locationName == %@", aLocationName)
            let filteredFetchedWeatherDatasets: [MNILocationWeatherData]
            do {
                filteredFetchedWeatherDatasets = try moc.executeFetchRequest(filteredFetchRequest) as! [MNILocationWeatherData]
                XCTAssertEqual(filteredFetchedWeatherDatasets.count, 1, "unexpected number of fetched weather datasets")
                
                let aDataset = filteredFetchedWeatherDatasets.first! as MNILocationWeatherData
                XCTAssertEqual(aDataset.locationName, aLocationName, "unexpected location name retrieved")
                XCTAssertEqual(aDataset.locationID, aLocationID, "unexpected location ID retrieved")
                
                // get the mantle object and check it
                guard let mantleModel = aDataset.mniWeatherDatasetForLocation
                    else {
                        fatalError("failed to construct a mantle model from dictionary");
                }
                XCTAssertEqual(mantleModel.locationKey, aLocationID, "mismatch in mantle model on location key")
                XCTAssertEqual(mantleModel.locationTitle, aLocationName, "mismatch in mantle model on location title")
            }
            catch {
                fatalError("fetch of weather datasets failed")
            }
        }
    }

    func test050Delete() {
        let moc = testDataController.workerObjectContext()
        let entityName = MNILocationWeatherData.entityName()
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPropertyValues = false
        fetchRequest.predicate = NSPredicate(format: "locationName == %@", "Fresno")
        var fetchedManagedObjects: [NSManagedObject]
        do {
            fetchedManagedObjects = try moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        }
        catch {
            fatalError("fetch of server configs failed")
        }
        
        for aManagedObject in fetchedManagedObjects {
            moc.deleteObject(aManagedObject)
        }
        fetchedManagedObjects.removeAll(keepCapacity: false)
        
        testDataController.persistWorkerMOCChanges(moc, synchronous: true, withCompletion:nil)

        
        let filteredFetchRequest = NSFetchRequest(entityName: entityName)
        filteredFetchRequest.predicate = NSPredicate(format: "locationName == %@", "Fresno")
        let filteredFetchedWeatherDatasets: [MNILocationWeatherData]
        do {
            filteredFetchedWeatherDatasets = try moc.executeFetchRequest(filteredFetchRequest) as! [MNILocationWeatherData]
            XCTAssertEqual(filteredFetchedWeatherDatasets.count, 0, "unexpected number of fetched weather datasets")
        }
        catch {
            fatalError("fetch of weather datasets failed")
        }
    }
}
