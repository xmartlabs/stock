import 'package:stock/stock.dart';

late TwitterApi _api;
late TweetsLocalDatabase _database;

void main() async {
  // Create fetcher
  final fetcher = Fetcher.ofFuture<String, List<Tweet>>(
    (userId) => _api.getUserTweets(userId),
  );

  // Create SourceOfTruth
  final sourceOfTruth = SourceOfTruth<String, List<Tweet>>(
    reader: (userId) => _database.getUserTweets(userId),
    writer: (userId, tweets) => _database.writeUserTweets(userId, tweets),
  );

  // Create Stock
  final stock = Stock<String, List<Tweet>>(
    fetcher: fetcher,
    sourceOfTruth: sourceOfTruth,
  );

  // Create a stream to listen tweet changes of the user `xmartlabs`
  stock
      .stream('xmartlabs', refresh: true)
      .listen((StockResponse<List<Tweet>> stockResponse) {
    stockResponse.when(
      onLoading: (_) => _displayLoadingIndicator(),
      onData: (_, data) => _displayTweetsInUI(data),
      onError: (_, error, __) => _displayErrorInUi(error),
    );
  });

  // Get Xmartlabs tweets from the network and save them in the DB.
  final List<Tweet> freshTweets = await stock.fresh('xmartlabs');

  // Get Xmartlabs tweets
  // It will try to use Local Database Tweets.
  // However, if the DB tweets are empty, it will fetch new tweets from the fetcher, and save them in the DB.
  final List<Tweet> cachedTweets = await stock.get('xmartlabs');
}

void _displayTweetsInUI(List<Tweet>? tweets) {}

void _displayLoadingIndicator() {}

void _displayErrorInUi(Object error) {}

// Example entity
class Tweet {
  // Tweets info, like text
}

// Example Rest Service
abstract class TwitterApi {
  // Rest Endpoint to get the Tweets of an specific user
  Future<List<Tweet>> getUserTweets(String userId);
}

// Example Local Database
abstract class TweetsLocalDatabase {
  // Get all user tweets from a local DB
  Stream<List<Tweet>> getUserTweets(String userId);

  // Replace the DB tweets with new tweets
  // It's typically do in a DB transaction, first the old tweets are deleted and then the new once are added
  Future<List<Tweet>> writeUserTweets(String userId, List<Tweet>? tweets);
}
