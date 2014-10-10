//
//  TWAContactDetailsViewController.m
//  ContactDemo
//
//  Created by Tom Arra on 10/8/14.
//  Copyright (c) 2014 tomarra. All rights reserved.
//

#import "TWAContactDetailsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
@import MapKit;

@interface TWAContactDetailsViewController () <MFMailComposeViewControllerDelegate>

#pragma mark - Variables
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

#pragma mark - Localized View Items
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *workPhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobilePhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapAddressButton;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;

#pragma mark - Data View Items
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UIImageView *largeImage;
@property (weak, nonatomic) IBOutlet UIButton *homePhoneButton;
@property (weak, nonatomic) IBOutlet UIButton *workPhoneButton;
@property (weak, nonatomic) IBOutlet UIButton *mobilePhoneButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLineOne;
@property (weak, nonatomic) IBOutlet UILabel *addressLineTwo;
@property (weak, nonatomic) IBOutlet UILabel *birthday;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

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
    
    //Set all the localized text
    self.nameLabel.text = NSLocalizedString(@"ContactDetailNameLabel", nil);
    self.companyLabel.text = NSLocalizedString(@"ContactDetailCompanyLabel", nil);
    self.phoneLabel.text = NSLocalizedString(@"ContactDetailPhoneLabel", nil);
    self.homePhoneNumberLabel.text = NSLocalizedString(@"ContactDetailHomePhoneLabel", nil);
    self.workPhoneNumberLabel.text = NSLocalizedString(@"ContactDetailWorkPhoneLabel", nil);
    self.mobilePhoneNumberLabel.text = NSLocalizedString(@"ContactDetailMobilePhoneLabel", nil);
    self.addressLabel.text = NSLocalizedString(@"ContactDetailAddressLabel", nil);
    [self.mapAddressButton setTitle:NSLocalizedString(@"ContactDetailMapAddressButton", nil) forState:UIControlStateNormal];
    self.birthdayLabel.text = NSLocalizedString(@"ContactDetailBirthdayLabel", nil);
    self.emailLabel.text = NSLocalizedString(@"ContactDetailEmailLabel", nil);
    self.websiteLabel.text = NSLocalizedString(@"ContactDetailWebsiteLabel", nil);
    
    //Null out all the data labels so the user doesn't see a flash of default
    //or old data
    self.name.text = @"";
    self.companyName.text = @"";
    self.largeImage.image = nil;
    [self.homePhoneButton setTitle:@"" forState:UIControlStateNormal];
    [self.workPhoneButton setTitle:@"" forState:UIControlStateNormal];
    [self.mobilePhoneButton setTitle:@"" forState:UIControlStateNormal];
    self.addressLineOne.text = @"";
    self.addressLineTwo.text = @"";
    self.birthday.text = @"";
    [self.emailButton setTitle:@"" forState:UIControlStateNormal];
    [self.websiteButton setTitle:@"" forState:UIControlStateNormal];
    
    //Set the labels for the data that we have
    self.name.text = self.contactListResponse.name;
    self.companyName.text = self.contactListResponse.company;
    [self.homePhoneButton setTitle:self.contactListResponse.phone.home forState:UIControlStateNormal];
    [self.workPhoneButton setTitle:self.contactListResponse.phone.work forState:UIControlStateNormal];
    [self.mobilePhoneButton setTitle:self.contactListResponse.phone.mobile forState:UIControlStateNormal];
    
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
    
    //TODO: Clean this up so that if there is no mobile number the content below moves up the view
    if([self.contactListResponse.phone.mobile  isEqual: @""]) {
        self.mobilePhoneNumberLabel.hidden = YES;
    }
    
    [self getContactDetailsFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)mapButtonClicked:(id)sender {
    //Using the lat/long of the contacts detail API call we can plot the point on a map
    MKPlacemark *pl = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude)
                                            addressDictionary:nil];
    MKMapItem *mi = [[MKMapItem alloc] initWithPlacemark:pl];
    mi.name = self.navigationItem.title;
    [mi openInMapsWithLaunchOptions:nil];
}

- (IBAction)callPhoneNumberButtonClicked:(id)sender {
    //Need to make sure we have a button so we can get the phone number from
    //the button text
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    NSString *phoneNumber = [(UIButton *)sender currentTitle];
    //Add a +1 to the phone numbers to make sure they always work
    //TODO: Fix this in order to support countries outside the US
    if(![phoneNumber hasPrefix:@"+1"]) {
        phoneNumber = [NSString stringWithFormat:@"+1%@", phoneNumber];
    }
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GeneralErrorString", nil)
                                                               message:NSLocalizedString(@"DeviceDoesntSupportTelErrorMessage", nil)
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"GeneralOKString", nil)
                                                     otherButtonTitles:nil];
        [warningAlert show];
    }

}

- (IBAction)createEmailButtonClicked:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        //Need to make sure we have a button so we can get the email from
        //the button text
        if (![sender isKindOfClass:[UIButton class]])
            return;
        
        NSString *emailAddress = [(UIButton *)sender currentTitle];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *usersTo = [NSArray arrayWithObjects: emailAddress, nil];
        //TODO Investigate why this works on device but not on the simulator
        [controller setToRecipients:usersTo];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GeneralErrorString", nil)
                                                               message:NSLocalizedString(@"DeviceDoesntSupportEmailMessage", nil)
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"GeneralOKString", nil)
                                                     otherButtonTitles:nil];
        [warningAlert show];
    }
}

- (IBAction)websiteButtonClicked:(id)sender {
    //Need to make sure we have a button so we can get the website from
    //the button text
    if (![sender isKindOfClass:[UIButton class]])
        return;
    
    NSString *url = [(UIButton *)sender currentTitle];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - MailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    //Not much to do here. Just make sure that the view controller does away
    //and the user ends back in the application
    if (result == MFMailComposeResultSent) {
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - API Call

- (void) getContactDetailsFromServer
{
    NSString *requestString = self.contactListResponse.detailsURL;
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                        if (error){
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GeneralErrorString", nil)
                                                                            message:NSLocalizedString(@"GeneralNoConnectionMessage", nil)
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"GeneralOKString", nil)
                                                                  otherButtonTitles:nil];
                            [alert show];
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
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.largeImage.image = [UIImage imageWithData:data];
    }];

    NSDictionary *addressObject = jsonDataObject[@"address"];
    
    //Put any UI updates in the dispatch so we can make safe updates to the UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.emailButton setTitle:jsonDataObject[@"email"] forState:UIControlStateNormal];
        [self.websiteButton setTitle:jsonDataObject[@"website"] forState:UIControlStateNormal];
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
