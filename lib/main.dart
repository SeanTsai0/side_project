import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = '聯絡人';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: ListTileSelectExample(isGridMode: false),
    );
  }
}

class ListTileSelectExample extends StatefulWidget {
  bool isGridMode;

  ListTileSelectExample({super.key,required this.isGridMode});

  @override
  ListTileSelectExampleState createState() => ListTileSelectExampleState(
      isGridMode: isGridMode);
}

class ListTileSelectExampleState extends State<ListTileSelectExample> {
  bool isSelectionMode = false;
  bool isGridMode;
  int? selectedId;

  ListTileSelectExampleState({required this.isGridMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('聯絡資訊'),
        leading: null,
        actions: <Widget>[
          if (isGridMode)
            IconButton(
              icon: const Icon(Icons.grid_on),
              onPressed: () {
                setState(() {
                  isGridMode = false;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                setState(() {
                  isGridMode = true;
                });
              },
            ),
        ],
      ),
      body: Center(
          child: FutureBuilder<List<PersonInfo>>(
              future: DatabaseHelper.instance.getPersonInfo(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<PersonInfo>> snapshot) {
                if (isGridMode)
                  return GridBuilder();
                return ListBuilder();
              }
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => editBuilder(isGridMode: isGridMode)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class GridBuilder extends StatefulWidget {
  const GridBuilder({
    super.key,
  });

  @override
  GridBuilderState createState() => GridBuilderState();
}

class GridBuilderState extends State<GridBuilder> {
  ImagePicker picker = ImagePicker();
  XFile? image;
  String? imgPath;
  int? selectedId;
  bool isGridMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: FutureBuilder<List<PersonInfo>>(
            future: DatabaseHelper.instance.getPersonInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<List<PersonInfo>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('無聯絡人'));
              }
              return snapshot.data!.isEmpty
                  ? Center(child: Text('無聯絡人'))
                  : GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: snapshot.data!.map((personInfos) {
                    return Center(
                      child: GridTile(
                        child: Column(
                          children: <Widget>[
                            Image(
                              height: 82,
                                width:140,
                                image: FileImage(File(personInfos.img))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: (){
                                      if(personInfos.id != null) {
                                        setState(() {
                                          selectedId = personInfos.id;
                                        });
                                      }
                                      Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailBuilder(
                                                      selectedId: personInfos.id!,
                                                      selectedName: personInfos.name,
                                                      selectedImg: personInfos.img,
                                                      selectedLine: personInfos.line,
                                                      selectedMail: personInfos.mail,
                                                      selectedNumber: personInfos.number,
                                                      selectedFb: personInfos.fb,
                                                      selectedIg: personInfos.ig,
                                                      isGridMode: true,
                                                  )));
                                    },
                                    child: Icon(Icons.more_horiz)),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: (){
                                      DatabaseHelper.instance.delete(
                                          personInfos.id!);
                                      setState(() {
                                      });
                                    },
                                    child: Icon(Icons.delete))
                              ],
                            )
                          ],
                        ),
                      ),);
                  }).toList());
            }),
      ),
    );
  }
}

class ListBuilder extends StatefulWidget {
  const ListBuilder({super.key,});

  @override
  State<ListBuilder> createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  ImagePicker picker = ImagePicker();
  XFile? image;
  String? imgPath;
  int? selectedId;
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  bool isGridMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: FutureBuilder<List<PersonInfo>>(
            future: DatabaseHelper.instance.getPersonInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<List<PersonInfo>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('無聯絡人'));
              }
              return snapshot.data!.isEmpty
                  ? Center(child: Text('無聯絡人'))
                  : ListView(
                  children: snapshot.data!.map((personInfos) {
                    return Center(
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                          onTap: (){
                            if(personInfos.id != null) {
                                  setState(() {
                                    selectedId = personInfos.id;
                                  });
                                }
                                Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailBuilder(
                                            selectedId: personInfos.id!,
                                            selectedName: personInfos.name,
                                            selectedImg: personInfos.img,
                                            selectedLine: personInfos.line,
                                            selectedMail: personInfos.mail,
                                            selectedNumber: personInfos.number,
                                            selectedFb: personInfos.fb,
                                            selectedIg: personInfos.ig,
                                            isGridMode: false,
                                        )));
                          },
                          leading: Image(
                            width: 50,
                            height: 50,
                            fit: BoxFit.fitHeight,
                            image: FileImage(File(personInfos.img))
                          ),
                            title: Text(personInfos.name,style: TextStyle(fontSize: 20),),
                            trailing: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        DatabaseHelper.instance.delete(
                                            personInfos.id!);
                                        setState(() {
                                        });
                                      },
                                      icon: Icon(Icons.delete))
                                ])));
                  }).toList());
            }),
      ),
    );
  }
}

class DetailBuilder extends StatefulWidget {
  int selectedId;
  String selectedName;
  String selectedImg;
  String selectedLine;
  String selectedMail;
  String selectedNumber;
  String selectedFb;
  String selectedIg;
  bool isGridMode;

