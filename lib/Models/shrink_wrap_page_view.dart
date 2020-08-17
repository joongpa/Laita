import 'package:flutter/material.dart';

class ShrinkWrapPageView extends StatefulWidget {
  final List<Widget> children;

  const ShrinkWrapPageView({Key key, this.children}) : super(key: key);

  @override
  _ShrinkWrapPageViewState createState() => _ShrinkWrapPageViewState();
}

class _ShrinkWrapPageViewState extends State<ShrinkWrapPageView> {
  double height;
  GlobalKey stackKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  _afterLayout(_) {
    final RenderBox renderBoxRed = stackKey.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    setState(() {
      height = sizeRed.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget element;
    if (height == null) {
      element = Container();
    } else {
      element = Container(
        height: height + 20,
        child: PageView(
          children: widget.children,
        ),
      );
    }

    return IndexedStack(
      key: stackKey,
      children: <Widget>[
        element,
        ...widget.children,
      ],
    );
  }
}
