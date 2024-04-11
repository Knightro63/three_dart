part of three_loaders;

class ImageLoader extends Loader {
  ImageLoader([LoadingManager? manager, this.flipY = false]):super(manager);
  bool flipY;

  @override
  Future<ImageElement?> fromNetwork(Uri uri) async{
    final url = uri.path;
    final cacheName = url;
    
    final cached = Cache.get(cacheName);

    if (cached != null) {
      manager.itemStart(cacheName);
      manager.itemEnd(cacheName);
      return cached;
    }

    //final resp = await ImageLoaderLoader.loadImage(url, flipY);
    
    final http.Response? response = kIsWeb? null:await http.get(Uri.parse(url));
    final bytes = kIsWeb? null:response!.bodyBytes;
    final resp = imageProcess2(bytes,url,flipY);

    Cache.add(cacheName,resp);
    return resp;
  }
  @override
  Future<ImageElement?> fromFile(File file) async{
    final Uint8List data = await file.readAsBytes();
    return await fromBytes(data);
  }
  @override
  Future<ImageElement?> fromPath(String fielPath) async{
    final File file = File(path+fielPath);
    final Uint8List data = await file.readAsBytes();
    return await fromBytes(data);
  }
  @override
  Future<ImageElement?> fromBlob(Blob blob) async{
    if(kIsWeb){
      final hblob = uhtml.Blob([blob.data.buffer], blob.options["type"]);
      return imageProcess2(null, uhtml.Url.createObjectUrl(hblob),flipY);
    }
    return await fromBytes(blob.data);
  }
  @override
  Future<ImageElement?> fromAsset(String asset, {String? package}) async{
    String? cacheName;
    asset = package != null?'assets/$package/$asset':asset;//path + asset;
    cacheName = asset;

    asset = manager.resolveURL(asset);
    final cached = Cache.get(cacheName);

    if (cached != null) {
      manager.itemStart(cacheName);
      manager.itemEnd(cacheName);
      return cached;
    }

    //final resp = await ImageLoaderLoader.loadImage(asset, flipY);

    final ByteData fileData = await rootBundle.load(asset);
    final bytes = fileData.buffer.asUint8List();
    final resp = imageProcess2(bytes,kIsWeb?'assets/$asset':asset,flipY);

    Cache.add(cacheName,resp);
    return resp;
  }
  @override
  Future<ImageElement?> fromBytes(Uint8List bytes) async{
    String cacheName = String.fromCharCodes(bytes).toString().substring(0,50);
    final cached = Cache.get(cacheName);

    if (cached != null) {
      manager.itemStart(cacheName);
      manager.itemEnd(cacheName);
      return cached;
    }

    final resp = imageProcess2(bytes,null,flipY);
    Cache.add(cacheName,resp);
    return resp;
  }

  
  @override
  @Deprecated("Please use ImageLoader with type.")
  Future loadAsync(url, [Function? onProgress, Function? onError]) async {
    final Completer completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    }, onProgress, onError);

    return completer.future;
  }
  @override
  @Deprecated("Please use ImageLoader with type.")
  dynamic load(url, Function onLoad, [Function? onProgress, Function? onError]) async {
    String? cacheName;
    if (path != "" && url is String) {
      url = path + url;
      cacheName = url;
    }
    else if(url is Blob){
      cacheName = String.fromCharCodes(url.data).toString().substring(0,50);
    }

    url = manager.resolveURL(url);
    cacheName ??= url;
    final cached = Cache.get(cacheName);

    if (cached != null) {
      manager.itemStart(cacheName);
      
      manager.itemEnd(cacheName);
      onLoad(cached);
      return cached;
    }

    final resp = await ImageLoaderLoader.loadImage(url, flipY);
    Cache.add(cacheName,resp);
    onLoad(resp);

    return resp;
  }
}
