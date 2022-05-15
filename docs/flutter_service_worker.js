'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "78b2e266d4db69c19b3e73236fe6b11c",
"index.html": "6132bd86ccccc0ac23f9cc7f207b28b3",
"/": "6132bd86ccccc0ac23f9cc7f207b28b3",
"main.dart.js": "12c0e35806afe95fe75f1c507e6918a7",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "9ec9a1caf00fbca5b4bdca9aa713e482",
"assets/AssetManifest.json": "0b243136824658312ba6aa7261ccd439",
"assets/NOTICES": "a736bde7b0137de32649c0ba110b3943",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/fonts/MaterialIcons-Regular.otf": "7e7a6cccddf6d7b20012a548461d5d81",
"assets/assets/images/bomb.png": "02ee82283114e1b0921e63c0af323a75",
"assets/assets/images/flag.png": "2c3dfeaafb027243583fbb7c9b64593a",
"assets/assets/images/field-8.png": "e52d38f84557e3de48cf25105f36bb33",
"assets/assets/images/field_hidden.png": "57bd91669c4f35fceeb2843bbcf78f80",
"assets/assets/images/field_8.png": "6cffc8da21e4b7e646f9e6213753f386",
"assets/assets/images/digital_6.png": "374c779db89ddb8fd63d18c8c25b9872",
"assets/assets/images/digital_7.png": "7b4f1542926a4bb06acc38491d4a43cd",
"assets/assets/images/field-hidden.png": "5784562f26de48e0a702ee7d04945d15",
"assets/assets/images/digital_5.png": "5abd80158537f4f634ba640d2f020931",
"assets/assets/images/digital_4.png": "0d8ad05dd642bb5887d29e60fc303cdf",
"assets/assets/images/digital_0.png": "c46013716f57dbd1d061a3e0df02b154",
"assets/assets/images/digital_1.png": "6465f01c78e8ee3c479fc2c3aec72703",
"assets/assets/images/field_wrong.png": "5fa1971fe2f8d2e088b58aaa66f43b51",
"assets/assets/images/digital_3.png": "9bd492c673b51e5d40f65a4f6c3e3891",
"assets/assets/images/digital_2.png": "26da2e48f5d09de116c14f9fe351e3f2",
"assets/assets/images/field_1.png": "73c26e6c79935da8578ac4e185bb5c42",
"assets/assets/images/field_2.png": "62eda1fce93889f66b6da416f6c8917e",
"assets/assets/images/field_3.png": "dc11e5bd4b04df32c359a736f9f61e5d",
"assets/assets/images/field_7.png": "83b5d6986af5b160d91ef4eac7b4d620",
"assets/assets/images/field_null.png": "53a6692976fd3d9d42b62687a922289c",
"assets/assets/images/digital_9.png": "b3376a6e888b3057b830c77dcf304caa",
"assets/assets/images/digital_8.png": "b192444201733fcc42ce96acc8cee3c6",
"assets/assets/images/digital_null.png": "0955e00546324f238a78b2f291571c77",
"assets/assets/images/field_6.png": "76828f98af1a200c8632374ec5ae5fe4",
"assets/assets/images/field_4.png": "b85547242e6c0aa2dd4a860abad8328c",
"assets/assets/images/field_5.png": "231582743e53eed57313e4ddad5b3b07",
"assets/assets/images/button-pressed.png": "81cd2cc76ee7ab0c7a06a3bd699b0892",
"assets/assets/images/field-3.png": "903b73db5245bbea2cc92329fc67dcf7",
"assets/assets/images/field-2.png": "3fa98d85eeb894a8c7bd463794f862ec",
"assets/assets/images/mark.png": "9a884ae8cc3c17f95dcbc83afd5a3917",
"assets/assets/images/field-0.png": "7dc3af93abf744e14c329040678b62d9",
"assets/assets/images/field-1.png": "62c218111c2fd5ac602892d57eece9c9",
"assets/assets/images/field-5.png": "1e62675e86db06213819c8f9eb13b025",
"assets/assets/images/field-4.png": "88ed99e5324b099f8c3093c714f9ee35",
"assets/assets/images/field-6.png": "9162dfa889e5ae1c136db8054ef187e6",
"assets/assets/images/field-7.png": "dc8af900d1446f28d9b9be4a12d795ad",
"assets/assets/images/button.png": "72bf848bcfaee9c85d697dd9749aeaa3",
"assets/assets/images/field_correct.png": "52a8f2c734df89464613528081c83721",
"assets/assets/sounds/explosion.mp3": "63f6f9b4880303857d82c37e04c19067",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
