// Copyright (c) 2015 RAMBLER&Co
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import <MagicalRecord/MagicalRecord.h>

#import "ManagedObjectMapper.h"
#import "ManagedObjectMappingProvider.h"
#import "ResultsResponseObjectFormatter.h"
#import "EntityNameFormatterImplementation.h"

#import "SocialNetworkAccountManagedObject.h"
#import "EventManagedObject.h"
#import "MetaEventManagedObject.h"
#import "TechManagedObject.h"
#import "NetworkingConstantsHeader.h"

@interface ManagedObjectMapperTests : XCTestCase

@property (strong, nonatomic) ManagedObjectMapper *mapper;

@end

@implementation ManagedObjectMapperTests

- (void)setUp {
    [super setUp];
    
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    ManagedObjectMappingProvider *provider = [[ManagedObjectMappingProvider alloc] init];
    EntityNameFormatterImplementation *entityFormatter = [[EntityNameFormatterImplementation alloc] init];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    provider.entityNameFormatter = entityFormatter;
    provider.dateFormatter = formatter;
    self.mapper = [[ManagedObjectMapper alloc] initWithMappingProvider:provider
                                                  responseObjectFormatter:nil
                                                   entityNameFormatter:entityFormatter];
}

- (void)tearDown {
    self.mapper = nil;
    
    [MagicalRecord cleanUp];
    
    [super tearDown];
}

- (void)testThatMapperMapsEvent {
    Class targetClass = [EventManagedObject class];
    NSArray *testProperties = @[
                                NSStringFromSelector(@selector(eventId)),
                                NSStringFromSelector(@selector(name)),
                                NSStringFromSelector(@selector(startDate)),
                                NSStringFromSelector(@selector(endDate)),
                                NSStringFromSelector(@selector(metaEvent))
                                ];
    [self verifyMappingOfClass:targetClass withNonNilChecksForProperties:testProperties];
}

- (void)testThatMapperMapsMetaEvent {
    Class targetClass = [MetaEventManagedObject class];
    NSArray *testProperties = @[
                                NSStringFromSelector(@selector(metaEventId)),
                                NSStringFromSelector(@selector(metaEventDescription)),
                                NSStringFromSelector(@selector(name)),
                                NSStringFromSelector(@selector(websiteUrlPath)),
                                NSStringFromSelector(@selector(imageUrlPath))
                                ];
    [self verifyMappingOfClass:targetClass withNonNilChecksForProperties:testProperties];
}

- (void)testThatMapperMapsTech {
    Class targetClass = [TechManagedObject class];
    NSArray *testProperties = @[
                                NSStringFromSelector(@selector(techId)),
                                NSStringFromSelector(@selector(name)),
                                NSStringFromSelector(@selector(color))
                                ];
    [self verifyMappingOfClass:targetClass withNonNilChecksForProperties:testProperties];
}

#pragma mark - Helper Methods

- (void)verifyMappingOfClass:(Class)objectClass withNonNilChecksForProperties:(NSArray *)properties {
    // given
    NSDictionary *serverResponse = [self generateServerResponseForModelClass:objectClass];
    NSDictionary *mappingContext = [self generateMappingContextForModelClass:objectClass];
    
    // when
    NSArray *result = [self.mapper mapServerResponse:serverResponse
                                  withMappingContext:mappingContext
                                               error:nil];
    id firstObject = [result firstObject];
    
    // then
    XCTAssertEqual(result.count, 1);
    XCTAssertTrue([firstObject isKindOfClass:objectClass]);
    for (NSString *property in properties) {
        SEL propertySelector = NSSelectorFromString(property);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        XCTAssertNotNil([firstObject performSelector:propertySelector]);
#pragma clang diagnostic pop
    }
}

- (NSDictionary *)generateMappingContextForModelClass:(Class)modelClass {
    NSString *className = NSStringFromClass(modelClass);
    return @{
             kMappingContextModelClassKey : className
             };
}

- (NSDictionary *)generateServerResponseForModelClass:(Class)modelClass {
    Class testCaseClass = [self class];
    
    NSString *bundleName = NSStringFromClass(testCaseClass);
    NSString *modelName = NSStringFromClass(modelClass);
    NSString *fileName = [NSString stringWithFormat:@"%@.json", modelName];
    
    NSBundle *resourceBundle = [NSBundle bundleForClass:testCaseClass];
    
    NSString *pathToTestBundle = [resourceBundle pathForResource:bundleName ofType:@"bundle"];
    NSBundle *testBundle = [NSBundle bundleWithPath:pathToTestBundle];
    
    NSString *pathToFile = [[testBundle resourcePath] stringByAppendingPathComponent:fileName];
    NSData *responseData = [NSData dataWithContentsOfFile:pathToFile
                                                  options:0
                                                    error:nil];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:nil];
    
    return json;
}

@end
