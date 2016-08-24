# Smashtag

- TweetTableViewController

使用 Twitter framework 通过 keyword 搜索，结果显示在 tableView
Array / searchTextField / searchForTweets() / GCD /  Table view data source / Navigation

- TweetTableViewCell

IBOutlets / var tweet / update()  /  setBodyText(tweet: Twitter.Tweet)

- MentionTableViewController

点击 TweetTableViewCell 进入 MentionTableViewController；
点击 hashtags and users 进入 TweetTableViewController 搜索；
点击 urls 用 Safari 打开

- ImageViewController

点击 MentionTableViewCell 的图片进入 ImageViewController
scrollView.contentSize/delegate / fetchImage() / setupGestureRecognizer() double-tap

- RecentSearchTableViewController / RecentSearches

通过 NSUserDefaults 保存搜索记录，点击纪录跳转到 TweetTableViewController 搜索
保存一百条纪录，可以删除，并且避免 insert 重复的关键字

- CoreDataTableViewController 


