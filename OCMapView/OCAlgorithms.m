//
//  OCAlgorythms.m
//  openClusterMapView
//
//  Created by Botond Kis on 15.07.11.
//

#import "OCAlgorithms.h"
#import "OCAnnotation.h"
#import "OCDistance.h"
#import "OCGrouping.h"

@implementation OCAlgorithms

// Bubble clustering with iteration
+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
{
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
	// Clustering
	for (id <MKAnnotation> annotation in annotationsToCluster)
    {
		// Find fitting existing cluster
		BOOL foundCluster = NO;
        for (OCAnnotation *clusterAnnotation in clusteredAnnotations) {
            // If the annotation is in range of the cluster, add it
            if ((CLLocationCoordinateDistance([annotation coordinate], [clusterAnnotation coordinate]) <= radius)) {
         
                foundCluster = YES;
                [clusterAnnotation addAnnotation:annotation];
                break;
            }
        }
        
        // If the annotation wasn't added to a cluster, create a new one
        if (!foundCluster){
            OCAnnotation *newCluster = [[OCAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
        }
	}
    
    // whipe all empty or single annotations
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (OCAnnotation *anAnnotation in clusteredAnnotations) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1){
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}


// Grid clustering with predefined size
+ (NSArray*)gridClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRect:(MKCoordinateSpan)tileRect
{
    NSMutableDictionary *clusteredAnnotations = [[NSMutableDictionary alloc] init];
    
    // iterate through all annotations
	for (id<MKAnnotation> annotation in annotationsToCluster)
    {
        // calculate grid coordinates of the annotation
        NSInteger row = ([annotation coordinate].longitude+180.0)/tileRect.longitudeDelta;
        NSInteger column = ([annotation coordinate].latitude+90.0)/tileRect.latitudeDelta;
        NSString *key = [NSString stringWithFormat:@"%d%d",row,column];
        
        // get the cluster for the calculated coordinates
        OCAnnotation *clusterAnnotation = [clusteredAnnotations objectForKey:key];
        
        // if there is none, create one
        if (clusterAnnotation == nil) {
            clusterAnnotation = [[OCAnnotation alloc] init];
            
            CLLocationDegrees lon = row * tileRect.longitudeDelta + tileRect.longitudeDelta/2.0 - 180.0;
            CLLocationDegrees lat = (column * tileRect.latitudeDelta) + tileRect.latitudeDelta/2.0 - 90.0;
            CLLocationCoordinate2D cllocation;
            cllocation.latitude = lat;
            cllocation.longitude = lon;
            
            clusterAnnotation.coordinate = cllocation;
           
            [clusteredAnnotations setValue:clusterAnnotation forKey:key];
        }
        
        // add annotation to the cluster
        [clusterAnnotation addAnnotation:annotation];
	}
    
    // return array
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    // add single annotations directly without OCAnnotation
    for (OCAnnotation *anAnnotation in [clusteredAnnotations allValues]) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1) {
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}

@end
