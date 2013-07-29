//
//  UAGamePlayer.h
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-28.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface UAGamePlayer : NSManagedObject

@property(nonatomic, retain) NSNumber *hasAccepted;
@property(nonatomic, retain) NSString *name;


@end
