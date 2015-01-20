//
//  AppDelegate.m
//  FMDB+SQLCypher
//
//  Created by EduardoUrso on 1/20/15.
//  Copyright (c) 2015 EduardoUrso. All rights reserved.
//

#import "AppDelegate.h"
#import <sqlite3.h>

@interface AppDelegate ()
@property (strong, nonatomic) NSString *databasePath;
@end

@implementation AppDelegate


- (void)createAndCheckDatabase
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.databasePath];
    
    if(success) return; // If file exists, don't do anything
    
    // if file does not exist, make a copy of the one in the Resources folder
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"myBeautifulDatabase.sqlite"]; // File path

    // Make a copy of the file in the Documents folder
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
    
    
    // Set the new encrypted database path to be in the Documents Folder
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *ecDB = [documentDir stringByAppendingPathComponent:@"encrypted.sqlite"];
    
    // SQL Query. NOTE THAT DATABASE IS THE FULL PATH NOT ONLY THE NAME
    const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY 'secretKey';",ecDB] UTF8String];
    
    sqlite3 *unencrypted_DB;
    if (sqlite3_open([self.databasePath UTF8String], &unencrypted_DB) == SQLITE_OK) {
        
        // Attach empty encrypted database to unencrypted database
        sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, NULL);
        
        // export database
        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        
        // Detach encrypted database
        sqlite3_exec(unencrypted_DB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
        
        sqlite3_close(unencrypted_DB);
    }
    else {
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(unencrypted_DB));
    }
    
    self.databasePath = [documentDir stringByAppendingPathComponent:@"encrypted.sqlite"];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:@"myBeautifulDatabase.sqlite"];
    
    [self createAndCheckDatabase];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
