# Stock

Stock is a dart package for loading data from both remote and local sources.
It is inspired by the [Store] Kotlin library.

Its main goal is to prevent excessive calls to the network and disk cache. 
By utilizing it, you eliminate the possibility of flooding your network with the same request while, at the same time, adding layers of caching.

Although you can use it without a local source, the greatest benefit comes from combining Stock with a local database such as [Floor], [Drift], [Sqflite], [Realm], etc. 

## Features

- Combine local (DB, cache) and network data simply. It provides a data `Stream` where you can listen and work with your data. 
- Know the data `Stream` state. It's useful for displaying errors or loading indicators, for example.
- If you are not using a local DB, `Stock` provides a memory cache, to share and improve upon your app's experience.
- Work with your data more safely. If an error is thrown, Stock will catch it and return it into the stream so it can be handled easily.

## Overview

A [`Stock`] is responsible for managing a particular data request.

It is based on two important classes:
- [`Fetcher`]: defines how data will be fetched over network.
- [`SourceOfTruth`]: defines how local data will be read and written in your local cache. Although `Stock` can be used without it, its use is recommended.

`Stock` uses generic keys as identifiers for data.
A key can be any value object that properly implements `toString()`, `equals()` and `hashCode()`.

When you create `Stock`, it provides you with a bunch of methods in order to access the data.
The most important one is `stream()`, which provides you with a `Stream` of your data, which can be used to update your UI or to do a specific action.


## Getting started

To use this package, add `stock` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### 1. Create a Fetcher

The `Fetcher` is required to fetch new data from the network.
You can create a it from a `Future` or from a `Stream`.

`FutureFetcher` is usually used alongside a RestApi, whereas `StreamFetcher` is used with a `Stream` source like a Web Socket.

```dart
  final futureFetcher = Fetcher.ofFuture<String, List<Tweet>>(
    (userId) => _api.getUserTweets(userId),
  );

  final streamFetcher = Fetcher.ofStream<String, List<Tweet>>(
    (userId) => _api.getUserTweetsStream(userId),
  );
```

### 2. Create a Source Of Truth

The `SourceOfTruth` is used to read and write the remote data in a local cache.

Generally you will implement the `SourceOfTruth` using a local database. However, if you are not using a local database / cache, the library provides the [`CachedSourceOfTruth`], a source of truth which stores the data in memory.   

```dart
  final sourceOfTruth = SourceOfTruth<String, List<Tweet>>(
    reader: (userId) => _database.getUserTweets(userId),
    writer: (userId, tweets) => _database.writeUserTweets(userId, tweets),
  );
```

