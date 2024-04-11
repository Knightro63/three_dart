part of three_loaders;

class FileLoader extends Loader {
  FileLoader([LoadingManager? manager]) : super(manager);

  @override
  @Deprecated("Please use FileLoader with type.")
  Future loadAsync(url) async {
    Completer completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    });

    return completer.future;
  }

  @override
  @Deprecated("Please use FileLoader with type.")
  dynamic load(url, Function onLoad, [Function? onProgress, Function? onError]) async {
    url ??= '';

    url = path + url;

    url = manager.resolveURL(url);

    FileLoader scope = this;

    var cached = Cache.get(url!);

    if (cached != null) {
      scope.manager.itemStart(url);

      onLoad(cached);
      scope.manager.itemEnd(url);

      return cached;
    }

    // Check if request is duplicate

    if (loading[url] != null) {
      loading[url].add({
        "onLoad": onLoad,
        "onProgress": onProgress, 
        "onError": onError
      });

      return;
    }

    // Check for data: URI
    RegExp dataUriRegex = RegExp(r"^data:(.*?)(;base64)?,(.*)$");
    RegExpMatch? dataUriRegexResult = dataUriRegex.firstMatch(url);
    var request;

    // Safari can not handle Data URIs through XMLHttpRequest so process manually
    if (dataUriRegex.hasMatch(url)) {
      RegExpMatch? dataUriRegexResult = dataUriRegex.firstMatch(url)!;

      String? mimeType = dataUriRegexResult.group(1);
      bool isBase64 = dataUriRegexResult.group(2) != null;

      String? data = dataUriRegexResult.group(3)!;
      // data = decodeURIComponent( data );

      Uint8List? base64Data;

      if (isBase64) base64Data = convert.base64.decode(data);

      // try {

      var response;
      String responseType = (this.responseType).toLowerCase();

      switch (responseType) {
        case 'arraybuffer':
        case 'blob':
          if (responseType == 'blob') {
            // response = new Blob( [ view.buffer ], { type: mimeType } );
            throw (" FileLoader responseType: $responseType need support .... ");
          } else {
            response = base64Data;
          }
          break;
        case 'document':
          // var parser = new DOMParser();
          // response = parser.parseFromString( data, mimeType );
          throw ("FileLoader responseType: $responseType is not support ....  ");
        case 'json':
          response = convert.jsonDecode(data);
          break;
        default: // 'text' or other
          response = data;
          break;
      }

      // Wait for next browser tick like standard XMLHttpRequest event dispatching does
      Future.delayed(Duration.zero, () {
        onLoad(response);

        scope.manager.itemEnd(url!);
      });

      return;
    }

    // Initialise array for duplicate requests

    loading[url] = [];

    loading[url].add({
      "onLoad": onLoad, 
      "onProgress": onProgress, 
      "onError": onError
    });

    var callbacks = loading[url];

    dynamic respData;
    if (!kIsWeb && !url.startsWith("http")) {
      if (url.startsWith("assets") || url.startsWith("packages")) {
        if (responseType == "text") {
          respData = await rootBundle.loadString(url);
        } else {
          ByteData resp = await rootBundle.load(url);
          respData = Uint8List.view(resp.buffer);
        }
      } else {
        var file = File(url);

        if (responseType == "text") {
          respData = await file.readAsString();
        } else {
          respData = await file.readAsBytes();
        }
      }
    } 
    else {
      if (url.startsWith("assets") || url.startsWith("packages")) {
        url = "assets/$url";
      }

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        for (var i = 0, il = callbacks.length; i < il; i++) {
          var callback = callbacks[i];
          if (callback["onError"] != null) callback["onError"](response.body);
        }

        scope.manager.itemError(url);
        scope.manager.itemEnd(url);
      }

      if (responseType == "text") {
        respData = response.body;
      } else {
        respData = response.bodyBytes;
      }
    }

    //loading.remove(url);

    // Add to cache only on HTTP success, so that we do not cache
    // error response bodies as proper responses to requests.
    Cache.add(url, respData);

    for (var i = 0, il = callbacks.length; i < il; i++) {
      var callback = callbacks[i];
      if (callback["onLoad"] != null) callback["onLoad"](respData);
    }

    scope.manager.itemEnd(url);

    //return respData;
  }

  FileLoader setResponseType(String value) {
    responseType = value;
    return this;
  }

  FileLoader setMimeType(String value) {
    mimeType = value;
    return this;
  }
}
