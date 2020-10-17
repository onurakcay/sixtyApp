import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final double radius;
  final double buttonHeight;
  final Widget buttonIcon;
  final VoidCallback onPressed;

  const SocialLoginButton(
      {Key key,
      @required this.buttonText,
      this.buttonColor: Colors.white,
      this.textColor: Colors.black,
      this.radius: 16,
      this.buttonHeight: 8,
      this.buttonIcon,
      this.onPressed})
      : assert(buttonText != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: RaisedButton(
        onPressed: onPressed,
        color: buttonColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: buttonHeight),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonIcon != null ? buttonIcon : Text(""),
              Text(
                buttonText,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Opacity(opacity: 0, child: buttonIcon),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
      ),
    );
  }
}
