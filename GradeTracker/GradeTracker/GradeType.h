//
//  GradeType.h
//  GradeTracker
//
//  Created by Briana Chapman on 9/2/14.
//  Copyright (c) 2014 Briana Chapman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface GradeType : NSManagedObject

@property (nonatomic, retain) NSNumber * myPoints;
@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) NSNumber * percent;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Course *classForGrade;

@end
