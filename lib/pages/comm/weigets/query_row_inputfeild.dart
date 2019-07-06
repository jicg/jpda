import 'package:flutter/material.dart';

import 'query_row_layout_iconbutton.dart';

class QueryRowInputFeild extends StatefulWidget {
  @override
  _QueryRowInputFeildState createState() => _QueryRowInputFeildState();
}

class _QueryRowInputFeildState extends State<QueryRowInputFeild> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

//  @override
//  Widget build(BuildContext context) {
//    return QueryRowLayoutIconButton(
//      child: TextField(
//        autofocus: true,
//        controller: _controller,
//        focusNode: _focusNote,
//        textInputAction: TextInputAction.next,
//        decoration: InputDecoration(border: InputBorder.none),
//        //内容提交(按回车)的回调
//        enabled: _pdtEnable,
//        onSubmitted: (text) {
//          _pdtFocusNote.unfocus();
//          FocusScope.of(context)
//              .requestFocus(_storeFocusNote);
//        },
//      ),
//      onTap: () async {
//        if (!_pdtEnable) {
//          _pdtEnable = true;
//          _pdtController.text = "";
//          return;
//        }
//        var d = await Navigator.of(context)
//            .pushNamed("/comm/query/product");
//        List<Map> dd = d as List<Map>;
//        if (dd.length > 0) {
//          String name = "";
//          dd.forEach((f) {
//            name += f["code"] + ",";
//          });
//          _pdtController.text = name;
//          _pdtEnable = false;
//        }
//      },
//    );
//  }
}