  DetailBuilder({
    super.key,
    required this.selectedId,
    required this.selectedName,
    required this.selectedImg,
    required this.selectedLine,
    required this.selectedMail,
    required this.selectedNumber,
    required this.selectedFb,
    required this.selectedIg,
    required this.isGridMode,
  });
  
  @override
  State<DetailBuilder> createState() => _DetailBuilderState(
    selectedId: selectedId,
    selectedName: selectedName,
    selectedImg: selectedImg,
    selectedLine: selectedLine,
    selectedMail: selectedMail,
    selectedNumber: selectedNumber,
    selectedFb: selectedFb,
    selectedIg: selectedIg,
    isGridMode:isGridMode,
  );
}

class _DetailBuilderState extends State<DetailBuilder> {
  int selectedId;
  String selectedName;
  String selectedImg;
  String selectedLine;
  String selectedMail;
  String selectedNumber;
  String selectedFb;
  String selectedIg;
  final nameController = TextEditingController();
  final lineController = TextEditingController();
  final mailController = TextEditingController();
  final numberController = TextEditingController();
  final fbController = TextEditingController();
  final igController = TextEditingController();
  ImagePicker picker = ImagePicker();
  XFile? image;
  bool isGridMode;

  _DetailBuilderState({
    required this.selectedId,
    required this.selectedName,
    required this.selectedImg,
    required this.selectedLine,
    required this.selectedMail,
    required this.selectedNumber,
    required this.selectedFb,
    required this.selectedIg,
    required this.isGridMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder:(BuildContext context) {
                return ListTileSelectExample(isGridMode: this.isGridMode);
              })
          )
        ),
      ),
      body: Center(
        child: FutureBuilder<List<PersonInfo>>(
          future: DatabaseHelper.instance.getPersonInfo(),
            builder: (BuildContext context,
                AsyncSnapshot<List<PersonInfo>> snapshot) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Image(
                      height: 100,width: 100,
                      image: FileImage(File(selectedImg))),
                      TextButton(
                          onPressed: () async{
                            image = await picker.pickImage(source: ImageSource.gallery);
                            setState(() async {
                              await DatabaseHelper.instance.update(
                                  PersonInfo(
                                      id: selectedId,
                                      name: selectedName,
                                      img: image!.path,
                                      line: lineController.text,
                                      mail: mailController.text,
                                      number: numberController.text,
                                      fb: fbController.text,
                                      ig: igController.text
                                  ));
                              setState(() {
                                selectedImg = image!.path;
                              });
                            });
                          },
                          child: Text('變更'))//更改圖片的按鈕
                    ]
                  ),//IMG
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('姓名 :', style: TextStyle(fontSize: 50)),
                      Text('$selectedName ', style: TextStyle(fontSize: 50)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              nameController.text = selectedName;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: nameController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                id: selectedId,
                                                name: nameController.text,
                                                img: selectedImg,
                                                line: lineController.text,
                                                mail: mailController.text,
                                                number: numberController.text,
                                                fb: fbController.text,
                                                ig: igController.text
                                              ));
                                          setState(() {
                                            selectedName = nameController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Text('變更')
                      ),
                    ],
                  ),//NAME
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('LINE :', style: TextStyle(fontSize: 30)),
                      Text('$selectedLine', style: TextStyle(fontSize: 30)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              lineController.text = selectedLine;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: lineController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                  id: selectedId,
                                                  name: nameController.text,
                                                  img: selectedImg,
                                                  line: lineController.text,
                                                  mail: mailController.text,
                                                  number: numberController.text,
                                                  fb: fbController.text,
                                                  ig: igController.text
                                              ));
                                          setState(() {
                                            selectedLine = lineController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],

                                  );
                                }
                            );
                          },
                          child: Text('變更')
                      ),
                    ],
                  ),//LINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('mail :', style: TextStyle(fontSize: 30)),
                      Text('$selectedMail', style: TextStyle(fontSize: 20)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              mailController.text = selectedMail;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: mailController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                  id: selectedId,
                                                  name: nameController.text,
                                                  img: selectedImg,
                                                  line: lineController.text,
                                                  mail: mailController.text,
                                                  number: numberController.text,
                                                  fb: fbController.text,
                                                  ig: igController.text
                                              ));
                                          setState(() {
                                            selectedMail = mailController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],

                                  );
                                }
                            );
                          },
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text('變更'),
                          )
                      ),
                    ],
                  ),//MAIL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('電話號碼 :', style: TextStyle(fontSize: 30)),
                      Text('$selectedNumber', style: TextStyle(fontSize: 30)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              numberController.text = selectedNumber;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: numberController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                  id: selectedId,
                                                  name: nameController.text,
                                                  img: selectedImg,
                                                  line: lineController.text,
                                                  mail: mailController.text,
                                                  number: numberController.text,
                                                  fb: fbController.text,
                                                  ig: igController.text
                                              ));
                                          setState(() {
                                            selectedNumber = numberController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Text('變更')
                      ),
                    ],
                  ),//電話號碼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Facebook :', style: TextStyle(fontSize: 30)),
                      Text('$selectedFb', style: TextStyle(fontSize: 30)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              fbController.text = selectedFb;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: fbController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                  id: selectedId,
                                                  name: nameController.text,
                                                  img: selectedImg,
                                                  line: lineController.text,
                                                  mail: mailController.text,
                                                  number: numberController.text,
                                                  fb: fbController.text,
                                                  ig: igController.text
                                              ));
                                          setState(() {
                                            selectedFb = fbController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Text('變更')
                      ),
                    ],
                  ),//FACEBOOK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Instagram :', style: TextStyle(fontSize: 30)),
                      Text('$selectedIg', style: TextStyle(fontSize: 30)),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              igController.text = selectedIg;
                            });
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: TextField(
                                      controller: igController,
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text("OK"),
                                        onPressed: () async {
                                          await DatabaseHelper.instance.update(
                                              PersonInfo(
                                                  id: selectedId,
                                                  name: nameController.text,
                                                  img: selectedImg,
                                                  line: lineController.text,
                                                  mail: mailController.text,
                                                  number: numberController.text,
                                                  fb: fbController.text,
                                                  ig: igController.text
                                              ));
                                          setState(() {
                                            selectedIg = igController.text;
                                          });
                                          Navigator.pop(context, PersonInfo);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text("CANCEL"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],

                                  );
                                }
                            );
                          },
                          child: Text('變更')
                      ),
                    ],
                  )//INSTAGRAM
                ],
              ),
            );
            }
    ),
      )
    );
  }
}

