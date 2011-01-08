#import "GHReposTableModel.h"
#import "GitHubServiceGotRepositoryDelegate.h"
#import "GitHubRepositoryServiceFactory.h"

@interface GHReposTableModel () <GitHubServiceGotRepositoryDelegate>
@property (readonly) NSArray *sortedRepositories;
@end

@implementation GHReposTableModel
@synthesize username;

- (void)refreshData {
  [self setObjects:[NSArray array]];
  [GitHubRepositoryServiceFactory requestRepositoriesWatchedByUser:self.username
                                                          delegate:self];
}

- (void)gitHubService:(id <GitHubService>)service gotRepository:(id <GitHubRepository>)repository {
  [self addObject:repository];
}

- (NSArray *)sortedRepositories {
  return [self.objects sortedArrayUsingComparator:^(id <GitHubRepository> a, id <GitHubRepository> b) {
    return [b.pushDate compare:a.pushDate];
  }];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
  return [self.sortedRepositories objectAtIndex:indexPath.row];
}

@end
