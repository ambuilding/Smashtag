# Smashtag

- TweetTableViewController

使用 Twitter framework 通过 keyword 搜索，结果显示在 tableView;
Array / searchTextField / searchForTweets() / GCD /  Table view data source / Navigation

- TweetTableViewCell

IBOutlets / var tweet / update() UI  /  setBodyText(tweet: Twitter.Tweet)改变字体颜色

- MentionTableViewController

点击 TweetTableViewCell 进入 MentionTableViewController；
点击 hashtags and users 进入 TweetTableViewController 搜索；
点击 urls 用 Safari 打开

- ImageViewController

点击 MentionTableViewCell 的图片进入 ImageViewController;
scrollView.contentSize/delegate / fetchImage() / setupGestureRecognizer() double-tap

- RecentSearchTableViewController / RecentSearches

通过 NSUserDefaults 保存搜索记录，点击纪录跳转到 TweetTableViewController 搜索;
保存一百条纪录，可以删除，并且避免 insert 重复的关键字

- CoreDataTableViewController / TwittersTableViewController 

NSFetchedResultsController provides the interface between Core Data and UITableView objects;
NSFetchedResultsControllerDelegate: Notify its delegate that the controller’s fetch results,
have been changed due to an add, remove, move, or update operation.

TwittersTableViewController 继承 CoreDataTableViewController;
mention or managedObjectContext 变化后 updateUI()，fetchedResultsController随着更新;
cell 里显示 screenName and tweetCountWithMentionByTwitterUser

- Tweet/TwitterUser

创建 data model/Entities; 
A TwitterUser can tweet many Tweets;
NSFetchRequest querying;
Use NSManagedObjectContext to insert/query for objects in the database;

context.executeFetchRequest / NSEntityDescription.insertNewObjectForEntityForName;
Returns a Tweet from the database if Twetter.Tweet has already been put in; 
Or returns a newly-added-to-the-database Tweet if not