class editBuilder extends StatefulWidget {
  editBuilder({Key? key, required this.isGridMode}) : super(key: key);
  bool isGridMode;

  @override
  State<editBuilder> createState() => _editBuilderState(isGridMode:isGridMode);
}

class _editBuilderState extends State<editBuilder> {
  final nameController = TextEditingController();
  final lineController = TextEditingController();
  final mailController = TextEditingController();
  final numberController = TextEditingController();
  final fbController = TextEditingController();
  final igController = TextEditingController();
  ImagePicker picker = ImagePicker();
  XFile? image;
  bool isGridMode;

  _editBuilderState({required this.isGridMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 25),
              (image == null)
                  ?const Icon(Icons.image,size:50)
                  :Image(
                      width: 100,
                      height:100,
                      image:FileImage(File(image!.path))),
              (image == null)?TextButton(
                onPressed: () async{
                  image = await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                  });
                },
                child: Text("加入照片")
              )
                  :TextButton(onPressed: ()async{
                    image = await picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                    });
                  },
                  child: Text("修改照片")),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人名稱",
                ),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人LINE",
                ),
                controller: lineController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人E-mail",
                ),
                controller: mailController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人電話",
                ),
                controller: numberController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人facebook",
                ),
                controller: fbController,
              ),
              TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_box),
                  labelText: "輸入聯絡人Instagram",
                ),
                controller: igController,
              ),
              ElevatedButton(
                  onPressed: () async {
                    DatabaseHelper.instance.add(
                        PersonInfo(
                          name: nameController.text,
                          img: image!.path,
                          line: lineController.text,
                          mail: mailController.text,
                          number: numberController.text,
                          fb: fbController.text,
                          ig: igController.text
                        ));
                    setState(() {
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder:(BuildContext context) {
                          return ListTileSelectExample(isGridMode: false) ;
                        })
                    );
                  },
                  child: const Icon(Icons.check),)
            ],
          )
      ),
    );
  }
}

class PersonInfo {
  final int? id;
  final String name;
  final String img;
  final String number;
  final String mail;
  final String line;
  final String ig;
  final String fb;

  PersonInfo({
    this.id,
    required this.name,
    required this.img,
    required this.number,
    required this.mail,
    required this.line,
    required this.ig,
    required this.fb
  });

  factory PersonInfo.fromMap(Map<String, dynamic> json) =>
      new PersonInfo(
        id: json['id'],
        name: json['name'],
        img: json['img'],
        number: json['number'],
        mail: json['mail'],
        line: json['line'],
        ig: json['ig'],
        fb: json['fb'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'img': img,
      'number': number,
      'mail': mail,
      'line': line,
      'ig': ig,
      'fb': fb,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'personInfo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE personInfo(
    id INTEGER PRIMARY KEY,
    name TEXT,
    img TEXT,
    number TEXT,
    mail TEXT,
    line TEXT,
    ig TEXT,
    fb TEXT
    )
    ''');
  }

  Future<List<PersonInfo>> getPersonInfo() async {
    Database db = await instance.database;
    var personInfos = await db.query('personInfo', orderBy: 'name');
    List<PersonInfo> personInfoList = personInfos.isNotEmpty
        ? personInfos.map((c) => PersonInfo.fromMap(c)).toList()
        : [];
    return personInfoList;
  }

  Future<int> add(PersonInfo personInfo) async {
    Database db = await instance.database;
    return await db.insert('personInfo', personInfo.toMap());
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete('personInfo', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(PersonInfo personInfo) async {
    Database db = await instance.database;
    return await db.update('personInfo', personInfo.toMap(),
        where: 'id = ?', whereArgs: [personInfo.id]);
  }
}
