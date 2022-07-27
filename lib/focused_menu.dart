library focused_menu;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:focused_menu/modals.dart';

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final List<FocusedMenuItem>? secondaryMenuItems;
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
  final bool enabled;
  final bool allowBothTapLongPress;

  /// Open with tap insted of long press.
  final bool openWithTap;

  const FocusedMenuHolder(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.menuItems,
      this.secondaryMenuItems,
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
      this.jumpToPage, this.enabled = true, this.allowBothTapLongPress = false})
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
        onTap: widget.enabled?() async {
          widget.onPressed();
          if (widget.openWithTap || widget.allowBothTapLongPress) {
            await openMenu(context);
          }
        }:(){},
        onLongPress: widget.enabled?() async {
          widget.onPressed();
          if (!widget.openWithTap || widget.allowBothTapLongPress) {
            await openMenu(context);
          }
        }:(){},
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
                    secondaryMenuItems: widget.secondaryMenuItems,
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
  final List<FocusedMenuItem> menuItems;
  final List<FocusedMenuItem>? secondaryMenuItems;
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
      this.secondaryMenuItems,
      this.jumpToPage})
      : super(key: key);

  @override
  State<FocusedMenuDetails> createState() => _FocusedMenuDetailsState();
}

class _FocusedMenuDetailsState extends State<FocusedMenuDetails> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && widget.secondaryMenuItems != null) {
        _pageController.animateToPage(widget.jumpToPage!.index,
            duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = this.widget.maxMenuHeight ?? size.height * 0.45;
    final listHeight = widget.menuItems.map((e) => e.menuItemHeight).reduce(
            (a, b) =>
                (a ?? widget.itemExtent ?? 50.0) +
                (b ?? widget.itemExtent ?? 50.0)) ??
        widget.menuItems.length * (widget.itemExtent ?? 50.0);
    double listHeight2 = 0;
    if (widget.secondaryMenuItems != null) {
      listHeight2 = widget.secondaryMenuItems!
              .map((e) => e.menuItemHeight)
              .reduce((a, b) =>
                  (a ?? widget.itemExtent ?? 50.0) +
                  (b ?? widget.itemExtent ?? 50.0)) ??
          widget.menuItems.length * (widget.itemExtent ?? 50.0);
    }

    final maxMenuWidth = widget.menuWidth ?? (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (widget.childOffset.dx + maxMenuWidth) < size.width
        ? widget.childOffset.dx
        : (widget.childOffset.dx - maxMenuWidth + widget.childSize!.width);
    final topOffset = (widget.childOffset.dy +
                menuHeight +
                widget.childSize!.height) <
            size.height - widget.bottomOffsetHeight!
        ? widget.childOffset.dy + widget.childSize!.height + widget.menuOffset!
        : widget.childOffset.dy - menuHeight - widget.menuOffset!;
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
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: widget.menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.white,
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
                    child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ListView.builder(
                            itemCount: widget.menuItems.length,
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              FocusedMenuItem item = widget.menuItems[index];
                              Widget listItem = GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    item.onPressed();
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      // margin: const EdgeInsets.only(bottom: 1),
                                      decoration: BoxDecoration(
                                          color:
                                          item.backgroundColor ?? Colors.white,
                                          border: Border.all(
                                              color: Colors.white, width: 0,
                                          )),

                                      height: item.menuItemHeight ??
                                          widget.itemExtent ??
                                          50.0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 14),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            item.title,
                                            if (item.trailingIcon != null) ...[
                                              item.trailingIcon!
                                            ]
                                          ],
                                        ),
                                      )));
                              if (widget.animateMenu) {
                                return TweenAnimationBuilder(
                                    builder: (context, dynamic value, child) {
                                      return Transform(
                                        transform:
                                            Matrix4.rotationX(1.5708 * value),
                                        alignment: Alignment.bottomCenter,
                                        child: child,
                                      );
                                    },
                                    tween: Tween(begin: 1.0, end: 0.0),
                                    duration:
                                        Duration(milliseconds: index * 200),
                                    child: listItem);
                              } else {
                                return listItem;
                              }
                            },
                          ),
                          if (widget.secondaryMenuItems != null)
                            ListView.builder(
                              itemCount: widget.secondaryMenuItems!.length,
                              padding: EdgeInsets.zero,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                FocusedMenuItem item =
                                    widget.secondaryMenuItems![index];
                                Widget listItem = GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      item.onPressed();
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color:
                                            item.backgroundColor ?? Colors.white,
                                            border: Border.all(
                                              color: Colors.white, width: 0,
                                            )),
                                        height: item.menuItemHeight ??
                                            widget.itemExtent ??
                                            50.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 14),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              item.title,
                                              if (item.trailingIcon !=
                                                  null) ...[item.trailingIcon!]
                                            ],
                                          ),
                                        )));
                                if (widget.animateMenu) {
                                  return TweenAnimationBuilder(
                                      builder: (context, dynamic value, child) {
                                        return Transform(
                                          transform:
                                              Matrix4.rotationX(1.5708 * value),
                                          alignment: Alignment.bottomCenter,
                                          child: child,
                                        );
                                      },
                                      tween: Tween(begin: 1.0, end: 0.0),
                                      duration:
                                          Duration(milliseconds: index * 200),
                                      child: listItem);
                                } else {
                                  return listItem;
                                }
                              },
                            ),
                        ]),
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
