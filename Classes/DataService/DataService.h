//
//  DataService.h
//  OnlySimchas
//
//  Created by Matt Ripston on 9/27/11.
//  Copyright 2011 RustyBrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataService : NSObject{
    NSString *urlPrefix;
    NSString *authToken;
    NSString *userName;
    NSString *userID;
    
}
-(BOOL)loginWithUserName:(NSString*)userName password:(NSString*)password;
-(BOOL)signupWithUserName:(NSString *)username password:(NSString *)pass retypedPassword:(NSString *)pass2 emailAddress:(NSString *)email didAgreeToMembership:(BOOL)agreeMembership getNewsletter:(BOOL) newsletter;
-(BOOL)checkIfLoggedIn;
-(void)saveLogin:(NSDictionary *)dict;
-(NSDictionary *)getLogin;
-(void)saveAuthUserName:(NSString *)u withUserID:(NSString *)_id andAuthToken:(NSString *)token;
-(NSDictionary *)getAuthInfo;

-(NSDictionary *)getSimchaCategories;
-(NSDictionary *)getSimchaTypes;
-(NSDictionary *)getSimchaList:(NSString *)name atStartRow:(int)s;
-(NSDictionary *)getSimchaDetails:(int )simchaid;

-(NSDictionary *)getSimchaMessages:(int )simchaid maxRows:(int )m startRow:(int )s;

-(NSDictionary *)doSearchAtstartRow:(int )sr withSearchTerm:(NSString *)term;

-(BOOL)addComment:(int )simchaID message:(NSString *)m;
-(BOOL)deleteComment:(int )simchaID messageId:(int )messageid;

-(NSDictionary *)getPhotos:(int )simchaid;
-(BOOL)PhotoUpload:(int )galleryID withPhoto:(UIImage *)photo;

-(BOOL)addFavorite:(int )simchaID;
-(BOOL)deleteFavorite:(int )simchaID;
-(NSDictionary *)getFavorites;

-(NSDictionary *)getMySimchas;

+ (DataService*)sharedDataService;
@end
