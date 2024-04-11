part of three_loaders;

/// Abstract Base class to load generic binary textures formats (rgbe, hdr, ...)
///
/// Sub classes have to implement the parse() method which will be used in load().
class TextureLoaderData{
  TextureLoaderData({
    this.width,
    this.height,
    this.data,
    required this.type,
    this.format,
    this.gamma,
    this.exposure,
    this.header,
    this.mipmapCount,
    this.generateMipmaps,
    this.flipY,
    this.encoding,
    this.anisotropy = 1,
    this.minFilter = LinearFilter,
    this.magFilter = LinearFilter,
    this.wrapS = ClampToEdgeWrapping,
    this.wrapT = ClampToEdgeWrapping,
    this.image
  });
  
  num? width;
  num? height;
  dynamic data;
  String? header;
  int? format;
  num? gamma;
  num? exposure;
  int type;
  int? mipmapCount;
  bool? generateMipmaps;
  List? mipmaps;
  bool? flipY;
  int? encoding;
  int anisotropy;
  int? minFilter;
  int? magFilter;
  int? wrapS;
  int? wrapT;
  dynamic image;

  Map<String,dynamic> get json => {
    'width': width,
    'height': height,
    'data': data,
    'header': header,
    'format': format,
    'gamma': gamma,
    'exposure': exposure,
    'type': type,
    'mipmapCount': mipmapCount,
    'generateMipmaps': generateMipmaps,
    'mipmaps': mipmaps,
    'flipY': flipY,
    'encoding': encoding,
    'anisotropy': anisotropy,
    'magFilter': magFilter,
    'minFilter': minFilter,
    'wrapS': wrapS,
    'wrapT': wrapT
  };
}

class DataTextureLoader extends Loader {
  DataTextureLoader([LoadingManager? manager]) : super(manager);

  parse(Uint8List json){}

  @override
  dynamic load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    final scope = this;

    final texture = DataTexture();

    final loader = FileLoader(manager);
    loader.setResponseType('arraybuffer');
    loader.setRequestHeader(requestHeader);
    loader.setPath(path);
    loader.setWithCredentials(scope.withCredentials);
    loader.load(
      url, 
      (buffer){
        final Map<String,dynamic> texData = scope.parse(buffer);

        if (texData == null) return;

        if (texData['image'] != null) {
          texture.image = texData['image'];
        } 
        else if (texData["data"] != null) {
          texture.image.width = texData["width"].toInt();
          texture.image.height = texData["height"].toInt();
          texture.image.data = texData["data"];
        }

        texture.wrapS =
            texData["wrapS"] ?? ClampToEdgeWrapping;
        texture.wrapT =
            texData["wrapT"] ?? ClampToEdgeWrapping;

        texture.magFilter =
            texData["magFilter"] ?? LinearFilter;
        texture.minFilter =
            texData["minFilter"] ?? LinearFilter;

        texture.anisotropy =
            texData["anisotropy"] ?? 1;

        if (texData["encoding"] != null) {
          texture.encoding = texData["encoding"];
        }

        if (texData["flipY"] != null) {
          texture.flipY = texData["flipY"];
        }

        if (texData["format"] != null) {
          texture.format = texData["format"];
        }

        if (texData["type"] != null) {
          texture.type = texData["type"];
        }

        if (texData["mipmaps"] != null) {
          texture.mipmaps = texData["mipmaps"];
          texture.minFilter = LinearMipmapLinearFilter; // presumably...

        }

        if (texData["mipmapCount"] == 1) {
          texture.minFilter = LinearFilter;
        }

        if (texData["generateMipmaps"] != null) {
          texture.generateMipmaps = texData["generateMipmaps"];
        }

        texture.needsUpdate = true;

        onLoad(texture, texData);
      }, 
      onProgress, 
      onError
    );

    return texture;
  }
}
