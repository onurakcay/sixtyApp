import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_widget.dart';

class PlatformBasedAlertDialog extends PlatformBasedWidget {
  final String title;
  final String content;
  final String okButtonText;
  final String cancelText;

  PlatformBasedAlertDialog({
    Key key,
    @required this.title,
    @required this.content,
    @required this.okButtonText,
    this.cancelText: null,
  });

  Future<bool> goster(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false)
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false);
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  List<Widget> _dialogButonlariniAyarla(BuildContext context) {
    final allButtons = <Widget>[];

    if (Platform.isIOS) {
      if (cancelText != null) {
        allButtons.add(
          CupertinoDialogAction(
            child: Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }
      allButtons.add(
        CupertinoDialogAction(
          child: Text(okButtonText),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    } else {
      if (cancelText != null) {
        allButtons.add(
          FlatButton(
            child: Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }
      allButtons.add(
        FlatButton(
          child: Text(okButtonText),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    }

    return allButtons;
  }
}
