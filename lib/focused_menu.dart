library focused_menu;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:focused_menu/modals.dart';

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final Widget menuItems;
  final bool? animateMenuItems;
  final BoxDecoration? menuBoxDecoration;
  final Function onPressed;
  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;
  final double? maxMenuHeight;
  final FocusedMenuPages? jumpToPage;
  final bool disableMenu;
  final bool allowBothTapLongPress;

  /// Open with tap insted of long press.
  final bool openWithTap;

  const FocusedMenuHolder(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.menuItems,
      this.duration,
      this.menuBoxDecoration,
      this.menuItemExtent,
      this.animateMenuItems,
      this.blurSize,
      this.blurBackgroundColor,
      this.menuWidth,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.maxMenuHeight,
      this.openWithTap = false,
      this.jumpToPage,
      this.disableMenu = false,
      this.allowBothTapLongPress = false})
      : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = Offset(0, 0);
  Size? childSize;

  getOffset() {
    RenderBox renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: containerKey,
        onTap: widget.disableMenu
            ? () {}
            : () async {
                widget.onPressed();
                if (widget.openWithTap || (widget.allowBothTapLongPress)) {
                  await openMenu(context);
                }
              },
        onLongPress: widget.disableMenu
            ? () {}
            :() async {
          if ((!widget.openWithTap) || (widget.allowBothTapLongPress)) {
            await openMenu(context);
          }
        },
        child: widget.child);
  }

  Future openMenu(BuildContext context) async {
    getOffset();
    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: widget.duration ?? Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              animation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: FocusedMenuDetails(
                    jumpToPage: widget.jumpToPage,
                    maxMenuHeight: widget.maxMenuHeight,
                    itemExtent: widget.menuItemExtent,
                    menuBoxDecoration: widget.menuBoxDecoration,
                    child: widget.child,
                    childOffset: childOffset,
                    childSize: childSize,
                    menuItems: widget.menuItems,
                    blurSize: widget.blurSize,
                    menuWidth: widget.menuWidth,
                    blurBackgroundColor: widget.blurBackgroundColor,
                    animateMenu: widget.animateMenuItems ?? true,
                    bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
                    menuOffset: widget.menuOffset ?? 0,
                  ));
            },
            fullscreenDialog: true,
            opaque: false));
  }
}

enum FocusedMenuPages { first, second }

class FocusedMenuDetails extends StatefulWidget {
  final Widget menuItems;
  final BoxDecoration? menuBoxDecoration;
  final Offset childOffset;
  final double? itemExtent;
  final Size? childSize;
  final Widget child;
  final bool animateMenu;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;
  final double? maxMenuHeight;
  final FocusedMenuPages? jumpToPage;
  FocusedMenuDetails(
      {Key? key,
      required this.menuItems,
      required this.child,
      required this.childOffset,
      required this.childSize,
      required this.menuBoxDecoration,
      required this.itemExtent,
      required this.animateMenu,
      required this.blurSize,
      required this.blurBackgroundColor,
      required this.menuWidth,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.maxMenuHeight,
      this.jumpToPage})
      : super(key: key);

  @override
  State<FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<FocusedMenuDetails> {
  var widgetKey = GlobalKey();
  Size? size;
  Size? sizeOfChild;
  double? leftOffset;
  double? topOffset;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Size size = MediaQuery.of(context).size;
      sizeOfChild = widgetKey.currentContext!.size;
      leftOffset = (widget.childOffset.dx + sizeOfChild!.width) < size.width
          ? widget.childOffset.dx
          : (widget.childOffset.dx -
              sizeOfChild!.width +
              widget.childSize!.width);
      topOffset = (widget.childOffset.dy +
                  sizeOfChild!.height +
                  widget.childSize!.height) <
              size.height - widget.bottomOffsetHeight!
          ? widget.childOffset.dy +
              widget.childSize!.height +
              widget.menuOffset!
          : widget.childOffset.dy - sizeOfChild!.height - widget.menuOffset!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> currentMenuItems = menuItems;
    //
    //
    // final maxMenuHeight = this.maxMenuHeight ?? size.height * 0.45;
    // final listHeight = currentMenuItems.length * (itemExtent ?? 50.0);
    //
    // final maxMenuWidth = menuWidth ?? (size.width * 0.70);
    // final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: widget.blurSize ?? 4,
                      sigmaY: widget.blurSize ?? 4),
                  child: Container(
                    color: (widget.blurBackgroundColor ?? Colors.black)
                        .withOpacity(0.7),
                  ),
                )),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: widget.childSize!.width,
                  height: widget.childSize!.height,
                  decoration: widget.menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: Container(
                      key: widgetKey,
                      child: widget.menuItems,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: widget.childOffset.dy,
                left: widget.childOffset.dx,
                child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                        width: widget.childSize!.width,
                        height: widget.childSize!.height,
                        child: widget.child))),
          ],
        ),
      ),
    );
  }
}
