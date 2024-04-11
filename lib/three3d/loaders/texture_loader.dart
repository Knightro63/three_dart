part of three_loaders;

class TextureLoader extends Loader {
  TextureLoader([LoadingManager? manager,this.flipY = false]):super(manager);
  bool flipY;

  Texture? _textureProcess(ImageElement? imageElement, String url){
    final Texture texture = Texture();
    //image = image?.convert(format:Format.uint8,numChannels: 4);
    if(imageElement != null){
      // ImageElement imageElement = ImageElement(
      //   url: url,
      //   data: Uint8Array.from(image.getBytes()),
      //   width: image.width,
      //   height: image.height
      // );
      texture.image = imageElement;
      texture.needsUpdate = true;

      return texture;
    }

    return null;
  }
  @override
  Future<Texture?> fromNetwork(Uri uri) async{
    final url = uri.path;
    final ImageElement? image = await ImageLoader(manager,flipY).fromNetwork(uri);
    return _textureProcess(image,url);
  }
  @override
  Future<Texture?> fromFile(File file) async{
    Uint8List bytes = await file.readAsBytes();
    final String url = String.fromCharCodes(bytes).toString().substring(0,50);
    final ImageElement? image = await ImageLoader(manager,flipY).fromBytes(bytes);
    return _textureProcess(image,url);
  }
  @override
  Future<Texture?> fromPath(String filePath) async{
    final ImageElement? image = await ImageLoader(manager,flipY).fromPath(filePath);
    return _textureProcess(image,filePath);
  }
  @override
  Future<Texture?> fromBlob(Blob blob) async{
    final String url = String.fromCharCodes(blob.data).toString().substring(0,50);
    final ImageElement? image = await ImageLoader(manager,flipY).fromBlob(blob);
    return _textureProcess(image,url);
  }
  @override
  Future<Texture?> fromAsset(String asset, {String? package}) async{
    final ImageElement? image = await ImageLoader(manager,flipY).fromAsset(asset, package: package);
    return _textureProcess(image,'$package/$asset');
  }
  @override
  Future<Texture?> fromBytes(Uint8List bytes) async{
    final String url = String.fromCharCodes(bytes).toString().substring(0,50);
    final ImageElement? image = await ImageLoader(manager,flipY).fromBytes(bytes);
    return _textureProcess(image,url);
  }

  @override
  @Deprecated("Please use TextureLoader with type.")
  Future<Texture> loadAsync(url, [Function? onProgress, Function? onError]) async {
    Completer<Texture> completer = Completer<Texture>();

    load(url, (texture) {
      completer.complete(texture);
    }, onProgress, onError);

    return completer.future;
  }
  @override
  @Deprecated("Please use TextureLoader with type.")
  void load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    final Texture texture = Texture();

    final ImageLoader loader = ImageLoader(manager);
    loader.setCrossOrigin(crossOrigin);
    loader.setPath(path);

    final Completer<Texture> completer = Completer<Texture>();
    loader.flipY = flipY;
    loader.load(url, (image) {
      ImageElement imageElement;

      // Web better way ???
      if (kIsWeb && image is! Image) {
        imageElement = ImageElement(
          url: url is Blob ? "" : url,
          data: image,
          width: image.width!.toDouble(),
          height: image.height!.toDouble()
        );
      } 
      else {
        image = image as Image;
        image = image.convert(format:Format.uint8,numChannels: 4);

        // print(" _pixels : ${_pixels.length} ");
        // print(" ------------------------------------------- ");
        imageElement = ImageElement(
          url: url,
          data: Uint8Array.from(image.getBytes()),
          width: image.width,
          height: image.height
        );
      }

      // print(" image.width: ${image.width} image.height: ${image.height} isJPEG: ${isJPEG} ");

      texture.image = imageElement;
      texture.needsUpdate = true;

      onLoad(texture);

      completer.complete(texture);
    }, onProgress, onError);

    //return completer.future;
  }

  @override
  TextureLoader setPath(String path){
    super.setPath(path);
    return this;
  }
  @override
  TextureLoader setCrossOrigin(String crossOrigin) {
    super.setCrossOrigin(crossOrigin);
    return this;
  }
  @override
  TextureLoader setWithCredentials(bool value) {
    super.setWithCredentials(value);
    return this;
  }
  @override
  TextureLoader setResourcePath(String? resourcePath) {
    super.setResourcePath(resourcePath);
    return this;
  }
  @override
  TextureLoader setRequestHeader(Map<String, dynamic> requestHeader) {
    super.setRequestHeader(requestHeader);
    return this;
  }
}
