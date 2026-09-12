'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "aff2304aa1151d5d57d78a7dc412c6ad",
"index.html": "bde6e38cc413d92df1dd168d81b373e2",
"/": "bde6e38cc413d92df1dd168d81b373e2",
"main.dart.js": "e200b475b7b456d9f4e7cc5f529d3cdf",
"version.json": "e0e164841df081070423c916c60c09b4",
"assets/assets/icon/app_icon.png": "9fbbdf59471bba6d7831745cbf298b8a",
"assets/assets/audio/sample_guide_01.mp3": "60a6d99bf91a6f4285204fd63e3f0d53",
"assets/assets/audio/sample_guide_02.mp3": "100a0464de7dec8f0a959d86054a154e",
"assets/fonts/MaterialIcons-Regular.otf": "3480d36bda391b3f82fb34a04bb33d67",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "1f2a937b1d52ed2fa8f509379abc981e",
"assets/AssetManifest.bin": "a97173bcb4cbdce5dc55c62bc58ce930",
"assets/AssetManifest.bin.json": "f2403b82e83cae17b440a320ab019726",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/NOTICES": "e940d0f6f9604dde960a7a095c1dfd52",
"icons/Icon-192.png": "222c1970e3058aad4daa19f7f26a774f",
"icons/Icon-512.png": "83a3c3681c5bd3485b184cfb194900fb",
"icons/Icon-maskable-192.png": "222c1970e3058aad4daa19f7f26a774f",
"icons/Icon-maskable-512.png": "83a3c3681c5bd3485b184cfb194900fb",
"favicon.png": "84b4504fe2f8a1884201648c2d0094fe",
"manifest.json": "db7a21d34e9a68fa89345612b187c6b1",
"cms/canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"cms/canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"cms/canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"cms/canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"cms/canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"cms/canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"cms/canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"cms/canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"cms/canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"cms/canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"cms/canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"cms/canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"cms/flutter.js": "888483df48293866f9f41d3d9274a779",
"cms/flutter_bootstrap.js": "d3a0bffe7f312c7db79b596c2af613cb",
"cms/index.html": "2da5749e673fb710d47d4bff3db669b3",
"cms/main.dart.js": "d8736afa0951a02a74a278ac06f66ce7",
"cms/version.json": "2e6c09b4acae39d69c2a30c5d1491206",
"cms/assets/assets/images/app_icon.png": "9fbbdf59471bba6d7831745cbf298b8a",
"cms/assets/assets/images/favicon.png": "356bec0f0823d7d3bc67f6fb8b65f930",
"cms/assets/assets/images/app_icon_40.png": "88eaddf4c791f3bfa6a423772d1f1358",
"cms/assets/assets/images/app_icon_40@2x.png": "55e1fd573c76f82605bbb995c5914e03",
"cms/assets/assets/images/app_icon_36@2x.png": "fdd47541dfba5b96e3068e086f8cf4fe",
"cms/assets/assets/images/app_icon_36.png": "37e4b5dc833e249aea1d874d5df0fc57",
"cms/assets/fonts/MaterialIcons-Regular.otf": "24ba5f5f8b4a9b429d4f915ac4cfe4fc",
"cms/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"cms/assets/AssetManifest.json": "9443743275edb5d85fe5bab4d9f0a72f",
"cms/assets/AssetManifest.bin": "801faf324048b5b5e61671c4958f73a4",
"cms/assets/AssetManifest.bin.json": "f4b911abbbbe1c6c5612a1b781de94cf",
"cms/assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"cms/assets/NOTICES": "c151a3951e008cf4663671523ba697fb",
"cms/icons/Icon-192.png": "dae8d148e5840ce68a7f2a7e209fed95",
"cms/icons/Icon-512.png": "9fbbdf59471bba6d7831745cbf298b8a",
"cms/icons/Icon-maskable-192.png": "dae8d148e5840ce68a7f2a7e209fed95",
"cms/icons/Icon-maskable-512.png": "9fbbdf59471bba6d7831745cbf298b8a",
"cms/favicon.png": "356bec0f0823d7d3bc67f6fb8b65f930",
"cms/manifest.json": "3c2a7fd3f592d6b819623c81a6d4e320"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