In this example, `Fetcher` type is exactly the `SourceOfTruth` type. If you need to use multiple types, you can use the [`mapTo` extension](#use-different-types-for-fetcher-and-sourceoftruth).

_Note: to the proper operation, when `write` is invoked with new data, the source of truth has to emit the new value in the `reader`._

### 3. Create the `Stock`

`Stock` lets you combine the different data sources and get the data.

```dart
 final stock = Stock<String, List<Tweet>>(
    fetcher: fetcher,
    sourceOfTruth: sourceOfTruth,
  );
```

### Get a data `Stream` from Stock

You can generate a data `Stream` using `stream()`.

You need to invoke it with a specific `key`, and an optional `refresh` value that tells Stock if a refresh is optional or mandatory.

That returns a data stream of `StockResponse`, which has 3 possible values:
- `StockResponseLoading` informs that a network request is in progress. It can be useful to display a loading indicator in your UI.
- `StockResponseData` holds the response data. It has a `value` field which includes an instance of the type returned by `Stock`.
- `StockResponseError` indicates that an error happened.
When an error happens, `Stock` does not throw an exception, instead, it wraps it in this class.
It includes an `error` field that contains the exception thrown by the given `origin`.

Each `StockResponse` includes an `origin` field which specifies where the event is coming from. 

```dart
  stock
      .stream('key', refresh: true)
      .listen((StockResponse<List<Tweet>> stockResponse) {
    if (stockResponse is StockResponseLoading) {
      _displayLoadingIndicator();
    } else if (stockResponse is StockResponseData) {
      _displayTweetsInUI((stockResponse is StockResponseData).data);
    } else {
      _displayErrorInUi((stockResponse as StockResponseError).error);
    }
  });
```

### Get non-stream data from Stock

Stock provides a couple of methods to get data without using a data stream.

1. `get` returns cached data -if it is cached- otherwise will return fresh/network data (updating your caches).
2. `fresh` returns fresh data updating your cache

```dart
  // Get fresh data
  final List<Tweet> freshTweets = await stock.fresh(key);
  
  // Get the previous cached data
  final List<Tweet> cachedTweets = await stock.get(key);
```


### Use different types for `Fetcher` and `SourceOfTruth`

Sometimes you need to use different entities for Network and DB. For that case `Stock` provides the `StockTypeMapper`, a class that transforms one entity into the other.

`StockTypeMapper` is used in the `SourceOfTruth` via the method `mapToUsingMapper`

```dart
class TweetMapper implements StockTypeMapper<DbTweet, NetworkTweet> {
  @override
  NetworkTweet fromInput(DbTweet value) => NetworkTweet(value);

  @override
  DbTweet fromOutput(NetworkTweet value) => DbTweet(value);
}

final SourceOfTruth<int, DbTweet> sot = _createMapper();
final SourceOfTruth<int, NetworkTweet> newSot = sot.mapToUsingMapper(TweetMapper());
```

You can also achieve the same result using the `mapTo` extension.

```dart

final SourceOfTruth<int, DbTweet> sot = _createMapper();
final SourceOfTruth<int, NetworkTweet> newSot = mapTo(
      (networkTweet) => DbTweet(networkTweet),
      (dbTweet) => NetworkTweet(dbTweet),
);
```

### Use a non-stream source of truth

Sometimes your Source of Truth does not provide you with a real-time data stream.
For example, suppose that you are using [shared_preferences] to store your data, or you are just catching your data in memory.
For these cases, `Stock` provides you the `CachedSourceOfThruth`, a `SourceOfThruth` that be helpful in these cases.

```dart
class SharedPreferencesSourceOfTruth extends CachedSourceOfTruth<String, String> {
  SharedPreferencesSourceOfTruth();

  @override
  @protected
  Stream<T?> reader(String key) async* {
    final prefs = await SharedPreferences.getInstance();
    // Read data from an non-stream source
    final stringValue = prefs.getString(key);
    setCachedValue(key, stringValue);
    yield* super.reader(key);
  }

  @override
  @protected
  Future<void> write(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    await super.write(key, value);
  }
}
```

This class can be used with `StockTypeMapper` to transform your data into an entity.

```dart
// The mapper json to transform a string into a User 
final StockTypeMapper<String, User> mapper = _createUserMapper();
final SharedPreferencesSourceOfTruth<String, User> = SharedPreferencesSourceOfTruth()
    .mapToUsingMapper(mapper);
```

## Additional information

For bugs please use [GitHub Issues](https://github.com/xmartlabs/stock/issues). For questions, ideas, and discussions use [GitHub Discussions](https://github.com/xmartlabs/stock/discussions).

Made with ❤️ by [Xmartlabs](https://xmartlabs.com).

## License

    Copyright (c) 2022 Xmartlabs SRL.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[Drift]: https://pub.dev/packages/drift
[Floor]: https://pub.dev/packages/floor
[Realm]: https://pub.dev/packages/realm
[Store]: https://github.com/MobileNativeFoundation/Store
[`CachedSourceOfTruth`]: lib/src/source_of_truth.dart
[`Fetcher`]: lib/src/fetcher.dart
[`SourceOfTruth`]: lib/src/source_of_truth.dart
[`Stock`]: lib/src/stock.dart
[shared_preferences]: https://pub.dev/packages/shared_preferences
[sqflite]: https://pub.dev/packages/sqflite
