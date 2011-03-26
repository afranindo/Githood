#import "GHChangesTableViewController.h"
#import "GitHubCommit.h"
#import "GitHubRepository.h"
#import "GitHubCommitServiceFactory.h"
#import "GitHubServiceGotCommitDelegate.h"
#import "GHChangesTableModel.h"
#import "GHChangesStatusItemController.h"

#import "GHDiffViewController.h"

#import "GHHeaderView.h"
#import "GHDockingTableHeaderViewController.h"
#import "GHStyler.h"

@interface GHChangesTableViewController ()
@property (nonatomic, retain) GHChangesStatusItemController *statusItem;
@end

@interface GHChangesTableViewController (TypeSpecification)
@property (nonatomic, readonly) GHChangesTableModel *tableModel;
@end

@implementation GHChangesTableViewController
@synthesize commit;
@synthesize repository;
@synthesize statusItem;

- (void)dealloc {
  [commit release];
  [repository release];
  [statusItem release];
  [super dealloc];
}

+ (id)withCommit:(id <GitHubCommit>)commit 
  fromRepository:(id <GitHubRepository>)repository {
  return [[[self alloc] initWithCommit:commit 
                        fromRepository:repository]
          autorelease];
}

- (id)initWithCommit:(id <GitHubCommit>)aCommit 
      fromRepository:(id<GitHubRepository>)aRepository {
  self = [super init];
  if (self != nil) {
    commit = [aCommit retain];
    repository = [aRepository retain];
  } return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Commit";
  self.tableModel.commit = self.commit;
  self.tableModel.repository = self.repository;
  
  self.tableView.rowHeight = 44.0f;
  self.statusItem = [GHChangesStatusItemController controller];
  self.statusItem.dataSource = self.tableModel;
  
  [self setSoleToolbarItem:self.statusItem.buttonItem];
}

- (void)configureCell:(UITableViewCell *)cell forObject:(id)object atIndexPath:(NSIndexPath *)path {
  cell.textLabel.text = object;
  cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
  
  if (path.section == 0) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
}


#pragma mark -
#pragma mark GHConcreteTableViewController

+ (Class)modelClass {
  return [GHChangesTableModel class];
}

- (NSString *)headerText {
  return self.commit.message;
}


#pragma mark -
#pragma mark GHTableModelDelegate

- (void)dataDidChange {
  [super dataDidChange];
  [self.statusItem refreshLabel];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
  if (path.section == 0) {
    id diff = [self.tableModel diffAtIndex:path.row];
    id fileName = [self.tableModel.commit.modified objectAtIndex:path.row];
    
    id controller = [GHDiffViewController withDiff:diff ofFile:fileName];
    [self.navigationController pushViewController:controller animated:YES];
  } else {
    [tableView deselectRowAtIndexPath:path animated:YES];
  }
}

@end
