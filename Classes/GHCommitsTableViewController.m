#import "GHCommitsTableViewController.h"
#import "GHCommitsTableModel.h"
#import "GitHubCommit.h"
#import "GitHubRepository.h"
#import "GHChangesTableViewController.h"
#import "GHCountStatusItemController.h"
#import "GHDockingTableHeaderViewController.h"
#import "GHHeaderView.h"

@interface GHCommitsTableViewController () <GHTableModelDelegate>
@property (nonatomic,retain) GHCountStatusItemController *statusItem;
@property (nonatomic,retain) GHDockingTableHeaderViewController *headerController;
@end

@interface GHCommitsTableViewController (TypeSpecification)
@property (nonatomic, readonly) GHCommitsTableModel *tableModel;
@end


@implementation GHCommitsTableViewController
@synthesize repository;
@synthesize statusItem;
@synthesize headerController;

+ (id)withRepository:(id <GitHubRepository>)repository {
  return [[[self alloc] initWithRepository:repository] autorelease];
}

- (id)initWithRepository:(id <GitHubRepository>)aRepository {
  self = [super init];
  if (self != nil) {
    repository = [aRepository retain];
  } return self;
}

+ (Class)modelClass {
  return [GHCommitsTableModel class];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = self.repository.name;
  self.tableView.rowHeight = 65; 
  
  self.tableModel.repository = self.repository;
  self.tableModel.delegate = self;
  
  id headerView = [GHHeaderView withText:self.repository.desc];
  self.headerController = [GHDockingTableHeaderViewController withTableView:self.tableView
                                                                 headerView:headerView];
  
  
  self.statusItem = [GHCountStatusItemController withSingularType:@"commit"
                                                       pluralType:@"commits"];
  
  self.statusItem.dataSource = self.tableModel;
  
  [self setSoleToolbarItem:self.statusItem.buttonItem];
  
  [self refreshData];
}

- (void)dealloc {
  [repository release];
  [statusItem release];
  [super dealloc];
}

#pragma mark -
#pragma mark GHTableModelDelegate

- (void)dataDidChange {
  [super dataDidChange];
  [self.statusItem refreshLabel];
}

#pragma mark -
#pragma mark LRTableModelCellProvider

- (void)configureCell:(UITableViewCell *)cell forObject:(id <GitHubCommit>)object atIndexPath:(id)path {
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.text = object.message;

  NSDateFormatter *formatter = [NSDateFormatter new];
  formatter.dateStyle = NSDateFormatterMediumStyle;
  formatter.timeStyle = NSDateFormatterShortStyle;
  
  cell.detailTextLabel.text = [formatter stringFromDate:object.committedDate];

  [formatter release];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(id)path {
  id <GitHubCommit> commit = [self.tableModel objectAtIndexPath:path];
  id controller = [GHChangesTableViewController withCommit:commit fromRepository:self.repository];
  [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.headerController scrollViewDidScroll:scrollView];
}

@end
