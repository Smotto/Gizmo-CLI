class Module
{
  String path;
  String name;
  String base10Handle;

  String get getPath
  {
    return path;
  }

  String get getName
  {
    return name;
  }

  String get getBase10Handle
  {
    return base10Handle;
  }

  set setPath(String path)
  {
    this.path = path;
  }

  set setName(String name)
  {
    this.name = name;
  }

  set setBase10Handle(String base10Handle)
  {
    this.base10Handle = base10Handle;
  }

  // Constructor
  Module(this.path, this.name, this.base10Handle);
}
