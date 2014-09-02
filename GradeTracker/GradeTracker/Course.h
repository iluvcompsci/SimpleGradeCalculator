//
//  Course.h
//  GradeTracker
//
//  Created by Briana Chapman on 9/2/14.
//  Copyright (c) 2014 Briana Chapman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GradeType;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *gradesForClass;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addGradesForClassObject:(GradeType *)value;
- (void)removeGradesForClassObject:(GradeType *)value;
- (void)addGradesForClass:(NSSet *)values;
- (void)removeGradesForClass:(NSSet *)values;

@end
