# ``Kumo/BlobCache``

## Overview

A ``BlobCache`` is a wrapper around a given ``Service`` that provides 
ephemeral / persistent caching for fetched requests. ``BlobCache`` performs 
a fetch on behalf of the user and caches it in its own internal storage. If 
available it returns a cached object as long as it hasn't expired. If 
unavailable then the ``BlobCache`` defaults to using its backing 
``service``.

A ``BlobCache`` checks each layer of storage in order of:

![Cache Storage Hierarchy](cache_storage_hierarchy)

At each subsequent level, after the fallback retrieves the content, the higher
cache layers will cache the retrieved content. Ultimately if the content has not
been cached the ``BlobCache`` will use its ``service`` to perform a download
request to fetch the content.

### Creating a Blob Cache

A blob cache uses a backing ``Service`` to handle fetches when a cached blob
can not be found for a given `URL`. This allows one to configure the service
/ session for all requests.

```swift
let service = Service(baseURL: URL(string: "https://www.apple.com")!)
let blobCache = BlobCache(using: service)
....
let imageURL = URL(string: "https://via.placeholder.com/150")!

let publisher: AnyPublisher<UIImage, Error> = blobCache.fetch(from: imageURL)
let dataPublisher: AnyPublisher<Data, Error> = blobCache.fetch(from: imageURL)
```

A blob cache can also be constructed with just a base URL. A service will
automatically be created for the blob cache:

```swift
let blobCache = BlobCache(baseURL: URL(string: "https://www.apple.com")!)
```

### Scenarios

Example 1:
1. The ephemeral storage does not contain a cached blob for the URL passed.
2. The persistent storage does not contain a cached blob for the URL passed.
3. ``BlobCache`` makes a fetch request with the ``service``.
4. That response is cached in both persistent and ephemeral storages.
5. The blob is returned.

Example 2:
1. The ephemeral storage does not contain a cached blob for the URL passed.
2. The persistent storage contains a cached blob matching the URL passed.
3. That cached blob is added to the ephemeral storage.
4. The blob is returned.

Example 3:
1. The ephemeral storage contains a cached blob matching the URL passed however
the blob has expired and its lifetime cannot be extended under the storage's
policies.
2. The persistent storage contains a cached blob matching the URL passed and
it has not expired.
3. That cached blob is added to the ephemeral storage.
4. The blob is returned.

### Cleaning a Blob Cache.

Cleaning is performed automatically for each storage depending on their 
settings. Ephemeral storage by default is reset each launch and is cleaned
whenever the system issues a memory warning. Persistent storage is cleaned when
the app is terminated. By default these storages also differ in how they clean.

Ephemeral storage cleans indiscriminately by default; meaning that cleaning
removes all cache blobs. Persistent storage by default only removes expired
cache blobs.
