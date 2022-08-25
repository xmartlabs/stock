import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/extensions/store_response_extensions.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

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

  // Create Store
  final store = Store<String, List<Tweet>>(
    fetcher: fetcher,
    sourceOfTruth: sourceOfTruth,
  );

  // Create a stream to listen tweet changes of the user `xmartlabs`
  store
      .stream('xmartlabs', refresh: true)
      .listen((StoreResponse<List<Tweet>> storeResponse) {
    if (storeResponse is StoreResponseLoading) {
      _displayLoadingIndicator();
    } else if (storeResponse is StoreResponseData) {
      _displayTweetsInUI(storeResponse.data);
    } else {
      _displayErrorInUi((storeResponse as StoreResponseError).error);
    }
  });

  // Get Xmartlabs tweets from the network and save them in the DB.
  final List<Tweet> freshTweets = await store.fresh('xmartlabs');

  // Get Xmartlabs tweets
  // It will try to use Local Database Tweets.
  // However, if the DB tweets are empty, it will fetch new tweets from the fetcher, and save them in the DB.
  final List<Tweet> cachedTweets = await store.get('xmartlabs');
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
