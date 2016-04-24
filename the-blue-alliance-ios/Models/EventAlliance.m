//
//  EventAlliance.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "EventAlliance.h"
#import "Event.h"

@implementation EventAlliance

@dynamic declines;
@dynamic picks;
@dynamic allianceNumber;
@dynamic event;

+ (instancetype)insertEventAllianceWithModelEventAlliance:(TBAEventAlliance *)modelEventAlliance withAllianceNumber:(int)number forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@ AND allianceNumber == %@", event, @(number)];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(EventAlliance *eventAlliance) {
        eventAlliance.picks = modelEventAlliance.picks;
        eventAlliance.declines = modelEventAlliance.declines;
        eventAlliance.event = event;
        eventAlliance.allianceNumber = @(number);
    }];
}

+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray<TBAEventAlliance *> *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < modelEventAlliances.count; i++) {
        TBAEventAlliance *eventAlliance = [modelEventAlliances objectAtIndex:i];
        [arr addObject:[self insertEventAllianceWithModelEventAlliance:eventAlliance withAllianceNumber:(i + 1) forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}


@end
