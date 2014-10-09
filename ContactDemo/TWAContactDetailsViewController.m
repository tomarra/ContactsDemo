//
//  TWAContactDetailsViewController.m
//  ContactDemo
//
//  Created by Tom Arra on 10/8/14.
//  Copyright (c) 2014 tomarra. All rights reserved.
//

#import "TWAContactDetailsViewController.h"
@import MapKit;

@interface TWAContactDetailsViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *largeImage;
@property (weak, nonatomic) IBOutlet UILabel *homePhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *homePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *workPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *workPhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLineOne;
@property (weak, nonatomic) IBOutlet UILabel *addressLineTwo;
@property (weak, nonatomic) IBOutlet UILabel *birthday;
@property (weak, nonatomic) IBOutlet UILabel *email;

@end

@implementation TWAContactDetailsViewController

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Null out all the data labels so the user doesn't see a flash of default
    //or old data
    self.nameLabel.text = @"";
    self.companyNameLabel.text = @"";
    self.largeImage.image = nil;
    self.homePhoneNumber.text = @"";
    self.workPhoneNumber.text = @"";
    self.mobilePhoneNumber.text = @"";
    self.addressLineOne.text = @"";
    self.addressLineTwo.text = @"";
    self.birthday.text = @"";
    self.email.text = @"";
    
    //Set the labels for the data that we have
    self.nameLabel.text = self.contactListResponse.name;
    self.companyNameLabel.text = self.contactListResponse.company;
    self.homePhoneNumber.text = self.contactListResponse.phone.home;
    self.workPhoneNumber.text = self.contactListResponse.phone.work;
    self.mobilePhoneNumber.text = self.contactListResponse.phone.mobile;
    
    //Make a simple but nice looking birthday string to be shown
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    NSDate *birthdayDate = [NSDate dateWithTimeIntervalSince1970:[self.contactListResponse.birthdate integerValue]];
    NSString *brithdayString = [dateFormatter stringFromDate:birthdayDate];
    self.birthday.text = brithdayString;
    
    //Simple title First Name + First Letter of Last Name
    NSArray *nameChunks = [self.contactListResponse.name componentsSeparatedByString: @" "];
    NSString *nameForTitleBar = [NSString stringWithFormat:@"%@ %c", nameChunks[0], [nameChunks[1] characterAtIndex:0]];
    self.navigationItem.title = nameForTitleBar;
    
    [self getContactDetailsFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)mapButtonClicked:(id)sender {
    
    MKPlacemark *pl = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) addressDictionary:nil];
    MKMapItem *mi = [[MKMapItem alloc] initWithPlacemark:pl];
    mi.name = self.navigationItem.title;
    [mi openInMapsWithLaunchOptions:nil];
}

#pragma mark - API Call

- (void) getContactDetailsFromServer
{
    NSString *requestString = self.contactListResponse.detailsURL;
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    [req setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                        if (error){
                            NSLog(@"General Error: %@", error.description);
                            return;
                        }
                        
                        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                            
                            if (statusCode == 200) {
                                NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:nil];
                                [self updateViewWithDetailData:jsonObject];
                                return;
                            }
                        }
                    }];
    
    [dataTask resume];
}

- (void) updateViewWithDetailData:(NSDictionary *)jsonDataObject
{
    NSString *imageUrl = jsonDataObject[@"largeImageURL"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.largeImage.image = [UIImage imageWithData:data];
    }];

    NSDictionary *addressObject = jsonDataObject[@"address"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.email.text = jsonDataObject[@"email"];
        self.addressLineOne.text = addressObject[@"street"];
        self.addressLineTwo.text = [NSString stringWithFormat:@"%@ %@, %@", addressObject[@"city"], addressObject[@"state"], addressObject[@"zip"]];
        self.latitude = [addressObject[@"latitude"] doubleValue];
        self.longitude = [addressObject[@"longitude"] doubleValue];
        
        if([jsonDataObject[@"favorite"] boolValue] == YES) {
            UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Favorite"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
            self.navigationItem.rightBarButtonItem = favoriteButton;
        }
    });
}

@end
