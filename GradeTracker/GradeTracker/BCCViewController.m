//
//  BCCViewController.m
//  GradeTracker
//
//  Created by Briana Chapman on 9/2/14.
//  Copyright (c) 2014 Briana Chapman. All rights reserved.
//

#import "BCCViewController.h"
#import "Course.h"
#import "GradeType.h"

@interface BCCViewController () <UIPickerViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *CoursePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *GradeTypePicker;
@property (weak, nonatomic) IBOutlet UITextField *myGrade;
@property (weak, nonatomic) IBOutlet UITextField *totalPossible;
@property (strong, nonatomic) NSArray *courses;
@property (strong, nonatomic) NSArray *gradeTypes;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Course *currentCourse;
@property (strong, nonatomic) GradeType *currentGradeType;
@property (strong, nonatomic) NSMutableArray *courseData;
@property (strong, nonatomic) NSMutableArray *labels;

@end

@implementation BCCViewController

- (IBAction)doneEnteringGrade:(UIButton *)sender {
    self.currentGradeType.myPoints = [NSNumber numberWithFloat:[self.myGrade.text floatValue]];
    self.currentGradeType.totalPoints = [NSNumber numberWithFloat:[self.totalPossible.text floatValue]];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self updateGrades];
}

- (void)updateGrades {
    if (self.labels) {
        for (UILabel *label in self.labels) {
            [label removeFromSuperview];
        }
    } else {
        self.labels = [[NSMutableArray alloc] init];
    }
    for (NSInteger i = 0; i<[self.courseData count]; i++) {
        UILabel *courseGrade = [[UILabel alloc] initWithFrame:CGRectMake(20, 288 + 31*i, 222, 21)];
        NSInteger percentGrade = 0;
        
        for (GradeType *grade in [self.courseData[i] gradesForClass]) {
            if ([grade.totalPoints floatValue] != 0) {
                percentGrade += [grade.percent floatValue] * ([grade.myPoints floatValue]/[grade.totalPoints floatValue]);
            }
        }
        
        NSString *shortName = [[self.courseData[i] name] substringToIndex:MIN([[self.courseData[i] name] length], 18)];
        if (shortName.length >= 18) {
            shortName = [shortName stringByAppendingString:@"..."];
        }
        courseGrade.text = [NSString stringWithFormat:@"%@: %d%%", shortName, percentGrade];
        [self.view addSubview:courseGrade];
        [self.labels addObject:courseGrade];
    }
}
- (Course *)currentCourse {
    NSInteger selectedCourse = [self.CoursePicker selectedRowInComponent:0];
    return self.courseData[selectedCourse];
}

- (GradeType *)currentGradeType {
    NSInteger selectedGradeType = [self.GradeTypePicker selectedRowInComponent:0];
    
    for (GradeType *gradeType in self.currentCourse.gradesForClass) {
        if ([gradeType.name isEqualToString:self.gradeTypes[selectedGradeType]]) {
            return gradeType;
        }
    }
    
    return nil;

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.CoursePicker) {
        if (self.courseData!=nil) {
            return [self.courseData count];
        }
    }
    
    if (pickerView == self.GradeTypePicker) {
        if (self.gradeTypes != nil) {
            return [self.gradeTypes count];
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.CoursePicker) {
        if (self.courseData!=nil) {
            return [[self.courseData objectAtIndex:row] name];
        }
    }
    
    if (pickerView == self.GradeTypePicker) {
        if (self.gradeTypes != nil) {
            return [self.gradeTypes objectAtIndex:row];
        }
    }
    return nil;
}

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.Store"];
    
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]]) {
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"Store"];
        if (defaultStoreURL) {
            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
        }
    }
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSArray *)courseData {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Course"
                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    _courseData = [[NSMutableArray alloc] init];
    _courseData = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    return _courseData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.myGrade becomeFirstResponder]; 
    self.gradeTypes = @[@"quiz", @"exam", @"homework", @"extra credit", @"lab"];
    self.courses = @[@"Algorithms and Models of Computation", @"The Teenage Years", @"System Programming", @"Human Factors", @"Social Cognition"];
    
    if ([self.courseData count] != [self.courses count]) {
        for (NSInteger i = 0; i < [self.courses count]; i++) {
            Course *currentCourse = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            currentCourse.name = self.courses[i];
            NSMutableSet *gradeCategories = [[NSMutableSet alloc] init];
            for (NSInteger j = 0; j < [self.gradeTypes count]; j++) {
                GradeType *emptyGrade = [NSEntityDescription insertNewObjectForEntityForName:@"GradeType" inManagedObjectContext:self.managedObjectContext];
                /*
                 *  The percent property determines the percent of the final grade that this grade
                 *  type determines. So, for instance, if quizzes make up 20% of the final grade,
                 *  percent == 20. In this case, all categories are counted evenly and it is a challenge
                 *  for you to figure out how to make it weight grades appropriately.
                 */
                emptyGrade.percent = [NSNumber numberWithInteger:(NSInteger)((1.0/[self.gradeTypes count]) * 100)];
                emptyGrade.myPoints = [NSNumber numberWithInteger:0];
                emptyGrade.totalPoints = [NSNumber numberWithInteger:0];
                emptyGrade.name = self.gradeTypes[j];
                [gradeCategories addObject:emptyGrade];
            }
            currentCourse.gradesForClass = gradeCategories;
            self.courseData[i] = currentCourse;
        }
    }
    
    [self updateGrades];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
