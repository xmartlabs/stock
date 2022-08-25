# Stock

Stock is a dart package for loading data from remote and local sources.
It was inspired by [Store] Kotlin library.

It prevents excessive calls to the network and disk cache. 
By utilizing it, you eliminate the possibility of flooding your network with the same request while adding layers of caching.

Although you can use it without a local source, the greatest benefit comes when you combine Stock with a local database such as [Floor], [Drift], [sqflite], [Realm], etc. 

## Features

- Combine the local (DB, cache) and network data simply. It provides a data `Stream` where you can listen and work with your data. 
- Know the data `Stream` state. It's useful for example to display a loading indicator or display errors.
- If you are not using a local DB, `Stock` provides a memory cache, to share and improve your app experience.
- Work with your data more safely. If an error is thrown, Stock will catch it and returned into the stream to handle it easily.

## Overview

A [`Stock`] is responsible for managing a particular data request.

It is based on two important classes:
- [`Fetcher`]: defines how data will be fetched over network.
- [`SourceOfTruth`]: defines how local data will be read and wrote in your local cache. It's optional. Although `Stock` can be used without it, it's recommendable to use it.

`Stock` uses generic keys as identifiers for data.
A key can be any value object that properly implements `toString()`, `equals()` and `hashCode()`.

When you create `Stock`, it provides you a bunch of methods to access to the data.
The most important one is `stream()`, which provides you a `Stream` of your data, which can be used to update your UI or doing an specific action.


## Getting started

To use this package, add `stock` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

### 1. Create a Fetcher

The `Fetcher` is required to fetch new data from the network.
You can create a it from a `Future` or from a `Stream`.

`FutureFetcher` is usually used with a RestApi, whereas `StreamFetcher` is used with a `Stream` source like a Web Socket.

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

Generally you implement the `SourceOfTruth` using a local database. However, if you are not using a local database / cache, the library provides the [`CachedSourceOfTruth`], a source of truth which stores the data in memory.   

```dart
  final sourceOfTruth = SourceOfTruth<String, List<Tweet>>(
    reader: (userId) => _database.getUserTweets(userId),
    writer: (userId, tweets) => _database.writeUserTweets(userId, tweets),
  );
```

_Note: to the proper operation, when `write` is invoked with new data, the source of truth has to emit the new value in the `reader`._

### 3. Create the `Stock`

`Stock` lets you to combine the different data sources and get the data.

```dart
 final store = Store<String, List<Tweet>>(
    fetcher: fetcher,
    sourceOfTruth: sourceOfTruth,
  );
```

### Get a `Stream` data from Stock

You can generate a data `Stream` using `stream()`.

You need to invoke it with a specific `key`, and an optional `refresh` value that tells Stoke if refresh is optional or mandatory.

That returns a data steam of `StoreResponse`, which has 3 possible values:
- `StoreResponseLoading` tells that a network request is in progress. It can be useful to display the loading spinner in your UI.
- `StoreResponseData` holds the response data. It has a `value` field which includes an instance of the type returned by `Stock`.
- `StoreResponseError` indicates that an error happened.
When an error happens, `Stock` does not throw an error, instead, it wraps it in this class.
It includes an `error` field that contains the exception thrown by the given `origin`.

Each `StoreResponse` includes an `origin` field which specifies where the event is coming from. 

```dart
  store
      .stream('key', refresh: true)
      .listen((StoreResponse<List<Tweet>> storeResponse) {
    if (storeResponse is StoreResponseLoading) {
      _displayLoadingIndicator();
    } else if (storeResponse is StoreResponseData) {
      _displayTweetsInUI((storeResponse is StoreResponseData).data);
    } else {
      _displayErrorInUi((storeResponse as StoreResponseError).error);
    }
  });
```

### Get non-stream data from Stock

Stock provides a couple of methods to get data without using a data stream.

1. `get` returns cached data if it is cached otherwise will return fresh/network data (updating your caches).
2. `fresh` returns fresh data updating your caches

```dart
  // Get fresh data
  final List<Tweet> freshTweets = await store.fresh(key);
  
  // Get the previous cached data
  final List<Tweet> cachedTweets = await store.get(key);
```


## Additional information

For bugs please use [GitHub Issues](https://github.com/xmartlabs/stock/issues). For questions, ideas, and discussions use [GitHub Discussions](https://github.com/xmartlabs/stock/discussions).

Made with ❤️ by [Xmartlabs](http://xmartlabs.com).

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

[Store]: https://github.com/MobileNativeFoundation/Store
[Floor]: https://pub.dev/packages/floor
[Drift]: https://pub.dev/packages/drift
[sqflite]: https://pub.dev/packages/sqflite
[Realm]: https://pub.dev/packages/realm
[`Stock`]: lib/store.dart
[`Fetcher`]: lib/fetcher.dart
[`SourceOfTruth`]: lib/source_of_truth.dart
[`CachedSourceOfTruth`]: lib/source_of_truth.dart
