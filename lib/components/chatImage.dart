
import 'package:flutter/material.dart';

import '../FullImageView.dart';
import 'errorContainer.dart';

Widget chatImage({required BuildContext context,required String imageSrc, required Function onTap}) {

  return OutlinedButton(
    style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(
            color: Colors.transparent,
            width: 1.0,
            style: BorderStyle.none))
    ),
    onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  FullImageView(url: imageSrc, ),
      ));
    },
    child: Image.network(
      imageSrc,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              value: loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}