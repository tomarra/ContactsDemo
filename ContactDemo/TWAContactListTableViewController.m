//
//  TWAContactListTableViewController.m
//  ContactDemo
//
//  Created by Tom Arra on 10/8/14.
//  Copyright (c) 2014 tomarra. All rights reserved.
//

#import "TWAContactListTableViewController.h"
#import "TWAContactDetailsViewController.h"
#import "TWAContactListResponse.h"
#import "TWAContactListTableViewCell.h"
#import "TWAContactPhone.h"

@interface TWAContactListTableViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarText;

@end

@implementation TWAContactListTableViewController

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:nil];
    
    _contactsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarText.title = NSLocalizedString(@"ContactListLoadingTitleBar", nil);
    
    [self getContactsListFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWAContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactListTableViewCell" forIndexPath:indexPath];
    
    cell.name.text = [[self.contactsArray objectAtIndex:indexPath.row] name];
    cell.phoneNumber.text = [[[self.contactsArray objectAtIndex:indexPath.row] phone] home];
    
    //Make the request for the image asyc so that we don't tie up the UI thread
    NSString *imageUrl = [[self.contactsArray objectAtIndex:indexPath.row] smallImageURL];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.smallImage.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSUInteger selectedRow = path.row;
    
    if([[segue identifier]  isEqual: @"showContactDetail"] && self.contactsArray[selectedRow]) {
        TWAContactDetailsViewController *vc = [segue destinationViewController];
        vc.contactListResponse = self.contactsArray[selectedRow];
    }
}

#pragma mark - API Call

- (void) getContactsListFromServer
{
    //While were getting data don't let the user click on the table cells
    //just to make things a bit eaiser
    self.tableView.allowsSelection = NO;
    
    NSString *requestString = @"http://solstice.applauncher.com/external/contacts.json";
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
                                NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:nil];
                                [self updateViewWithData:jsonObject];
                                return;
                            }
                        }
                    }];
    
    [dataTask resume];
    
}

- (void) updateViewWithData:(NSArray *)jsonDataObject
{
    for (NSDictionary *d in jsonDataObject)
    {
        TWAContactListResponse *clr = [[TWAContactListResponse alloc] init];
        clr.birthdate = d[@"birthdate"];
        clr.company = d[@"company"];
        clr.detailsURL = d[@"detailsURL"];
        clr.employeeId = [d[@"employeeId"] doubleValue];
        clr.name = d[@"name"];
        clr.smallImageURL = d[@"smallImageURL"];
        
        NSDictionary *phoneObject = d[@"phone"];
        TWAContactPhone *cp = [[TWAContactPhone alloc] init];
        cp.home = phoneObject[@"home"];
        cp.work = phoneObject[@"work"];
        cp.mobile = phoneObject[@"mobile"];
        clr.phone = cp;
        
        [self.contactsArray addObject:clr];
    }
    
    //Once we have all the data ask the UI thread to do some updates
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.navBarText.title = NSLocalizedString(@"ContactListTitleBar", nil);
        self.tableView.allowsSelection = YES;
    });

}


@end
