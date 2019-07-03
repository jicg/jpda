import 'package:flutter/material.dart';

class StockHome extends StatefulWidget {
  @override
  _StockHomeState createState() => _StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("库存查询"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/stock/query");
            },
            tooltip: "查询",
          ),
//          PopupMenuButton<String>(
//            onSelected: (s) {
//              print(s);
//            },
//            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                  const PopupMenuItem<String>(
//                    value: 'doc',
//                    child: ListTile(
//                      leading: Icon(
//                        Icons.library_books,
//                        size: 22.0,
//                      ),
//                      title: Text('查看文档'),
//                    ),
//                  ),
//                  const PopupMenuDivider(
//                    height: 1.0,
//                  ),
//                  const PopupMenuItem<String>(
//                    value: 'code',
//                    child: ListTile(
//                      leading: Icon(
//                        Icons.code,
//                        size: 22.0,
//                      ),
//                      title: Text('查看Demo'),
//                    ),
//                  ),
//                ],
//          ),
        ],
      ),
      body: Container(
        child: StockItemWidget(),
      )
    );
  }
}

class StockItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "店仓",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "条码",
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
            Text(
              "100",
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

//class searchBarDelegate extends SearchDelegate<String> {
//  @override
//  List<Widget> buildActions(BuildContext context) {
//    return [
//      IconButton(
//        icon: Icon(Icons.clear),
//        onPressed: () => query = "",
//      ),
//    ];
//  }
//
//  @override
//  Widget buildLeading(BuildContext context) {
//    return IconButton(
//      icon: AnimatedIcon(
//          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
//      onPressed: () {
//        close(context, null);
////        if (query.isEmpty) {
////          close(context, null);
////        } else {
////          query = "";
////          showSuggestions(context);
////        }
//      },
//    );
//  }
//
//  @override
//  Widget buildResults(BuildContext context) {
//    return new Container(
//      child: Text(this.query + "  buildResults"),
//    );
//  }
//
//  @override
//  Widget buildSuggestions(BuildContext context) {
//    return new Container(
//      child: Text(this.query + " buildSuggestions"),
//    );
//  }
//
//  @override
//  ThemeData appBarTheme(BuildContext context) {
//    // TODO: implement appBarTheme
//    return super.appBarTheme(context);
//  }
//}
