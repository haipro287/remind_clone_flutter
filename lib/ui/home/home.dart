import 'package:flutter/material.dart';
import 'package:remind_clone_flutter/stores/classroom_store.dart';
import 'package:remind_clone_flutter/stores/user_store.dart';
import 'package:remind_clone_flutter/models/classroom.dart';
import 'widgets/home_tab_message.dart';
import 'package:provider/provider.dart';

enum MenuActions { account, logOut }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, Widget> tabs = {
    "Messages": MessageTab(),
    "Files": Center(
      child: Text("Files"),
    ),
    "People": Center(
      child: Text("People"),
    ),
    "Settings": Center(
      child: Text("Settings"),
    ),
  };

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Class"),
        bottom: TabBar(
          controller: this._tabController,
          isScrollable: true,
          tabs: <Tab>[
            for (final tabLabel in this.tabs.keys)
              Tab(
                text: tabLabel,
              )
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              //TODO: Implement search bar
              print("Show search bar");
            },
            //TODO: Use variables or constant instead of a 'magic number'
            splashRadius: 20.0,
          ),
          PopupMenuButton<MenuActions>(
            onSelected: (result) {
              if (result == MenuActions.logOut) {
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<MenuActions>>[
                const PopupMenuItem(
                  child: Text("Select me!"),
                ),
                const PopupMenuItem(
                  child: Text("Select me!"),
                ),
                const PopupMenuItem(
                  value: MenuActions.logOut,
                  child: Text("Get me out!"),
                ),
              ];
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: this._tabController,
        children: <Widget>[for (final tab in this.tabs.values) tab],
      ),
      drawer: buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.create,
        ),
        onPressed: () {
          print(this._tabController.index);
        },
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    var classroomStore = Provider.of<ClassroomStore>(context);
    var joinedClassrooms = classroomStore.getJoinedClassrooms();
    var ownedClassrooms = classroomStore.getOwnedClassrooms();

    List<ListTile> joinedClassroomTiles = [];
    for (Classroom classroom in joinedClassrooms) {
      joinedClassroomTiles.add(ListTile(
        title: Text(classroom.name),
        onTap: () {},
      ));
    }

    List<ListTile> ownedClassroomTiles = [];
    for (Classroom classroom in ownedClassrooms) {
      ownedClassroomTiles.add(ListTile(
        title: Text(classroom.name),
        onTap: () {},
      ));
    }

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Center(
              child: Consumer<UserStore>(
                builder: (context, store, child) {
                  String userName = store.getUser().name;
                  return Text(
                    userName,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                  );
                },
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ...joinedClassroomTiles,
          ...ownedClassroomTiles,
        ],
      ),
    );
  }
}
