//
//  CoreData.m
//  BankHelper
//
//  Created by popeveryday on 4/21/13.
//  Copyright (c) 2013 Best4U. All rights reserved.
//

#import "CoreData.h"

@implementation CoreData

@synthesize ManagedObjectContext = _ManagedObjectContext;
@synthesize ManagedObjectModel = _ManagedObjectModel;
@synthesize PersistentStoreCoordinator = _PersistentStoreCoordinator;

@synthesize ModelName = _ModelName;
@synthesize SqlFileName = _SqlFileName;

//---------------------------------------------------------------------------------------------------------------
-(NSManagedObjectContext*)managedObjectContext
{
    if (_ManagedObjectContext != nil) {
        return _ManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self PersistentStoreCoordinator];
    if (coordinator != nil) {
        _ManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_ManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _ManagedObjectContext;
}

-(NSManagedObjectModel*)managedObjectModel
{
    if (_ManagedObjectModel != nil) {
        return _ManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_ModelName withExtension:@"momd"];
    _ManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _ManagedObjectModel;
}

-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_PersistentStoreCoordinator != nil) {
        return _PersistentStoreCoordinator;
    }
    
    
    NSURL *embedURL = [FileLib getEmbedResourceURLWithFilename:_SqlFileName];
    NSURL *storeURL = [FileLib getLibraryURL:_SqlFileName];
    
    if ([FileLib checkPathExisted:[embedURL path]] && ![FileLib checkPathExisted:[storeURL path]])
    {
        [FileLib copyFileFromPath:[embedURL path] toPath:[storeURL path]];
    }
    
    
    NSError *error = nil;
    _PersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self ManagedObjectModel]];
    
    //for migration database
    NSDictionary* migrationOption = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_PersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:migrationOption error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _PersistentStoreCoordinator;
}
//---------------------------------------------------------------------------------------------------------------
static CoreData* instance;

+(CoreData*)instance
{
    if (instance == nil) {
        instance = [[CoreData alloc] initCoreDataModel:@"Model" sqlFileName:@"model.sqlite"];
    }
    
    return instance;
}

+(CoreData*)initInstanceDataModel:(NSString*)modelName  sqlFileName:(NSString*)sqlFileName
{
    instance = [[CoreData alloc] initCoreDataModel:modelName sqlFileName:sqlFileName];
    return instance;
}



+(NSExpressionDescription*)buildSearchExpressionForField:(NSString*) field function:(FunctionExpression) function expressionName:(NSString*) name resultType: (NSAttributeType) resultType{
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:field];
    
    NSString* func = @"";
    
    switch (function) {
        case min:
            func = @"min";
            break;
        case sum:
            func = @"sum";
            break;
        case max:
            func = @"max";
            break;
        case average:
            func = @"average";
            break;
        case count:
            func = @"count";
            break;
            
    }
    
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression *minExpression = [NSExpression expressionForFunction: [func stringByAppendingString:@":"]
                                                            arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName: name ];
    [expressionDescription setExpression:minExpression];
    [expressionDescription setExpressionResultType:resultType];
    
    return expressionDescription;
}


//---------------------------------------------------------------------------------------------------------------

-(id)initCoreDataModel:(NSString*)modelName  sqlFileName:(NSString*)sqlFileName
{
    _ModelName = modelName;
    _SqlFileName = sqlFileName;
    return self;
}

-(ReturnSet*)searchTable:(NSString*) table filter:(NSString*) filter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType
{
    return [self searchTable:table predicatefilter:[NSPredicate predicateWithFormat:filter] sortField:sortField sortAscending:asc searchExpressionArray:searchExpression resultType:resultType];
}

-(ReturnSet*)searchTable:(NSString*) table predicatefilter:(NSPredicate*) predicatefilter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType
{
    return [self searchTable:table predicatefilter:predicatefilter sortField:sortField sortAscending:asc searchExpressionArray:searchExpression resultType:resultType limit:0 offset:0];
}

-(ReturnSet*)searchTable:(NSString*) table predicatefilter:(NSPredicate*) predicatefilter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType limit:(NSUInteger)limit offset:(NSUInteger) offset
{
    NSManagedObjectContext *context = [self ManagedObjectContext];
    
    // Construct a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (predicatefilter != nil) {
        [fetchRequest setPredicate:predicatefilter];
    }
    
    // Add an NSSortDescriptor to sort the labels alphabetically
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField ascending:asc];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setResultType:resultType];
    
    if (searchExpression != nil) {
        [fetchRequest setPropertiesToFetch:searchExpression];
    }
    
    if (limit > 0) {
        [fetchRequest setFetchLimit:limit];
    }
    
    if (offset > 0) {
        [fetchRequest setFetchOffset:offset];
    }
    
    
    NSError *error = nil;
    NSArray* result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error){
        NSString* message = [NSString stringWithFormat:@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]];
        NSLog(@"%@", message);
        return [[ReturnSet alloc] initWithMessage:NO message:message];
    }
    
    return [[ReturnSet alloc] initWithObject:YES object:result ];
}

-(ReturnSet*)searchTable:(NSString*) table sortField:(NSString*)sortField sortAscending:(BOOL) asc{
    return [self searchTable:table filter:nil sortField:sortField sortAscending:asc searchExpressionArray:nil resultType:NSManagedObjectResultType];
}

-(ReturnSet*)searchTable:(NSString*) table filter:(NSString*) filter sortField:(NSString*)sortField sortAscending:(BOOL) asc{
    return [self searchTable:table filter:filter sortField:sortField sortAscending:asc searchExpressionArray:nil resultType:NSManagedObjectResultType];
}


-(id)insertTable:(NSString*) table
{
    NSManagedObjectContext *context = [self ManagedObjectContext];
    
    // Grab the Label entity
    return [NSEntityDescription insertNewObjectForEntityForName:table inManagedObjectContext:context];
    
}


-(void)deleteRecord:(id) record
{
    [_ManagedObjectContext deleteObject:record];
}


-(ReturnSet*)saveChange{
    NSError *error;
    [_ManagedObjectContext save:&error];
    
    if (error){
        NSString* message = [NSString stringWithFormat:@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]];
        NSLog(@"%@", message);
        return [[ReturnSet alloc] initWithMessage:NO message:message];
    }
    
    return [[ReturnSet alloc] initWithResult:YES];
}

-(NSManagedObjectContext*)getEntity
{
    return [self ManagedObjectContext];
}

@end

