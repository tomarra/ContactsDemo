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

- (void)awakeFromNib
{
    //self = [super initWithStyle:UITableViewStylePlain];
    NSLog(@"TWAContactListTableViewController - init");
    
    //if (self){
        NSLog(@"TWAContactListTableViewController - init successful");
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
    
    _contactsArray = [[NSMutableArray alloc] init];
    //}
    
    //return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TWAContactListTableViewController - viewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    self.navBarText.title = @"Loading...";
    
    [self getContactsListFromServer];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.contactsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWAContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactListTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.name.text = [[self.contactsArray objectAtIndex:indexPath.row] name];
    cell.phoneNumber.text = [[[self.contactsArray objectAtIndex:indexPath.row] phone] home];
    
    NSString *imageUrl = [[self.contactsArray objectAtIndex:indexPath.row] smallImageURL];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.smallImage.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSUInteger selectedRow = path.row;
    
    TWAContactDetailsViewController *vc = [segue destinationViewController];
    vc.contactListResponse = self.contactsArray[selectedRow];
}

#pragma mark - API Call

- (void) getContactsListFromServer
{
    NSString *requestString = @"http://solstice.applauncher.com/external/contacts.json";
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    [req setHTTPMethod:@"GET"];
    
    self.tableView.allowsSelection = NO;
    NSLog(@"GOING TO SEND REQUEST");
    
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:req
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                        NSLog(@"GOT RESPONSE");
                        
                        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                        //int newContacts = 0;
                        for (NSDictionary *d in jsonObject)
                        {
                            NSLog(@"CONTACT");
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
                        
                        NSLog(@"OUT OF CONTACT LOOP");
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            self.navBarText.title = @"Contacts";
                            self.tableView.allowsSelection = YES;
                        });
                        
                    }];
    
    [dataTask resume];
    
}


@end
